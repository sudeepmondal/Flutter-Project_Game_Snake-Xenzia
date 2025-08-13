import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(SnakeGame());

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game with Big Buttons',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  // Game variables
  final int gridSize = 22;
  final int cellSize = 20;
  List<Offset> snake = [Offset(10, 10)];
  late Offset food;
  late Offset specialFood;
  String direction = 'right';
  String nextDirection = 'right';
  late Timer timer;
  bool isGameOver = false;
  int score = 0;
  int highScore = 0;
  bool isPaused = false;
  bool specialFoodActive = false;
  int specialFoodTimer = 0;
  late AnimationController _animationController;
  Color snakeColor = Colors.green;
  Color foodColor = Colors.red;
  Color specialFoodColor = Colors.yellow;
  bool isDarkMode = false;
  DateTime? lastTapTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    spawnFood();
    startGame();
    _loadHighScore();
  }

  void _loadHighScore() async {
    // Implement your high score saving logic here
  }

  void _saveHighScore() async {
    // Implement your high score saving logic here
  }

  void startGame() {
    timer = Timer.periodic(Duration(milliseconds: 520), (timer) {
      if (!isPaused && !isGameOver) {
        setState(() {
          moveSnake();
          if (specialFoodActive) {
            specialFoodTimer--;
            if (specialFoodTimer <= 0) {
              specialFoodActive = false;
            }
          } else if (Random().nextDouble() < 0.01 && !specialFoodActive) {
            spawnSpecialFood();
          }
        });
      }
    });
  }

  void spawnFood() {
    final random = Random();
    int x, y;
    do {
      x = random.nextInt(gridSize);
      y = random.nextInt(gridSize);
    } while (snake.contains(Offset(x.toDouble(), y.toDouble())));
    food = Offset(x.toDouble(), y.toDouble());
  }

  void spawnSpecialFood() {
    final random = Random();
    int x, y;
    do {
      x = random.nextInt(gridSize);
      y = random.nextInt(gridSize);
    } while (snake.contains(Offset(x.toDouble(), y.toDouble())));
    specialFood = Offset(x.toDouble(), y.toDouble());
    specialFoodActive = true;
    specialFoodTimer = 50;
  }

  void moveSnake() {
    direction = nextDirection;
    Offset head = snake.first;

    Offset newHead = head;
    switch (direction) {
      case 'up':    newHead = Offset(head.dx, head.dy - 1); break;
      case 'down':  newHead = Offset(head.dx, head.dy + 1); break;
      case 'left':  newHead = Offset(head.dx - 1, head.dy); break;
      case 'right': newHead = Offset(head.dx + 1, head.dy); break;
    }

    // Wrap around the walls
    if (newHead.dx < 0) newHead = Offset(gridSize.toDouble() - 1, newHead.dy);
    if (newHead.dx >= gridSize) newHead = Offset(0, newHead.dy);
    if (newHead.dy < 0) newHead = Offset(newHead.dx, gridSize.toDouble() - 1);
    if (newHead.dy >= gridSize) newHead = Offset(newHead.dx, 0);

    // Check for body collision (only game over condition)
    if (snake.contains(newHead)) {
      gameOver();
      return;
    }

    snake.insert(0, newHead);

    if (newHead == food) {
      score += 1;
      if (score > highScore) {
        highScore = score;
        _saveHighScore();
      }
      spawnFood();
      snakeColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    } else if (specialFoodActive && newHead == specialFood) {
      score += 5;
      specialFoodActive = false;
      snakeColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    } else {
      snake.removeLast();
    }
  }

  void gameOver() {
    isGameOver = true;
    timer.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $score', style: TextStyle(fontSize: 20)),
            Text('High Score: $highScore', style: TextStyle(fontSize: 20)),
          ],
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        actions: [
          TextButton(
            child: Text('Play Again', style: TextStyle(color: isDarkMode ? Colors.white : Colors.blue)),
            onPressed: () {
              resetGame();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      snake = [Offset(10, 10)];
      direction = 'right';
      nextDirection = 'right';
      isGameOver = false;
      isPaused = false;
      score = 0;
      snakeColor = Colors.green;
      spawnFood();
      specialFoodActive = false;
      startGame();
    });
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void changeDirection(String newDirection) {
    if (!isPaused && !isGameOver) {
      setState(() {
        if ((direction == 'up' && newDirection != 'down') ||
            (direction == 'down' && newDirection != 'up') ||
            (direction == 'left' && newDirection != 'right') ||
            (direction == 'right' && newDirection != 'left')) {
          nextDirection = newDirection;
          direction = newDirection; // Immediate update
        }
      });
    }
  }


  void immediateMove() {
    if (!isPaused && !isGameOver) {
      setState(() {
        moveSnake();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Snake Xenzia"),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleTheme,
          ),
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: togglePause,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Score', style: TextStyle(fontSize: 16)),
                    Text('$score', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('High Score', style: TextStyle(fontSize: 16)),
                    Text('$highScore', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: SnakePainter(
                snake: snake,
                food: food,
                specialFood: specialFoodActive ? specialFood : null,
                gridSize: gridSize,
                isGameOver: isGameOver,
                snakeColor: snakeColor,
                foodColor: foodColor,
                specialFoodColor: specialFoodColor,
                animation: _animationController,
              ),
              size: Size(gridSize * cellSize.toDouble(), gridSize * cellSize.toDouble()),
            ),
          ),

          SizedBox(
            height: 220,
            child: Stack( // Using Stack to overlay larger invisible touch areas
              children: [
                // Visual buttons (maintains your original layout)
                Column(
                  children: [
                    Container(
                      height: 60,
                      padding: EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: Icon(Icons.arrow_upward, size: 100),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(right: 30, bottom: 40),
                            child: Center(
                              child: Icon(Icons.arrow_back, size: 100),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(top: 60),
                            child: Center(
                              child: Icon(Icons.arrow_downward, size: 100),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 30, bottom: 40),
                            child: Center(
                              child: Icon(Icons.arrow_forward, size: 100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Expanded touch areas (invisible but responsive)
                // Up button touch area (expanded to full width)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 80, // Larger than visual button
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) {
                      changeDirection('up');
                      immediateMove();
                    },
                    onPanUpdate: (_) {
                      changeDirection('up');
                      immediateMove();
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Left button touch area (expanded left side)
                Positioned(
                  top: 80,
                  left: 0,
                  width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) {
                      changeDirection('left');
                      immediateMove();
                    },
                    onPanUpdate: (_) {
                      changeDirection('left');
                      immediateMove();
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Down button touch area (expanded center)
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.3,
                  right: MediaQuery.of(context).size.width * 0.3,
                  top: 80,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) {
                      changeDirection('down');
                      immediateMove();
                    },
                    onPanUpdate: (_) {
                      changeDirection('down');
                      immediateMove();
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Right button touch area (expanded right side)
                Positioned(
                  top: 80,
                  right: 0,
                  width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) {
                      changeDirection('right');
                      immediateMove();
                    },
                    onPanUpdate: (_) {
                      changeDirection('right');
                      immediateMove();
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          )



        ],
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    _animationController.dispose();
    super.dispose();
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final Offset? specialFood;
  final int gridSize;
  final bool isGameOver;
  final Color snakeColor;
  final Color foodColor;
  final Color specialFoodColor;
  final Animation<double> animation;

  SnakePainter({
    required this.snake,
    required this.food,
    this.specialFood,
    required this.gridSize,
    required this.isGameOver,
    this.snakeColor = Colors.green,
    this.foodColor = Colors.red,
    this.specialFoodColor = Colors.yellow,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;
    final center = cellSize / 2;

    // Draw grid with wrap-around indication
    final gridPaint = Paint()..color = Colors.grey.withOpacity(0.3)..style = PaintingStyle.stroke;
    final wrapPaint = Paint()..color = Colors.blue.withOpacity(0.2)..style = PaintingStyle.fill;

    // Fill edges to indicate wrap-around
    canvas.drawRect(Rect.fromLTWH(0, 0, 2, size.height), wrapPaint);
    canvas.drawRect(Rect.fromLTWH(size.width-2, 0, 2, size.height), wrapPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 2), wrapPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height-2, size.width, 2), wrapPaint);

    // Draw grid lines
    for (int i = 0; i <= gridSize; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), gridPaint);
      canvas.drawLine(Offset(0, i * cellSize), Offset(size.width, i * cellSize), gridPaint);
    }

    // Draw food
    final foodPaint = Paint()..color = foodColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(food.dx * cellSize, food.dy * cellSize, cellSize, cellSize),
        Radius.circular(4),
      ),
      foodPaint,
    );

    // Draw special food (if active)
    if (specialFood != null) {
      final pulse = 1 + animation.value * 0.2;
      final specialPaint = Paint()..color = specialFoodColor.withOpacity(0.8);
      canvas.drawCircle(
        Offset(specialFood!.dx * cellSize + center, specialFood!.dy * cellSize + center),
        (cellSize / 2) * pulse,
        specialPaint,
      );
    }

    // Draw snake
    for (int i = 0; i < snake.length; i++) {
      final segment = snake[i];
      final paint = Paint()
        ..color = snakeColor.withOpacity(1 - (i / snake.length) * 0.5)
        ..style = i == 0 ? PaintingStyle.fill : PaintingStyle.fill;

      // Head is rounded
      if (i == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(segment.dx * cellSize, segment.dy * cellSize, cellSize, cellSize),
            Radius.circular(8),
          ),
          paint,
        );

        // Draw eyes on head
        final eyePaint = Paint()..color = Colors.white;
        canvas.drawCircle(
          Offset(segment.dx * cellSize + cellSize * 0.3, segment.dy * cellSize + cellSize * 0.3),
          cellSize * 0.1,
          eyePaint,
        );
        canvas.drawCircle(
          Offset(segment.dx * cellSize + cellSize * 0.7, segment.dy * cellSize + cellSize * 0.3),
          cellSize * 0.1,
          eyePaint,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(segment.dx * cellSize, segment.dy * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }

    // Game over overlay
    if (isGameOver) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.black54,
      );
    }
  }

  @override
  bool shouldRepaint(SnakePainter oldDelegate) => true;
}