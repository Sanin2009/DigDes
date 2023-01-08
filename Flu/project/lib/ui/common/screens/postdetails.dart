import 'package:flutter/material.dart';
import 'package:project/domain/models/comment.dart';
import 'package:project/domain/models/post.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/user.dart';
import '../../../internal/config/app_config.dart';
import '../../../internal/config/shared_prefs.dart';
import '../../../internal/dependencies/repository_module.dart';
import '../../navigation/tab_navigator.dart';
import '../helper.dart';

class _ViewModelState {
  final String? comment;
  const _ViewModelState({this.comment});
  _ViewModelState copyWith({String? comment}) {
    return _ViewModelState(comment: comment ?? this.comment);
  }
}

class _ViewModel extends ChangeNotifier {
  final BuildContext context;
  ShowPost post;

  var commentTec = TextEditingController();
  final _api = RepositoryModule.apiRepository();

  var _state = const _ViewModelState();
  _ViewModelState get state => _state;
  set state(_ViewModelState val) {
    _state = val;
    notifyListeners();
  }

  User? _user;
  User? get user => _user;
  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  bool? _isLiked;
  bool? get isLiked => _isLiked;
  set isLiked(bool? val) {
    _isLiked = val;
    notifyListeners();
  }

  int? _totalLikes;
  int? get totalLikes => _totalLikes;
  set totalLikes(int? val) {
    _totalLikes = val;
    notifyListeners();
  }

  bool checkFields() {
    return (state.comment?.isNotEmpty ?? false);
  }

  void updateLike(String postId) async {
    await _api.updateLike(postId);
    if (isLiked ?? false) {
      isLiked = false;
      int t = totalLikes ?? 1;
      t--;
      totalLikes = t;
    } else {
      isLiked = true;
      int t = totalLikes ?? 0;
      t++;
      totalLikes = t;
    }
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

  Future addComment() async {
    await _api.addComment(post.showPostModel.id, commentTec.text);
    commentTec.text = "";
    comments = await _api.showComments(post.showPostModel.id);
  }

  Future deleteComment(String commentId) async {
    await _api.deleteComment(commentId);
    comments = await _api.showComments(post.showPostModel.id);
  }

  Future editComment(String commentId, String msg) async {
    await _api.editComment(commentId, msg);
    comments = await _api.showComments(post.showPostModel.id);
  }

  void toUserProfile(String userid) async {
    var newuser = await _api.getUserById(userid);
    if (newuser != null) toUserProfileNavigation(newuser);
  }

  void toUserProfileByName(String name) async {
    var newuser = await _api.getUserByName(name);
    if (newuser != null) toUserProfileNavigation(newuser);
  }

  void toUserProfileNavigation(User user) {
    Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.userProfile, arguments: user);
  }

  void asyncInit() async {
    user = await SharedPrefs.getStoredUser();
    isLiked = post.showPostModel.likedByMe;
    totalLikes = post.showPostModel.totalLikes;
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
                  GestureDetector(
                    child: Container(
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
                    onTap: () {
                      viewModel.toUserProfile(viewModel.post.userModel.id);
                    },
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
                height: (viewModel.post.showPostModel.attaches!.isEmpty)
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
                    icon: Icon(Icons.thumb_up,
                        color: (viewModel.isLiked ?? false
                            ? Colors.black
                            : Colors.green)),
                    label: Text("${viewModel.totalLikes}"),
                    onPressed: () {
                      viewModel.updateLike(viewModel.post.showPostModel.id);
                    },
                  ),
                ],
              ),
              Text(
                  "Comments (${viewModel.comments?.length ?? viewModel.post.showPostModel.totalComments}):"),
              SizedBox(
                  height: ((viewModel.comments?.length ?? 0) > 2) ? 200 : 75,
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
                                    height: 75,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            GestureDetector(
                                              child: Container(
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
                                              onTap: () {
                                                viewModel.toUserProfileByName(
                                                    comment.name);
                                              },
                                            ),
                                            Expanded(
                                              flex: 8,
                                              child: Text(
                                                  "${comment.name}: ${comment.message}"),
                                            ),
                                            if ((viewModel.user?.name) ==
                                                comment.name)
                                              Expanded(
                                                flex: 1,
                                                child: IconButton(
                                                  icon: const Icon(Icons.edit),
                                                  onPressed: () {
                                                    var commentTec =
                                                        TextEditingController();
                                                    commentTec.text =
                                                        comment.message;
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                                title: const Text(
                                                                    "Edit comment"),
                                                                content:
                                                                    TextField(
                                                                  controller:
                                                                      commentTec,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                          hintText:
                                                                              "your comment"),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (commentTec.text ==
                                                                            "") {
                                                                          viewModel
                                                                              .deleteComment(comment.id);
                                                                        } else {
                                                                          viewModel.editComment(
                                                                              comment.id,
                                                                              commentTec.text);
                                                                        }
                                                                        // TODO
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: const Text(
                                                                          "Edit")),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: const Text(
                                                                          "Cancel")),
                                                                ]));
                                                  },
                                                ),
                                              ),
                                            if ((viewModel.user?.id) ==
                                                    viewModel
                                                        .post.userModel.id ||
                                                (viewModel.user?.name) ==
                                                    comment.name)
                                              Expanded(
                                                flex: 1,
                                                child: IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () {
                                                    viewModel.deleteComment(
                                                        comment.id);
                                                  },
                                                ),
                                              ),
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                    "${DateTime.parse(comment.created).day.toString()} of ${Helper.GetMonth(DateTime.parse(comment.created).month.toString())}, ${DateTime.parse(comment.created).hour.toString()}:${(DateTime.parse(comment.created).minute.toInt() > 9) ? DateTime.parse(comment.created).minute.toString() : "0${DateTime.parse(comment.created).minute}"} "))
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
