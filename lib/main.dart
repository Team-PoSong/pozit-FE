import 'package:flutter/material.dart';

import 'package:pozit/core/auth/auth_deep_link.dart';
import 'package:pozit/core/design_system/app_colors.dart';
import 'package:pozit/screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late final AuthDeepLinkListener _authDeepLinkListener;

  @override
  void initState() {
    super.initState();
    _authDeepLinkListener = AuthDeepLinkListener()
      ..listen(onLoginCode: _handleLoginCode);
  }

  void _handleLoginCode(String loginCode) {
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('로그인 정보를 확인하고 있어요.')));

    // loginCode 교환 API가 확정되면 여기서 accessToken으로 교환한다.
  }

  @override
  void dispose() {
    _authDeepLinkListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pozit',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.white,
        fontFamily: 'Pretendard',
      ),
      home: const LoginScreen(),
    );
  }
}
