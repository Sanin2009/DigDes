import 'package:flutter/material.dart';
import 'package:project/ui/tab_allposts/allposts.dart';
import 'package:project/ui/tab_feed/feed.dart';
import 'package:project/ui/tab_searchpost/searchpost.dart';
import 'package:project/ui/tab_searchuser/searchusers.dart';

import '../../ui/tab_profile/profile.dart';

enum TabItemEnum { feed, searchUser, allPosts, searchPost, profile }

class TabEnums {
  static const TabItemEnum defTab = TabItemEnum.profile;

  static Map<TabItemEnum, IconData> tabIcon = {
    TabItemEnum.feed: Icons.home_outlined,
    TabItemEnum.searchUser: Icons.search_outlined,
    TabItemEnum.allPosts: Icons.list,
    TabItemEnum.searchPost: Icons.search,
    TabItemEnum.profile: Icons.person_outline,
  };

  static Map<TabItemEnum, String> tabLabel = {
    TabItemEnum.feed: "Feed",
    TabItemEnum.searchUser: "User search",
    TabItemEnum.allPosts: "All posts",
    TabItemEnum.searchPost: "Post search",
    TabItemEnum.profile: "Profile",
  };

  static Map<TabItemEnum, Widget> tabRoots = {
    TabItemEnum.feed: Feed.create(),
    TabItemEnum.profile: Profile.create(),
    TabItemEnum.searchPost: SearchPost.create(),
    TabItemEnum.searchUser: SearchUser.create(),
    TabItemEnum.allPosts: AllPosts.create()
  };
}
