import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import 'login_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  static const routeName = '/change-password';

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;


  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePassword() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) return;

    final token = _authService.token;
    if (token == null) {
      setState(() {
        _errorMessage = "Error: Sesión no válida. Por favor, inicia sesión de nuevo.";
      });
      _redirectToLogin();
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final result = await _apiService.changePassword(
        token: token,
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      if (result['exito'] == true) {
        setState(() {
          _successMessage = result['mensaje'] ?? 'Contraseña cambiada con éxito.';
          _errorMessage = null;
          _formKey.currentState?.reset();
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(_successMessage!),
            backgroundColor: Colors.green,
          ),
         );
      } else {
        setState(() {
          _errorMessage = result['mensaje'] ?? 'Error al cambiar la contraseña.';
          _successMessage = null;
        });
      }

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Error de conexión: ${e.toString()}";
        _successMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

   void _redirectToLogin() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
           Navigator.of(context).pushNamedAndRemoveUntil(
              LoginPage.routeName, (route) => false);
        }
     });
   }

  @override
  Widget build(BuildContext context) {
     if (!_authService.isLoggedIn) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
             Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor, inicia sesión.')),
             );
          }
       });
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
     }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _oldPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña Actual',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureOld = !_obscureOld),
                    ),
                  ),
                  obscureText: _obscureOld,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su contraseña actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                     prefixIcon: const Icon(Icons.lock_outline),
                     suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  obscureText: _obscureNew,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una nueva contraseña';
                    }
                    if (value.length < 4) {
                      return 'La contraseña debe tener al menos 4 caracteres';
                    }
                    if (value == _oldPasswordController.text) {
                       return 'La nueva contraseña debe ser diferente a la actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nueva Contraseña',
                     prefixIcon: const Icon(Icons.lock_outline),
                     suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  obscureText: _obscureConfirm,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirme la nueva contraseña';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Las contraseñas nuevas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Cambios'),
                        onPressed: _submitChangePassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}