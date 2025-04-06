import 'package:flutter/material.dart';
import 'package:battery_optimization_helper/battery_optimization_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Battery Optimization Helper')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final isEnabled =
                      await BatteryOptimizationHelper.isBatteryOptimizationEnabled();
                  debugPrint("Battery optimization enabled: $isEnabled");
                },
                child: const Text("Check Optimization"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await BatteryOptimizationHelper.requestDisableBatteryOptimization();
                },
                child: const Text("Request Disable"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await BatteryOptimizationHelper.openBatteryOptimizationSettings();
                },
                child: const Text("Open Settings"),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () async {
                  await BatteryOptimizationHelper.openAutoStartSettings();
                },
                child: const Text("Background autostart"),
              ),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
