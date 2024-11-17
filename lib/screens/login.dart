import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/helpers/helper_service.dart';
import '../main.dart';
import 'package:quick_task/helpers/app_regex.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class User {
  String username;
  String email;
  String password;

  User({required this.username, required this.email, required this.password});
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  HelperService helperService = HelperService();
  bool isLogin = true;

  Future<bool> login(String username, String password) async {
    try {
      await Parse().initialize(applicationId, parseURL,
          clientKey: clientKey, autoSendSessionId: true);

      final parseUser = ParseUser(username, password, null);
      final result = await parseUser.login();
      return result.success;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final ParseUser parseUser = await ParseUser.currentUser();
      final result = await parseUser.logout();
      return result.success;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> signup(User user) async {
    try {
      await Parse().initialize(applicationId, parseURL,
          clientKey: clientKey, autoSendSessionId: true);

      final parseUser = ParseUser(user.username, user.password, user.email);
      final result = await parseUser.signUp();
      return result.success;
    } catch (e) {      
      print(e);
      return false;
    }
  }

  List<Widget> loginForm() {
    return [
      const SizedBox(height: 50),  
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Quick Task",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[900],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 50),
      _buildInputField(
        controller: _usernameController,
        labelText: "Enter Username",
        icon: Icons.person,
      ),
      _buildInputField(
        controller: _passwordController,
        labelText: "Enter Password",
        icon: Icons.lock,
        obscureText: true,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.blueGrey[900],  
          side: BorderSide(color: Colors.blueGrey[900]!, width: 3),  
        ),
        onPressed: () async {
            String username = _usernameController.text.trim().toLowerCase();
            String password = _passwordController.text;

            login(username, password).then((success) {
              if (success) {                
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.rightSlide,
                  title: 'Login Success',
                  desc: 'You have successfully Logged up.',
                ).show();
                Navigator.of(context).pushReplacementNamed("/");
              } else {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.rightSlide,
                  title: 'Error',
                  desc: 'Wrong username or password provided.',
                ).show();
              }
            });
          },
        child: Text(
          "Login",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          setState(() {
            isLogin = false;
          });
        },
        child: Text(
          "Don't have an account yet? Sign Up",
          style: TextStyle(
            color: Colors.blueGrey[900],
            fontSize: 16,
          ),
        ),
      ),
    ];
  }

  List<Widget> signupForm() {
    return [
      const SizedBox(height: 60),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Quick Task",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[900],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 40),
      _buildInputField(
        controller: _usernameController,
        labelText: "Enter Username",
        icon: Icons.person,
      ),
      _buildInputField(
        controller: _emailController,
        labelText: "Enter Email",
        icon: Icons.email,
      ),
      _buildInputField(
        controller: _passwordController,
        labelText: "Enter Password",
        icon: Icons.lock,
        obscureText: true,
      ),
      _buildInputField(
        controller: _rePasswordController,
        labelText: "Re-enter Password",
        icon: Icons.lock,
        obscureText: true,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.blueGrey[900],  
          side: BorderSide(color: Colors.blueGrey[900]!, width: 3),  
        ),
        onPressed: () async {
            String username = _usernameController.text.trim().toLowerCase();
            String password = _passwordController.text;
            String rePassword = _rePasswordController.text;
            String email = _emailController.text.trim().toLowerCase();
            if (password != rePassword) {
              helperService.showMessage(
                  context, 'Password and Re-password do not match.',
                  error: true);
              return;
            }
            if (!AppRegexHelper.isEmailValid(email)) {
              helperService.showMessage(context, 'Please provide valid email.',
                  error: true);
              return;
            }
            if (!AppRegexHelper.hasMinLength(password) ||
                !AppRegexHelper.hasMinLength(rePassword)) {
              helperService.showMessage(
                  context, 'Please provide password.',
                  error: true);
              return;
            }

            User user =
                User(username: username, email: email, password: password);
            signup(user).then((success) {
              if (success) {
                _passwordController.clear();
                _rePasswordController.clear();
                _emailController.clear();
                setState(() {
                  isLogin = true;
                });
				AwesomeDialog(
				  context: context,
				  dialogType: DialogType.success,
				  animType: AnimType.rightSlide,
				  title: 'Sign up Success',
				  desc: 'You have successfully signed up.',
				).show();
              } else {
                helperService.showMessage(context,
                    'Username or email already exists, please try again.',
                    error: true);
              }
            });            
			},
        child: Text(
          "Signup",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          setState(() {
            isLogin = true;
          });
        },
        child: Text(
          "Already have an account?",
          style: TextStyle(
            color: Colors.blueGrey[900],
            fontSize: 16,
          ),
        ),
      ),
    ];
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueGrey[900]),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.blueGrey[900]),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8), 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.blueGrey[900]!, width: 2),
          ),
        ),
        style: TextStyle(color: Colors.blueGrey[900]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/quick_task_background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: isLogin ? loginForm() : signupForm(),
          ),
        ),
      ),
    );
  }
}
