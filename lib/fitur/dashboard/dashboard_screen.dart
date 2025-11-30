import 'package:flutter/material.dart';
import 'package:donatopia/widgets/custom_drawer.dart'; 

class DonatopiaColors {
  static const Color backgroundSoftPink = Color.fromARGB(255, 240, 229, 231);
  static const Color headerPink = Color.fromARGB(255, 240, 153, 169);
  static const Color cardBackground = Colors.white;
  static const Color cardBorder = Color.fromARGB(255, 230, 230, 230);
  static const Color cardValueColor = Color(0xFFCC6073);
  static const Color cardLabelColor = Color.fromARGB(255, 139, 133, 134);
  static const Color activeButtonBg = Color.fromARGB(255, 250, 124, 147);
  static const Color inactiveButtonBg = Color.fromARGB(255, 230, 230, 230);
  static const Color chartLineColor = Color.fromARGB(255, 245, 179, 190); 
  static const Color gradientBorderLightPink = Color.fromARGB(255, 255, 215, 225);
  static const Color gradientBorderFuchsia = Color.fromARGB(255, 250, 150, 170);
 
  static const Color latestTransactionItemBg = Color.fromARGB(255, 255, 235, 240); 
}

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard'; 

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isWeeklyActive = false; // Default: Bulanan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(currentRoute: DashboardScreen.routeName),
      backgroundColor: DonatopiaColors.backgroundSoftPink,
      appBar: AppBar(
        automaticallyImplyLeading: true, 
        backgroundColor: DonatopiaColors.cardBackground,
        surfaceTintColor: DonatopiaColors.cardBackground,
        title: Row(
          children: [
            Container(
              width: 40, 
              height: 40, 
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DonatopiaColors.headerPink.withOpacity(0.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/donatopia.png', 
                  fit: BoxFit.cover, 
                  errorBuilder: (context, error, stackTrace) {
                    return const Center();
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donatopia',
                  style: TextStyle(
                    color: DonatopiaColors.cardLabelColor, 
                    fontWeight: FontWeight.normal, 
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    color: DonatopiaColors.cardLabelColor, 
                    fontWeight: FontWeight.normal, 
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.black54), // Ikon garis tiga
                onPressed: () => Scaffold.of(context).openEndDrawer(), 
              );
            },
          ),
        ],
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    label: 'Total Penjualan',
                    value: 'Rp 302.000',
                    subtitle: '8 transaksi',
                    valueColor: DonatopiaColors.cardValueColor,
                    barColor: DonatopiaColors.gradientBorderLightPink,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    label: 'Total Stok',
                    value: '407',
                    subtitle: '15 produk',
                    barColor: DonatopiaColors.gradientBorderFuchsia,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    label: 'Pelanggan Aktif',
                    value: '1',
                    subtitle: 'Terdaftar',
                    barColor: DonatopiaColors.gradientBorderFuchsia,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    label: 'Stok Rendah',
                    value: '0',
                    subtitle: 'Perlu restock',
                    barColor: DonatopiaColors.gradientBorderLightPink,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildChartCard(context),

            const SizedBox(height: 24), 
            _buildTransactionChartCard(context),

            const SizedBox(height: 24), 

            // Card Transaksi Terbaru
            _buildLatestTransactionCard(context),

            const SizedBox(height: 16), // Padding akhir
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String label,
    required String value,
    required String subtitle,
    Color valueColor = Colors.black,
    Color barColor = DonatopiaColors.gradientBorderFuchsia,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: DonatopiaColors.cardBackground, 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: barColor, 
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(left: 8),
            color: DonatopiaColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide.none,
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: DonatopiaColors.cardLabelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: DonatopiaColors.cardLabelColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final CustomPainter activePainter = isWeeklyActive
        ? _ChartWeeklyPlaceholderPainter()
        : _ChartMonthlyPlaceholderPainter();
    
    final List<Widget> xAxisLabels = isWeeklyActive
        ? const [
            Text('Sen', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Sel', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Rab', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Kam', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Jum', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Sab', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Min', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ]
        : const [
            Text('Jan', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Feb', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Mar', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Apr', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Mei', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Jun', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Jul', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Agu', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Sep', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Okt', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Nov', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Des', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ];

    final double xAxisPadding = isWeeklyActive ? 25.0 : 10.0;
    
    return Card(
      color: DonatopiaColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: DonatopiaColors.cardBorder,
          width: 1,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grafik Penjualan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: DonatopiaColors.inactiveButtonBg,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isWeeklyActive = true;
                          });
                        },
                        child: _buildChartButton('Mingguan', isWeeklyActive),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isWeeklyActive = false;
                          });
                        },
                        child: _buildChartButton('Bulanan', !isWeeklyActive),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('4', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 38), 
                    Text('3', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 38),
                    Text('2', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 38),
                    Text('1', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 38),
                    Text('0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                        left: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Center(
                      child: CustomPaint(
                        painter: activePainter, 
                        child: Container(height: 200, width: double.infinity),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(top: 8.0, left: xAxisPadding, right: xAxisPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: xAxisLabels,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartButton(String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? DonatopiaColors.activeButtonBg
              : DonatopiaColors.inactiveButtonBg,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  Widget _buildTransactionChartCard(BuildContext context) {
    return Card(
      color: DonatopiaColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: DonatopiaColors.cardBorder,
          width: 1,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jumlah Transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label Y-Axis (0, 1, 2, 3, 4)
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('4', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 38), 
                    Text('3', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 38),
                    Text('2', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 38),
                    Text('1', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 38),
                    Text('0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                        left: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: CustomPaint(
                      painter: _BarChartPlaceholderPainter(), 
                      child: Container(height: 200, width: double.infinity),
                    ),
                  ),
                ),
              ],
            ),

            // Label X-Axis (Mingguan)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Sen', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Rab', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Jum', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Min', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Sel', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestTransactionCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, 
      color: DonatopiaColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: DonatopiaColors.cardBorder,
          width: 1,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaksi Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Item transaksi
            _buildTransactionItem(
              transactionId: 'TRX20251015167153',
              customerName: 'Caca',
              amount: 'Rp 21.000',
              time: '09:15',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String transactionId,
    required String customerName,
    required String amount,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: DonatopiaColors.latestTransactionItemBg, 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Ikon Keranjang
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DonatopiaColors.activeButtonBg.withOpacity(0.5), 
            ),
            child: const Icon(
              Icons.shopping_cart,
              size: 20,
              color: DonatopiaColors.activeButtonBg, 
            ),
          ),
          const SizedBox(width: 12),
          // Info Transaksi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  customerName,
                  style: TextStyle(
                    fontSize: 12,
                    color: DonatopiaColors.cardLabelColor,
                  ),
                ),
              ],
            ),
          ),
          // Nominal dan Waktu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: DonatopiaColors.cardValueColor, 
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: DonatopiaColors.cardLabelColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// CustomPainter untuk Bar Chart Transaksi Mingguan (BARU)
class _BarChartPlaceholderPainter extends CustomPainter {
  final List<double> barHeights = [0, 0, 0, 2.5, 2.7, 3.5, 2.2]; 
  final List<int> visibleDaysIndex = [0, 2, 4, 6]; // Index Sen, Rab, Jum, Min
  
  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()..color = DonatopiaColors.activeButtonBg.withOpacity(0.8);
    final widthPerDay = size.width / 7;
    const barWidth = 25.0; 
    
