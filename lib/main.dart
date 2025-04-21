
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/change_password_page.dart'; 
import 'screens/report_situation_page.dart';
import 'screens/my_situations_page.dart';
import 'screens/situations_map_page.dart'; 
import 'screens/video_page.dart';
import 'screens/news_page.dart';
import 'screens/services_page.dart';
import 'screens/videos_page.dart';
import 'screens/albergues_page.dart';
import 'screens/albergues_map_page.dart';
import 'screens/medidas_preventivas_page.dart';
import 'screens/miembros_page.dart';
import 'screens/volunteer_form_page.dart';
import 'screens/about_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_DO', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Defensa Civil App',
      theme: _buildThemeData(),
      initialRoute: HomePage.routeName,
      routes: _buildRoutes(),
      onUnknownRoute: _handleUnknownRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primarySwatch: Colors.indigo,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
           borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        focusedBorder: OutlineInputBorder(
           borderSide: BorderSide(color: Colors.indigoAccent, width: 2.0),
           borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        filled: true,
        fillColor: Colors.white70,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.indigo,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
       appBarTheme: AppBarTheme(
         backgroundColor: Colors.indigo[600],
         foregroundColor: Colors.white,
         elevation: 1.0,
         centerTitle: true,
      ),
       cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      HomePage.routeName: (ctx) => HomePage(),
      LoginPage.routeName: (ctx) => const LoginPage(),
      ForgotPasswordPage.routeName: (ctx) => const ForgotPasswordPage(),
      ChangePasswordPage.routeName: (ctx) => const ChangePasswordPage(), 

      ReportSituationPage.routeName: (ctx) => const ReportSituationPage(),
      MySituationsPage.routeName: (ctx) => const MySituationsPage(),
      SituationsMapPage.routeName: (ctx) => const SituationsMapPage(), 

      NewsPage.routeName: (ctx) => const NewsPage(),
      ServicesPage.routeName: (ctx) => const ServicesPage(),
      VideoPage.routeName: (ctx) => const VideoPage(),
      VideosPage.routeName: (ctx) => const VideosPage(),
      AlberguesPage.routeName: (ctx) => const AlberguesPage(),
      AlberguesMapPage.routeName: (ctx) => const AlberguesMapPage(),
      MedidasPreventivasPage.routeName: (ctx) => const MedidasPreventivasPage(),
      MiembrosPage.routeName: (ctx) => const MiembrosPage(),
      VolunteerFormPage.routeName: (ctx) => const VolunteerFormPage(),
      AboutPage.routeName: (ctx) => const AboutPage(),
    };
  }

   Route<dynamic> _handleUnknownRoute(RouteSettings settings) {
    print("ALERTA: Navegando a ruta desconocida: ${settings.name}");
    return MaterialPageRoute(builder: (ctx) => HomePage());
   }
}