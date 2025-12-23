import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  
  String type = 'Expense'; 
  String category = 'Food'; 
  bool isLoading = false;

  // 1. قسمنا القوائم لقائمتين منفصلتين
  final List<String> expenseCategories = ['Food', 'Shopping', 'Transport', 'Others'];
  final List<String> incomeCategories = ['Salary', 'Others']; // ممكن تضيف مصادر تانية للدخل هنا

  Future<void> saveTransaction() async {
    if (amountController.text.isEmpty) return;
    
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('transactions')
          .add({
        'amount': double.parse(amountController.text),
        'type': type,
        'category': category,
        'note': noteController.text,
        'date': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Added Successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print(e);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // 2. بنحدد القائمة الحالية بناءً على النوع المختار
    List<String> currentCategories = type == 'Income' ? incomeCategories : expenseCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F7),
      appBar: AppBar(title: const Text("Add Transaction"), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            // اختيار النوع
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("Expense"),
                    value: "Expense",
                    groupValue: type,
                    activeColor: Colors.red,
                    // 3. لما نغير لـ Expense، نرجع الكاتيجوري لأول عنصر في قائمة المصاريف
                    onChanged: (val) {
                      setState(() {
                        type = val.toString();
                        category = expenseCategories[0]; // (Food)
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("Income"),
                    value: "Income",
                    groupValue: type,
                    activeColor: Colors.green,
                    // 4. لما نغير لـ Income، نغير الكاتيجوري لأول عنصر في قائمة الدخل
                    onChanged: (val) {
                      setState(() {
                        type = val.toString();
                        category = incomeCategories[0]; // (Salary)
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // اختيار القسم
            DropdownButtonFormField(
              value: category,
              // 5. هنا بنستخدم القائمة المتغيرة (currentCategories)
              items: currentCategories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => category = val.toString()),
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D4C6E),
                  foregroundColor: Colors.white,
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Save Transaction", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}