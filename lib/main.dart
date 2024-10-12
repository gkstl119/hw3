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

// Card Widget with Animation and Text Fix
class CardWidget extends StatefulWidget {
  final CardModel card;

  const CardWidget({Key? key, required this.card}) : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFaceUp) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<GameProvider>(context, listen: false).flipCard(widget.card);
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isUnder = _animation.value > 0.5;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective effect
              ..rotateY(_animation.value * 3.14), // Rotate the card
            alignment: Alignment.center,
            child: isUnder ? _buildFrontCard() : _buildBackCard(),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Transform(
      transform: Matrix4.identity()..rotateY(3.14), // Corrects the flipped text
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            widget.card.frontDesign,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Center(
        child: Text(
          'Card Back',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
