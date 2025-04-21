import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '../screens/video_page.dart';
import '../screens/news_page.dart';
import '../screens/videos_page.dart';
import '../screens/albergues_page.dart';
import '../screens/albergues_map_page.dart';
import '../screens/medidas_preventivas_page.dart';
import '../screens/miembros_page.dart';
import '../screens/volunteer_form_page.dart';
import '../screens/about_page.dart';
import '../screens/login_page.dart';
import '../screens/report_situation_page.dart';
import '../screens/my_situations_page.dart';
import '../screens/situations_map_page.dart';
import '../screens/change_password_page.dart';
import '../screens/services_page.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required String? currentRoute,
    required String routeName,
    required BuildContext context,
    VoidCallback? specificOnTap,
  }) {
    bool isSelected = currentRoute == routeName && routeName != LoginPage.routeName;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.08),
      onTap: specificOnTap ?? () {
        Navigator.pop(context);
        if (currentRoute != routeName) {
          if (routeName == ReportSituationPage.routeName ||
              routeName == MySituationsPage.routeName ||
              routeName == SituationsMapPage.routeName ||
              routeName == ChangePasswordPage.routeName ||
              routeName == VolunteerFormPage.routeName) {
             Navigator.pushNamed(context, routeName);
          } else {
             Navigator.pushReplacementNamed(context, routeName);
          }
        }
      },
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final authService = AuthService();

    return ValueListenableBuilder<String?>(
      valueListenable: authService.tokenNotifier,
      builder: (context, token, child) {
        final bool isLoggedIn = token != null;
        final String? userName = authService.userData?['nombre'];

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                       const Text(
                        'Defensa Civil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isLoggedIn
                            ? 'Voluntario: ${userName ?? 'Usuario'}'
                            : 'Menú Principal',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  )
              ),

              if (isLoggedIn) ...[
                _createDrawerItem(
                  icon: Icons.article_outlined,
                  text: 'Noticias',
                  currentRoute: currentRoute,
                  routeName: NewsPage.routeName,
                  context: context,
                ),
                _createDrawerItem(
                  icon: Icons.report_problem_outlined,
                  text: 'Reportar Situación',
                  currentRoute: currentRoute,
                  routeName: ReportSituationPage.routeName,
                  context: context,
                ),
                _createDrawerItem(
                   icon: Icons.list_alt_outlined,
                   text: 'Mis Situaciones',
                   currentRoute: currentRoute,
                   routeName: MySituationsPage.routeName,
                   context: context,
                ),
                 _createDrawerItem(
                    icon: Icons.map_outlined,
                    text: 'Mapa de Situaciones',
                    currentRoute: currentRoute,
                    routeName: SituationsMapPage.routeName,
                    context: context,
                 ),
                 _createDrawerItem(
                    icon: Icons.key_outlined,
                    text: 'Cambiar Contraseña',
                    currentRoute: currentRoute,
                    routeName: ChangePasswordPage.routeName,
                    context: context,
                 ),
                const Divider(thickness: 1, indent: 16, endIndent: 16),
                 _createDrawerItem(
                    icon: Icons.logout,
                    text: 'Cerrar Sesión',
                    currentRoute: currentRoute,
                    routeName: LoginPage.routeName,
                    context: context,
                    specificOnTap: () async {
                      Navigator.pop(context);
                      await authService.logout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        LoginPage.routeName,
                        (route) => false
                      );
                    },
                  ),

              ] else ...[
                _createDrawerItem(
                  icon: Icons.home_outlined,
                  text: 'Inicio',
                  currentRoute: currentRoute,
                  routeName: HomePage.routeName,
                  context: context,
                ),
                _createDrawerItem(
                  icon: Icons.video_library_outlined,
                  text: 'Historia',
                  currentRoute: currentRoute,
                  routeName: VideoPage.routeName,
                  context: context,
                ),
                 _createDrawerItem(
                   icon: Icons.design_services_outlined,
                   text: 'Servicios',
                   currentRoute: currentRoute,
                   routeName: ServicesPage.routeName,
                   context: context,
                 ),
                _createDrawerItem(
                  icon: Icons.article_outlined,
                  text: 'Noticias',
                  currentRoute: currentRoute,
                  routeName: NewsPage.routeName,
                  context: context,
                ),
                _createDrawerItem(
                  icon: Icons.play_circle_outline,
                  text: 'Videos',
                  currentRoute: currentRoute,
                  routeName: VideosPage.routeName,
                  context: context,
                ),
                 _createDrawerItem(
                   icon: Icons.business_outlined,
                   text: 'Albergues',
                   currentRoute: currentRoute,
                   routeName: AlberguesPage.routeName,
                   context: context,
                 ),
                 _createDrawerItem(
                   icon: Icons.map_outlined,
                   text: 'Mapa de Albergues',
                   currentRoute: currentRoute,
                   routeName: AlberguesMapPage.routeName,
                   context: context,
                 ),
                _createDrawerItem(
                  icon: Icons.shield_outlined,
                  text: 'Medidas Preventivas',
                  currentRoute: currentRoute,
                  routeName: MedidasPreventivasPage.routeName,
                  context: context,
                ),
                _createDrawerItem(
                  icon: Icons.groups_outlined,
                  text: 'Miembros',
                  currentRoute: currentRoute,
                  routeName: MiembrosPage.routeName,
                  context: context,
                ),
                 _createDrawerItem(
                   icon: Icons.volunteer_activism_outlined,
                   text: 'Quiero ser Voluntario',
                   currentRoute: currentRoute,
                   routeName: VolunteerFormPage.routeName,
                   context: context,
                 ),
                 _createDrawerItem(
                   icon: Icons.info_outline,
                   text: 'Acerca De',
                   currentRoute: currentRoute,
                   routeName: AboutPage.routeName,
                   context: context,
                 ),
                 const Divider(thickness: 1, indent: 16, endIndent: 16),
                 _createDrawerItem(
                    icon: Icons.login,
                    text: 'Iniciar Sesión',
                    currentRoute: currentRoute,
                    routeName: LoginPage.routeName,
                    context: context,
                  ),
              ]
            ],
          ),
        );
      },
    );
  }
}