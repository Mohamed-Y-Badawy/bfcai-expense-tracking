import 'package:expenseapp/services/support_widget.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff8edc2),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 120),
            Image.asset('images/onboard.png'),
            SizedBox(height: 50),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Managee your daily\n life expenses',
                      textAlign: TextAlign.center,
                      style: AppWidget.headlineTextStyle(30.0),
                    ),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Text(
                        "Expenese Tracker is a simple and efficent personal finance management app that allows you to track your daily expenses and income.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color.fromARGB(160, 0, 0, 0),
                          fontWeight: FontWeight.w500,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.0),
                    Container(
                      margin: EdgeInsets.only(left: 40.0, right: 40.0),
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(60.0),
                        child: Container(
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Color(0xffee6856),
                            borderRadius: BorderRadius.circular(60.0),
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text(
                              "Get Started",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
