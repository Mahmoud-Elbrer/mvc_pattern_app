import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/custom_trace.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class SplashScreenController extends ControllerMVC with ChangeNotifier {
  ValueNotifier<Map<String, double>> progress = new ValueNotifier(new Map());
  GlobalKey<ScaffoldState>? scaffoldKey;
  final FirebaseMessaging? firebaseMessaging ;
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  SplashScreenController(this.firebaseMessaging) {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }

  @override
  void initState() {
    super.initState();
    // todo : enable this comment 
    //firebaseMessaging!.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    configureFirebase(firebaseMessaging!);
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != null && settingRepo.setting.value.appName != '' && settingRepo.setting.value.mainColor != null) {
        progress.value["Setting"] = 41;
        progress.notifyListeners();
      }
    });
    userRepo.currentUser.addListener(() {
      if (userRepo.currentUser.value.auth != null) {
        progress.value["User"] = 59;
        progress.notifyListeners();
      }
    });
    Timer(Duration(seconds: 20), () {
//      ScaffoldMessenger.of(scaffoldKey.currentContext).showSnackBar(SnackBar(
//        content: Text(S.of(state.context).verify_your_internet_connection),
//      ));

      scaffoldKey!.currentState!.showSnackBar(new SnackBar(
        content: new Text(S.of(state!.context)!.verify_your_internet_connection),
      ));

      print("spsp");
      print(S.of(state!.context)!.verify_your_internet_connection);



    });
  }

  void configureFirebase(FirebaseMessaging _firebaseMessaging) {
    try {
      _firebaseMessaging.configure(
        onMessage: notificationOnMessage,
        onLaunch: notificationOnLaunch,
        onResume: notificationOnResume,
      );
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
      print(CustomTrace(StackTrace.current, message: 'Error Config Firebase'));
    }
  }

  Future notificationOnResume(Map<String, dynamic> message) async {
    print(CustomTrace(StackTrace.current, message: message['data']['id']));
    try {
      if (message['data']['id'] == "orders") {
        settingRepo.navigatorKey.currentState!.pushReplacementNamed('/Pages', arguments: 1);
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Future notificationOnLaunch(Map<String, dynamic> message) async {
    String? messageId = await settingRepo.getMessageId();
    try {
      if (messageId != message['google.message_id']) {
        if (message['data']['id'] == "orders") {
          await settingRepo.saveMessageId(message['google.message_id']);
          settingRepo.navigatorKey.currentState!.pushReplacementNamed('/Pages', arguments: 1);
        }
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Future notificationOnMessage(Map<String, dynamic> message) async {
    Fluttertoast.showToast(
      msg: message['notification']['title'],
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
//      backgroundColor: Theme.of(state.context).backgroundColor,
//      textColor: Theme.of(state.context).hintColor,
      timeInSecForIosWeb: 5,
    );
  }
}
