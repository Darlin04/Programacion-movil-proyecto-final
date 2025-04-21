import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/';

  HomePage({super.key});

  final List<String> imgList = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKgGH49s33faKbgNwqsKKHciQB-Gp6bF9VvQ&s',
    'https://presidencia.gob.do/sites/default/files/news/2022-10/310690518_170442345577808_2718689553182378246_n%20%281%29.jpg',
    'https://www.magisfm.ipl.edu.do/images/2019/10/24/defensa.png'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slider de Imágenes'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            height: 300.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            aspectRatio: 16/9,
            viewportFraction: 0.8,
          ),
          items: imgList.map((item) => Container(
            margin: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              child: Image.network(
                item,
                fit: BoxFit.cover,
                width: 1000.0,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 40));
                },
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}