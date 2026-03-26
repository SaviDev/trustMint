import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bando.dart';
import '../../data/chain/iota_chain_service.dart';
import '../../data/chain/iota_constants.dart';
import '../../data/chain/iota_signer.dart';
import '../../data/local/secure_storage.dart';

class BandiState {
  final List<Bando> available;
  final List<Bando> myBandi;
  final String? joiningBandoId;
  final bool isCreatingCampaign;

  BandiState({
    required this.available,
    required this.myBandi,
    this.joiningBandoId,
    this.isCreatingCampaign = false,
  });

  BandiState copyWith({
    List<Bando>? available,
    List<Bando>? myBandi,
    String? joiningBandoId,
    bool clearJoiningId = false,
    bool? isCreatingCampaign,
  }) {
    return BandiState(
      available: available ?? this.available,
      myBandi: myBandi ?? this.myBandi,
      joiningBandoId: clearJoiningId
          ? null
          : (joiningBandoId ?? this.joiningBandoId),
      isCreatingCampaign: isCreatingCampaign ?? this.isCreatingCampaign,
    );
  }
}

class BandiController extends StateNotifier<BandiState> {
  BandiController(this._chain, this._storage)
    : super(
        BandiState(
          available: [
            Bando(
              id: 'dummy_1',
              title: 'Placeholder Bounty',
              description:
                  'This is a sample bounty used for display. Create a real one using the hidden button!',
              durationDays: 30,
              payout: 0.0,
              requiredSensors: [],
            ),
          ],
          myBandi: [],
          joiningBandoId: null,
        ),
      );

  final IotaChainService _chain;
  final SecureStorage _storage;

  Future<bool> participate(Bando bando) async {
    if (bando.id == 'dummy_1') return false; // Non interagibile

    if (state.myBandi.any((b) => b.id == bando.id)) return false;

    state = state.copyWith(joiningBandoId: bando.id);
    bool success = false;
    try {
      final ticketId = await _chain.joinCampaign(
        bandoId: bando.id,
        campaignObjectId: bando.campaignObjectId,
      );
      if (ticketId != null) {
        final newMyBandi = [...state.myBandi, bando];
        state = state.copyWith(myBandi: newMyBandi);
        await _storage.write('active_${bando.id}', 'true');
        await _storage.write('any_bando_active', 'true');
        await _storage.write('current_bando_id', bando.id);
        success = true;
      }
    } catch (e) {
      print('[BandiController] participate failed with exception: $e');
      success = false;
    } finally {
      state = state.copyWith(clearJoiningId: true);
    }
    return success;
  }

  void removeBando(String id) {
    final updatedList = state.myBandi.where((b) => b.id != id).toList();
    final updatedAvailable = state.available.where((b) => b.id != id).toList();
    state = state.copyWith(myBandi: updatedList, available: updatedAvailable);
  }

  Future<void> createRealBando() async {
    if (state.isCreatingCampaign) return;

    state = state.copyWith(isCreatingCampaign: true);
    try {
      final random = Random();
      // Genera un payout casuale tra 0.01 e 0.1 IOTA (arrotondato a 2 decimali)
      final payoutIota = (1 + random.nextInt(10)) / 100.0;
      final rewardMists = (payoutIota * 1000000000).toInt();

      // Genera una durata casuale tra 1 e 14 giorni
      final durationDays = 1 + random.nextInt(14);
      final deadlineMs = DateTime.now()
          .add(Duration(days: durationDays))
          .millisecondsSinceEpoch;

      final campaignId = await _chain.createCampaign(
        rewardPerUser: rewardMists,
        maxParticipants: 1,
        deadlineMs: deadlineMs,
      );
      if (campaignId != null) {
        final newBando = Bando(
          id: campaignId.substring(
            0,
            10,
          ), // Usiamo parte dell'ID come bandoId locale
          title: 'IOTA On-Chain Bounty',
          description:
              'A newly created real bounty directly from IOTA Testnet Rebased.',
          durationDays: durationDays,
          payout: payoutIota, // Reward mostrato in IOTA
          campaignObjectId: campaignId,
          requiredSensors: [],
        );
        state = state.copyWith(available: [...state.available, newBando]);
      }
    } catch (e) {
      print('[BandiController] Error creating campaign: $e');
    } finally {
      state = state.copyWith(isCreatingCampaign: false);
    }
  }
}

final iotaChainProvider = Provider<IotaChainService>(
  (ref) => IotaChainService(),
);

final bandiProvider = StateNotifierProvider<BandiController, BandiState>((ref) {
  return BandiController(ref.read(iotaChainProvider), SecureStorage());
});

final walletAddressProvider = FutureProvider<String>((ref) async {
  final signer = IotaSigner(
    privateKeyHex: IotaChainConstants.hardcodedPrivateKeyHex,
    publicKeyHex: IotaChainConstants.hardcodedPublicKeyHex,
  );
  return await signer.getIotaAddress();
});
