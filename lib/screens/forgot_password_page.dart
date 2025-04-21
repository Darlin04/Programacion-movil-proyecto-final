import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static const routeName = '/forgot-password';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _feedbackMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _cedulaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitRecoveryRequest() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
      _isSuccess = false;
    });

    try {
      final result = await _apiService.recoverPassword(
        cedula: _cedulaController.text.trim(),
        email: _emailController.text.trim(),
      );

       if (mounted) {
         setState(() {
           _feedbackMessage = result['mensaje'];
           _isSuccess = result['exito'] ?? false;
           if (_isSuccess) {
              _cedulaController.clear();
              _emailController.clear();
           }
         });
       }

    } catch (e) {
      if (mounted) {
        setState(() {
          _feedbackMessage = "Ocurrió un error inesperado: $e";
          _isSuccess = false;
        });
      }
    } finally {
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
        title: const Text('Recuperar Contraseña'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                 const Text(
                   'Ingresa tu cédula y correo electrónico registrados para recuperar tu contraseña.',
                   textAlign: TextAlign.center,
                   style: TextStyle(fontSize: 16),
                 ),
                 const SizedBox(height: 24),
                TextFormField(
                  controller: _cedulaController,
                  decoration: const InputDecoration(
                    labelText: 'Cédula',
                    hintText: 'Ingresa tu número de cédula',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu cédula';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                     hintText: 'ejemplo@correo.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                       return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                if (_feedbackMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        color: _isSuccess ? Colors.green.shade700 : Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                       icon: const Icon(Icons.send_outlined),
                        label: const Text('Enviar Solicitud'),
                        onPressed: _submitRecoveryRequest,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}