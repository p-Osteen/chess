# ♟️ Flutter Chess Game with AI (GetX + Chess Engine)

A sleek, fully functional **Flutter chess game** with AI support, built using `GetX` for state management and the `chess` Dart package for game logic. This app features smart move validation, game-over alerts, and visually tracks captured pieces for both players.


## 🔥 Features

- 🎮 Tap-to-move chess gameplay
- 🤖 Play vs AI (3 difficulty levels)
- ✨ Smooth UI with square highlights and animations
- 🚨 Real-time "Check!" and "Game Over" alerts
- 👑 Automatic pawn promotion (Queen)
- ♟️ Captured piece display (Black on left, White on right)
- 🧠 Reactive state management with GetX
- 🧪 Built with `chess` Dart package for FIDE-compliant rules


## 🎯 AI Difficulty

The AI difficulty can be set before the game starts via:

```dart
controller.setDifficulty(Difficulty.easy); // .beg, .intm, .exp
```

⚠️ Cannot be changed during an active game.

## ✨ To Do

- [ ] Undo / Redo functionality
- [ ] Stockfish integration
- [ ] Chess clocks
- [ ] UI themes (dark/light/retro)


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.