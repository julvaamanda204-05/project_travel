import 'package:flutter/material.dart';
import 'data.dart';
import 'booking.dart';
import 'history.dart';

void main() => runApp(const JalanYukApp());

final tab = ValueNotifier<int>(0);

class JalanYukApp extends StatelessWidget {
  const JalanYukApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'JalanYuk',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorSchemeSeed: const Color(0xFF00897B), useMaterial3: true),
        home: AnimatedBuilder(
          animation: AppState.i,
          builder: (_, __) =>
              AppState.i.email == null ? const AuthScreen() : const HomeShell(),
        ),
      );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _key = GlobalKey<FormState>();
  final _n = TextEditingController(),
      _e = TextEditingController(),
      _p = TextEditingController();
  bool login = true, hide = true;
  String? error;

  void _submit() {
    if (!_key.currentState!.validate()) return;
    final err = login
        ? AppState.i.login(_e.text, _p.text)
        : AppState.i.register(_n.text, _e.text, _p.text);
    if (err != null) setState(() => error = err);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _key,
              child: Column(children: [
                Icon(Icons.directions_car_filled, size: 72, color: cs.primary),
                Text('JalanYuk',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Text('Booking travel jadi gampang'),
                const SizedBox(height: 24),
                if (!login)
                  TextFormField(
                    controller: _n,
                    decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                if (!login) const SizedBox(height: 12),
                TextFormField(
                  controller: _e,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim())
                          ? null
                          : 'Email tidak valid',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _p,
                  obscureText: hide,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                        icon: Icon(
                            hide ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => hide = !hide)),
                  ),
                  validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
                ),
                if (error != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(error!, style: TextStyle(color: cs.error))),
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        onPressed: _submit,
                        child: Text(login ? 'Masuk' : 'Daftar'))),
                TextButton(
                  onPressed: () => setState(() {
                    login = !login;
                    error = null;
                  }),
                  child: Text(login
                      ? 'Belum punya akun? Daftar'
                      : 'Sudah punya akun? Masuk'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: tab,
        builder: (_, i, __) => Scaffold(
          appBar: AppBar(title: const Text('JalanYuk')),
          body: [
            const SearchScreen(),
            const HistoryScreen(),
            const AccountScreen()
          ][i],
          bottomNavigationBar: NavigationBar(
            selectedIndex: i,
            onDestinationSelected: (v) => tab.value = v,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.search), label: 'Cari'),
              NavigationDestination(
                  icon: Icon(Icons.receipt_long), label: 'Pesanan'),
              NavigationDestination(
                  icon: Icon(Icons.settings), label: 'Pengaturan'),
              NavigationDestination(icon: Icon(Icons.person), label: 'Akun'),
            ],
          ),
        ),
      );
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Text(AppState.i.name, style: Theme.of(context).textTheme.titleLarge),
          Text(AppState.i.email ?? ''),
          const SizedBox(height: 20),
          OutlinedButton.icon(
              onPressed: () {
                tab.value = 0;
                AppState.i.logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Keluar')),
        ]),
      );
}
