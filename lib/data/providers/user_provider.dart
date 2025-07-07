import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String id = "1234";

  void getId() => notifyListeners();
}
