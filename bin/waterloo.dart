import 'dart:io';

// размер поля, корабли и само поле
class Battleship {
  final int size;
  final List<List<String>> board;
  int ships;
  int hits = 0; // количество попаданий
  int misses = 0; // количество промахов

  Battleship(this.size, this.ships)
      : board = List.generate(size, (_) => List.filled(size, '-'));

  // расставляем корабли
  void placeShips() {
    for (int i = 1; i <= ships; i++) {
      print("Установите корабль №$i. Введите координаты (например, 2 3):");
      while (true) {
        var input = stdin.readLineSync();
        var moves = input?.split(' ');
        if (moves == null || moves.length != 2) {
          print("Некорректный ввод. Введите две координаты через пробел.");
          continue;
        }
        var row = int.tryParse(moves[0]);
        var col = int.tryParse(moves[1]);
        if (row == null ||
            col == null ||
            row < 0 ||
            row >= size ||
            col < 0 ||
            col >= size) {
          print("Координаты вне поля. Попробуйте снова.");
          continue;
        }
        if (board[row][col] == '-') {
          board[row][col] = 'S';
          break;
        } else {
          print("Здесь уже установлен корабль. Выберите другое место.");
        }
      }
    }
  }

  // выводим игровое поле
  void printBoard(bool reveal) {
    for (var row in board) {
      print(row
          .map((cell) => reveal ? cell : (cell == 'S' ? '-' : cell))
          .join(' '));
    }
  }

  // обработка атаки
  bool attack(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      print("Вы стреляете за пределы поля!");
      return false;
    }
    if (board[row][col] == 'S') {
      board[row][col] = 'X';
      print("Попадание!");
      ships--;
      hits++;
      return true;
    } else if (board[row][col] == '-') {
      board[row][col] = 'O';
      print("Мимо.");
      misses++;
      return false;
    } else {
      print("Вы уже стреляли сюда!");
      return false;
    }
  }

  // проверка на корабли
  bool isGameOver() => ships == 0;

  // записываем статистику в файл
  void saveStatistics() {
    var directory = Directory('game_statistics');
    if (!directory.existsSync()) {
      directory.createSync();
    }

    var file = File('game_statistics/statistics.txt');
    var stats = '''Игра окончена!
    Корабли противника уничтожены.
    Попаданий: $hits
    Промахов: $misses
    Оставшиеся корабли на поле: $ships из $hits
    ''';

    file.writeAsStringSync(stats);
    print("Статистика сохранена в файл 'game_statistics/statistics.txt'");
  }

  // выводим статистику
  void printStatistics() {
    print('''Игра окончена!
    Корабли противника уничтожены.
    Попаданий: $hits
    Промахов: $misses
    Оставшиеся корабли на поле: $ships из $hits
    ''');
  }
}

// размер поля
void main() {
  print("Добро пожаловать в игру 'Морской бой'!");
  print("Введите размер поля (например, 5 для 5x5): ");
  var sizeInput = stdin.readLineSync();
  var size = int.tryParse(sizeInput ?? '5') ?? 5;
  if (size < 3) {
    print("Размер слишком мал, устанавливаю 5.");
    size = 5;
  }

  // кол-во кораблей
  print("Введите количество кораблей: ");
  var shipsInput = stdin.readLineSync();
  var ships = int.tryParse(shipsInput ?? '3') ?? 3;
  if (ships < 1) {
    print("Слишком мало, устанавливаю 3.");
    ships = 3;
  }

  var game = Battleship(size, ships);
  print("Расставьте свои корабли на поле.");
  game.placeShips();

  while (true) {
    print("Текущее поле:");
    // поле без отображения кораблей
    game.printBoard(false);
    print("Введите координаты для атаки (например, 2 3): ");
    var input = stdin.readLineSync();
    if (input == null || input.toLowerCase() == 'выход') {
      print("Вы прошли игру!");
      break;
    }

    var moves = input.split(' ');
    if (moves.length != 2) {
      print("Некорректный ввод. Введите две координаты через пробел.");
      continue;
    }

    var row = int.tryParse(moves[0]);
    var col = int.tryParse(moves[1]);
    if (row == null || col == null) {
      print("Некорректный ввод. Используйте числа.");
      continue;
    }

    // атака на указанные координаты
    game.attack(row, col);

    if (game.isGameOver()) {
      print("Ура, победа!");
      game.printBoard(true);
      game.printStatistics(); // Выводим статистику на экран
      game.saveStatistics(); // Сохраняем статистику в файл
      break;
    }
  }
}
