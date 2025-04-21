import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const routeName = '/acerca-de';

  final String nombre = 'Darlin';
  final String apellido = 'De la Nieve';
  final String matricula = '2021-2292';
  final String correo = '20212292@itla.edu.do';
  final String telefono = '8094990201';
  final String telegramUser = 'Darlin1997';
  final String fotoAssetPath = 'assets/images/darlin.jpg';

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: telefono);
    if (!await launchUrl(phoneUri)) {
      print('No se pudo lanzar la llamada a $telefono');
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: correo,
      query: 'subject=Contacto desde App Defensa Civil&body=Hola Darlin,',
    );
    if (!await launchUrl(emailUri)) {
      print('No se pudo lanzar el correo a $correo');
    }
  }

  Future<void> _launchTelegram() async {
    final Uri telegramUri = Uri.parse('https://t.me/$telegramUser');
    if (!await launchUrl(telegramUri, mode: LaunchMode.externalApplication)) {
      print('No se pudo abrir Telegram para $telegramUser');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey[300],
                backgroundImage: AssetImage(fotoAssetPath),
                onBackgroundImageError: (exception, stackTrace) {
                  print("Error cargando imagen: $exception");
                },
                child: Image.asset('assets/images/darlin.jpg'),
              ),
              const SizedBox(height: 20),
              Text(
                '$nombre $apellido',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                'Matrícula: $matricula',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 15),
              Text(
                'Contacto',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.phone_outlined, color: Colors.indigo),
                title: Text(telefono),
                onTap: _launchPhone,
                visualDensity: VisualDensity.compact,
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.indigo),
                title: Text(correo),
                onTap: _launchEmail,
                visualDensity: VisualDensity.compact,
              ),
              ListTile(
                leading: const Icon(Icons.send_outlined, color: Colors.blue),
                title: Text('@$telegramUser (Telegram)'),
                onTap: _launchTelegram,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}