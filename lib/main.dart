import 'package:flutter/material.dart';
import 'widgets/general_app_bar.dart';
import 'widgets/app_drawer.dart';
import 'view/actividades_view.dart';
import 'package:provider/provider.dart';
import 'viewModels/actividades_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ActividadViewModel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Créditos Complementarios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {'/actividades': (context) => const ActividadView()},
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeneralAppBar(), // <- Aquí ya no necesitas pasar `title`
      drawer: const AppDrawer(), // Aquí es donde se agrega el Drawer
      body: const Center(
        child: Text(
          'Bienvenido a Créditos Complementarios',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
