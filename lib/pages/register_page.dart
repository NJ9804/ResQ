import 'package:flutter/material.dart';
import 'package:resq/components/button.dart';
import 'package:resq/components/text_field.dart';
import 'package:resq/pages/alertlist_page.dart';
import 'package:resq/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void register() async {
    final authService = AuthService();
    if(passwordController.text == confirmPasswordController.text) {
      try {
        await authService.signUpWithEmailAndPassword(emailController.text, passwordController.text);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AlertlistPage()));
      } catch (e) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          );
        });
      }
    } else {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: const Text("Passwords do not match"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        );
      }
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_open_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(height: 25),
            Text(
              "Let's Create an Account",
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            const SizedBox(height: 25),
            MyTextField(
              controller: emailController,
              hintText: "Email",
              obsecureText: false,
            ),
            const SizedBox(height: 15),
            MyTextField(
              controller: passwordController,
              hintText: "Password",
              obsecureText: true,
            ),
            const SizedBox(height: 15),
            MyTextField(
              controller: confirmPasswordController,
              hintText: "Confirm Password",
              obsecureText: true,
            ),
            const SizedBox(height: 10),
            MyButton(
              text: "Sign Up",
              onTap: () {
                register();
              },
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an Account?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary)),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text("Login Here",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold)
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
