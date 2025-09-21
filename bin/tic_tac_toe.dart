import 'dart:io';
import 'dart:math';
import 'package:tic_tac_toe/side.dart';
import 'package:tic_tac_toe/cell.dart';
import 'package:tic_tac_toe/result.dart';

List<List<Cell>> winComb = [];
List<Cell> turns = List.empty(growable: true);
List<Cell> availableTurns = List.empty();
int? fieldDiameter;
Side? playerSide;
Random? random;

void main(List<String> arguments) {
  bool keepMoving = true;

  do {
    random = Random();
    print(
      "\n\n\n------------------------------------------------------------------------------------------------\n",
    );
    print("Select the board size:\n\t1 - 3x3\n\t2 - 4x4");
    int? option;
    while (option == null) {
      var inputSize = stdin.readLineSync();
      if (inputSize == null) {
        continue;
      }
      option = int.tryParse(inputSize);

      if (option != 1 && option != 2) {
        option = null;
      }
    }

    //ge tthe player side
    print(
      "Would you like to lead the play (you will play as crosses if you print YES, in case you don`t get it)?",
    );
    var answer = stdin.readLineSync()?.toLowerCase();
    if (answer == null || (answer != "yes" && answer != "no")) {
      print("Well, you picked the random decision. Who i am to blame you.");
      playerSide = Side.values[random!.nextInt(Side.values.length)];
    } else if (answer == "no") {
      print(
        "Well, you picked the opposite to offered side. Who i am to blame you.",
      );
      playerSide = Side.zeroes;
    } else if (answer == "yes") {
      print(
        "Well, you picked the side you've been suggested to. How long did it take you to pick non other but the side of crosses.",
      );
      playerSide = Side.crosses;
    }

    //ask if stupid bot is needed
    print(
      "By the way, before you start i`d like to ask if you have the real opponent to play with. If not you`ll be pushed to play with stupid bot, who place signs randomly. (YES - turn bot of)",
    );
    answer = stdin.readLineSync();

    var needBot = false;
    if (answer == null || answer.toLowerCase() != "yes") {
      print(
        "Well, enjoy playing with the bot, not knowing basic combinations to win.",
      );
      needBot = true;
    } else {
      print("Well, enjoy this console sheet, i guess.");
    }

    //initializing game settings
    if (option == 1) initializeGame(3);

    if (option == 2) initializeGame(4);

    //the game
    Result? res;
    while (res == null) {
      //defining the turns` priority
      if (playerSide == Side.crosses) {
        printSheet();
        makeTurn(playerSide!);
        res = checkIfWon();
        if (res != null) {
          break;
        }

        if (needBot) {
          aiTurn();
        } else {
          makeTurn(Side.zeroes);
        }
      } else {
        if (needBot) {
          aiTurn();
          res = checkIfWon();
          if (res != null) {
            break;
          }
        } else {
          printSheet();
          makeTurn(Side.zeroes);
        }
        printSheet();
        makeTurn(playerSide!);
      }
      res = checkIfWon();
    }

    printSheet();
    switch (res) {
      case Result.CrossesWin:
        print("Crosses won");
        break;
      case Result.ZeroesWin:
        print("Toes won");
        break;
      case Result.Draw:
        print("draw");
        break;
    }

    print("Shal we keep going with this shity game");
    answer = stdin.readLineSync();
    keepMoving = (answer?.toLowerCase() == "yes");
  } while (keepMoving);
}

void makeTurn(Side currentTurn) {
  Cell? playerTurn;
  do {
    print("Pick the cell to place your sign at (format: \"x:y\")");
    var turnInput = stdin.readLineSync();
    if (turnInput == null) continue;
    RegExp format = RegExp(r'[0-9]{1}\:[0-9]{1}');
    if (!format.hasMatch(turnInput)) {
      print(
        "Let me remind you that the format is to place x axis, then - vertical double dot and then - y axis. For example, 1:2. This will be equal to: \"Place my sign at row 2, column 1\"",
      );
      continue;
    }

    var axises = turnInput.split(':');
    var xAxis = int.tryParse(axises[0]);
    var yAxis = int.tryParse(axises[1]);
    var availableTurn = availableTurns.indexOf(Cell(xAxis ?? -1, yAxis ?? -1));

    if (availableTurn == -1) {
      print("Cell was not found");
      continue;
    }

    playerTurn = availableTurns[availableTurn];
    availableTurns.removeAt(availableTurn);
    playerTurn.sign = currentTurn;
  } while (playerTurn == null);

  turns.add(playerTurn);
}

void printSheet() {
  if (fieldDiameter == null) throw Exception("Cannot define the sheet size");
  for (var i = 1; i <= fieldDiameter!; i++) {
    for (var j = 1; j <= fieldDiameter!; j++) {
      Cell? signOnPlace = turns.firstWhere(
        (cell) => cell.xAxis == j && cell.yAxis == i,
        orElse: () => Cell(0, 0),
      );
      stdout.write(signOnPlace.sign?.toString() ?? "*");
      if (j != fieldDiameter) stdout.write(" --- ");
    }
    stdout.writeln();
  }
}

