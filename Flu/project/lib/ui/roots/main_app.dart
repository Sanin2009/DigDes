import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/enums/tab_item.dart';
import '../../domain/models/user.dart';
import '../../internal/config/app_config.dart';
import '../../internal/config/shared_prefs.dart';
import '../common/widgets/bottom_app_bar_tabs.dart';
import '../navigation/app_navigator.dart';
import '../navigation/tab_navigator.dart';

class AppViewModel extends ChangeNotifier {
  BuildContext context;
  AppViewModel({required this.context}) {
    asyncInit();
  }

  var _currentTab = TabEnums.defTab;
  TabItemEnum? beforeTab;
  TabItemEnum get currentTab => _currentTab;
  void selectTab(TabItemEnum tabItemEnum) {
    if (tabItemEnum == _currentTab) {
      AppNavigator.navigationKeys[tabItemEnum]!.currentState!
          .popUntil((route) => route.isFirst);
    } else {
      beforeTab = _currentTab;
      _currentTab = tabItemEnum;
      notifyListeners();
    }
  }

  User? _user;
  User? get user => _user;
  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  String? _msg;
  String? get msg => _msg;
  set msg(String? val) {
    _msg = val;
    if (val != null) {
      showSnackBar(val);
    }
    notifyListeners();
  }

  Image? _avatar;
  Image? get avatar => _avatar;
  set avatar(Image? val) {
    _avatar = val;
    notifyListeners();
  }

  void asyncInit() async {
    user = await SharedPrefs.getStoredUser();
    var img = await NetworkAssetBundle(Uri.parse("$baseUrl${user!.avatarLink}"))
        .load("$baseUrl${user!.avatarLink}");
    avatar = Image.memory(
      img.buffer.asUint8List(),
      fit: BoxFit.fill,
    );
  }

  showSnackBar(String text) {
    var sb = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(sb);
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<AppViewModel>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
          onWillPop: () async {
            var isFirstRouteInCurrentTab = !await AppNavigator
                .navigationKeys[viewModel.currentTab]!.currentState!
                .maybePop();
            if (isFirstRouteInCurrentTab) {
              if (viewModel.currentTab != TabEnums.defTab) {
                viewModel.selectTab(TabEnums.defTab);
              }
              return false;
            }
            return isFirstRouteInCurrentTab;
          },
          child: Scaffold(
            bottomNavigationBar: BottomTabs(
              currentTab: viewModel.currentTab,
              onSelectTab: viewModel.selectTab,
            ),
            body: Stack(
                children: TabItemEnum.values
                    .map((e) => _buildOffstageNavigator(context, e))
                    .toList()),
          )),
    );
  }

  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => AppViewModel(context: context),
      child: const App(),
    );
  }

  Widget _buildOffstageNavigator(BuildContext context, TabItemEnum tabItem) {
    var viewModel = context.watch<AppViewModel>();

    return Offstage(
      offstage: viewModel.currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: AppNavigator.navigationKeys[tabItem]!,
        tabItem: tabItem,
      ),
    );
  }
}
