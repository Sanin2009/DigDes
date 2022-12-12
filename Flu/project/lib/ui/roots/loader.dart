import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../app_navigator.dart';

class _ViewModel extends ChangeNotifier {
  final _authService = AuthService();

  BuildContext context;
  _ViewModel({required this.context}) {
    _asyncInit();
  }

  void _asyncInit() async {
    if (await _authService.checkAuth()) {
      AppNavigator.toFeed();
    } else {
      AppNavigator.toAuth();
    }
  }
}

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  static Widget create() => ChangeNotifierProvider<_ViewModel>(
        create: (context) => _ViewModel(context: context),
        lazy: false,
        child: const LoaderWidget(),
      );
}
