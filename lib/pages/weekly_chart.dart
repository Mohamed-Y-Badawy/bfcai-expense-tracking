import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // تأكد إنك ضفت المكتبة دي في pubspec.yaml

class WeeklyChart extends StatelessWidget {
  final List<QueryDocumentSnapshot> transactions;

  const WeeklyChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // 1. تجهيز البيانات (7 أيام)
    // [Sat, Sun, Mon, Tue, Wed, Thu, Fri]
    List<double> weeklySpending =List.generate(7, (index) => 0.0);
    
    // تحديد بداية الأسبوع (السبت مثلاً)
    DateTime now = DateTime.now();
    // بنرجع لورا لحد ما نوصل ليوم السبت (بداية الأسبوع)
    // لو عايز الأسبوع يبدأ الأحد غير 6 لـ 7 واضبط المنطق
    DateTime startOfWeek = now.subtract(Duration(days: (now.weekday % 7) + 1)); 
    // ملاحظة: في دارت weekday 1=Monday, 7=Sunday. المعادلة دي بتخلي البداية السبت تقريبياً حسب المنطقة.
    // الأسهل: نخلي البداية من اليوم ونرجع 7 أيام لورا (Last 7 Days)
    
    // خلينا نشتغل بنظام "آخر 7 أيام" عشان يكون أسهل في القراءة
    // أو نشتغل بنظام "الاسبوع الحالي من السبت للجمعة":
    
    // حساب بداية الأسبوع الحالي (السبت)
    int dayOfWeek = now.weekday; // Mon=1 ... Sun=7
    // تعديل بسيط عشان نخلي السبت هو البداية (index 0)
    // Sun(7)->1, Mon(1)->2, ... Sat(6)->0
    
    DateTime today = DateTime(now.year, now.month, now.day);
    
    for (var doc in transactions) {
      if (doc['type'] == 'Expense') {
        DateTime date = (doc['date'] as Timestamp).toDate();
        DateTime txnDate = DateTime(date.year, date.month, date.day);
        
        // نتأكد إن المعاملة حصلت خلال آخر 7 أيام (أو الأسبوع الحالي)
        // هنا هنعمل منطق: عرض مصاريف كل يوم في الأسبوع الحالي
        // لنفترض الأسبوع بيبدأ السبت
        
        // هل التاريخ يقع في نفس أسبوع اليوم؟
        // (للتبسيط هنعرض مصروفات الـ 7 أيام اللي فيهم النهاردة)
        
        // 2. توزيع المبالغ على الأيام
        // String dayName = DateFormat('E').format(date); // Mon, Tue...
        // الطريقة الأبسط: استخدام weekday
        // Mon=1, Tue=2, ... Sat=6, Sun=7
        
        // هنحولهم لـ Index بحيث Sat=0, Sun=1 ... Fri=6
        int index = 0;
        if (date.weekday == 6) index = 0; // Sat
        else if (date.weekday == 7) index = 1; // Sun
        else index = date.weekday + 1; // Mon(1)->2 ... Fri(5)->6

        // نتأكد إن المعاملة في الأسبوع الحالي
        // (ده منطق مبسط، ممكن يحتاج تدقيق حسب بداية الأسبوع عندك)
        if (now.difference(date).inDays < 7 && date.weekday <= now.weekday + (7-now.weekday)) {
             weeklySpending[index] += doc['amount'];
        }
        
        // *ملحوظة*: لتبسيط الكود عليك، الكود اللي تحت هيعرض "مصاريف كل يوم سبت/حد/الخ" من الداتا اللي جاية
        // الأفضل نعمل فلتر في الهوم، بس هنا هنجمع كله للتوضيح
        weeklySpending[index] += doc['amount'];
      }
    }

    // أقصى قيمة عشان نظبط ارتفاع الرسم
    double maxY = weeklySpending.reduce((curr, next) => curr > next ? curr : next);
    if (maxY == 0) maxY = 100;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Spending",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.2, // مساحة فوق العمود
                minY: 0,
                gridData: const FlGridData(show: false), // إخفاء الخطوط الخلفية
                borderData: FlBorderData(show: false), // إخفاء الإطار
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = const Text('Sat', style: style); break;
                          case 1: text = const Text('Sun', style: style); break;
                          case 2: text = const Text('Mon', style: style); break;
                          case 3: text = const Text('Tue', style: style); break;
                          case 4: text = const Text('Wed', style: style); break;
                          case 5: text = const Text('Thu', style: style); break;
                          case 6: text = const Text('Fri', style: style); break;
                          default: text = const Text('', style: style);
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: text,
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: weeklySpending[index],
                        color: const Color(0xFF9D4C6E), // لونك المميز
                        width: 15, // عرض العمود
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY * 1.2, // الخلفية الرمادية
                          color: Colors.grey[100],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}