import 'package:upgrader/upgrader.dart';

class MyUpgraderMessages extends UpgraderMessages {
  @override
  String get buttonTitleUpdate => 'Opdater';
  String get body => 'En ny version af Vikarly er tilgængelig.';
  String get prompt => 'Du bedes opdatere nu.';
  String get title => 'Ny opdatering';
}