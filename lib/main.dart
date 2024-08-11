import 'package:logitrust_drivers/authentication/car_info_screen.dart';
import 'package:logitrust_drivers/mainScreens/new_trip_screen.dart';
import 'package:logitrust_drivers/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'InfoHandler/app_info.dart';
import 'authentication/login_screen.dart';
import 'authentication/register_screen.dart';
import 'mainScreens/main_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("8919687a-effe-4f5f-929d-1cbac7845e8f");
  OneSignal.Notifications.requestPermission(true);

  runApp(ChangeNotifierProvider(
    create: (context) => AppInfo(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    String? screen;
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      screen = data?['screen'];
      if (screen != null) {
        navigatorKey.currentState?.pushNamed(screen!);
      }
    },);
    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => const MySplashScreen(),
        '/main_screen': (context) => const MainScreen(),
        '/login_screen': (context) => const Login(),
        '/register_screen': (context) => const Register(),
        '/car_info_screen': (context) => const CarInfoScreen(),
        '/new_trip_screen': (context) => NewTripScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
