import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chess/chess.dart' as ch;
import '../logic/chess_ai.dart';

class ChessController extends GetxController {
  final board = ch.Chess().obs;
  final playerVsAI = true.obs;
  final aiDifficulty = Difficulty.beg.obs;
  final selectedSquare = RxnString();
  final possibleMoves = <String>[].obs;

  final capturedWhite = <String>[].obs;
  final capturedBlack = <String>[].obs;

  void setDifficulty(Difficulty difficulty) {
    if (!board.value.in_checkmate &&
        !board.value.in_stalemate &&
        board.value.history.isNotEmpty) {
      Get.snackbar(
        'Not Allowed',
        'You can’t change difficulty during an active game.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
      );
      return;
    }
    aiDifficulty.value = difficulty;
  }

  void onSquareTap(String square) {
    if (board.value.game_over) {
      Get.snackbar(
        'Game Over',
        board.value.in_checkmate
            ? (board.value.turn == ch.Color.WHITE
                ? 'Black wins!'
                : 'White wins!')
            : 'The game ended in a draw.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
      );
      return;
    }

    final currentPiece = board.value.get(square);

    if (selectedSquare.value != null && selectedSquare.value != square) {
      final selectedPiece = board.value.get(selectedSquare.value!);

      if (selectedPiece != null &&
          (currentPiece == null || currentPiece.color != selectedPiece.color)) {
        String? promotion;
        if (selectedPiece.type == ch.PieceType.PAWN) {
          final isWhite = selectedPiece.color == ch.Color.WHITE;
          final targetRank = int.tryParse(square[1]);
          if ((isWhite && targetRank == 8) || (!isWhite && targetRank == 1)) {
            promotion = "q";
          }
        }

        final move = {
          "from": selectedSquare.value!,
          "to": square,
          if (promotion != null) "promotion": promotion,
        };

        final beforeMoveFEN = board.value.fen;

        final captured = board.value.get(square);
        if (captured != null) {
          final symbol = getPieceSymbol(captured);
          if (captured.color == ch.Color.WHITE) {
            capturedWhite.add(symbol);
          } else {
            capturedBlack.add(symbol);
          }
        }

        final moveResult = board.value.move(move);

        if (moveResult != null && moveResult != false) {
          board.refresh();
          selectedSquare.value = null;
          possibleMoves.clear();

          if (board.value.in_check && !board.value.in_checkmate) {
            Get.snackbar(
              'Check!',
              board.value.turn == ch.Color.WHITE
                  ? 'White is in check.'
                  : 'Black is in check.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
              snackStyle: SnackStyle.FLOATING,
            );
          }

          if (playerVsAI.value &&
              board.value.turn == ch.Color.BLACK &&
              !board.value.game_over) {
            Future.delayed(const Duration(milliseconds: 300), _makeAIMove);
          }

          if (board.value.game_over) {
            _showGameOverMessage();
          }
        } else {
          board.value = ch.Chess.fromFEN(beforeMoveFEN);
          board.refresh();

          Future.delayed(const Duration(milliseconds: 50), () {
            Get.snackbar(
              'Invalid Move',
              'That move is not allowed.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
              snackStyle: SnackStyle.FLOATING,
            );
          });

          _selectSquare(selectedSquare.value!);
        }

        return;
      }
    }

    if (currentPiece != null && currentPiece.color == board.value.turn) {
      _selectSquare(square);
    } else {
      selectedSquare.value = null;
      possibleMoves.clear();
    }
  }

  void _selectSquare(String square) {
    selectedSquare.value = square;
    final moves = board.value.moves({'square': square, 'verbose': true});
    possibleMoves.value = moves.map((m) => m['to'] as String).toList();
  }

  void _makeAIMove() async {
    if (board.value.game_over) return;

    if (playerVsAI.value && board.value.turn == ch.Color.BLACK) {
      await Future.delayed(const Duration(milliseconds: 400));

      final ai = ChessAI(aiDifficulty.value);
      final move = ai.getMove(board.value); // Returns a ch.Move

      if (move != null) {
        final toSquare =
            ch.Chess.SQUARES[move.to]; // ✅ convert int index to 'e4'

        final captured = board.value.get(toSquare); // ✅ now it's a String
        if (captured != null) {
          final symbol = getPieceSymbol(captured);
          if (captured.color == ch.Color.WHITE) {
            capturedWhite.add(symbol);
          } else {
            capturedBlack.add(symbol);
          }
        }

        board.value.move(move);
        board.refresh();

        if (board.value.in_check && !board.value.in_checkmate) {
          Get.snackbar(
            'Check!',
            board.value.turn == ch.Color.WHITE
                ? 'White is in check.'
                : 'Black is in check.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            snackStyle: SnackStyle.FLOATING,
          );
        }

        if (board.value.game_over) {
          _showGameOverMessage();
        }
      }
    }
  }

  void resetGame() {
    board.value = ch.Chess();
    selectedSquare.value = null;
    possibleMoves.clear();
    capturedWhite.clear();
    capturedBlack.clear();
    board.refresh();
  }

  void _showGameOverMessage() {
    String message;

    if (board.value.in_checkmate) {
      message =
          board.value.turn == ch.Color.WHITE ? "Black wins!" : "White wins!";
    } else if (board.value.in_stalemate) {
      message = "Draw by stalemate.";
    } else if (board.value.insufficient_material) {
      message = "Draw: Insufficient material.";
    } else if (board.value.in_threefold_repetition) {
      message = "Draw: Threefold repetition.";
    } else if (board.value.in_draw) {
      message = "Draw!";
    } else {
      message = "Game over.";
    }

    Get.snackbar(
      'Game Over',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade800,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
    );
  }

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
}
