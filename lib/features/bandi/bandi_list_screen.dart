import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'bandi_controller.dart';

class BandiListScreen extends ConsumerWidget {
  const BandiListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bandiProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1D2E),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bounty Program'),
              Consumer(
                builder: (context, ref, child) {
                  final addressAsync = ref.watch(walletAddressProvider);
                  return addressAsync.when(
                    data: (address) => Text(
                      'Wallet: ${address.substring(0, 6)}...${address.substring(address.length - 4)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    loading: () => const Text(
                      'Loading wallet...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    error: (_, __) => const Text(
                      'Error loading wallet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFF6C63FF),
            labelColor: Color(0xFF6C63FF),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Explore'),
              Tab(text: 'My Bounties'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _EsploraList(state: state),
            _MyBandiList(state: state),
          ],
        ),
      ),
    );
  }
}

class _EsploraList extends ConsumerWidget {
  final BandiState state;
  const _EsploraList({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.available.isEmpty) {
      return const Center(
        child: Text(
          'No new bounty available.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.available.length,
      itemBuilder: (context, index) {
        final bando = state.available[index];
        final isParticipated = state.myBandi.any((b) => b.id == bando.id);
        final isJoining = state.joiningBandoId == bando.id;
        final isDummy = bando.id == 'dummy_1';

        return Column(
          children: [
            Card(
              color: const Color(0xFF1A1D2E),
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bando.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bando.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration: ${bando.durationDays} days',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Reward: ${bando.payout} IOTA',
                          style: const TextStyle(
                            color: Color(0xFF2ECC71),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: (isParticipated || isJoining || isDummy)
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final notifier = ref.read(bandiProvider.notifier);
                              final success = await notifier.participate(bando);

                              if (messenger.mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Successfully joined ${bando.title}!'
                                          : 'Failed to join ${bando.title}.',
                                    ),
                                    backgroundColor: success
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (isParticipated || isJoining || isDummy)
                            ? Colors.grey[800]
                            : const Color(0xFF6C63FF),
                        foregroundColor:
                            (isParticipated || isJoining || isDummy)
                            ? Colors.grey[400]
                            : Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isJoining
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              isParticipated
                                  ? 'Joined'
                                  : (isDummy ? 'Not Available' : 'Join'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            // Hidden button per la creazione della vera campagna, visibile solo se c'è solo questo bando dummy in lista
            if (isDummy && state.available.length == 1)
              Align(
                alignment: Alignment.centerRight,
                child: Opacity(
                  opacity: 0.3, // Molto trasparente, "nascosto"
                  child: IconButton(
                    icon: state.isCreatingCampaign
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                          ),
                    onPressed: state.isCreatingCampaign
                        ? null
                        : () async {
                            ref.read(bandiProvider.notifier).createRealBando();
                          },
                    tooltip: 'Create MVP Campaign On-Chain',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MyBandiList extends ConsumerWidget {
  final BandiState state;
  const _MyBandiList({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.myBandi.isEmpty) {
      return const Center(
        child: Text(
          'You are not participating in any bounty.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.myBandi.length,
      itemBuilder: (context, index) {
        final bando = state.myBandi[index];
        return _AnimatedBandoItem(bando: bando, ref: ref);
      },
    );
  }
}

class _AnimatedBandoItem extends StatefulWidget {
  final bando;
  final WidgetRef ref;
  const _AnimatedBandoItem({required this.bando, required this.ref});

  @override
  State<_AnimatedBandoItem> createState() => _AnimatedBandoItemState();
}

class _AnimatedBandoItemState extends State<_AnimatedBandoItem>
    with TickerProviderStateMixin {
  bool isCompleted = false;
  int? realPayoutMists;
  late AnimationController _animController;
  late Animation<Color?> _borderColorAnim;
  late Animation<Color?> _bgColorAnim;

  late AnimationController _exitController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _sizeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _borderColorAnim = ColorTween(
      begin: const Color(0xFF6C63FF),
      end: Colors.green,
    ).animate(_animController);

    _bgColorAnim = ColorTween(begin: const Color(0xFF1A1D2E), end: Colors.green)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.5, 1.0),
          ),
        );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Slide happens in the first 70% of the animation
    _slideAnim =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1.5, 0.0), // Swipe to the left
        ).animate(
          CurvedAnimation(
            parent: _exitController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
          ),
        );

    // Shrinking happens in the last 30% of the animation, preventing the diagonal effect
    _sizeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  void _completeBounty(int? payoutAmount) async {
    setState(() {
      isCompleted = true;
      realPayoutMists = payoutAmount;
    });
    await _animController.forward();
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Wait slightly on the green success state
    await _exitController.forward(); // Start the swipe exit animation

    if (mounted) {
      widget.ref.read(bandiProvider.notifier).removeBando(widget.bando.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _sizeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final iotaAmountStr = realPayoutMists != null
                ? (realPayoutMists! / 1000000000).toStringAsFixed(2)
                : widget.bando.payout.toString();

            return Card(
              color: _bgColorAnim.value,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _borderColorAnim.value ?? const Color(0xFF6C63FF),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          '+$iotaAmountStr IOTA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        widget.bando.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Tap to enter Data Collector and start collecting.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF6C63FF),
                      ),
                      onTap: () async {
                        final result = await context.push<Map<String, dynamic>>(
                          '/collector/${widget.bando.id}',
                        );
                        if (result != null && result['completed'] == true) {
                          _completeBounty(result['payoutAmount'] as int?);
                        }
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
