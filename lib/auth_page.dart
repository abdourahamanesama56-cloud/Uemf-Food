import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'l10n.dart';
import 'main.dart' show firebaseOk;
import 'theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false;
  bool _loading = false;
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? lang.t('errRequired') : null;

  String? _emailCheck(String? value) {
    final v = (value ?? '').trim().toLowerCase();
    if (v.isEmpty) return lang.t('errRequired');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return lang.t('errEmail');
    }
    if (_register &&
        !v.endsWith('@$kUniversityDomain') &&
        !v.endsWith('.$kUniversityDomain')) {
      return lang.t('errDomain');
    }
    return null;
  }

  String? _passCheck(String? v) {
    if (v == null || v.isEmpty) return lang.t('errRequired');
    if (_register && v.length < 8) return lang.t('errPass');
    return null;
  }

  String? _confirmCheck(String? v) =>
      v != _pass.text ? lang.t('errMatch') : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!firebaseOk) {
      setState(() => _error = lang.t('errFirebase'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_register) {
        await AuthService.register(_name.text, _email.text, _pass.text);
      } else {
        await AuthService.signIn(_email.text, _pass.text);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = lang.t(AuthService.errorKey(e.code)));
      }
    } catch (_) {
      if (mounted) setState(() => _error = lang.t('errGeneric'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _switchMode(bool register) {
    setState(() {
      _register = register;
      _error = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final t = lang.t;
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: LangSwitch(),
                      ),
                      const SizedBox(height: 12),
                      _header(t),
                      const SizedBox(height: 20),
                      SegmentedButton<bool>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: kNavy,
                          selectedForegroundColor: Colors.white,
                        ),
                        segments: [
                          ButtonSegment(value: false, label: Text(t('login'))),
                          ButtonSegment(value: true, label: Text(t('register'))),
                        ],
                        selected: {_register},
                        onSelectionChanged: (s) => _switchMode(s.first),
                      ),
                      const SizedBox(height: 16),
                      _form(t),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(String Function(String) t) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: kTerracotta,
            child: Icon(Icons.restaurant_menu, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            t('welcome'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t('welcomeSub'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _form(String Function(String) t) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_register) ...[
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: t('name'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: t('email'),
              hintText: t('emailHint'),
              prefixIcon: const Icon(Icons.school_outlined),
            ),
            validator: _emailCheck,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pass,
            obscureText: _hide,
            decoration: InputDecoration(
              labelText: t('password'),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _hide = !_hide),
              ),
            ),
            validator: _passCheck,
          ),
          if (_register) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirm,
              obscureText: _hide,
              decoration: InputDecoration(
                labelText: t('confirm'),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              validator: _confirmCheck,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB3261E)),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(_register ? t('btnRegister') : t('btnLogin')),
          ),
        ],
      ),
    );
  }
}
