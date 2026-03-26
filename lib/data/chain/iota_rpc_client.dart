import 'package:dio/dio.dart';
import 'iota_constants.dart';

class IotaMoveCallResult {
  final String txBytes;
  final String? txDigest;
  final Map<String, dynamic> raw;

  IotaMoveCallResult({required this.txBytes, required this.raw, this.txDigest});
}

class IotaExecutionResult {
  final String? digest;
  final Map<String, dynamic> raw;

  IotaExecutionResult({required this.raw, this.digest});
}

class IotaRpcClient {
  IotaRpcClient({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: IotaChainConstants.rpcUrl));

  final Dio _dio;
  int _counter = 0;

  Future<Map<String, dynamic>> _call(
    String method,
    List<dynamic> params,
  ) async {
    final response = await _dio.post(
      '',
      data: {
        'jsonrpc': '2.0',
        'id': ++_counter,
        'method': method,
        'params': params,
      },
    );

    if (response.data is! Map) {
      throw Exception('Invalid RPC response shape for $method');
    }
    final map = Map<String, dynamic>.from(response.data as Map);
    if (map['error'] != null) {
      throw Exception('RPC $method error: ${map['error']}');
    }
    if (!map.containsKey('result')) {
      throw Exception('RPC $method missing result');
    }
    return Map<String, dynamic>.from(map['result'] as Map);
  }

  Future<IotaMoveCallResult> unsafeMoveCall({
    required String signerAddress,
    required String packageId,
    required String module,
    required String function,
    required List<String> typeArguments,
    required List<dynamic> arguments,
    int gasBudget = IotaChainConstants.defaultGasBudget,
    String? gasPayment,
  }) async {
    // IOTA Rebased follows standard method naming: unsafe_moveCall
    final result = await _call('unsafe_moveCall', [
      signerAddress,
      packageId,
      module,
      function,
      typeArguments,
      arguments,
      gasPayment,
      gasBudget.toString(), // Must be a string for JSON-RPC
    ]);

    return IotaMoveCallResult(
      txBytes: result['txBytes'] as String,
      txDigest: result['txDigest'] as String?,
      raw: result,
    );
  }

  Future<List<Map<String, dynamic>>> getCoins(String ownerAddress) async {
    final result = await _call('iotax_getCoins', [ownerAddress]);
    final data = result['data'];
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<Map<String, dynamic>?> getObject(String objectId) async {
    try {
      final result = await _call('iota_getObject', [
        objectId,
        {'showContent': true},
      ]);
      return result['data'] as Map<String, dynamic>?;
    } catch (e) {
      print('[IOTA RPC] getObject Error: $e');
      return null;
    }
  }

  Future<IotaExecutionResult> executeTransactionBlock({
    required String txBytes,
    required String signature,
  }) async {
    final result = await _call('iota_executeTransactionBlock', [
      txBytes,
      [signature],
      {
        'showEffects': true,
        'showObjectChanges': true,
        'showEvents': true,
        'showBalanceChanges': true,
      },
      'WaitForLocalExecution',
    ]);

    return IotaExecutionResult(
      raw: result,
      digest: result['digest'] as String?,
    );
  }
}
