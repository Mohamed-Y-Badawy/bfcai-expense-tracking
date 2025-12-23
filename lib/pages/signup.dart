import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. استيراد مكتبة الـ Auth
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  Color myColor = const Color(0xFF9D4C6E);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // --- دوال التحقق زي ما هي ---
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!value.contains('@')) return 'Please enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // 5. دالة التسجيل الحقيقية (Firebase Logic)
  // حولناها لـ Future عشان بتتعامل مع النت
  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      // إظهار دائرة تحميل عشان المستخدم يعرف إننا شغالين
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // 1. إنشاء المستخدم في فايربيز
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(), // trim بتشيل المسافات الزيادة
              password: passwordController.text.trim(),
            );

        // 2. تحديث اسم المستخدم (DisplayName) لأن دالة الإنشاء بتاخد إيميل وباسورد بس
        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(nameController.text);
        }

        // قفل دائرة التحميل
        if (mounted) Navigator.pop(context);

        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Account Created Successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        // الانتقال لصفحة تسجيل الدخول أو الصفحة الرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogIn()),
        );
      } on FirebaseAuthException catch (e) {
        // قفل دائرة التحميل لو حصل خطأ
        if (mounted) Navigator.pop(context);

        // معالجة الأخطاء الشائعة وإظهار رسالة للمستخدم
        String errorMessage = "An error occurred";

        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      } catch (e) {
        // أي خطأ تاني غير متوقع
        if (mounted) Navigator.pop(context);
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image.asset(
            "images/signup.png",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        "Create\nAccount",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Name
                      const Text(
                        "Name",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: nameController,
                        validator: validateName,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration("Enter your name"),
                      ),

                      const SizedBox(height: 20),

                      // Email
                      const Text(
                        "Email",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        validator: validateEmail,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration("Enter your email"),
                      ),

                      const SizedBox(height: 20),

                      // Password
                      const Text(
                        "Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        validator: validatePassword,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(
                          "Enter your password",
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              register, // هنا هيتم استدعاء الدالة الجديدة
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: myColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LogIn(),
                                ),
                              );
                            },
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                color: myColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: myColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white70),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: myColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
