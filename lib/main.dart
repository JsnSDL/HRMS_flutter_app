import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/admin_home.dart';
import 'package:hrm_employee/Screens/Authentication/sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/Home/home_screen.dart';
import 'Screens/Splash Screen/splash_screen.dart';
import 'providers/user_provider.dart';
import 'providers/attendance_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/error_image.png',
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  };
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AttendanceProvider()),
          ChangeNotifierProvider(create: (context) => UserData()),
        ],
        child: Consumer<UserData>(
          builder: (context, userData, _) {
            if (!userData.isTokenLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignIn()),
                  (Route<dynamic> route) => false,
                );
              });
            }
            return MaterialApp(
                theme: ThemeData(
                  pageTransitionsTheme: const PageTransitionsTheme(builders: {
                    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  }),
                ),
                title: 'SmartH2R HRMS',
                debugShowCheckedModeBanner: false,
                home:  _getHomeScreen(userData),
                //  userData.isTokenLoaded ? const HomeScreen() : const SplashScreen(),
                routes: <String, WidgetBuilder>{
                  '/homescreen': (BuildContext context) => const HomeScreen(),
                });
          }
        ));
  }
   Widget _getHomeScreen(UserData userData) {
    if (!userData.isTokenLoaded) {
      return const SplashScreen();
    } else if (userData.role == "3") {
      return const AdminDashboard();
    } else {
      return const HomeScreen();
    }
  }
}
