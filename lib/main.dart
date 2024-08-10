import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'choice.dart'; // Import the choice.dart file
import 'login.dart'; // Import the login.dart.file
import 'customer_signup.dart';
import 'startup_signup.dart';
import 'customer_form.dart';
import 'news.dart';
import 'startup_form.dart';
import 'discover.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gummies: Google Stock Market for Dummies',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomePage(),
      routes: {
        '/choice': (context) => ChoicePage(),
        '/login': (context) => LoginPage(),
        '/customer_signup': (context) => CustomerSignupPage(),
        '/startup_signup': (context) => StartupSignupPage(),
        '/customer_form': (context) => CustomerFormPage(),
        '/startup_form': (context) => StartupFormPage(),
        '/news': (context) => StockMarketNewsPage(),
        '/discover': (context) => DiscoverNewsPage(),
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isHoveringLogin = false;
  bool _isHoveringSignup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF131314),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.blue,
                    Color.fromRGBO(182, 109, 164, 1),
                    Color.fromRGBO(217, 100, 112, 1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: TypewriterText(
                  text: 'Gummies',
                  textStyle: TextStyle(
                    fontSize: 82,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  duration: Duration(milliseconds: 2000),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.blue,
                    Color.fromRGBO(182, 109, 164, 1),
                    Color.fromRGBO(217, 100, 112, 1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Google Stock Market for Dummies',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 50),
              MouseRegion(
                onEnter: (_) => setState(() {
                  _isHoveringLogin = true;
                }),
                onExit: (_) => setState(() {
                  _isHoveringLogin = false;
                }),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, '/login'); // Navigate to ChoicePage
                        // context, '/news');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor:
                        _isHoveringLogin ? Colors.blue : Color(0xFF1e1f20),
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Login'),
                ),
              ),
              SizedBox(height: 40),
              MouseRegion(
                onEnter: (_) => setState(() {
                  _isHoveringSignup = true;
                }),
                onExit: (_) => setState(() {
                  _isHoveringSignup = false;
                }),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, '/choice'); // Navigate to Sign Up Page
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor:
                        _isHoveringSignup ? Colors.pink : Color(0xFF1e1f20),
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration duration;

  TypewriterText({
    required this.text,
    required this.textStyle,
    required this.duration,
  });

  @override
  _TypewriterTextState createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _characterCount = StepTween(begin: 0, end: widget.text.length)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        String text = widget.text.substring(0, _characterCount.value);
        return Text(
          text,
          style: widget.textStyle,
        );
      },
    );
  }
}
