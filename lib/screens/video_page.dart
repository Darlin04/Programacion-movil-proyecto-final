import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../widgets/app_drawer.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  static const routeName = '/video';

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late YoutubePlayerController _controller;
  final String videoId = 'eMXgS_U3p9g';

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video e Historia'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.amber,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.amber,
                  handleColor: Colors.amberAccent,
                ),
              ),
              const SizedBox(height: 24.0),

              Text(
                'Historia de la Defensa Civil Dominicana',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12.0),

              const Text('• Creada: 14 de junio de 1966 (Ley 257).'),
              const SizedBox(height: 8.0),

              const Text(
                  '• Propósito: Organizar y coordinar la respuesta del país ante desastres y emergencias para proteger a la población.'),
              const SizedBox(height: 8.0),

              const Text(
                  '• Evolución: Pasó de enfocarse solo en la respuesta a incluir también la prevención y mitigación de riesgos.'),
              const SizedBox(height: 8.0),

              const Text(
                  '• Actualidad: Es el brazo operativo de la Comisión Nacional de Emergencias (CNE) y se basa fuertemente en el trabajo de miles de voluntarios.'),
            ],
          ),
        ),
      ),
    );
  }
}