    // Skala Y (0-4)
    double getY(double value) => size.height - (value * (size.height / 4));

    for (int i = 0; i < barHeights.length; i++) {
      final xCenter = (i * widthPerDay) + (widthPerDay / 2);
      final xLeft = xCenter - barWidth / 2;
      final yTop = getY(barHeights[i]); 
      final yBottom = getY(0); 

      if (barHeights[i] > 0) {
          final RRect barRect = RRect.fromRectAndCorners(
            Rect.fromLTRB(xLeft, yTop, xLeft + barWidth, yBottom),
            topLeft: const Radius.circular(5),
            topRight: const Radius.circular(5),
          );
          canvas.drawRRect(barRect, barPaint);
      }
    }

    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    for (double y = 0; y <= 4; y++) {
      final yPos = getY(y);
      canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _ChartWeeklyPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pinkPaint = Paint()
      ..color = DonatopiaColors.chartLineColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = DonatopiaColors.chartLineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = DonatopiaColors.chartLineColor
      ..style = PaintingStyle.fill;

    final points = [
      Offset(size.width * 0.0, size.height * (1 - 0/4)), // Sen - 
      Offset(size.width * 0.14285, size.height * (1 - 0/4)), // Sel - 
      Offset(size.width * 0.2857, size.height * (1 - 0/4)), // Rab - 
      Offset(size.width * 0.42855, size.height * (1 - 0/4)), // Kam -
      Offset(size.width * 0.5714, size.height * (1 - 2/4)), // Jum - 
      Offset(size.width * 0.71425, size.height * (1 - 2.5/4)), // Sab - 
      Offset(size.width * 0.8571, size.height * (1 - 3/4)), // Min -
      Offset(size.width * 1.0, size.height * (1 - 1.5/4)), // Sen - 
    ];

    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    for (double y = 0; y <= 4; y++) {
      final yPos = size.height - (y * (size.height / 4));
      canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), gridPaint);
    }

    final path = Path();
    path.moveTo(points.first.dx, size.height); 
    path.lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.lineTo(points.last.dx, size.height); 
    path.close();

    canvas.drawPath(path, pinkPaint);

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    for (var point in points) {
      canvas.drawCircle(point, 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChartMonthlyPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pinkPaint = Paint()
      ..color = DonatopiaColors.chartLineColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = DonatopiaColors.chartLineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = DonatopiaColors.chartLineColor
      ..style = PaintingStyle.fill;

    double getY(double value) => size.height - (value * (size.height / 4));

    final points = [
      Offset(size.width * (0 / 11), getY(0)), // Jan
      Offset(size.width * (1 / 11), getY(0)), // Feb
      Offset(size.width * (2 / 11), getY(0)), // Mar
      Offset(size.width * (3 / 11), getY(0)), // Apr
      Offset(size.width * (4 / 11), getY(0)), // Mei
      Offset(size.width * (5 / 11), getY(0)), // Jun
      Offset(size.width * (6 / 11), getY(0)), // Jul
      Offset(size.width * (7 / 11), getY(0)), // Agu
      Offset(size.width * (8 / 11), getY(1.7)), // Sep 
      Offset(size.width * (9 / 11), getY(1.8)), // Okt 
      Offset(size.width * (10 / 11), getY(2.0)), // Nov 
      Offset(size.width * (11 / 11), getY(1.5)), // Des 
    ];

    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    for (double y = 0; y <= 4; y++) {
      final yPos = getY(y);
      canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), gridPaint);
    }
    final path = Path();
    path.moveTo(points.first.dx, size.height); 

    int firstActiveIndex = points.indexWhere((p) => p.dy < getY(0));
    if (firstActiveIndex == -1) firstActiveIndex = points.length; 
    if (firstActiveIndex < points.length) {
      path.lineTo(points[firstActiveIndex - 1].dx, size.height);
      path.lineTo(points[firstActiveIndex - 1].dx, points[firstActiveIndex - 1].dy);
      for (int i = firstActiveIndex; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      
      path.lineTo(points.last.dx, size.height); 
      path.close();

      canvas.drawPath(path, pinkPaint);
      final linePath = Path();
      linePath.moveTo(points[firstActiveIndex].dx, points[firstActiveIndex].dy);
      for (int i = firstActiveIndex + 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(linePath, linePaint);
    }
    for (int i = firstActiveIndex; i < points.length; i++) {
        canvas.drawCircle(points[i], 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}