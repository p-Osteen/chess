import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controller/chess_controller.dart';
import 'package:chess/chess.dart' as ch;

class ChessBoard extends StatelessWidget {
  final controller = Get.find<ChessController>();

  ChessBoard({super.key});

  String getPieceSymbol(ch.Piece? piece) {
    if (piece == null) return '';
    const symbols = {
      'P': '♙',
      'N': '♘',
      'B': '♗',
      'R': '♖',
      'Q': '♕',
      'K': '♔',
      'p': '♟',
      'n': '♞',
      'b': '♝',
      'r': '♜',
      'q': '♛',
      'k': '♚',
    };
    final key = piece.color == ch.Color.WHITE
        ? piece.type.name.toUpperCase()
        : piece.type.name.toLowerCase();
    return symbols[key] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final board = controller.board.value;
      final selected = controller.selectedSquare.value;
      final highlights = controller.possibleMoves;

      return LayoutBuilder(
        builder: (_, constraints) {
          double boardSize = constraints.maxWidth * 0.65;
          double sideWidth = (constraints.maxWidth - boardSize) / 2;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Black captures
              SizedBox(
                width: sideWidth,
                child: Column(
                  children: [
                    const Text("Black Captures",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      children: controller.capturedWhite
                          .map((s) =>
                              Text(s, style: const TextStyle(fontSize: 20)))
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Chess board
              SizedBox(
                width: boardSize,
                height: boardSize,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 64,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) {
                    int rank = 7 - index ~/ 8;
                    int file = index % 8;
                    String square = "${'abcdefgh'[file]}${rank + 1}";
                    var piece = board.get(square);
                    bool isDark = (file + rank) % 2 == 1;
                    bool isSelected = selected == square;
                    bool isHighlighted = highlights.contains(square);

                    Color baseColor = isDark
                        ? const Color(0xFF8C7A68)
                        : const Color(0xFFB58863);

                    return GestureDetector(
                      onTap: () => controller.onSquareTap(square),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.withValues(alpha: 0.6)
                              : baseColor,
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Stack(
                          children: [
                            if (isHighlighted)
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: boardSize / 10,
                                  height: boardSize / 10,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.withValues(alpha: 0.5),
                                  ),
                                )
                                    .animate(
                                      onPlay: (controller) =>
                                          controller.repeat(reverse: true),
                                    )
                                    .scale(
                                      duration: const Duration(seconds: 1),
                                      begin: const Offset(0.9, 0.9),
                                      end: const Offset(1.2, 1.2),
                                      curve: Curves.easeInOut,
                                    )
                                    .fade(
                                      duration: const Duration(seconds: 1),
                                      begin: 0.3,
                                      end: 0.6,
                                      curve: Curves.easeInOut,
                                    ),
                              ),
                            Center(
                              child: Text(
                                getPieceSymbol(piece),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontFamily: 'ChessMerida',
                                  color: piece?.color == ch.Color.WHITE
                                      ? const Color(0xFFF8F8F8)
                                      : const Color(0xFF222222),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // White captures
              SizedBox(
                width: sideWidth,
                child: Column(
                  children: [
                    const Text("White Captures",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      children: controller.capturedBlack
                          .map((s) =>
                              Text(s, style: const TextStyle(fontSize: 20)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
