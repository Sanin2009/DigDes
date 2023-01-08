import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/widgets/posts_view_model.dart';
import 'feed_view_model.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => FeedViewModel(context: context),
      child: const Feed(),
    );
  }

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<FeedViewModel>();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text("Feed"),
      ),
      body: Column(
        children: [
          viewModel.posts == null
              ? const Center(child: CircularProgressIndicator())
              : PostsViewModel.create(context, viewModel.posts),
          Row(children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                onPressed: () {
                  viewModel.refresh();
                },
                child: const Icon(Icons.refresh),
              ),
            ),
            const Spacer(),
            if (!viewModel.isLoading && !viewModel.isEnd)
              FloatingActionButton(
                onPressed: () {
                  viewModel.addPosts();
                },
                child: const Icon(Icons.h_plus_mobiledata),
              ),
          ]),
          if (viewModel.isLoading && !viewModel.isEnd)
            const LinearProgressIndicator()
        ],
      ),
    );
  }
}
