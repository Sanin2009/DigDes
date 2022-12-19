import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../app_navigator.dart';

class _ViewModelState {
  final String? title;
  final String? tags;
  final bool isLoading;
  final String? errorText;
  const _ViewModelState({
    this.title,
    this.tags,
    this.isLoading = false,
    this.errorText,
  });
  _ViewModelState copyWith({
    String? title,
    String? tags,
    bool? isLoading = false,
    String? errorText,
  }) {
    return _ViewModelState(
        title: title ?? this.title,
        tags: tags ?? this.tags,
        isLoading: isLoading ?? this.isLoading,
        errorText: errorText ?? this.errorText);
  }
}

class _ViewModel extends ChangeNotifier {
  var titleTec = TextEditingController();
  var tagTec = TextEditingController();
  final _authService = AuthService();

  BuildContext context;
  _ViewModel({required this.context}) {
    titleTec.addListener(() {
      state = state.copyWith(title: titleTec.text);
    });
    tagTec.addListener(() {
      state = state.copyWith(tags: tagTec.text);
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
    return (state.title?.isNotEmpty ?? false) &&
        (state.tags?.isNotEmpty ?? false);
  }

  // ToDo 0%
  void createPost() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.auth(state.title, state.tags).then((value) {
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

class CreatePost extends StatelessWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a Post"),
        actions: const [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: (() => AppNavigator.toBack()),
                    child: const Text("Back")),
                TextField(
                  controller: viewModel.titleTec,
                  decoration: const InputDecoration(hintText: "Title"),
                ),
                TextField(
                  controller: viewModel.tagTec,
                  decoration: const InputDecoration(
                      hintText: "Insert tags separated by spaces"),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_camera_back),
                  onPressed: () {
                    //ToDo;
                  },
                ),
                ElevatedButton(
                    onPressed:
                        viewModel.checkFields() ? viewModel.createPost : null,
                    child: const Text("Create Post")),
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
        child: const CreatePost(),
      );
}