import 'package:example/sample1.dart';
import 'package:example/sample2.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eChartFlutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF262626),
          centerTitle: true,
          elevation: 1,
          scrolledUnderElevation: 0,
        ),
        indicatorColor: const Color(0xFF0C00C5),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.black,
        ),
        primaryColor: const Color(0xFF0C00C5),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              const Color(0xFF0C00C5),
            ),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE5E5E5),
          thickness: 1,
          space: 0,
          indent: 0,
          endIndent: 0,
        ),
      ),
      home: const _MyHomePage(title: 'eChart Flutter'),
    );
  }
}

class _MyHomePage extends StatelessWidget {
  const _MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(
                  text: 'Sample 1',
                ),
                Tab(
                  text: 'Sample 2',
                ),
              ],
            ),
          ),
          body: const TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Center(child: Sample1()),
                Center(
                  child: Sample2(),
                ),
              ]),
        ));
  }
}
