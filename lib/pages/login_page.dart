// login_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoginMode = true;
  bool loading = false;
  String? error;

  Future<void> _submit() async {
    setState(() { loading = true; error = null; });
    final app = context.read<AppState>();
    try {
      if (isLoginMode) {
        await app.login(emailCtrl.text.trim(), passCtrl.text.trim());
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/leaderboard');
      } else {
        await app.signup(emailCtrl.text.trim(), passCtrl.text.trim());
        if (!mounted) return;
        setState(() { isLoginMode = true; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 완료! 로그인 해주세요.')),
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('email')) {
        errorMessage = errorMessage.replaceAll('email', 'id');
      }
      setState(() { error = errorMessage; });
    } finally {
      if (mounted) setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // 로고와 앱 이름 추가
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 8),
                    Text('Grin Mind', style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: '아이디')),
                const SizedBox(height: 8),
                TextField(controller: passCtrl, decoration: const InputDecoration(labelText: '비밀번호'), obscureText: true),
                const SizedBox(height: 12),
                if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: loading ? null : _submit,
                  child: Text(loading ? '처리중...' : (isLoginMode ? '로그인' : '회원가입')),
                ),
                TextButton(
                  onPressed: () => setState(() => isLoginMode = !isLoginMode),
                  child: Text(isLoginMode ? '회원가입으로' : '로그인으로'),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}