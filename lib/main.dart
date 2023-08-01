import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moli_ai/constants/color_constants.dart';
import 'package:moli_ai/providers/default_privider.dart';
import 'package:moli_ai/providers/diary_privider.dart';
import 'package:moli_ai/screens/diary/diary_list_screen.dart';
import 'package:provider/provider.dart';

import 'package:moli_ai/constants/constants.dart';

import 'models/config_model.dart';
import 'repositories/configretion/config_repo.dart';
import 'repositories/datebase/client.dart';
import 'providers/palm_priovider.dart';
import 'screens/conversation/conversation_screen.dart';
import 'screens/conversation/conversation_list_screen.dart';
import 'screens/settings/setting_screen.dart';
import 'widgets/navigation/disappearing_bottom_navigation_bar.dart';
import 'widgets/navigation/disappearing_navigation_rail.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the database
  await dbClient.init();
  runApp(const MoliAIApp());
}

class MoliAIApp extends StatefulWidget {
  const MoliAIApp({super.key});

  @override
  State<MoliAIApp> createState() => _MoliAIAppState();
}

class _MoliAIAppState extends State<MoliAIApp> {
  Map<String, ConfigModel> _configMap = {};
  String themeName = "";
  String darkMode = "";
  ThemeData lightTheme = blumineBlueLight;
  ThemeData darkTheme = blumineBlueDark;

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  ThemeMode _getThemeDarkMode(
      DefaultSettingProvider defaultProvider, String selectedDarkMode) {
    var isDarkMode = defaultProvider.isDark;
    if (defaultProvider.darkMode != "") {
      selectedDarkMode = defaultProvider.darkMode;
    }
    if (selectedDarkMode == darkModeDark) {
      isDarkMode = true;
    } else if (selectedDarkMode == darkModeLight) {
      isDarkMode = false;
    } else {
      isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Map<String, ThemeData> _getThemeInfo(
      DefaultSettingProvider defaultProvider, String themeName) {
    if (defaultProvider.themeName != "") {
      themeName = defaultProvider.themeName;
    }
    Map<String, ThemeData>? theme = themesMap[themeName];
    if (theme != null) {
      return theme;
    }
    return <String, ThemeData>{
      darkModeLight: blumineBlueLight,
      darkModeDark: blumineBlueDark
    };
  }

  void _initConfig() async {
    _configMap = await ConfigReop().getAllConfigsMap();

    ConfigModel? themeConf = _configMap[themeConfigname];
    if (themeConf != null) {
      final themeConfig = themeConf.toThemeConfig();
      themeName = themeConfig.themeName;
      darkMode = themeConfig.darkMode;
      log("themeConfig: $themeName, $darkMode");
      setState(() {
        themeName = themeConfig.themeName;
        darkMode = themeConfig.darkMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // dbClient.q();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AISettingProvider(),
        ),
        ChangeNotifierProvider(create: (context) => DiaryProvider()),
        ChangeNotifierProvider(create: (context) => DefaultSettingProvider()),
      ],
      child: Consumer<DefaultSettingProvider>(
        builder: (context, defaultProvider, child) {
          var themeMode = _getThemeDarkMode(defaultProvider, darkMode);
          var themeData = _getThemeInfo(defaultProvider, themeName);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeData[darkModeLight],
            darkTheme: themeData[darkModeDark],
            themeMode: themeMode,
            home: const RootPage(),
          );
        },
      ),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ConversationListScreen(),
    DiaryistScreen(),
    // PalmSettingScreen(),
    SettingScreen(),
  ];

  bool wideScreen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final double width = MediaQuery.of(context).size.width;
    wideScreen = width > 600;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (wideScreen)
            DisappearingNavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          Expanded(
            child: Container(
              child: _widgetOptions.elementAt(selectedIndex),
            ),
          ),
        ],
      ),
      floatingActionButton: wideScreen || selectedIndex != 0
          ? null
          : FloatingActionButton(
              heroTag: "newConversation",
              onPressed: () {
                _navigateToCreateNewConversation();
              },
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: wideScreen
          ? null
          : DisappearingBottomNavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
    );
  }

  void _navigateToCreateNewConversation() {
    final palmProvider = Provider.of<AISettingProvider>(context, listen: false);
    palmProvider.setCurrentConversationInfo(newConversation);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          conversationData: newConversation,
        ),
      ),
    );
  }
}
