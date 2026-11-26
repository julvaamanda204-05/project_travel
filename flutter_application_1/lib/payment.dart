import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'chat.dart' show ChatScreen;
import 'data.dart';
import 'history.dart' show TrackingScreen;

const payMethods = [
  ('BCA Virtual Account', Icons.account_balance),
  ('Mandiri Virtual Account', Icons.account_balance),
  ('GoPay', Icons.account_balance_wallet),
  ('OVO', Icons.account_balance_wallet),
  ('DANA', Icons.account_balance_wallet),
  ('QRIS', Icons.qr_code),
];

class CheckoutScreen extends StatefulWidget {
  final Booking b;

  const CheckoutScreen(this.b, {super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String method = payMethods[2].$1;
  bool paying = false;

  Future<void> _pay() async {
    setState(() => paying = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => TicketScreen(
          widget.b,
          payMethod: method,
          paymentCompleted: true,
        ),
      ),
    );
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final booking = widget.b;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (paying) const LinearProgressIndicator(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${booking.from} → ${booking.to}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${fmtDate(booking.date)} • ${booking.time} • '
                    '${booking.carName}',
                  ),
                  Text('Kursi ${booking.seats.join(", ")}'),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Pembayaran ini hanya simulasi dan tidak memproses transaksi nyata.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          _heading('Metode Pembayaran'),
          for (final item in payMethods)
            ListTile(
              leading: Icon(item.$2),
              title: Text(item.$1),
              trailing: Icon(
                method == item.$1
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: Colors.teal,
              ),
              onTap: paying ? null : () => setState(() => method = item.$1),
            ),
          _heading('Rincian'),
          _row('Total', rp(booking.total), bold: true),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: paying ? null : _pay,
            child: Text(
              paying ? 'Memproses pembayaran...' : 'Bayar ${rp(booking.total)}',
            ),
          ),
        ),
      ),
    );
  }
}

class TicketScreen extends StatefulWidget {
  final Booking b;
  final String? payMethod;
  final bool paymentCompleted;

  const TicketScreen(
    this.b, {
    super.key,
    this.payMethod,
    this.paymentCompleted = false,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  Widget _keyValue(String key, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key, style: const TextStyle(color: Colors.grey)),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final booking = widget.b;

    return Scaffold(
      appBar: AppBar(title: const Text('E-Tiket')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.teal,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'JalanYuk • E-Tiket',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '${booking.from} → ${booking.to}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${fmtDate(booking.date)} • ${booking.time}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _keyValue('Penumpang', AppState.i.name),
                      _keyValue('Mobil', booking.carName),
                      _keyValue('Kursi', booking.seats.join(', ')),
                      _keyValue('Estimasi tiba', fmtTime(booking.eta)),
                      const Divider(),
                      _keyValue(
                        'Metode bayar',
                        widget.payMethod ?? 'Belum dipilih',
                      ),
                      _keyValue('Total', rp(booking.total)),
                      _keyValue(
                        'Status',
                        widget.paymentCompleted
                            ? 'LUNAS (SIMULASI)'
                            : 'MENUNGGU PEMBAYARAN',
                      ),
                      const SizedBox(height: 16),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: CustomPaint(
                          size: const Size(180, 180),
                          painter: FakeQrPainter(booking.id),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: booking.id),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kode booking disalin'),
                            ),
                          );
                        },
                        child: Text(
                          booking.id,
                          style: const TextStyle(
                            fontSize: 22,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'Tunjukkan kode ini kepada sopir',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (!widget.paymentCompleted)
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutScreen(booking),
                ),
              ),
              icon: const Icon(Icons.payment),
              label: const Text('Lanjut ke Pembayaran'),
            ),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrackingScreen(booking),
              ),
            ),
            icon: const Icon(Icons.my_location),
            label: const Text('Lacak Perjalanan'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  prefill: 'Halo CS, saya butuh bantuan untuk pesanan '
                      '${booking.id}',
                ),
              ),
            ),
            icon: const Icon(Icons.support_agent),
            label: const Text('Hubungi CS'),
          ),
        ],
      ),
    );
  }
}

class FakeQrPainter extends CustomPainter {
  final String data;

  const FakeQrPainter(this.data);

  static const n = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / n;
    final random = Random(
      data.codeUnits.fold<int>(11, (a, b) => (a * 31 + b) & 0x7fffffff),
    );
    final black = Paint()..color = Colors.black;
    final white = Paint()..color = Colors.white;

    bool isFinderPattern(int x, int y) =>
        (x < 7 && y < 7) || (x >= n - 7 && y < 7) || (x < 7 && y >= n - 7);

    for (var x = 0; x < n; x++) {
      for (var y = 0; y < n; y++) {
        if (!isFinderPattern(x, y) && random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell, cell),
            black,
          );
        }
      }
    }

    for (final origin in [(0, 0), (n - 7, 0), (0, n - 7)]) {
      canvas.drawRect(
        Rect.fromLTWH(origin.$1 * cell, origin.$2 * cell, 7 * cell, 7 * cell),
        black,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          (origin.$1 + 1) * cell,
          (origin.$2 + 1) * cell,
          5 * cell,
          5 * cell,
        ),
        white,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          (origin.$1 + 2) * cell,
          (origin.$2 + 2) * cell,
          3 * cell,
          3 * cell,
        ),
        black,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FakeQrPainter oldDelegate) =>
      oldDelegate.data != data;
}
