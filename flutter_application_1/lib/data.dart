import 'dart:math';
import 'package:flutter/material.dart';

String rp(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp$b';
}

String two(int n) => n.toString().padLeft(2, '0');
String fmtDate(DateTime d) => '${two(d.day)}/${two(d.month)}/${d.year}';
String fmtTime(DateTime d) => '${two(d.hour)}:${two(d.minute)}';
String fmtDur(int m) => '${m ~/ 60}j ${two(m % 60)}m';

class CarType {
  final String name;
  final int seats;
  final double mult;
  final IconData icon;
  const CarType(this.name, this.seats, this.mult, this.icon);
}

const cars = [
  CarType('Sedan', 4, 1.0, Icons.directions_car),
  CarType('MPV (Innova)', 6, 1.2, Icons.airport_shuttle),
  CarType('Hiace', 10, 0.9, Icons.directions_bus),
];

class RouteInfo {
  final String a, b;
  final int km, minutes, price;
  const RouteInfo(this.a, this.b, this.km, this.minutes, this.price);
}

const routes = [
  RouteInfo('Padang', 'Bukittinggi', 90, 150, 90000),
  RouteInfo('Padang', 'Payakumbuh', 125, 210, 120000),
  RouteInfo('Padang', 'Solok', 60, 100, 70000),
  RouteInfo('Padang', 'Painan', 75, 120, 80000),
  RouteInfo('Padang', 'Pekanbaru', 360, 480, 250000),
  RouteInfo('Bukittinggi', 'Payakumbuh', 35, 60, 50000),
  RouteInfo('Bukittinggi', 'Pekanbaru', 250, 360, 200000),
];

const cities = ['Padang', 'Bukittinggi', 'Payakumbuh', 'Solok', 'Painan', 'Pekanbaru'];
const times = ['06:00', '09:00', '13:00', '19:00'];

RouteInfo? findRoute(String x, String y) {
  for (final r in routes) {
    if ((r.a == x && r.b == y) || (r.a == y && r.b == x)) return r;
  }
  return null;
}

int fare(RouteInfo r, CarType c) => ((r.price * c.mult) / 1000).round() * 1000;

DateTime departure(DateTime d, String t) {
  final p = t.split(':');
  return DateTime(d.year, d.month, d.day, int.parse(p[0]), int.parse(p[1]));
}

class Booking {
  final String id, from, to, time, carName;
  final DateTime date;
  final List<int> seats;
  final int total, minutes;
  Booking(this.id, this.from, this.to, this.date, this.time, this.carName,
      this.seats, this.total, this.minutes);
  DateTime get depart => departure(date, time);
  DateTime get eta => depart.add(Duration(minutes: minutes));
}

class AppState extends ChangeNotifier {
  static final i = AppState._();
  AppState._();
  final Map<String, List<String>> _users = {}; // email -> [nama, password]
  String? email;
  String get name => email == null ? '' : _users[email]![0];
  final List<Booking> bookings = [];

  String? register(String n, String e, String pw) {
    e = e.trim().toLowerCase();
    if (_users.containsKey(e)) return 'Email sudah terdaftar';
    _users[e] = [n.trim(), pw];
    email = e;
    notifyListeners();
    return null;
  }

  String? login(String e, String pw) {
    e = e.trim().toLowerCase();
    if (_users[e]?[1] != pw) return 'Email atau password salah';
    email = e;
    notifyListeners();
    return null;
  }

  void logout() {
    email = null;
    notifyListeners();
  }

  void add(Booking b) {
    bookings.insert(0, b);
    notifyListeners();
  }

  /// Kursi yang sudah terisi (acak deterministik + pesanan pengguna).
  Set<int> taken(String f, String t, DateTime d, String time, CarType c) {
    final key = '$f$t${fmtDate(d)}$time${c.name}';
    final rnd = Random(key.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0x7fffffff));
    final s = <int>{};
    for (var k = 0; k < rnd.nextInt(c.seats ~/ 2 + 1); k++) {
      s.add(1 + rnd.nextInt(c.seats));
    }
    for (final b in bookings) {
      if (b.from == f && b.to == t && fmtDate(b.date) == fmtDate(d) &&
          b.time == time && b.carName == c.name) {
        s.addAll(b.seats);
      }
    }
    return s;
  }
}
