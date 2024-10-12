import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Card Model
class CardModel {
  final String id;
  final String frontDesign;
  final String backDesign;
  bool isFaceUp;

  CardModel({
    required this.id,
    required this.frontDesign,
    required this.backDesign,
    this.isFaceUp = false, // Initially face-down
  });
}

// Game Provider (State Management)
class GameProvider with ChangeNotifier {
  List<CardModel> _cards = [];

  List<CardModel> get cards => _cards;

  GameProvider() {
    _initializeCards();
  }

  void _initializeCards() {
    // Create pairs of cards for the game (e.g., 4 pairs for 4x4 grid)
    _cards = List.generate(8, (index) {
      return [
        CardModel(
            id: 'card_$index',
            frontDesign: 'Front $index',
            backDesign: 'Back',
            isFaceUp: false),
        CardModel(
            id: 'card_${index}_pair',
            frontDesign: 'Front $index',
            backDesign: 'Back',
            isFaceUp: false),
      ];
    }).expand((cardPair) => cardPair).toList();

    _cards.shuffle(); // Shuffle the cards to randomize the grid
  }

  void flipCard(CardModel card) {
    card.isFaceUp = !card.isFaceUp;
    notifyListeners();
  }
}

void main() {
  runApp(const CardMatchingGame());
}

// Main App
class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'Card Matching Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const GameScreen(),
      ),
    );
  }
}

// Game Screen
class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: gameProvider.cards.length,
              itemBuilder: (context, index) {
                final card = gameProvider.cards[index];
                return CardWidget(card: card);
              },
            );
          },
        ),
      ),
    );
  }
}

// Card Widget
class CardWidget extends StatelessWidget {
  final CardModel card;

  const CardWidget({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<GameProvider>(context, listen: false).flipCard(card);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            card.isFaceUp ? card.frontDesign : card.backDesign,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
