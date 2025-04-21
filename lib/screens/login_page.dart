// lib/screens/login_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Service for authentication logic
import '../screens/news_page.dart'; // Default page to navigate to after login
import '../widgets/app_drawer.dart'; // The app's navigation drawer
import 'forgot_password_page.dart'; // Import the Forgot Password screen

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // Route name for navigation
  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Global key for the form to enable validation
  final _formKey = GlobalKey<FormState>();
  // Controllers to manage text input fields
  final _cedulaController = TextEditingController();
  final _passwordController = TextEditingController();
  // Instance of the authentication service
  final AuthService _authService = AuthService();

  // State variables to manage UI feedback
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true; // To toggle password visibility

  @override
  void dispose() {
    // Clean up controllers when the widget is removed from the widget tree
    _cedulaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle the login submission
  Future<void> _submitLogin() async {
    // Prevent submission if already loading
    if (_isLoading) return;

    // Trigger form validation
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    // Update UI state to show loading indicator and clear errors
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the login method from the AuthService
      await _authService.login(
        _cedulaController.text.trim(), // Use trimmed input
        _passwordController.text,
      );

      // Check if the widget is still mounted before navigating
      if (mounted) {
        // Navigate to the NewsPage on successful login, replacing the LoginPage
        // You could change NewsPage.routeName to another target screen if needed
        Navigator.of(context).pushReplacementNamed(NewsPage.routeName);
      }

    } catch (e) {
      // If login fails (exception thrown by AuthService), show error message
      if (mounted) {
        setState(() {
          // Display the error message from the exception
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
        });
      }

    } finally {
      // Always ensure loading indicator is turned off, even if an error occurred
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        centerTitle: true,
        // Optionally hide back button if it's the initial route after logout
        // automaticallyImplyLeading: false,
      ),
      // Include the AppDrawer, its content will adapt based on login state
      drawer: const AppDrawer(),
      body: Center( // Center the content vertically
        child: SingleChildScrollView( // Allow scrolling on smaller screens
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Associate the form key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content horizontally in Column
              crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch
              children: <Widget>[
                // Optional: Add an app logo or image here
                // Icon(Icons.security, size: 80, color: Theme.of(context).primaryColor),
                // const SizedBox(height: 32),

                // Cédula Input Field
                TextFormField(
                  controller: _cedulaController,
                  decoration: const InputDecoration(
                    labelText: 'Cédula',
                    hintText: 'Ingresa tu número de cédula',
                    prefixIcon: Icon(Icons.person_outline),
                    // Border uses global theme
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu cédula';
                    }
                    // Optional: Add more specific cedula format validation
                    // e.g., if (!RegExp(r'^\d{3}-?\d{7}-?\d{1}$').hasMatch(value)) { ... }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Input Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration( // Need InputDecoration to add suffixIcon
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    // Add suffix icon to toggle password visibility
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword, // Control password visibility
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    // Optional: Add password complexity rules if needed
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Error Message Display Area
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Login Button or Loading Indicator
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon( // Use ElevatedButton.icon for better visual cue
                        icon: const Icon(Icons.login),
                        label: const Text('Iniciar Sesión'),
                        onPressed: _submitLogin, // Call the login handler
                        // Style is inherited from the global theme
                      ),
                const SizedBox(height: 16),

                // Forgot Password Button
                TextButton(
                  // Disable button briefly if login is in progress
                  onPressed: _isLoading ? null : () {
                    // Navigate to the Forgot Password page using its route name
                    Navigator.pushNamed(context, ForgotPasswordPage.routeName);
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),

                 // Optional: Add a button/link for registration if needed
                 // TextButton(
                 //   onPressed: _isLoading ? null : () {
                 //     // Navigator.pushNamed(context, RegisterPage.routeName); // If you have a registration page
                 //   },
                 //   child: const Text('¿No tienes cuenta? Regístrate'),
                 // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}