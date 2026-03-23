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
          title: const Text('Bounty Program'),
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
        child: Text('No new bounty available.', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.available.length,
      itemBuilder: (context, index) {
        final bando = state.available[index];
        final isParticipated = state.myBandi.any((b) => b.id == bando.id);
        return Card(
          color: const Color(0xFF1A1D2E),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bando.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(bando.description, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Duration: ${bando.durationDays} days', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('Reward: \$${bando.payout}', style: const TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isParticipated ? null : () {
                    ref.read(bandiProvider.notifier).participate(bando);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Joined ${bando.title} successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isParticipated ? Colors.grey[800] : const Color(0xFF6C63FF),
                    foregroundColor: isParticipated ? Colors.grey[400] : Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isParticipated ? 'Joined' : 'Join'),
                ),
              ],
            ),
          ),
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
        child: Text('You are not participating in any bounty.', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.myBandi.length,
      itemBuilder: (context, index) {
        final bando = state.myBandi[index];
        return Card(
          color: const Color(0xFF1A1D2E),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF6C63FF), width: 1)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(bando.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('Tap to enter Data Collector and start collecting.', style: TextStyle(color: Colors.white70)),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF6C63FF)),
            onTap: () {
              context.push('/collector/${bando.id}');
            },
          ),
        );
      },
    );
  }
}
