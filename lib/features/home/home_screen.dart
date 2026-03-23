import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String bandoId;
  const HomeScreen({super.key, required this.bandoId});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPermissions());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check permissions when user returns from system settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final controller = ref.read(homeProvider(widget.bandoId).notifier);

    // IMU sensors (accelerometer, gyroscope, magnetometer) require NO runtime
    // permission on Android — they are always available.
    controller.updatePermission('Sensors (Accel/Gyro/Mag)', true);

    // These DO require runtime permission requests:
    final notification = await Permission.notification.status;
    final battery = await Permission.ignoreBatteryOptimizations.status;
    final activity = await Permission.activityRecognition.status;

    controller.updatePermission('Notifications', notification.isGranted);
    controller.updatePermission('Battery Optimization', battery.isGranted);
    controller.updatePermission('Physical Activity', activity.isGranted);
  }

  Future<void> _requestPermission(String name) async {
    final controller = ref.read(homeProvider(widget.bandoId).notifier);

    switch (name) {
      case 'Notifications':
        final r = await Permission.notification.request();
        controller.updatePermission(name, r.isGranted);
        break;

      case 'Battery Optimization':
        // This opens the system settings page — permission_handler handles it.
        await Permission.ignoreBatteryOptimizations.request();
        // Status is re-checked when the app resumes via didChangeAppLifecycleState
        break;

      case 'Physical Activity':
        final r = await Permission.activityRecognition.request();
        controller.updatePermission(name, r.isGranted);
        break;

      default:
        break;
    }
  }

  Future<void> _onUpload(BuildContext context) async {
    final controller = ref.read(homeProvider(widget.bandoId).notifier);
    await controller.uploadRandomRecords();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 100 record inviati con successo!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF2ECC71),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider(widget.bandoId));
    final allGranted = state.permissions.values.every((v) => v);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D2E),
        title: Text('Collector - ${widget.bandoId}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          state.isUploading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  tooltip: 'Send 100 random records',
                  icon: const Icon(Icons.upload_rounded, color: Colors.white),
                  onPressed: () => _onUpload(context),
                ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- User ID chip ----------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.fingerprint,
                  color: Color(0xFF6C63FF),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ID: ${state.userId.isEmpty ? "…" : state.userId}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---------- Data Summary card ----------
          _SectionCard(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF6C63FF),
            title: 'Data Summary',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (state.totalRecordsSent % 1000) / 1000,
                    minHeight: 10,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.totalRecordsSent} total records',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Last sync: ${state.lastSync}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDataSummary(context),
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: const Text('Data Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C63FF),
                      side: const BorderSide(color: Color(0xFF6C63FF)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---------- Permissions card ----------
          _SectionCard(
            icon: Icons.lock_rounded,
            iconColor: allGranted
                ? const Color(0xFF2ECC71)
                : const Color(0xFFE67E22),
            title: 'Required Permissions',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enable the necessary sensors to participate in this bounty.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                ...state.permissions.entries.map((entry) {
                  final granted = entry.value;
                  // Sensor permission is auto-granted — don't show Concedi button
                  final isAutoGranted = entry.key == 'Sensors (Accel/Gyro/Mag)';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          granted
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          color: granted
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFE67E22),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!granted && !isAutoGranted)
                          TextButton(
                            onPressed: () => _requestPermission(entry.key),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6C63FF),
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(60, 28),
                            ),
                            child: Text(
                              entry.key == 'Battery Optimization'
                                  ? 'Settings'
                                  : 'Grant',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (widget.bandoId == 'b2')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/ema/${widget.bandoId}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.edit_document),
                label: const Text('Take Survey Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          if (widget.bandoId == 'b2')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement generate mock data logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Generate Mock Data', style: TextStyle(color: Colors.white)),
              ),
            ),
          const SizedBox(height: 24),

          // ---------- Collection status chip ----------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: allGranted
                  ? const Color(0xFF2ECC71).withOpacity(0.12)
                  : const Color(0xFFE67E22).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: allGranted
                    ? const Color(0xFF2ECC71).withOpacity(0.4)
                    : const Color(0xFFE67E22).withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  allGranted
                      ? Icons.sensors_rounded
                      : Icons.sensors_off_rounded,
                  color: allGranted
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFFE67E22),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    allGranted
                        ? 'Collection active ✓'
                        : 'Grant all permissions to start collection',
                    style: TextStyle(
                      color: allGranted
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE67E22),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ---------- Manual upload button ----------
          ElevatedButton.icon(
            onPressed: state.isUploading ? null : () => _onUpload(context),
            icon: state.isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.upload_rounded),
            label: Text(
              state.isUploading
                  ? 'Uploading…'
                  : 'Send 100 Test Records',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: allGranted
          ? Padding(
              padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 16, right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'action_btn',
                    onPressed: () {
                      if (state.isCollecting) {
                        ref.read(homeProvider(widget.bandoId).notifier).pauseCollection();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data collection paused ⏸️')),
                        );
                      } else {
                        ref.read(homeProvider(widget.bandoId).notifier).resumeCollection();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data collection resumed ▶️')),
                        );
                      }
                    },
                    backgroundColor: state.isCollecting ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71),
                    icon: Icon(state.isCollecting ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    label: Text(
                      state.isCollecting
                          ? 'Pause'
                          : (state.totalRecordsSent == 0 && (state.lastSync == 'Mai' || state.lastSync == 'Never') ? 'Start' : 'Resume'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  void _showDataSummary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DataSummarySheet(bandoId: widget.bandoId),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Colors.white12),
          child,
        ],
      ),
    );
  }
}

class _DataSummarySheet extends ConsumerWidget {
  final String bandoId;
  const _DataSummarySheet({required this.bandoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(homeProvider(bandoId).notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const CloseButton(color: Colors.white),
            title: const Text(
              'Data Summary',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: FutureBuilder<Map<String, int>>(
            future: controller.getSensorCounts(),
            builder: (context, countsSnapshot) {
              if (countsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                );
              }
              if (countsSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${countsSnapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final counts = countsSnapshot.data ?? {};
              if (counts.isEmpty) {
                return const Center(
                  child: Text(
                    'No data collected yet.',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: counts.length,
                itemBuilder: (context, index) {
                  final String type = counts.keys.elementAt(index);
                  final int count = counts[type]!;

                  return Card(
                    color: const Color(0xFF0F1117),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                type.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4A44B0,
                                  ).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$count records',
                                  style: const TextStyle(
                                    color: Color(0xFF8C86FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Last 10 records:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<dynamic>>(
                            future: controller.getLastRecords(type, limit: 10),
                            builder: (context, recordsSnapshot) {
                              if (recordsSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 40,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF6C63FF),
                                    ),
                                  ),
                                );
                              }
                              final records = recordsSnapshot.data ?? [];
                              if (records.isEmpty) {
                                return const Text(
                                  'No recent records.',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                );
                              }

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: records.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        color: Colors.white12,
                                        height: 1,
                                      ),
                                  itemBuilder: (context, idx) {
                                    final record = records[idx];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        record
                                            .value, // value contains the JSON {"x": ...} payload
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
