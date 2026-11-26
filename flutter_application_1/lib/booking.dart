import 'package:flutter/material.dart';
import 'data.dart';
import 'main.dart' show tab;

/// 1) Pencarian rute
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String from = 'Padang', to = 'Bukittinggi';
  DateTime date = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final r = findRoute(from, to);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Halo, ${AppState.i.name}!', style: Theme.of(context).textTheme.titleLarge),
      const Text('Mau ke mana hari ini?'),
      const SizedBox(height: 16),
      _drop('Asal', from, (v) => setState(() => from = v!)),
      Align(
        child: IconButton(
          icon: const Icon(Icons.swap_vert),
          onPressed: () => setState(() { final t = from; from = to; to = t; }),
        ),
      ),
      _drop('Tujuan', to, (v) => setState(() => to = v!)),
      const SizedBox(height: 12),
      ListTile(
        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
        leading: const Icon(Icons.calendar_today),
        title: Text('Tanggal: ${fmtDate(date)}'),
        onTap: () async {
          final d = await showDatePicker(
            context: context, initialDate: date,
            firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
          if (d != null) setState(() => date = d);
        },
      ),
      const SizedBox(height: 12),
      if (from == to) const Text('Asal dan tujuan tidak boleh sama', style: TextStyle(color: Colors.red)),
      if (from != to && r == null) const Text('Rute belum tersedia', style: TextStyle(color: Colors.red)),
      if (r != null && from != to)
        Card(child: ListTile(
          leading: const Icon(Icons.route),
          title: Text('${r.km} km • ${fmtDur(r.minutes)}'),
          subtitle: Text('Mulai dari ${rp(fare(r, cars[2]))}'),
        )),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: (r == null || from == to)
            ? null
            : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultsScreen(from, to, date, r))),
        icon: const Icon(Icons.search),
        label: const Text('Cari Jadwal'),
      ),
    ]);
  }

  Widget _drop(String label, String v, ValueChanged<String?> cb) => DropdownButtonFormField<String>(
        value: v,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.place)),
        items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: cb,
      );
}

/// 2) Jadwal, tarif, dan pemilihan tipe mobil
class ResultsScreen extends StatefulWidget {
  final String from, to;
  final DateTime date;
  final RouteInfo route;
  const ResultsScreen(this.from, this.to, this.date, this.route, {super.key});
  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int ci = 0;
  @override
  Widget build(BuildContext context) {
    final c = cars[ci];
    return Scaffold(
      appBar: AppBar(title: Text('${widget.from} → ${widget.to}')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(spacing: 8, children: [
            for (var i = 0; i < cars.length; i++)
              ChoiceChip(
                avatar: Icon(cars[i].icon, size: 18),
                label: Text('${cars[i].name} (${cars[i].seats} kursi)'),
                selected: ci == i,
                onSelected: (_) => setState(() => ci = i),
              ),
          ]),
        ),
        Expanded(
          child: ListView(children: [
            for (final t in times) _tile(t, c),
          ]),
        ),
      ]),
    );
  }

  Widget _tile(String t, CarType c) {
    final dep = departure(widget.date, t);
    final left = c.seats - AppState.i.taken(widget.from, widget.to, widget.date, t, c).length;
    final price = fare(widget.route, c);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        enabled: left > 0,
        leading: Icon(c.icon, size: 32),
        title: Text('${fmtTime(dep)} → ${fmtTime(dep.add(Duration(minutes: widget.route.minutes)))}'),
        subtitle: Text('${fmtDur(widget.route.minutes)} • sisa $left kursi'),
        trailing: Text(rp(price), style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => SeatScreen(widget.from, widget.to, widget.date, t, c, widget.route))),
      ),
    );
  }
}

/// 3) Pemilihan kursi + 4) Pemesanan
class SeatScreen extends StatefulWidget {
  final String from, to, time;
  final DateTime date;
  final CarType car;
  final RouteInfo route;
  const SeatScreen(this.from, this.to, this.date, this.time, this.car, this.route, {super.key});
  @override
  State<SeatScreen> createState() => _SeatScreenState();
}

class _SeatScreenState extends State<SeatScreen> {
  final picked = <int>{};
  @override
  Widget build(BuildContext context) {
    final taken = AppState.i.taken(widget.from, widget.to, widget.date, widget.time, widget.car);
    final price = fare(widget.route, widget.car);
    return Scaffold(
      appBar: AppBar(title: Text('Pilih Kursi • ${widget.car.name}')),
      body: Column(children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _Legend(Colors.grey, 'Terisi'), _Legend(Colors.teal, 'Dipilih'), _Legend(Colors.white, 'Kosong'),
          ]),
        ),
        const Text('Depan (sopir)', style: TextStyle(color: Colors.grey)),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(24),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (var s = 1; s <= widget.car.seats; s++)
                InkWell(
                  onTap: taken.contains(s) ? null : () => setState(() => picked.contains(s) ? picked.remove(s) : picked.add(s)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: taken.contains(s) ? Colors.grey : picked.contains(s) ? Colors.teal : Colors.white,
                      border: Border.all(color: Colors.teal),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text('$s', style: TextStyle(fontWeight: FontWeight.bold, color: picked.contains(s) ? Colors.white : Colors.black)),
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Text('${picked.length} kursi\n${rp(price * picked.length)}', style: Theme.of(context).textTheme.titleMedium)),
              FilledButton(onPressed: picked.isEmpty ? null : _book, child: const Text('Pesan Sekarang')),
            ]),
          ),
        ),
      ]),
    );
  }

  void _book() {
    final seats = picked.toList()..sort();
    final b = Booking(
      'JY${DateTime.now().millisecondsSinceEpoch % 1000000}',
      widget.from, widget.to, widget.date, widget.time, widget.car.name, seats,
      fare(widget.route, widget.car) * seats.length, widget.route.minutes,
    );
    AppState.i.add(b);
    tab.value = 1;
    Navigator.popUntil(context, (r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pemesanan ${b.id} berhasil!')));
  }
}

class _Legend extends StatelessWidget {
  final Color c;
  final String t;
  const _Legend(this.c, this.t);
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 18, height: 18, decoration: BoxDecoration(color: c, border: Border.all(color: Colors.teal), borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(t),
      ]);
}
