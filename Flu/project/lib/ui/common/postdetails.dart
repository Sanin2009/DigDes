import 'package:flutter/material.dart';
import 'package:project/domain/models/comment.dart';
import 'package:project/domain/models/post.dart';
import 'package:provider/provider.dart';

import '../../internal/config/app_config.dart';
import '../../internal/dependencies/repository_module.dart';
import 'helper.dart';

class _ViewModelState {
  final String? comment;
  const _ViewModelState({this.comment});
  _ViewModelState copyWith({String? comment}) {
    return _ViewModelState(comment: comment ?? this.comment);
  }
}

class _ViewModel extends ChangeNotifier {
  BuildContext context;
  ShowPost post;
  var commentTec = TextEditingController();
  final _api = RepositoryModule.apiRepository();

  var _state = const _ViewModelState();
  _ViewModelState get state => _state;
  set state(_ViewModelState val) {
    _state = val;
    notifyListeners();
  }

  bool checkFields() {
    return (state.comment?.isNotEmpty ?? false);
  }

  _ViewModel({required this.context, required this.post}) {
    commentTec.addListener(() {
      state = state.copyWith(comment: commentTec.text);
    });
    asyncInit();
  }

  List<ShowCommentModel>? _comments;
  List<ShowCommentModel>? get comments => _comments;
  set comments(List<ShowCommentModel>? val) {
    _comments = val;
    notifyListeners();
  }

  void addComment() async {
    await _api.addComment(post.showPostModel.id, commentTec.text);
    // post.showPostModel.totalComments++;
    commentTec.text = "";
    notifyListeners();
    comments = await _api.showComments(post.showPostModel.id);
    //TODO ???????
  }

  void asyncInit() async {
    comments = await _api.showComments(post.showPostModel.id);
  }
}

class PostDetail extends StatelessWidget {
  const PostDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    var itemCount = viewModel.comments?.length ?? 0;
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: const EdgeInsets.all(10),
          height: size.height,
          color: Colors.white,
          child: ListView(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(
                              "$baseUrl${viewModel.post.userModel.avatarLink}"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Text(
                        "${viewModel.post.userModel.name}: ${viewModel.post.showPostModel.name}"),
                  ),
                  Expanded(
                      flex: 2,
                      child: Text(
                          "${DateTime.parse(viewModel.post.showPostModel.created).day.toString()} of ${Helper.GetMonth(DateTime.parse(viewModel.post.showPostModel.created).month.toString())}"))
                ],
              ),
              SizedBox(
                height: (viewModel.post.showPostModel.attaches!.length == 0)
                    ? 20
                    : size.width,
                child: PageView.builder(
                  itemCount: viewModel.post.showPostModel.attaches!.length,
                  itemBuilder: (pageContext, pageIndex) => Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Image(
                              image: NetworkImage(
                            "$baseUrl${viewModel.post.showPostModel.attaches![pageIndex]}",
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.thumb_up),
                    label: Text("${viewModel.post.showPostModel.totalLikes}"),
                    onPressed: () {},
                  ),
                ],
              ),
              Text("Comments (${viewModel.post.showPostModel.totalComments}):"),
              SizedBox(
                  height: 200,
                  child: viewModel.comments == null
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Expanded(
                                child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemCount: itemCount,
                              itemBuilder: (listContext, listIndex) {
                                Widget res;
                                var comments = viewModel.comments;
                                if (comments != null) {
                                  var comment = comments[listIndex];
                                  res = Container(
                                    padding: const EdgeInsets.all(10),
                                    height: 100,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        "$baseUrl${comment.avatarLink}"),
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 8,
                                              child: Text(
                                                  "${comment.name}: ${comment.message}"),
                                            ),
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                    "${DateTime.parse(comment.created).day.toString()} of ${Helper.GetMonth(DateTime.parse(comment.created).month.toString())}, ${DateTime.parse(comment.created).hour.toString()}:${DateTime.parse(comment.created).minute.toString()} "))
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  res = const SizedBox.shrink();
                                }
                                return res;
                              },
                            )),
                          ],
                        )),
              TextField(
                controller: viewModel.commentTec,
                decoration: const InputDecoration(hintText: "Your comment"),
              ),
              ElevatedButton(
                  onPressed:
                      viewModel.checkFields() ? viewModel.addComment : null,
                  child: const Text("Add comment")),
            ],
          ),
        ));
  }

  static create(Object? arg) {
    ShowPost post;
    if (arg != null && arg is ShowPost) {
      post = arg;
    } else {
      throw Exception();
    }
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          _ViewModel(context: context, post: post),
      child: const PostDetail(),
    );
  }
}
