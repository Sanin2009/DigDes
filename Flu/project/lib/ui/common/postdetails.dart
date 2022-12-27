import 'package:flutter/material.dart';
import 'package:project/domain/models/post.dart';
import 'package:provider/provider.dart';

import '../../internal/config/app_config.dart';
import 'helper.dart';

class _ViewModel extends ChangeNotifier {
  BuildContext context;
  final ShowPost post;
  _ViewModel({required this.context, required this.post});
}

class PostDetail extends StatelessWidget {
  const PostDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: const EdgeInsets.all(10),
          height: (viewModel.post.showPostModel.attaches!.isNotEmpty)
              ? size.width + 150
              : 120,
          color: Colors.white,
          child: Column(
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
              Expanded(
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
              Text("Comments (${viewModel.post.showPostModel.totalComments}):")
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
