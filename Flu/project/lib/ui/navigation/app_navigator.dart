import 'package:flutter/material.dart';
import 'package:project/ui/common/create_post.dart';
import 'package:project/ui/roots/register.dart';
import 'package:project/ui/common/settings.dart';

import '../../domain/enums/tab_item.dart';
import '../roots/main_app.dart';
import '../roots/auth.dart';
import '../roots/loader.dart';

class NavigationRoutes {
  static const loaderWidget = "/";
  static const auth = "/auth";
  static const register = "/auth/register";
  static const settings = "/settings";
  static const createpost = "/createpost";
  static const app = "/app";
}

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();

  static final navigationKeys = {
    TabItemEnum.feed: GlobalKey<NavigatorState>(),
    TabItemEnum.searchUser: GlobalKey<NavigatorState>(),
    TabItemEnum.searchPost: GlobalKey<NavigatorState>(),
    TabItemEnum.allPosts: GlobalKey<NavigatorState>(),
    TabItemEnum.profile: GlobalKey<NavigatorState>(),
  };

  static Future toLoader() async {
    return key.currentState?.pushNamedAndRemoveUntil(
        NavigationRoutes.loaderWidget, ((route) => false));
  }

  static void toAuth() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.auth, ((route) => false));
  }

  static Future toApp() async {
    return await key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.app, ((route) => false));
  }

  static void toCreatePost() {
    key.currentState?.pushNamed(NavigationRoutes.createpost);
  }

  static void toRegister() {
    key.currentState?.pushNamed(
      NavigationRoutes.register,
    );
  }

  static void toSettings() {
    key.currentState?.pushNamed(NavigationRoutes.settings);
  }

  static void toBack() {
    key.currentState?.pop();
  }

  static Route<dynamic>? onGeneratedRoutes(RouteSettings settings, context) {
    switch (settings.name) {
      case NavigationRoutes.loaderWidget:
        return PageRouteBuilder(
            pageBuilder: ((_, __, ___) => LoaderWidget.create()));
      case NavigationRoutes.auth:
        return PageRouteBuilder(pageBuilder: ((_, __, ___) => Auth.create()));
      case NavigationRoutes.register:
        return PageRouteBuilder(
            pageBuilder: ((_, __, ___) => Register.create()));
      case NavigationRoutes.createpost:
        return PageRouteBuilder(
            pageBuilder: ((_, __, ___) => CreatePost.create()));
      case NavigationRoutes.settings:
        return PageRouteBuilder(
            pageBuilder: ((_, __, ___) => Settings.create()));
      case NavigationRoutes.app:
        return PageRouteBuilder(pageBuilder: (_, __, ___) => App.create());
    }
    return null;
  }
}
