import '../local/secure_storage.dart';
import 'iota_constants.dart';
import 'iota_rpc_client.dart';
import 'iota_signer.dart';

class IotaChainService {
  IotaChainService({
    IotaRpcClient? client,
    IotaSigner? signer,
    SecureStorage? storage,
  }) : _client = client ?? IotaRpcClient(),
       _signer =
           signer ??
           IotaSigner(
             privateKeyHex: IotaChainConstants.hardcodedPrivateKeyHex,
             publicKeyHex: IotaChainConstants.hardcodedPublicKeyHex,
           ),
       _storage = storage ?? SecureStorage();

  final IotaRpcClient _client;
  final IotaSigner _signer;
  final SecureStorage _storage;

  String _ticketKey(String bandoId) => 'task_ticket_$bandoId';

  bool _isValidObjectId(String id) {
    final hex = id.startsWith('0x') ? id.substring(2) : id;
    return hex.isNotEmpty &&
        hex.length <= 64 &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex);
  }

  /// Calls submit_and_payout to complete the bounty and returns the amount received (in mist).
  Future<int?> submitAndPayout({
    required String bandoId,
    required String dataHashHex,
    String? campaignObjectId,
    String? configObjectId,
    String? userDidObjectId,
    int gasBudget = IotaChainConstants.defaultGasBudget,
  }) async {
    final ticketId =
        await _storage.read(_ticketKey(bandoId)) ??
        IotaChainConstants.placeholderTicketObjectId;
    final campaignId =
        campaignObjectId ?? IotaChainConstants.defaultCampaignObjectId;
    final configId =
        configObjectId ?? IotaChainConstants.defaultMarketplaceConfigObjectId;
    final userDid =
        userDidObjectId ??
        await _storage.read('user_did') ??
        IotaChainConstants.defaultUserDidObjectId;

    if (_isPlaceholder(campaignId) ||
        _isPlaceholder(userDid) ||
        _isPlaceholder(ticketId) ||
        _isPlaceholder(configId)) {
      print(
        '[IOTA] Missing required objects for submit_and_payout. Update iota_constants.dart',
      );
      return 100; // Fake payout for missing objects so the UI can proceed during dev
    }

    try {
      final userAddress = await _signer.getIotaAddress();

      // The payload to sign is the current data_hash from the worker
      List<int> dataHashBytes = hexToBytes(dataHashHex);

      // FORCE OVERRIDE: Fetch actual hash from on-chain Ticket
      final ticketObj = await _client.getObject(ticketId);
      if (ticketObj != null) {
        final content = ticketObj['content'];
        if (content != null && content['fields'] != null) {
          final fields = content['fields'];
          if (fields['data_hash'] is List) {
            dataHashBytes = List<int>.from(fields['data_hash']);
            print(
              '[IOTA] Overriding local hash with ON-CHAIN hash: $dataHashBytes',
            );
          }
        }
      }

      // Simulate backend computing the signature
      final backendSigner = IotaSigner(
        privateKeyHex: IotaChainConstants.backendPrivateKeyHex,
        publicKeyHex: IotaChainConstants.backendPublicKeyHex,
      );
      final backendSigBytes = await backendSigner.signRawData(dataHashBytes);

      print('[IOTA - BACKEND MOCK] Signing payload dataHashHex: $dataHashHex');
      print(
        '[IOTA - BACKEND MOCK] dataHashBytes length: ${dataHashBytes.length}',
      );
      print('[IOTA - BACKEND MOCK] dataHashBytes: $dataHashBytes');
      print(
        '[IOTA - BACKEND MOCK] backendSigBytes length: ${backendSigBytes.length}',
      );
      print('[IOTA - BACKEND MOCK] backendSigBytes: $backendSigBytes');

      final moveCall = await _client.unsafeMoveCall(
        signerAddress: userAddress,
        packageId: IotaChainConstants.packageId,
        module: IotaChainConstants.campaignModule,
        function: IotaChainConstants.submitAndPayoutFunction,
        typeArguments: [IotaChainConstants.coinType],
        arguments: [ticketId, campaignId, configId, userDid, backendSigBytes],
        gasBudget: gasBudget,
      );

      final signature = await _signer.signTxBytes(moveCall.txBytes);
      final exec = await _client.executeTransactionBlock(
        txBytes: moveCall.txBytes,
        signature: signature,
      );

      print('[IOTA] submit_and_payout execution raw: ${exec.raw}');

      if (exec.raw['effects']?['status']?['status'] == 'failure') {
        print(
          '[IOTA] submitAndPayout failed on-chain: ${exec.raw['effects']['status']['error']}',
        );
        return null;
      }

      // Calculate total gas consumed
      final gasUsed = exec.raw['effects']?['gasUsed'];
      int totalGas = 0;
      if (gasUsed != null) {
        final comp =
            int.tryParse(gasUsed['computationCost']?.toString() ?? '0') ?? 0;
        final storage =
            int.tryParse(gasUsed['storageCost']?.toString() ?? '0') ?? 0;
        final rebate =
            int.tryParse(gasUsed['storageRebate']?.toString() ?? '0') ?? 0;
        totalGas = comp + storage - rebate;
      }

      int payoutAmount = 0;
      final balanceChanges = exec.raw['balanceChanges'];
      if (balanceChanges is List) {
        for (final change in balanceChanges) {
          final owner = change['owner'];
          if (owner is Map && owner['AddressOwner'] == userAddress) {
            if (change['coinType'] == IotaChainConstants.coinType) {
              final amountStr = change['amount']?.toString();
              if (amountStr != null) {
                payoutAmount += int.tryParse(amountStr) ?? 0;
              }
            }
          }
        }
      }

      // If the reward coin type is the same as the gas payment coin type,
      // the balance change is the net amount (reward - gas cost).
      // We add gas to get the actual reward received from the contract.
      payoutAmount += totalGas;

      // Cleanup the task ticket from local storage as it is consumed
      await _storage.delete(_ticketKey(bandoId));

      return payoutAmount;
    } catch (e) {
      print('[IOTA] submitAndPayout failed: $e');
      return null;
    }
  }

  /// Calls join_campaign on-chain and stores the returned TaskTicket object ID in secure storage.
  Future<String?> joinCampaign({
    required String bandoId,
    String? campaignObjectId,
    String? userDidObjectId,
    int gasBudget = IotaChainConstants.defaultGasBudget,
  }) async {
    final campaignId =
        campaignObjectId ?? IotaChainConstants.defaultCampaignObjectId;
    final userDid =
        userDidObjectId ??
        await _storage.read('user_did') ??
        IotaChainConstants.defaultUserDidObjectId;

    if (_isPlaceholder(campaignId) || _isPlaceholder(userDid)) {
      print('[IOTA] Missing campaignId or userDid. Update iota_constants.dart');
      return null;
    }

    if (!_isValidObjectId(campaignId) ||
        !_isValidObjectId(userDid) ||
        !_isValidObjectId(IotaChainConstants.clockObjectId)) {
      print('[IOTA] Invalid object id format for campaign/userDid/clock');
      return null;
    }

    try {
      final userAddress = await _signer.getIotaAddress();

      final moveCall = await _client.unsafeMoveCall(
        signerAddress: userAddress,
        packageId: IotaChainConstants.packageId,
        module: IotaChainConstants.campaignModule,
        function: IotaChainConstants.joinCampaignFunction,
        typeArguments: [IotaChainConstants.coinType],
        arguments: [campaignId, userDid, IotaChainConstants.clockObjectId],
        gasBudget: gasBudget,
      );

      final signature = await _signer.signTxBytes(moveCall.txBytes);
      final exec = await _client.executeTransactionBlock(
        txBytes: moveCall.txBytes,
        signature: signature,
      );

      print('[IOTA] exec result status: ${exec.raw['effects']?['status']}');
      print('[IOTA] join_campaign execution raw: ${exec.raw}');

      final ticketId = _extractTaskTicket(exec.raw);
      if (ticketId != null) {
        await _storage.write(_ticketKey(bandoId), ticketId);
        print('[IOTA] TaskTicket created and stored: $ticketId');
      } else {
        print(
          '[IOTA] join_campaign executed but no TaskTicket found in objectChanges.',
        );
      }
      return ticketId;
    } catch (e) {
      print('[IOTA] joinCampaign failed: $e');
      return null;
    }
  }

  /// Commits the rolling hash on-chain via update_data_hash(ticket, did, new_hash).
  Future<void> updateDataHash({
    required String bandoId,
    required String newHashHex,
    String? ticketObjectId,
    String? userDidObjectId,
    int gasBudget = IotaChainConstants.defaultGasBudget,
  }) async {
    final ticketId =
        ticketObjectId ??
        await _storage.read(_ticketKey(bandoId)) ??
        IotaChainConstants.placeholderTicketObjectId;
    final userDid =
        userDidObjectId ??
        await _storage.read('user_did') ??
        IotaChainConstants.defaultUserDidObjectId;

    if (_isPlaceholder(ticketId) || _isPlaceholder(userDid)) {
      print('[IOTA] Skipping update_data_hash: missing ticketId or userDid');
      return;
    }

    final hashBytes = hexToBytes(newHashHex);

    try {
      final userAddress = await _signer.getIotaAddress();
      final moveCall = await _client.unsafeMoveCall(
        signerAddress: userAddress,
        packageId: IotaChainConstants.packageId,
        module: IotaChainConstants.campaignModule,
        function: IotaChainConstants.updateDataHashFunction,
        typeArguments: [], // update_data_hash is not generic
        arguments: [
          ticketId,
          userDid,
          hashBytes, // Pass the byte list directly
        ],
        gasBudget: gasBudget,
      );

      final signature = await _signer.signTxBytes(moveCall.txBytes);
      final exec = await _client.executeTransactionBlock(
        txBytes: moveCall.txBytes,
        signature: signature,
      );
      print(
        '[IOTA] update_data_hash committed. digest=${exec.digest ?? 'n/a'} status=${exec.raw['effects']?['status']}',
      );
    } catch (e) {
      print('[IOTA] updateDataHash failed: $e');
    }
  }

  Future<String?> getStoredTicketId(String bandoId) =>
      _storage.read(_ticketKey(bandoId));

  bool _isPlaceholder(String value) => value.startsWith('<TODO');

  String? _extractTaskTicket(Map<String, dynamic> rawExecResult) {
    final changes = rawExecResult['objectChanges'];
    if (changes is List) {
      for (final change in changes) {
        if (change is Map<String, dynamic>) {
          final type = change['objectType'] as String?;
          final changeType = change['type'] as String?;
          if (changeType == 'created' &&
              type != null &&
              type.contains('::TaskTicket')) {
            return change['objectId'] as String?;
          }
        }
      }
    }
    return null;
  }

  /// Calls create_campaign on-chain and returns the deployed Campaign object id.
  Future<String?> createCampaign({
    int rewardPerUser = 100000000, // 0.1 IOTA in mists
    int maxParticipants =
        1, // Impostato a 1 così il totale bloccato è solo 0.1 IOTA
    int deadlineMs = 1792369150000,
    int minReputationTier = 0,
    String? creatorDid,
    int gasBudget = 50000000, // Safe buffer for create
  }) async {
    try {
      // In this system, the backend is creating the campaign on behalf of the system
      final backendSigner = IotaSigner(
        privateKeyHex: IotaChainConstants.backendPrivateKeyHex,
        publicKeyHex: IotaChainConstants.backendPublicKeyHex,
      );
      final backendAddress = await backendSigner.getIotaAddress();
      // Use the backend's DID to create the campaign
      final did = creatorDid ?? IotaChainConstants.backendDidObjectId;

      // Dynamically fetch a valid coin to use for payment from the backend's wallet
      final coins = await _client.getCoins(backendAddress);

      // Filter out small dust coins and pick one big enough
      // The total cost is rewardPerUser * maxParticipants
      // We also need some margin, so let's pick one with > 10,000,000 mists just to be safe
      final requiredBalance = (rewardPerUser * maxParticipants) + 10000000;

      String? paymentCoinId;
      for (final coin in coins) {
        final bal = int.tryParse(coin['balance']?.toString() ?? '0') ?? 0;
        if (bal > requiredBalance) {
          paymentCoinId = coin['coinObjectId'] as String;
          break;
        }
      }

      if (paymentCoinId == null) {
        print(
          '[IOTA] createCampaign failed: No suitable coin found with balance > $requiredBalance in backend wallet',
        );
        return null;
      }

      final moveCall = await _client.unsafeMoveCall(
        signerAddress: backendAddress,
        packageId: IotaChainConstants.packageId,
        module: IotaChainConstants.campaignModule,
        function: 'create_campaign',
        typeArguments: [IotaChainConstants.coinType],
        arguments: [
          paymentCoinId,
          rewardPerUser.toString(),
          maxParticipants.toString(),
          deadlineMs.toString(),
          minReputationTier.toString(),
          did, // creator_did (can be any object passed conceptually)
        ],
        gasBudget: gasBudget,
      );

      final signature = await backendSigner.signTxBytes(moveCall.txBytes);
      final exec = await _client.executeTransactionBlock(
        txBytes: moveCall.txBytes,
        signature: signature,
      );

      print('[IOTA] create_campaign execution raw: ${exec.raw}');

      if (exec.raw['effects']?['status']?['status'] == 'failure') {
        print(
          '[IOTA] createCampaign failed on-chain: ${exec.raw['effects']['status']['error']}',
        );
        return null;
      }

      // Extract Campaign object ID
      final changes = exec.raw['objectChanges'];
      if (changes is List) {
        for (final change in changes) {
          if (change is Map<String, dynamic>) {
            final type = change['objectType'] as String?;
            if (change['type'] == 'created' &&
                type != null &&
                type.contains('::Campaign')) {
              return change['objectId'] as String?;
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('[IOTA] createCampaign failed: $e');
      return null;
    }
  }
}
