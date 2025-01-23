import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/museum_page.dart';
import 'pages/setting_page.dart';

// 全局主题颜色，方便后续修改
const Color kPrimaryColor = Color(0xFF90C9A6);  // 淡绿色

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '博物馆',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          primary: kPrimaryColor,
          background: Colors.white,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: kPrimaryColor.withOpacity(0.1),
          indicatorColor: kPrimaryColor.withOpacity(0.2),
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: kPrimaryColor.withOpacity(0.2),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MuseumPage(),
    const SettingPage(),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '主页',
          ),
          NavigationDestination(
            icon: Icon(Icons.museum_outlined),
            selectedIcon: Icon(Icons.museum),
            label: '展品',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
