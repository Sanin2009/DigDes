import 'package:flutter/material.dart';
import 'package:project/ui/common/widgets/user_profile_widget.dart';
import 'package:provider/provider.dart';

import '../navigation/app_navigator.dart';
import 'profile_view_model.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<ProfileViewModel>();
    var u = viewModel.user;
    return Scaffold(
      appBar: AppBar(
        leading: (u != null && viewModel.headers != null)
            ? IconButton(
                onPressed: viewModel.changePhoto,
                icon: const Icon(Icons.photo_camera))
            : null,
        title: Text(u == null ? "Hello!" : "Hello, ${u.name}"),
        actions: [
          const IconButton(
            icon: Icon(Icons.settings),
            onPressed: AppNavigator.toSettings,
          ),
          IconButton(
              icon: const Icon(Icons.exit_to_app), onPressed: viewModel.logout),
        ],
      ),
      body: (u != null) ? UserProfileWidget.create(u) : null,
    );
  }

  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ProfileViewModel(context: context),
      child: const Profile(),
    );
  }
}
