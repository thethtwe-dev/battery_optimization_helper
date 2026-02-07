import 'package:flutter/material.dart';
import 'package:battery_optimization_helper/battery_optimization_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExampleHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  bool? _isOptimized;
  String _log = '';

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final v = await BatteryOptimizationHelper.isBatteryOptimizationEnabled();
    setState(() => _isOptimized = v);
  }

  Future<void> _showRationaleThenEnsure() async {
    final proceed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Background Execution'),
            content: const Text(
              'To run reliably in the background, the app requests an exception '
              'from battery optimizations. You can change this at any time in '
              'system settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Not now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Continue'),
              ),
            ],
          ),
    );
    if (proceed != true) return;

    final outcome =
        await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed(
          openSettingsIfDirectRequestNotPossible: true,
        );
    setState(() {
      _log =
          'ensureOptimizationDisabledDetailed => ${outcome.status.name} '
          '(disabled=${outcome.isOptimizationDisabled})';
    });
    await _refreshStatus();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_log)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battery Optimization Helper')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Optimization enabled: ${_isOptimized ?? '...'}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _showRationaleThenEnsure,
                  child: const Text('Ensure Disabled (with rationale)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final outcome =
                        await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed(
                          openSettingsIfDirectRequestNotPossible: true,
                        );
                    setState(
                      () =>
                          _log =
                              'Detailed outcome: ${outcome.status.name} '
                              '(disabled=${outcome.isOptimizationDisabled})',
                    );
                    await _refreshStatus();
                  },
                  child: const Text('Ensure Disabled'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final snapshot =
                        await BatteryOptimizationHelper.getBatteryRestrictionSnapshot();
                    setState(
                      () =>
                          _log =
                              'Snapshot: sdk=${snapshot.androidSdkInt}, '
                              'manufacturer=${snapshot.manufacturer}, '
                              'optimized=${snapshot.isBatteryOptimizationEnabled}, '
                              'powerSave=${snapshot.isPowerSaveModeOn}, '
                              'canOpenOEM=${snapshot.canOpenAutoStartSettings}',
                    );
                  },
                  child: const Text('Refresh Diagnostics'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final isEnabled =
                        await BatteryOptimizationHelper.isBatteryOptimizationEnabled();
                    setState(
                      () => _log = 'Battery optimization enabled: $isEnabled',
                    );
                    await _refreshStatus();
                  },
                  child: const Text('Check Optimization'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await BatteryOptimizationHelper.requestDisableBatteryOptimization();
                    await _refreshStatus();
                  },
                  child: const Text('Request Disable (fire-and-forget)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await BatteryOptimizationHelper.openBatteryOptimizationSettings();
                  },
                  child: const Text('Open System Settings'),
                ),
                const Divider(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final opened =
                        await BatteryOptimizationHelper.openAutoStartSettings();
                    setState(() => _log = 'Opened OEM auto-start: $opened');
                  },
                  child: const Text('Open Auto-start Settings'),
                ),
                const SizedBox(height: 12),
                Text(_log, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
