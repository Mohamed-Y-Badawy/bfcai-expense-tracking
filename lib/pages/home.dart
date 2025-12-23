import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'add_transaction.dart'; // استدعاء صفحة الإضافة
import 'weekly_chart.dart';
import 'package:intl/intl.dart'; // لو محتاجه
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final Stream<QuerySnapshot> _transactionsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('transactions')
        .orderBy('date', descending: true) // الأحدث الأول
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F7),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // 1. زرار عائم لإضافة معاملة جديدة
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransaction()));
        },
        backgroundColor: const Color(0xFF9D4C6E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _transactionsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(context, user); // لو مفيش بيانات
            }

            // 2. العمليات الحسابية (Statistics Logic)
            double totalIncome = 0;
            double totalExpense = 0;
            // تجميع المصاريف حسب كل قسم عشان الشارت
            Map<String, double> categoryTotals = {};

            for (var doc in snapshot.data!.docs) {
              double amount = doc['amount'];
              String type = doc['type'];
              String cat = doc['category'];

              if (type == 'Income') {
                totalIncome += amount;
              } else {
                totalExpense += amount;
                // تجميع للأقسام (فقط للمصاريف)
                if (categoryTotals.containsKey(cat)) {
                  categoryTotals[cat] = categoryTotals[cat]! + amount;
                } else {
                  categoryTotals[cat] = amount;
                }
              }
            }

            double balance = totalIncome - totalExpense;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  _buildHeader(context, user),
                  const SizedBox(height: 30),

                  const Text(
                    "Manage your\nexpenses",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
                  ),

                  const SizedBox(height: 25),

                  // --- البطاقة الرئيسية مع PieChart ديناميكي ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Balance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text("Total Available", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            Text(
                              "\EGP${balance.toStringAsFixed(0)}", // الرصيد الحالي
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: balance >= 0 ? const Color(0xFF00897B) : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // --- رسم الشارت بناء على البيانات ---
                        Row(
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: categoryTotals.isEmpty 
                                ? Center(child: Text("No Expenses", style: TextStyle(color: Colors.grey[400])))
                                : PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    sections: _generateChartSections(categoryTotals, totalExpense),
                                  ),
                                ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // توليد قائمة مفاتيح الألوان (Legend)
                                children: categoryTotals.entries.map((e) {
                                  return _buildLegendItem(e.key, "\EGP${e.value}", _getColorForCategory(e.key));
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- ملخص الدخل والمصروف ---
                  Row(
                    children: [
                      _buildSummaryCard("Income", "+\EGP${totalIncome.toStringAsFixed(0)}", Colors.green, const Color(0xFF7E86F3)),
                      const SizedBox(width: 15),
                      _buildSummaryCard("Expenses", "-\EGP${totalExpense.toStringAsFixed(0)}", Colors.red, const Color(0xFFD9594C)),
                      
                    ],
                  ),
                  // ... كود الـ Summary Cards اللي فات

                      const SizedBox(height: 20),

                      // --- هنا الإحصائية الأسبوعية ---
                      // بنمرر ليها كل المستندات (snapshot.data!.docs) وهي هتتصرف
                      WeeklyChart(transactions: snapshot.data!.docs),

                      const SizedBox(height: 20),

                      // ... كود Recent Transactions (List)
                  const SizedBox(height: 20),
                  // عرض آخر المعاملات (List)
                  const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length > 5 ? 5 : snapshot.data!.docs.length, // عرض آخر 5 فقط
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: doc['type'] == 'Income' ? Colors.green[100] : Colors.red[100],
                          child: Icon(
                            doc['type'] == 'Income' ? Icons.arrow_upward: Icons.arrow_downward ,
                            color: doc['type'] == 'Income' ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(doc['category'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(doc['note'] ?? ''),
                        trailing: Text(
                          "${doc['type'] == 'Income' ? '+' : '-'}\EGP${doc['amount']}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: doc['type'] == 'Income' ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // دالة مساعدة لتلوين الشارت
  List<PieChartSectionData> _generateChartSections(Map<String, double> totals, double totalExp) {
    return totals.entries.map((e) {
      final percentage = (e.value / totalExp) * 100;
      return PieChartSectionData(
        color: _getColorForCategory(e.key),
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 35,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food': return const Color(0xFFEF4438);
      case 'Shopping': return const Color(0xFF8BC34A);
      case 'Transport': return const Color(0xFF00897B);
      case 'Salary': return const Color(0xFFFFA07A);
      default: return Colors.grey;
    }
  }

  // --- Widgets (نفس تصميمك القديم) ---
  Widget _buildHeader(BuildContext context, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Back", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            // 1. لو فيه خطأ في الاتصال
            if (snapshot.hasError) {
              return const Text("Error");
            }

            // 2. لو لسه بيحمل البيانات
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            }

            // 3. تجهيز الاسم الافتراضي
            String displayName = user!.displayName ?? "User";

            // 4. محاولة جلب الاسم من Firestore
            if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
              
              // نتأكد إن الحقل 'name' موجود ومش فاضي
              if (data.containsKey('name') && data['name'] != null && data['name'].toString().isNotEmpty) {
                displayName = data['name'];
              }
            }

            // 5. عرض الاسم النهائي
            return Text(
              displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            );
          },
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            backgroundImage: const AssetImage('images/Profile_Picture_DropJPG_2.jpg'),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color textColor, Color barColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(amount, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(height: 6, width: 80, decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(10))),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const Spacer(),
          Text(amount, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, User? user) {
     return SingleChildScrollView(
       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           _buildHeader(context, user),
           const SizedBox(height: 100),
           const Center(child: Text("Start adding your expenses!", style: TextStyle(fontSize: 18, color: Colors.grey))),
         ],
       ),
     );
  }
}