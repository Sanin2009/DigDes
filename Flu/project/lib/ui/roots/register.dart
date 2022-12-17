import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../app_navigator.dart';

class _ViewModelState {
  final String? login;
  final String? password;
  final bool isLoading;
  final String? errorText;
  final String? passwordAgain;
  final String? name;
  final String? birthday;
  const _ViewModelState(
      {this.login,
      this.password,
      this.isLoading = false,
      this.errorText,
      this.name,
      this.passwordAgain,
      this.birthday});

  _ViewModelState copyWith({
    String? login,
    String? password,
    String? passwordAgain,
    String? name,
    String? birthday,
    bool? isLoading = false,
    String? errorText,
  }) {
    return _ViewModelState(
        login: login ?? this.login,
        password: password ?? this.password,
        isLoading: isLoading ?? this.isLoading,
        errorText: errorText ?? this.errorText,
        passwordAgain: passwordAgain ?? this.passwordAgain,
        name: name ?? this.name,
        birthday: birthday ?? this.birthday);
  }
}

class _ViewModel extends ChangeNotifier {
  var loginTec = TextEditingController();
  var nameTec = TextEditingController();
  var passwTec = TextEditingController();
  var passagainTec = TextEditingController();
  var bdayTec = TextEditingController();
  final _authService = AuthService();

  BuildContext context;
  _ViewModel({required this.context}) {
    loginTec.addListener(() {
      state = state.copyWith(login: loginTec.text);
    });
    passwTec.addListener(() {
      state = state.copyWith(password: passwTec.text);
    });
    passagainTec.addListener(() {
      state = state.copyWith(passwordAgain: passagainTec.text);
    });
    nameTec.addListener(() {
      state = state.copyWith(name: nameTec.text);
    });
    bdayTec.addListener(() {
      state = state.copyWith(birthday: bdayTec.text);
    });
  }

  var _state = const _ViewModelState();
  _ViewModelState get state => _state;
  set state(_ViewModelState val) {
    _state = val;
    notifyListeners();
  }

  //ToDo 50%
  bool checkFields() {
    return (state.login?.isNotEmpty ?? false) &&
        (state.password?.isNotEmpty ?? false) &&
        (state.passwordAgain?.isNotEmpty ?? false) &&
        (state.name?.isNotEmpty ?? false) &&
        (state.birthday?.isNotEmpty ?? false);
  }

  // ToDo 0%
  void register() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.auth(state.login, state.password).then((value) {
        AppNavigator.toLoader()
            .then((value) => {state = state.copyWith(isLoading: false)});
      });
    } on NoNetworkException {
      state = state.copyWith(errorText: "нет сети");
    } on ServerException {
      state = state.copyWith(errorText: "произошла ошибка на сервере");
    }
  }
}

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: (() => AppNavigator.toAuth()),
                    child: const Text("Back")),
                TextField(
                  controller: viewModel.loginTec,
                  decoration: const InputDecoration(hintText: "Login"),
                ),
                TextField(
                  controller: viewModel.nameTec,
                  decoration: const InputDecoration(hintText: "Display Name"),
                ),
                TextField(
                  controller: viewModel.bdayTec,
                  decoration: const InputDecoration(
                      hintText: "Birthday, format dd.mm.yyyy"),
                ),
                TextField(
                    controller: viewModel.passwTec,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: "Password")),
                TextField(
                    controller: viewModel.passagainTec,
                    obscureText: true,
                    decoration:
                        const InputDecoration(hintText: "Password again")),
                ElevatedButton(
                    onPressed:
                        viewModel.checkFields() ? viewModel.register : null,
                    child: const Text("Register")),
                if (viewModel.state.isLoading)
                  const CircularProgressIndicator(),
                if (viewModel.state.errorText != null)
                  Text(viewModel.state.errorText!)
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget create() => ChangeNotifierProvider<_ViewModel>(
        create: (context) => _ViewModel(context: context),
        child: const Register(),
      );
}