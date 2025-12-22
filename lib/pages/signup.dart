import 'package:flutter/material.dart';
import 'login.dart'; // اتأكد إن ملف اللوجين موجود

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // 1. تعريف اللون المميز
  Color myColor = const Color(0xFF9D4C6E);

  // 2. تعريف أدوات التحكم في النصوص (Controllers)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 3. مفتاح الفورم (Form Key) للتحقق
  final _formKey = GlobalKey<FormState>();

  // 4. دوال التحقق (Validation Functions) - كود نضيف ومنفصل
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // 5. دالة التسجيل (Logic)
  void register() {
    if (_formKey.currentState!.validate()) {
      // لو البيانات صحيحة، نفذ الكود
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Processing Data..."), 
          backgroundColor: myColor
        ),
      );
      
      // اطبع البيانات للتأكد
      print("Name: ${nameController.text}");
      print("Email: ${emailController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // الخلفية
          Image.asset(
            "images/signup.png",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                // 6. تغليف الـ Column بـ Form
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
                      
                      // --- Name ---
                      const Text(
                        "Name",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      TextFormField( // استخدمنا TextFormField
                        controller: nameController,
                        validator: validateName, // ربطنا دالة التحقق
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration("Enter your name"), // التنسيق الجديد
                      ),
                      
                      const SizedBox(height: 20),

                      // --- Email ---
                      const Text(
                        "Email",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
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

                      // --- Password ---
                      const Text(
                        "Password",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        validator: validatePassword,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration("Enter your password"),
                      ),

                      const SizedBox(height: 40),

                      // --- Sign Up Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: register, // استدعينا دالة register
                          style: ElevatedButton.styleFrom(
                            
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold ,color:  Color(0xFF9D4C6E)),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // --- Already have an account ---
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
                                MaterialPageRoute(builder: (context) => const LogIn())
                              );
                            },
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                color: myColor, // اللون الجديد للنص
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

  // دالة مساعدة للتصميم عشان منكررش الكود
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white70),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: myColor, width: 2), // اللون عند الكتابة
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder( // شكل الحدود لما يكون فيه خطأ
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
    );
  }
}