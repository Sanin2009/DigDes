import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/enums/tab_item.dart';
import '../roots/main_app.dart';

class BottomTabs extends StatelessWidget {
  final TabItemEnum currentTab;
  final ValueChanged<TabItemEnum> onSelectTab;
  const BottomTabs(
      {Key? key, required this.currentTab, required this.onSelectTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appModel = context.watch<AppViewModel>();
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.grey,
      currentIndex: TabItemEnum.values.indexOf(currentTab),
      items: TabItemEnum.values.map((e) => _buildItem(e, appModel)).toList(),
      onTap: (value) {
        FocusScope.of(context).unfocus();
        onSelectTab(TabItemEnum.values[value]);
      },
    );
  }

  BottomNavigationBarItem _buildItem(
      TabItemEnum tabItem, AppViewModel appmodel) {
    var isCurrent = currentTab == tabItem;
    var color = isCurrent ? Colors.grey[600] : Colors.grey[400];
    Widget icon = Icon(
      TabEnums.tabIcon[tabItem],
      size: isCurrent ? 26 : 22,
      color: color,
    );
    if (tabItem == TabItemEnum.profile) {
      icon = CircleAvatar(
        maxRadius: isCurrent ? 14 : 10,
        backgroundImage: appmodel.avatar?.image,
      );
    }
    String itemLabel = "";
    if (tabItem == TabItemEnum.profile) itemLabel = "Profile";
    if (tabItem == TabItemEnum.allPosts) itemLabel = "Posts";
    if (tabItem == TabItemEnum.feed) itemLabel = "Feed";
    if (tabItem == TabItemEnum.searchUser) itemLabel = "User search";
    if (tabItem == TabItemEnum.searchPost) itemLabel = "Post search";
    return BottomNavigationBarItem(
        label: itemLabel,
        backgroundColor: isCurrent ? Colors.grey : Colors.transparent,
        icon: icon);
  }
}
