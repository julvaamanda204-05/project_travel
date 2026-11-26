import 'dart:async';
import 'package:flutter/material.dart';
import 'data.dart';

/// 5) Riwayat pesanan
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: AppState.i,
        builder: (_, __) {
          final list = AppState.i.bookings;
          if (list.isEmpty) return const Center(child: Text('Belum ada pesanan'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final b = list[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.confirmation_number),
                  title: Text('${b.from} → ${b.to}'),
                  subtitle: Text('${b.id} • ${fmtDate(b.date)} ${b.time}\n${b.carName} • Kursi ${b.seats.join(", ")}'),
                  isThreeLine: true,
                  trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(rp(b.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Lacak', style: TextStyle(color: Colors.teal)),
                  ]),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(b))),
                ),
              );
            },
          );
        },
      );
}

/// 6) Estimasi tiba + 7) Tracking perjalanan (simulasi)
class TrackingScreen extends StatefulWidget {
  final Booking b;
  const TrackingScreen(this.b, {super.key});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  double p = 0; // 0..1
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _simulate() {
    timer?.cancel();
    setState(() => p = 0);
    timer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      setState(() => p = (p + 0.01).clamp(0, 1));
      if (p >= 1) t.cancel();
    });
  }

  String get status => p == 0 ? 'Menunggu keberangkatan' : p < 1 ? 'Dalam perjalanan' : 'Telah tiba';

  @override
  Widget build(BuildContext context) {
    final b = widget.b;
    final remaining = ((1 - p) * b.minutes).round();
    final eta = p == 0 ? b.eta : DateTime.now().add(Duration(minutes: remaining));
    return Scaffold(
      appBar: AppBar(title: Text('Tracking ${b.id}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(status, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(b.from, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(b.to, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: Stack(alignment: Alignment.center, children: [
              LinearProgressIndicator(value: p, minHeight: 8, borderRadius: BorderRadius.circular(4)),
              Align(alignment: Alignment(p * 2 - 1, 0), child: const Icon(Icons.directions_car, color: Colors.teal, size: 32)),
            ]),
          ),
          Text('${(p * 100).round()}% • ${(p * (findRoute(b.from, b.to)?.km ?? 0)).round()} / ${findRoute(b.from, b.to)?.km ?? 0} km'),
          const SizedBox(height: 24),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.schedule), title: const Text('Berangkat'), trailing: Text('${fmtDate(b.date)} ${b.time}')),
            ListTile(leading: const Icon(Icons.flag), title: const Text('Estimasi tiba'), trailing: Text(fmtTime(eta))),
            ListTile(leading: const Icon(Icons.timer), title: const Text('Sisa waktu'), trailing: Text(fmtDur(remaining))),
          ])),
          const Spacer(),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: _simulate, icon: const Icon(Icons.play_arrow), label: const Text('Mulai Simulasi Perjalanan'))),
        ]),
      ),
    );
  }
}
