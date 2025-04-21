import 'package:flutter/material.dart';
import '../models/situation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import 'situation_detail_page.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';

class MySituationsPage extends StatefulWidget {
  const MySituationsPage({super.key});

  static const routeName = '/my-situations';

  @override
  State<MySituationsPage> createState() => _MySituationsPageState();
}

class _MySituationsPageState extends State<MySituationsPage> {
  late Future<List<Situation>> _situationsFuture;
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadSituations();
  }

  void _loadSituations() {
    final token = _authService.token;
    if (token != null) {
      setState(() {
        _situationsFuture = _apiService.fetchMySituations(token);
      });
    } else {
      setState(() {
        _situationsFuture = Future.error('Usuario no autenticado.');
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_authService.isLoggedIn) {
          Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, inicia sesión para ver tus situaciones.')),
          );
        }
      });
    }
  }

  void _navigateToDetail(Situation situation) {
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SituationDetailPage(situation: situation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_authService.isLoggedIn) {
      return Scaffold(
          appBar: AppBar(title: const Text('Mis Situaciones')),
           drawer: const AppDrawer(),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Debes iniciar sesión para ver tus situaciones reportadas.',
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 16),
              ),
            )
          ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Situaciones Reportadas'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadSituations();
          await _situationsFuture;
        },
        child: FutureBuilder<List<Situation>>(
          future: _situationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                        Text(
                          'Error al cargar situaciones:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                         const SizedBox(height: 20),
                         ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            onPressed: _loadSituations,
                         )
                     ],
                  )
                ),
              );
            }
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No has reportado ninguna situación aún.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              );
            }
            else {
              final situations = snapshot.data!;
              return ListView.builder(
                itemCount: situations.length,
                itemBuilder: (context, index) {
                  final situation = situations[index];

                  final String formattedDate;
                  if (situation.createdAt != null) {
                    formattedDate = DateFormat('dd/MM/yyyy hh:mm a', 'es_DO')
                                     .format(situation.createdAt!);
                  } else {
                    formattedDate = 'Fecha desconocida';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      leading: CircleAvatar(
                         backgroundColor: Colors.orange.shade100,
                         child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      ),
                      title: Text(
                        situation.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('Fecha: $formattedDate'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _navigateToDetail(situation),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}