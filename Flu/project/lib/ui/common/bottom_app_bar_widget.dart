import 'package:flutter/material.dart';

import '../app_navigator.dart';

class BottomAppBarMenu extends StatelessWidget {
  BottomAppBarMenu({
    super.key,
    required this.fabLocation,
    this.shape,
  });

  final FloatingActionButtonLocation fabLocation;

  final NotchedShape? shape;

  final List<FloatingActionButtonLocation> centerVariants = [
    FloatingActionButtonLocation.centerDocked,
    FloatingActionButtonLocation.centerFloat,
  ];
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        shape: shape,
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                AppNavigator.toProfile();
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                AppNavigator.toFeed();
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                AppNavigator.toSearchUser();
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.file_copy),
              onPressed: () {
                AppNavigator.toSearchPost();
              },
            )
          ],
        ));
  }
}
