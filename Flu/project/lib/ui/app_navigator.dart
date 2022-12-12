import 'package:flutter/material.dart';
import 'package:project/ui/roots/searchpost.dart';
import 'package:project/ui/roots/searchusers.dart';
import 'package:project/ui/roots/settings.dart';

import 'roots/profile.dart';
import 'roots/auth.dart';
import 'roots/feed.dart';
import 'roots/loader.dart';

class NavigationRoutes {
  static const loaderWidget = "/";
  static const auth = "/auth";
  static const profile = "/profile";
  static const feed = "/feed";
  static const settings = "/settings";
  static const searchuser = "/searchuser";
  static const searchpost = "/searchpost";
}

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();

  static Future toLoader() async {
    return key.currentState?.pushNamedAndRemoveUntil(
        NavigationRoutes.loaderWidget, ((route) => false));
  }

  static void toAuth() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.auth, ((route) => false));
  }

  static void toProfile() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.feed, ((route) => false));
    key.currentState?.pushNamed(NavigationRoutes.profile);
  }

  static void toFeed() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.feed, ((route) => false));
  }

  static void toSettings() {
    key.currentState?.pushNamed(NavigationRoutes.settings);
  }

  static void toSearchUser() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.feed, ((route) => false));
    key.currentState?.pushNamed(NavigationRoutes.searchuser);
  }

  static void toSearchPost() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.feed, ((route) => false));
    key.currentState?.pushNamed(NavigationRoutes.searchpost);
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
      case NavigationRoutes.profile:
        return PageRouteBuilder(
            pageBuilder: ((_, __, ___) => Profile.create()));
      case NavigationRoutes.feed:
        return PageRouteBuilder(pageBuilder: ((_, __, ___) => Feed.create()));
      case NavigationRoutes.settings:
        return PageRouteBuilder(
            pageBuilder: ((_, __, ___) => Settings.create()));
      case NavigationRoutes.searchuser:
        return PageRouteBuilder(
            pageBuilder: ((_, __, ___) => SearchUser.create()));
      case NavigationRoutes.searchpost:
        return PageRouteBuilder(
            pageBuilder: ((_, __, ___) => SearchPost.create()));
    }
    return null;
  }
}
