import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

List<int> _hexToBytes(String hex) {
  final cleaned = hex.startsWith('0x') ? hex.substring(2) : hex;
  final result = <int>[];
  for (var i = 0; i < cleaned.length; i += 2) {
    result.add(int.parse(cleaned.substring(i, i + 2), radix: 16));
  }
  return result;
}

/// Signs transaction blocks (txBytes) using Ed25519 following the IOTA
/// signature format: base64(scheme_flag || signature || public_key).
class IotaSigner {
  IotaSigner({required String privateKeyHex, required String publicKeyHex})
    : _publicKeyBytes = _hexToBytes(publicKeyHex),
      _keyPair = SimpleKeyPairData(
        _hexToBytes(privateKeyHex),
        publicKey: SimplePublicKey(
          _hexToBytes(publicKeyHex),
          type: KeyPairType.ed25519,
        ),
        type: KeyPairType.ed25519,
      );

  final SimpleKeyPairData _keyPair;
  final List<int> _publicKeyBytes;

  /// Returns the base64-encoded serialized signature ready for executeTransactionBlock.
  Future<String> signTxBytes(String txBytesBase64) async {
    final txBytes = base64.decode(txBytesBase64);
    // IntentMessage for TransactionData = [0,0,0]
    final intent = Uint8List.fromList([0, 0, 0]);
    final message = Uint8List.fromList([...intent, ...txBytes]);

    final digest = await Blake2b(hashLengthInBytes: 32).hash(message);
    final signature = await Ed25519().sign(digest.bytes, keyPair: _keyPair);

    // scheme flag 0x00 for Ed25519
    final serialized = Uint8List.fromList([
      0,
      ...signature.bytes,
      ..._publicKeyBytes,
    ]);
    return base64.encode(serialized);
  }

  /// Computes the IOTA address from the public key.
  /// Derived from blake2b-256(publicKeyBytes) (IOTA Rebased seems to not prepend 0x00 flag for the address)
  Future<String> getIotaAddress() async {
    final message = Uint8List.fromList([..._publicKeyBytes]);
    final digest = await Blake2b(hashLengthInBytes: 32).hash(message);
    return '0x${digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  /// Signs raw data without hashing it with Blake2b and without intent flags.
  /// Used for generating the backend signature of the data_hash.
  Future<List<int>> signRawData(List<int> data) async {
    final signature = await Ed25519().sign(data, keyPair: _keyPair);
    return signature.bytes;
  }
}

/// Encodes a vector<u8> for Move as BCS: uleb128 length + bytes, base64 encoded.
String encodeVectorU8ToBase64(List<int> bytes) {
  final length = bytes.length;
  final lengthEncoded = <int>[];
  var value = length;
  while (true) {
    var byte = value & 0x7f;
    value >>= 7;
    if (value == 0) {
      lengthEncoded.add(byte);
      break;
    } else {
      lengthEncoded.add(byte | 0x80);
    }
  }
  final data = Uint8List.fromList([...lengthEncoded, ...bytes]);
  return base64.encode(data);
}

List<int> hexToBytes(String hex) => _hexToBytes(hex);