void initializeGame(int fieldD) {
  fieldDiameter = fieldD;
  if (fieldD == 3) {
    winComb = [
      [Cell(1, 1), Cell(2, 1), Cell(3, 1)],
      [Cell(2, 1), Cell(2, 2), Cell(2, 3)],
      [Cell(3, 1), Cell(3, 2), Cell(3, 3)],
      [Cell(1, 1), Cell(2, 2), Cell(3, 3)],
      [Cell(1, 1), Cell(1, 2), Cell(1, 3)],
      [Cell(2, 1), Cell(2, 2), Cell(2, 3)],
      [Cell(3, 1), Cell(2, 2), Cell(1, 3)],
    ];
    availableTurns = [
      Cell(1, 1),
      Cell(2, 1),
      Cell(3, 1),
      Cell(1, 2),
      Cell(2, 2),
      Cell(3, 2),
      Cell(1, 3),
      Cell(2, 3),
      Cell(3, 3),
    ];
  } else if (fieldDiameter == 4) {
    winComb = [
      [Cell(1, 1), Cell(2, 1), Cell(3, 1), Cell(4, 1)],
      [Cell(1, 2), Cell(2, 2), Cell(3, 2), Cell(4, 2)],
      [Cell(1, 3), Cell(2, 3), Cell(3, 3), Cell(4, 3)],
      [Cell(1, 4), Cell(2, 4), Cell(3, 4), Cell(4, 4)],

      [Cell(1, 1), Cell(1, 2), Cell(1, 3), Cell(1, 4)],
      [Cell(2, 1), Cell(2, 2), Cell(2, 3), Cell(2, 4)],
      [Cell(3, 1), Cell(3, 2), Cell(3, 3), Cell(3, 4)],
      [Cell(4, 1), Cell(4, 2), Cell(4, 3), Cell(4, 4)],

      [Cell(1, 1), Cell(2, 2), Cell(3, 3), Cell(4, 4)],
      [Cell(1, 4), Cell(2, 3), Cell(3, 2), Cell(4, 1)],
    ];
    availableTurns = [
      Cell(1, 1),
      Cell(2, 1),
      Cell(3, 1),
      Cell(4, 1),
      Cell(1, 2),
      Cell(2, 2),
      Cell(3, 2),
      Cell(4, 2),
      Cell(1, 3),
      Cell(2, 3),
      Cell(3, 3),
      Cell(4, 3),
      Cell(1, 4),
      Cell(2, 4),
      Cell(3, 4),
      Cell(4, 4),
    ];
  }
}

Result? checkIfWon() {
  List<Cell> persCells;
  persCells = turns.where((cell) => cell.sign == Side.crosses).toList();
  if (winComb.any(
    (bl) =>
        persCells.where((cell) => bl.contains(cell)).toList().length ==
        bl.length,
  )) {
    return Result.CrossesWin;
  }

  persCells = turns.where((cell) => cell.sign == Side.zeroes).toList();
  var comb = winComb.where((bl) {
    var cells = persCells.where((cell) => bl.contains(cell)).toList();
    return cells.length == bl.length;
  });
  if (winComb.any(
    (bl) =>
        persCells.where((cell) => bl.contains(cell)).toList().length ==
        bl.length,
  )) {
    print(comb);
    return Result.ZeroesWin;
  }
  if (turns.where((cell) => cell.sign != null).length ==
      fieldDiameter! * fieldDiameter!) {
    return Result.Draw;
  }

  return null;
}

void aiTurn() {
  if (playerSide == null) {
    throw Exception("No opponent found");
  }

  var myTurns = turns.where((cell) => cell.sign != playerSide);

  // check if can win
  var almostWinCombs = winComb
      .where(
        (bl) =>
            myTurns.where((cell) => bl.contains(cell)).length == bl.length - 1,
      )
      .map((bl) {
        var cell = bl.firstWhere(
          (cell) => availableTurns.any((tCell) => tCell == cell),
          orElse: () => Cell(-1, -1),
        );
        if (cell.xAxis == -1) return null;
        return cell;
      })
      .nonNulls
      .toList();
  if (almostWinCombs.isNotEmpty) {
    var index = availableTurns.indexOf(almostWinCombs.first);
    var freeComb = availableTurns[index];
    availableTurns.removeAt(index);

    if (playerSide == Side.crosses) {
      freeComb.sign = Side.zeroes;
    } else {
      freeComb.sign = Side.crosses;
    }
    turns.add(freeComb);
    return;
  }

  //check if should prevent winning
  var opponentTurns = turns.where((cell) => cell.sign == playerSide);
  var almostLooseCombs = winComb
      .where(
        (bl) =>
            opponentTurns.where((cell) => bl.contains(cell)).length ==
            bl.length - 1,
      )
      .map((bl) {
        var cell = bl.firstWhere(
          (cell) => availableTurns.any((tCell) => tCell == cell),
          orElse: () => Cell(-1, -1),
        );
        if (cell.xAxis == -1) return null;
        return cell;
      })
      .nonNulls
      .toList();

  if (almostLooseCombs.isNotEmpty) {
    var index = availableTurns.indexOf(almostLooseCombs.first);
    var freeComb = availableTurns[index];
    availableTurns.removeAt(index);
    if (playerSide == Side.crosses) {
      freeComb.sign = Side.zeroes;
    } else {
      freeComb.sign = Side.crosses;
    }
    turns.add(freeComb);
    return;
  }

  //make random turn
  if (random == null) {
    throw Exception("Cannot decide which cell to pick");
  }
  var index = random!.nextInt(availableTurns.length);
  var freeComb = availableTurns[index];
  availableTurns.removeAt(index);
  if (playerSide == Side.crosses) {
    freeComb.sign = Side.zeroes;
  } else {
    freeComb.sign = Side.crosses;
  }
  turns.add(freeComb);
}
