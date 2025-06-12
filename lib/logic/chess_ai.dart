import 'dart:math';
import 'package:chess/chess.dart' as ch;

enum Difficulty { beg, intm, exp }

class ChessAI {
  final Difficulty difficulty;
  ChessAI(this.difficulty);

  ch.Move? getMove(ch.Chess game) {
    switch (difficulty) {
      case Difficulty.beg:
        return _randomMove(game);
      case Difficulty.intm:
        return _captureOrCheckMove(game) ?? _basicEval(game);
      case Difficulty.exp:
        final isWhite = game.turn == ch.Color.WHITE;
        final result = _minimax(game, 4, isWhite); // Increased depth to 4
        if (result.move != null) return result.move!;
        return _randomMove(game);
    }
  }

  ch.Move? _randomMove(ch.Chess game) {
    var moves = game.generate_moves();
    if (moves.isEmpty) return null;
    return moves[Random().nextInt(moves.length)];
  }

  ch.Move? _captureOrCheckMove(ch.Chess game) {
    var moves = game.generate_moves();
    if (moves.isEmpty) return null;

    var captureMoves = moves.where((m) => m.captured != null).toList();
    if (captureMoves.isNotEmpty) {
      return captureMoves[Random().nextInt(captureMoves.length)];
    }

    var checkMoves = <ch.Move>[];
    for (var move in moves) {
      game.move(move);
      if (game.in_check) checkMoves.add(move);
      game.undo_move();
    }
    if (checkMoves.isNotEmpty) {
      return checkMoves[Random().nextInt(checkMoves.length)];
    }

    return null;
  }

  ch.Move? _basicEval(ch.Chess game) {
    var moves = game.generate_moves();
    if (moves.isEmpty) return null;
    var bestMove = moves.first;
    var bestScore = -99999;
    final isWhite = game.turn == ch.Color.WHITE;
    for (var move in moves) {
      game.move(move);
      int score = _evaluateBoard(game, isWhite, move: move);
      game.undo_move();
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  int _evaluateBoard(ch.Chess game, bool isWhite, {ch.Move? move}) {
    // Piece values
    const values = {
      'p': -1,
      'P': 1,
      'n': -3,
      'N': 3,
      'b': -3,
      'B': 3,
      'r': -5,
      'R': 5,
      'q': -9,
      'Q': 9,
      'k': -1000,
      'K': 1000,
    };
    var fen = game.fen.split(' ')[0];
    int score = 0;
    for (var char in fen.split('')) {
      score += values[char] ?? 0;
    }

    // --- Expert: Add bonuses for checks, captures, center control, mobility ---
    if (difficulty == Difficulty.exp) {
      // Bonus for being in check
      if (game.in_check) score += isWhite ? 10 : -10;

      // Bonus for mobility (number of legal moves)
      int mobility = game.generate_moves().length;
      score += isWhite ? mobility : -mobility;

      // Bonus for controlling the center (e4, d4, e5, d5)
      final centerSquares = ['e4', 'd4', 'e5', 'd5'];
      for (var sq in centerSquares) {
        var piece = game.get(sq);
        if (piece != null) {
          if (piece.color == ch.Color.WHITE) score += 0.5.round();
          if (piece.color == ch.Color.BLACK) score -= 0.5.round();
        }
      }

      // Bonus for capturing higher-value pieces
      if (move != null && move.captured != null) {
        // Use uppercase for white, lowercase for black
        var capturedValue = values[move.captured?.name] ?? 0;
        score += isWhite ? capturedValue.abs() * 2 : -capturedValue.abs() * 2;
      }

      // Bonus for piece development (knights/bishops not on original squares)
      final developedSquares = [
        'c3',
        'f3',
        'c4',
        'f4',
        'c5',
        'f5',
        'c6',
        'f6',
        'b3',
        'g3',
        'b4',
        'g4',
        'b5',
        'g5',
        'b6',
        'g6'
      ];
      for (var sq in developedSquares) {
        var piece = game.get(sq);
        if (piece != null &&
            (piece.type == ch.PieceType.KNIGHT ||
                piece.type == ch.PieceType.BISHOP)) {
          if (piece.color == ch.Color.WHITE) score += 0.5.round();
          if (piece.color == ch.Color.BLACK) score -= 0.5.round();
        }
      }
    }

    // If AI is black, invert score
    return isWhite ? score : -score;
  }

  _MiniMaxResult _minimax(ch.Chess game, int depth, bool maximizing) {
    if (depth == 0 || game.game_over) {
      final isWhite = maximizing;
      return _MiniMaxResult(score: _evaluateBoard(game, isWhite), move: null);
    }

    var bestScore = maximizing ? -99999 : 99999;
    ch.Move? bestMove;

    for (var move in game.generate_moves()) {
      game.move(move);
      var result = _minimax(game, depth - 1, !maximizing);
      game.undo_move();

      if (maximizing && result.score > bestScore) {
        bestScore = result.score;
        bestMove = move;
      } else if (!maximizing && result.score < bestScore) {
        bestScore = result.score;
        bestMove = move;
      }
    }

    return _MiniMaxResult(score: bestScore, move: bestMove);
  }
}

class _MiniMaxResult {
  final int score;
  final ch.Move? move;

  _MiniMaxResult({required this.score, this.move});
}
