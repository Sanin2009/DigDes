import 'package:flutter/material.dart';
import 'package:project/domain/enums/user_list.dart';
import 'package:project/ui/common/widgets/user_list_widget.dart';
import 'package:provider/provider.dart';

import '../../domain/models/user.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_storage.dart';
import '../../internal/dependencies/repository_module.dart';

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
  final _api = RepositoryModule.apiRepository();

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

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  User? _user;
  User? get user => _user;
  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  Map<String, String>? headers;

  List<User>? _users;
  List<User>? get users => _users;
  set users(List<User>? val) {
    _users = val;
    notifyListeners();
  }

  void asyncInit() async {
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    user = await SharedPrefs.getStoredUser();
  }

  void search() async {
    isLoading = true;
    users = await _api.searchUsers(searchUserTec.text);
    isLoading = false;
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
    var size = MediaQuery.of(context).size;
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
                      viewModel.search();
                    },
                  ),
                ),
                viewModel.users == null
                    ? const Center(child: Text(""))
                    : SizedBox(
                        width: size.width,
                        height: 500,
                        child: UserListWidget(
                            viewModel.users, UserListTypeEnum.look)),
                if (viewModel.isLoading) const LinearProgressIndicator()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
