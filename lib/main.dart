import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/chess_controller.dart';
import 'logic/chess_ai.dart';
import 'ui/chess_board.dart';

import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import 'package:bitsdojo_window/bitsdojo_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    doWhenWindowReady(() async {
      await windowManager.setResizable(true);
      await windowManager.setMinimizable(true);
      await windowManager.setMaximizable(true);
      await windowManager.maximize();
      windowManager.show();
    });
  }
  Get.put(ChessController());
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Chess')),
        body: const ResponsiveChessScreen(),
      ),
    );
  }
}

class ResponsiveChessScreen extends StatelessWidget {
  const ResponsiveChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChessController>();
    return Column(
      children: [
        Expanded(child: Center(child: ChessBoard())),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: Difficulty.values.map((diff) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ChoiceChip(
                    label: Text(diff.name),
                    selected: controller.aiDifficulty.value == diff,
                    onSelected: (_) => controller.setDifficulty(diff),
                  ),
                );
              }).toList(),
            )),
        ElevatedButton(
          onPressed: controller.resetGame,
          child: const Text('Restart'),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
