import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/booking_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin_login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BookingProvider(),
      child: MaterialApp(
        title: 'Shooting Arena Booking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color(0xFF00ff88),
          scaffoldBackgroundColor: Color(0xFF0a0e1a),
          fontFamily: 'Roboto',
        ),
        home: WelcomeScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/admin-login': (context) => AdminLoginScreen(),
        },
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0a0e1a),
              Color(0xFF1a1f35),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF00ff88), Color(0xFF00d9ff)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00ff88).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.gps_fixed,
                      size: 60,
                      color: Color(0xFF0a0e1a),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Title
                  Text(
                    'ELITE SHOOTING ARENA',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00ff88),
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lane Booking System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF00d9ff),
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 60),

                  // Member Login Button
                  _buildButton(
                    context: context,
                    text: 'MEMBER LOGIN',
                    icon: Icons.person,
                    colors: [Color(0xFF00ff88), Color(0xFF00d9ff)],
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  SizedBox(height: 20),

                  // Admin Portal Button
                  _buildButton(
                    context: context,
                    text: 'ADMIN PORTAL',
                    icon: Icons.shield,
                    colors: [Color(0xFFff6b00), Color(0xFFff0844)],
                    onPressed: () => Navigator.pushNamed(context, '/admin-login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: text.contains('ADMIN') ? Colors.white : Color(0xFF0a0e1a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
