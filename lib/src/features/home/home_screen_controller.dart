import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeScreenControllerProvider =
    StateNotifierProvider.autoDispose<HomeScreenController, int>(
  (ref) => HomeScreenController(),
  name: 'HomeScreenControllerProvider',
);

class HomeScreenController extends StateNotifier<int> {
  HomeScreenController() : super(0);

  void setActiveScreen(int index) {
    state = index;
  }
}
