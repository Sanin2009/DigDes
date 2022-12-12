import 'package:flutter/material.dart';
import 'package:project/ui/roots/searchpost.dart';
import 'package:project/ui/roots/searchusers.dart';
import 'package:project/ui/roots/settings.dart';

import 'roots/app.dart';
import 'roots/auth.dart';
import 'roots/home.dart';
import 'roots/loader.dart';

class NavigationRoutes {
  static const loaderWidget = "/";
  static const auth = "/auth";
  static const app = "/app";
  static const home = "/home";
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

  static void toApp() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.app, ((route) => false));
  }

  static void toHome() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.home, ((route) => false));
  }

  static void toSettings() {
    key.currentState?.pushNamed(NavigationRoutes.settings);
  }

  static void toSearchUser() {
    key.currentState?.pushNamedAndRemoveUntil(
        NavigationRoutes.searchuser, ((route) => false));
  }

  static void toSearchPost() {
    key.currentState?.pushNamedAndRemoveUntil(
        NavigationRoutes.searchpost, ((route) => false));
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
      case NavigationRoutes.app:
        return PageRouteBuilder(pageBuilder: ((_, __, ___) => App.create()));
      case NavigationRoutes.home:
        return PageRouteBuilder(pageBuilder: ((_, __, ___) => Home.create()));
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
