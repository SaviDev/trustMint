import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constants and placeholders for the IOTA JSON-RPC integration.
/// Replace the placeholder object IDs with your real on-chain objects when available.
class IotaChainConstants {
  static const String rpcUrl = 'https://api.testnet.iota.cafe';

  // Package / module information for the deployed Move contract.
  static const String packageId =
      '0x8a96acb05ed372f277780cff13a894a96e79c4f1f0a3980a2f1b78d65698bab4';
  static const String campaignModule = 'campaign';
  static const String joinCampaignFunction = 'join_campaign';
  static const String updateDataHashFunction = 'update_data_hash';
  static const String submitAndPayoutFunction = 'submit_and_payout';
  // Coin type used when creating the Campaign (must match on-chain object). Update to the real coin type.
  static const String coinType =
      '0x2::iota::IOTA'; // TODO: set to the coin used to fund the campaign

  // On-chain objects (placeholders — update with real IDs from your deployment).
  // Shared campaign object: created via create_campaign; required by join_campaign.
  static const String defaultCampaignObjectId =
      '0xc6e418808bca55c49358d62b3ec4a1bab642fd7a03ea973e576a62b885e23876'; // e.g. 0x...
  // DID object representing the worker; must exist on-chain.
  static const String defaultUserDidObjectId =
      '0x8c7db8a22513450383c9049b5ed4e79e0dc58f0cd5a7237be44f3746f7726254';
  // Config object representing MarketplaceConfig
  static const String defaultMarketplaceConfigObjectId =
      '0x15bb534db1e4d1089cd2ad8c6a1fd43289260bbe8904ea4dd11b77d0f32828fb';

  // DID object representing the backend/admin; must exist on-chain to create campaigns.
  static const String backendDidObjectId =
      '0x57f5797078f5c938f7bda522ff82b8242ae3ab5367037c3c1d5a838c869b50b8';

  // Backend keys (Simulating the Verifier Backend's signature)
  // These correspond to the IOTA address: 0xb283046ce7d9c032ace4edf784dfac8d139c6709e5538b7f5ae6c6ef6dd48115
  static String get backendPrivateKeyHex =>
      dotenv.env['BACKEND_PRIVATE_KEY_HEX'] ??
      ''; // The Ed25519 32-byte seed from the Bech32 string
  static String get backendPublicKeyHex =>
      dotenv.env['BACKEND_PUBLIC_KEY_HEX'] ?? ''; // Derivated Pubkey from seed

  // TaskTicket object will be created by join_campaign and cached per-bando; fallback placeholder only.
  static const String placeholderTicketObjectId =
      '<TODO: TaskTicket object id after join_campaign>';
  static const String clockObjectId = '0x6';

  // Gas budget (in mist) used for unsafe_moveCall; adjust based on network fees and txn complexity.
  static const int defaultGasBudget =
      20000000; // 20 million ≈ safe default for simple calls

  // Hardcoded Ed25519 keypair for signing transactions.
  // Extracted from iotaprivkey1qzhzk0mufdlnvd8n09vhnq9dyw2snfttx4kdwpmsp54zk8g4yvv370e0p0n
  static String get hardcodedPrivateKeyHex =>
      dotenv.env['HARDCODED_PRIVATE_KEY_HEX'] ?? '';
  static String get hardcodedPublicKeyHex =>
      dotenv.env['HARDCODED_PUBLIC_KEY_HEX'] ?? '';
  static String get hardcodedAddress => dotenv.env['HARDCODED_ADDRESS'] ?? '';
}
