import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/screens/auth/auth_gate.dart';
import 'package:pozit/screens/auth/login_screen.dart';

class _HomeProbe extends StatelessWidget {
  const _HomeProbe({required this.onMyPageTap});

  final VoidCallback onMyPageTap;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  testWidgets('기존 회원 로그인 성공 시 AuthGate가 콜백이 연결된 홈을 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          readAccessToken: () async => null,
          homeBuilder: (onMyPageTap) => _HomeProbe(onMyPageTap: onMyPageTap),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final loginScreen = tester.widget<LoginScreen>(find.byType(LoginScreen));
    await loginScreen.onLoginSuccess!(false);
    await tester.pumpAndSettle();

    final home = tester.widget<_HomeProbe>(find.byType(_HomeProbe));
    expect(home.onMyPageTap, isNotNull);
  });
}
