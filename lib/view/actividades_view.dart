import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewModels/actividades_viewmodel.dart';

class ActividadView extends StatefulWidget {
  const ActividadView({super.key});

  @override
  State<ActividadView> createState() => _ActividadViewState();
}

class _ActividadViewState extends State<ActividadView> {
  @override
  void initState() {
    super.initState();
    // Ejecutar fetchActividades después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ActividadViewModel>(context, listen: false);
      viewModel.fetchActividades();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final viewModel = Provider.of<ActividadViewModel>(
                context,
                listen: false,
              );
              viewModel.fetchActividades();
            },
          ),
        ],
      ),
      body: Consumer<ActividadViewModel>(
        builder: (context, viewModel, child) {
          // Mostrar loading
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando actividades...'),
                ],
              ),
            );
          }

          // Mostrar error si existe
          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar actividades',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.fetchActividades();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Si no hay actividades
          if (viewModel.actividades.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay actividades disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Mostrar la tabla con actividades
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Actividad')),
                  DataColumn(label: Text('Créditos')),
                  DataColumn(label: Text('Ubicación')),
                  DataColumn(label: Text('Categoría')),
                  DataColumn(label: Text('Encargado')),
                ],
                rows:
                    viewModel.actividades.map((actividad) {
                      return DataRow(
                        cells: [
                          DataCell(Text(actividad.actividad ?? 'N/A')),
                          DataCell(Text('${actividad.creditos ?? 0}')),
                          DataCell(Text(actividad.ubicacion ?? 'N/A')),
                          DataCell(Text(actividad.categoria?.nombre ?? 'N/A')),
                          DataCell(
                            Text(
                              '${actividad.encargado?.nombres ?? ''} ${actividad.encargado?.apellido1 ?? ''}'
                                      .trim()
                                      .isEmpty
                                  ? 'N/A'
                                  : '${actividad.encargado?.nombres ?? ''} ${actividad.encargado?.apellido1 ?? ''}'
                                      .trim(),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
