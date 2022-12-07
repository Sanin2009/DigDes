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
                AppNavigator.toApp();
              },
            ),
            if (centerVariants.contains(fabLocation)) const Spacer(),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                AppNavigator.toHome();
              },
            )
          ],
        ));
  }
}
