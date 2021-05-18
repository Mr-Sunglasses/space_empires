import 'package:flutter/material.dart';
import 'package:some_game/models/attack_ships_model.dart';
import 'package:some_game/models/planet_model.dart';
import 'package:some_game/models/upgrade_model.dart';
import 'defence_ships_model.dart';
import 'game_data.dart';

enum StatsType {
  Propoganda,
  Culture,
  Luxury,
  Military,
}

class Player extends ChangeNotifier with Stats, Military, Planets {
  Ruler ruler;
  int money;

  Player({this.ruler, List<Planet> planets}) {
    money = 10000;
    planetsInit(planets);
    statsInit();
    militaryInit();
  }

  nextTurn() {
    money += income;
    notifyListeners();
  }

  int get income {
    return planetsIncome - statsExpenditure - militaryExpenditure;
  }

  buyAttackShip(AttackShipType type) {
    if (money > kAttackShipsData[type].cost) {
      militaryAddShip(type, 1);
      money -= kAttackShipsData[type].cost;
      notifyListeners();
    }
  }

  sellAttackShip(AttackShipType type) {
    if (militaryShipCount(type) > 0) {
      militaryRemoveShip(type, 1);
      money += (kAttackShipsData[type].cost * 0.8).round();
      notifyListeners();
    }
  }

  buyDefenseShip({DefenseShipType type, PlanetName name}) {
    if (money > kDefenseShipsData[type].cost) {
      planetAddShip(type: type, name: name, quantity: 1);
      money -= kDefenseShipsData[type].cost;
      notifyListeners();
    }
  }

  sellDefenseShip({DefenseShipType type, PlanetName name}) {
    int ships = planetShipCount(type: type, name: name);
    if (ships > 0) {
      planetRemoveShip(type: type, name: name, quantity: 1);
      money += (kDefenseShipsData[type].cost * 0.8).round();
      notifyListeners();
    }
  }

  buyUpgrade({UpgradeType type, PlanetName name}) {
    if (money > kUpgradesData[type].cost) {
      planetAddUpgrade(type: type, name: name);
      money -= kUpgradesData[type].cost;
      notifyListeners();
    }
  }

  increaseStat(StatsType type) {
    statIncrement(type);
    notifyListeners();
  }

  decreaseStat(StatsType type) {
    if (statValue(type) <= 0) return;
    statDecrement(type);
    notifyListeners();
  }
}

mixin Stats {
  Map<StatsType, int> _stats = {};

  int get statsExpenditure {
    int expense = 0;
    for (var type in List.from(_stats.keys)) {
      expense += _stats[type] * 5;
    }
    return expense;
  }

  void statsInit() {
    _stats[StatsType.Propoganda] = 40;
    _stats[StatsType.Luxury] = 40;
    _stats[StatsType.Culture] = 40;
    _stats[StatsType.Military] = 40;
  }

  int statValue(StatsType type) {
    return _stats[type];
  }

  statIncrement(StatsType type) {
    _stats[type]++;
  }

  statDecrement(StatsType type) {
    if (_stats[type] > 0) {
      _stats[type]--;
    }
  }

  List<StatsType> get statsList {
    return List.from(_stats.keys);
  }
}

mixin Military {
  Map<AttackShipType, int> _ownedShips = {};

  int get militaryExpenditure {
    int expense = 0;
    for (var type in List.from(_ownedShips.keys)) {
      expense += _ownedShips[type] * kAttackShipsData[type].maintainance;
    }
    return expense;
  }

  int militaryShipCount(AttackShipType type) {
    return _ownedShips[type];
  }

  void militaryInit() {
    _ownedShips[AttackShipType.Astro] = 3;
    _ownedShips[AttackShipType.Magnum] = 3;
    _ownedShips[AttackShipType.Rover] = 5;
  }

  militaryAddShip(AttackShipType type, int quantity) {
    _ownedShips[type] += quantity;
  }

  militaryRemoveShip(AttackShipType type, int quantity) {
    if (_ownedShips[type] > quantity) {
      _ownedShips[type] -= quantity;
    } else {
      _ownedShips[type] = 0;
    }
  }
}

mixin Planets {
  List<Planet> _planets;

  planetsInit(List<Planet> planets) {
    _planets = planets;
  }
  
  List<Planet> get planets{
    return _planets;
  }
  int get planetsIncome {
    int income = 0;
    for (var planet in _planets) {
      income += planet.income;
    }
    return income;
  }

  planetAddShip({DefenseShipType type, PlanetName name, int quantity}) {
    _planets
        .firstWhere((planet) => planet.name == name)
        .defenseAddShip(type, quantity);
  }

  planetRemoveShip({DefenseShipType type, PlanetName name, int quantity}) {
    _planets
        .firstWhere((planet) => planet.name == name)
        .defenseRemoveShip(type, quantity);
  }

  planetAddUpgrade({UpgradeType type, PlanetName name}) {
    _planets.firstWhere((planet) => planet.name == name).upgradeBuy(type);
  }
  
  planetStats({PlanetName name}){
    return _planets.firstWhere((planet) => planet.name == name).stats;
  }
  int planetShipCount({DefenseShipType type, PlanetName name}) {
    return _planets
        .firstWhere((planet) => planet.name == name)
        .defenseShipCount(type);
  }
}
