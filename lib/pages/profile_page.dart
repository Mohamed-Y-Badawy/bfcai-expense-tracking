import 'package:expenseapp/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // المتغيرات
  final User? user = FirebaseAuth.instance.currentUser;
  final Color myColor = const Color(0xFF9D4C6E);
  bool isEditing = false; // عشان نعرف احنا في وضع العرض ولا التعديل
  bool isLoading = false;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData(); // جلب البيانات أول ما الصفحة تفتح
  }

  // 1. دالة جلب البيانات
  Future<void> getUserData() async {
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      // بنحاول نجيب البيانات من Firestore
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userData.exists) {
        // لو البيانات موجودة في الداتابيز، اعرضها
        var data = userData.data() as Map<String, dynamic>;
        nameController.text = data['name'] ?? user!.displayName ?? '';
        phoneController.text = data['phone'] ?? '';
        bioController.text = data['bio'] ?? '';
      } else {
        // لو مفيش بيانات في الداتابيز، اعرض اسم الـ Auth
        nameController.text = user!.displayName ?? '';
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    setState(() => isLoading = false);
  }

  // 2. دالة حفظ البيانات
  Future<void> saveData() async {
    setState(() => isLoading = true);

    try {
      // حفظ البيانات في Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': nameController.text,
        'phone': phoneController.text,
        'bio': bioController.text,
        'email': user!.email, // بنحفظ الإيميل كمان كمرجع
      }, SetOptions(merge: true)); // merge: عشان ميحذفش بيانات قديمة لو موجودة

      // تحديث الاسم في الـ Auth كمان
      await user!.updateDisplayName(nameController.text);

      setState(() {
        isEditing = false; // نرجع لوضع العرض
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: myColor,
        actions: [
          // زرار التبديل بين التعديل والعرض
          IconButton(
            onPressed: () {
              if (isEditing) {
                // لو كنا بنعدل ودوسنا، يبقى عايزين نحفظ
                saveData();
              } else {
                // لو كنا بنعرض ودوسنا، يبقى عايزين نعدل
                setState(() => isEditing = true);
              }
            },
            icon: Icon(isEditing ? Icons.check : Icons.edit),
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: myColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // صورة البروفايل
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: const AssetImage("images/Profile_Picture_DropJPG_2.jpg"), // حط صورة افتراضية هنا
                        
                      ),
                      if (isEditing)
                        CircleAvatar(
                          backgroundColor: myColor,
                          radius: 18,
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),

                  // عرض الإيميل (غير قابل للتعديل عادة)
                  ListTile(
                    leading: Icon(Icons.email, color: myColor),
                    title: const Text("Email"),
                    subtitle: Text(user?.email ?? "No Email", style: const TextStyle(fontSize: 16)),
                  ),
                  const Divider(),

                  // --- حقل الاسم ---
                  buildProfileField("Name", nameController, Icons.person),
                  
                  // --- حقل الهاتف ---
                  buildProfileField("Phone", phoneController, Icons.phone),
                  
                  // --- حقل النبذة (Bio) ---
                  buildProfileField("Bio", bioController, Icons.info_outline),
                  ListTile(
                        onTap: () async {
                          // إظهار رسالة تأكيد (اختياري بس احترافي)
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Logout"),
                              content: const Text("Are you sure you want to logout?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true), 
                                  child: const Text("Logout", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            // تنفيذ الخروج
                            await FirebaseAuth.instance.signOut();
                            
                            if (context.mounted) {
                              // الرجوع لصفحة اللوجين ومسح الذاكرة
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const SignUp()),
                                (route) => false,
                              );
                            }
                          }
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1), // خلفية حمراء فاتحة
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout, color: Colors.red),
                        ),
                        title: const Text(
                          "Log Out",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red, // لون أحمر للنص
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.red),
                      ),
                  
                ],
              ),
            ),
    );
  }

  // ويدجت عشان نكرر الحقول بسهولة
  Widget buildProfileField(String label, TextEditingController controller, IconData icon) {
    return Column(
      children: [
        if (isEditing) 
          // شكل الحقل في وضع التعديل
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: myColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: myColor, width: 2)),
              ),
            ),
          )
        else 
          // شكل الحقل في وضع العرض
          ListTile(
            leading: Icon(icon, color: myColor),
            title: Text(label),
            subtitle: Text(
              controller.text.isEmpty ? "Not set" : controller.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        if (!isEditing) const Divider(),
      ],
    );
  }
}