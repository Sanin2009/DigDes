import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project/domain/models/post.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../internal/dependencies/repository_module.dart';
import '../app_navigator.dart';
import '../common/cam_widget.dart';

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
  var postImages = <Metadatum>[];
  final _api = RepositoryModule.apiRepository();
  String? _imagePath;

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

  // ToDo 50%
  void createPost() async {
    state = state.copyWith(isLoading: true);
    var newPost = CreatePostModel(
        title: state.title ?? " ",
        tags: state.tags ?? " ",
        metadata: postImages);
    try {
      await _api.createPost(newPost);
      AppNavigator.toBack();
    } on NoNetworkException {
      state = state.copyWith(errorText: "нет сети");
    } on ServerException {
      state = state.copyWith(errorText: "произошла ошибка на сервере");
    }
  }

  Future addPhoto() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (newContext) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: SafeArea(
          child: CamWidget(
            onFile: (file) {
              _imagePath = file.path;
              Navigator.of(newContext).pop();
            },
          ),
        ),
      ),
    ));
    if (_imagePath != null) {
      var t = await _api.uploadTemp(files: [File(_imagePath!)]);
      if (t.isNotEmpty) postImages.add(t[0]);
      notifyListeners();
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
                    viewModel.addPhoto();
                  },
                ),
                Text("Images attached:${viewModel.postImages.length}"),
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
