import 'package:flutter/material.dart';
import 'package:project/ui/common/screens/user_profile.dart';

import '../../domain/enums/tab_item.dart';
import '../common/screens/postdetails.dart';

class TabNavigatorRoutes {
  static const String root = '/app/';
  static const String postDetails = "/app/postDetails";
  static const String userProfile = "/app/userProfile";
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItemEnum tabItem;
  const TabNavigator({
    Key? key,
    required this.navigatorKey,
    required this.tabItem,
  }) : super(key: key);

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
          {Object? arg}) =>
      {
        TabNavigatorRoutes.root: (context) =>
            TabEnums.tabRoots[tabItem] ??
            SafeArea(
              child: Text(tabItem.name),
            ),
        TabNavigatorRoutes.postDetails: (context) => PostDetail.create(arg),
        TabNavigatorRoutes.userProfile: (context) => UserProfile.create(arg),
      };

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (settings) {
        var rb = _routeBuilders(context, arg: settings.arguments);
        if (rb.containsKey(settings.name)) {
          return MaterialPageRoute(
              builder: (context) => rb[settings.name]!(context));
        }
        return null;
      },
    );
  }
}
