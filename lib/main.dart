import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lunad/data/bloc/auth/auth_bloc.dart';
import 'package:lunad/repositories/firebase_auth_repository.dart';
import 'package:lunad/screens/login/login_screen.dart';
import 'package:lunad/screens/rider/rider_welcome_screen.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'screens/consumer/consumer_welcome_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

String selectedNotificationPayload;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await _configureLocalTimeZone();

  final NotificationAppLaunchDetails notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });

  runApp(
    RepositoryProvider(
      create: (context) => FirebaseAuthRepo(),
      child: BlocProvider<AuthBloc>(
        create: (context) {
          final _authRepo = RepositoryProvider.of<FirebaseAuthRepo>(context);
          return AuthBloc(_authRepo);
        },
        child: MyApp(),
      ),
    ),
  );
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'lunad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.white,
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is UninitializedState) {
            return buildUninitializedState(context);
          }

          if (state is UnAuthenticatedState) {
            return LoginScreen();
          }

          if (state is AuthenticatedUserState) {
            print('consumer');
            final user = state.user;
            return ConsumerWelcomeScreen(user: user);
          }

          if (state is AuthenticatedRiderState) {
            final rider = state.rider;
            return RiderWelcomeScreen(rider: rider);
          }

          return buildUninitializedState(context);
        },
      ),
    );
  }

  Scaffold buildUninitializedState(BuildContext context) {
    BlocProvider.of<AuthBloc>(context).add(AppStart());

    return Scaffold(
      backgroundColor: Colors.red.shade600,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: HeartbeatProgressIndicator(
                    duration: Duration(seconds: 2),
                    child: SizedBox(
                      height: 100.0,
                      width: 100.0,
                      child: Image.asset('assets/images/logo_white.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}
