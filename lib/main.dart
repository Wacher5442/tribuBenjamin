import 'dart:convert';

import 'package:Benjamin/app/features/dashboard/views/screens/com/com_dashbord_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/events/event_dashboard_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/priere/priere_dashboard_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/tresorerie/treso_dashboard_screen.dart';
import 'package:Benjamin/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/features/dashboard/views/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Une erreur s'est produite",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                height: 49,
                width: 345,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.amberAccent,
                ),
                child: const Text(
                  "",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Tribu de Benjamin',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale("en", "US"), Locale("fr", "FR")],
        debugShowCheckedModeBanner: false,
        theme: AppTheme.basic,
        home: const CheckAuth());
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({Key? key}) : super(key: key);
  static const rootName = '/check-login';

  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  bool isEntreprise = false;

  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  String memberType = "";
  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token != null) {
      var memberdata = jsonDecode(localStorage.getString('member')!);

      setState(() {
        isAuth = true;
        memberType = memberdata['membretype'] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = const LoginPage();
    if (isAuth) {
      child = memberType == "Admin"
          ? const DashboardScreen()
          : memberType == "Treso"
              ? const TresoDashboardScreen()
              : memberType == "Com" || memberType == "Visite"
                  ? const ComDashboardScreen()
                  : memberType == "Event" || memberType == "Deco"
                      ? const EventDashboardScreen()
                      : memberType == "Prière"
                          ? const PriereDashboardScreen()
                          : const EventDashboardScreen();
    } else {
      child = const LoginPage();
    }
    return Scaffold(
      body: child,
    );
  }
}
