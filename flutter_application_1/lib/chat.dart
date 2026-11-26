import 'package:flutter/material.dart';
import 'data.dart';
import 'payment.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: AnimatedBuilder(
        animation: AppState.i,
        builder: (_, __) {
          if (AppState.i.bookings.isEmpty)
            return const Center(child: Text('Belum ada pesanan'));
          return ListView(children: [
            for (final b in AppState.i.bookings)
              Card(
                  child: ListTile(
                title: Text('${b.from} → ${b.to}'),
                subtitle:
                    Text('${fmtDate(b.date)} • ${b.carName} • ${rp(b.total)}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => TicketScreen(b))),
              )),
          ]);
        },
      ),
    );
  }
}

class TrackingScreen extends StatelessWidget {
  final Booking b;
  const TrackingScreen(this.b, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lacak Perjalanan')),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.directions_car, size: 80, color: Colors.teal),
        const SizedBox(height: 16),
        Text('${b.from} → ${b.to}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('Estimasi tiba: ${fmtTime(b.eta)}'),
        const SizedBox(height: 16),
        const Text('Sopir sedang dalam perjalanan...',
            style: TextStyle(color: Colors.grey)),
      ])),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String prefill;
  const ChatScreen({super.key, this.prefill = ''});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _controller;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.prefill);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _messages.add(message);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hubungi CS')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('Tulis pesan untuk Customer Service'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final message in _messages)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(message),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Tulis pesan...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    tooltip: 'Kirim pesan',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
