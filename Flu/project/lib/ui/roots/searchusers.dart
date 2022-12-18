import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/user.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_storage.dart';
import '../common/bottom_app_bar_widget.dart';

class _ViewModelState {
  final String? search;
  const _ViewModelState({
    this.search,
  });

  _ViewModelState copyWith({
    String? search,
  }) {
    return _ViewModelState(
      search: search ?? this.search,
    );
  }
}

class _ViewModel extends ChangeNotifier {
  BuildContext context;
  var searchUserTec = TextEditingController();

  var _state = const _ViewModelState();
  _ViewModelState get state => _state;
  set state(_ViewModelState val) {
    _state = val;
    notifyListeners();
  }

  _ViewModel({required this.context}) {
    searchUserTec.addListener(() {
      state = state.copyWith(search: searchUserTec.text);
    });
  }

  User? _user;

  User? get user => _user;

  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  Map<String, String>? headers;

  void asyncInit() async {
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    user = await SharedPrefs.getStoredUser();
  }

  void search() async {
    //logic for searching
  }
}

class SearchUser extends StatelessWidget {
  const SearchUser({Key? key}) : super(key: key);
  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => _ViewModel(context: context),
      child: const SearchUser(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search for user"),
        actions: const [],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Column(
              children: [
                TextField(
                    controller: viewModel.searchUserTec,
                    decoration: const InputDecoration(hintText: "Username")),
                Card(
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      //search();
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBarMenu(
          fabLocation: FloatingActionButtonLocation.centerDocked),
    );
  }
}
