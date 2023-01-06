import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/post.dart';
import '../../domain/models/user.dart';
import '../../internal/dependencies/repository_module.dart';
import '../common/widgets/posts_view_model.dart';

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
  var searchPostTec = TextEditingController();

  final _api = RepositoryModule.apiRepository();

  int skip = 0;
  int take = 10;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  bool _isEnd = true;
  bool get isEnd => _isEnd;
  set isEnd(bool val) {
    _isEnd = val;
    notifyListeners();
  }

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;
  set isRefreshing(bool val) {
    _isRefreshing = val;
    notifyListeners();
  }

  var _state = const _ViewModelState();
  _ViewModelState get state => _state;
  set state(_ViewModelState val) {
    _state = val;
    isEnd = true;
    notifyListeners();
  }

  _ViewModel({required this.context}) {
    posts = null;
    searchPostTec.addListener(() {
      state = state.copyWith(search: searchPostTec.text);
    });
  }

  User? _user;
  User? get user => _user;
  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  List<ShowPost>? newPosts;

  List<ShowPost>? _posts;
  List<ShowPost>? get posts => _posts;
  set posts(List<ShowPost>? val) {
    _posts = val;
    notifyListeners();
  }

  void addPosts(String tag) async {
    isLoading = true;
    newPosts = await _api.getPostsByTag(tag, skip, take);
    skip += 10;
    if (newPosts == null || newPosts!.isEmpty) {
      isEnd = true;
      return;
    }
    posts = <ShowPost>[...posts!, ...newPosts!];
    isLoading = false;
  }

  void search(String tag) async {
    isLoading = true;
    skip = 0;
    take = 10;
    posts = await _api.getPostsByTag(tag, skip, take);
    skip += 10;
    isLoading = false;
    isEnd = false;
  }
}

class SearchPost extends StatelessWidget {
  const SearchPost({Key? key}) : super(key: key);
  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => _ViewModel(context: context),
      child: const SearchPost(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search for posts"),
        actions: const [],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Column(
              children: [
                TextField(
                    controller: viewModel.searchPostTec,
                    decoration: const InputDecoration(hintText: "tag")),
                Card(
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      viewModel.search(viewModel.searchPostTec.text);
                    },
                  ),
                ),
                viewModel.posts == null
                    ? const Center(child: Text(""))
                    : SizedBox(
                        width: size.width,
                        height: 500,
                        child: PostsViewModel.create(context, viewModel.posts),
                      ),
                Row(children: [
                  const Spacer(),
                  if (!viewModel.isLoading && !viewModel.isEnd)
                    FloatingActionButton(
                      onPressed: () {
                        viewModel.addPosts(viewModel.searchPostTec.text);
                      },
                      child: const Icon(Icons.h_plus_mobiledata),
                    ),
                ]),
                if (viewModel.isLoading && !viewModel.isEnd)
                  const LinearProgressIndicator()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
