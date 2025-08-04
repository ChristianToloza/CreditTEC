import 'package:flutter/material.dart';
import 'package:mobile/view/actividades_formview.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewModels/actividades_viewmodel.dart';
import 'package:mobile/widgets/app_drawer.dart';
import 'package:mobile/widgets/general_app_bar.dart';

class ActividadView extends StatefulWidget {
  const ActividadView({super.key});

  @override
  State<ActividadView> createState() => _ActividadViewState();
}

class _ActividadViewState extends State<ActividadView> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoriaId;
  String? _selectedEncargadoId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ActividadViewModel>(context, listen: false);
      viewModel.fetchActividades();
      viewModel.cargarDatosFormulario();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeneralAppBar(),
      drawer: const AppDrawer(),
      body: Consumer<ActividadViewModel>(
        builder: (context, viewModel, child) {
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

          if (viewModel.errorMessage != null) {
            return _buildErrorView(viewModel);
          }

          if (viewModel.actividades.isEmpty) {
            return _buildEmptyView();
          }

          final actividadesFiltradas =
              viewModel.actividades.where((actividad) {
                final matchesSearch =
                    actividad.actividad?.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ) ??
                    false;
                final matchesCategoria =
                    _selectedCategoriaId == null ||
                    actividad.categoria.id == _selectedCategoriaId;
                final matchesEncargado =
                    _selectedEncargadoId == null ||
                    actividad.encargado.id == _selectedEncargadoId;
                return matchesSearch && matchesCategoria && matchesEncargado;
              }).toList();

          return Column(
            children: [
              _buildFiltros(viewModel),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Actividad')),
                        DataColumn(label: Text('Créditos')),
                        DataColumn(label: Text('Ubicación')),
                        DataColumn(label: Text('Categoría')),
                        DataColumn(label: Text('Encargado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows:
                          actividadesFiltradas.map((actividad) {
                            return DataRow(
                              cells: [
                                DataCell(Text(actividad.actividad ?? 'N/A')),
                                DataCell(Text('${actividad.creditos ?? 0}')),
                                DataCell(Text(actividad.ubicacion ?? 'N/A')),
                                DataCell(
                                  Text(actividad.categoria?.nombre ?? 'N/A'),
                                ),
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
                                DataCell(
                                  PopupMenuButton(
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'editar',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                SizedBox(width: 8),
                                                Text('Editar'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'eliminar',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Eliminar',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                    onSelected: (value) async {
                                      if (value == 'eliminar') {
                                        _confirmarEliminar(
                                          actividad.id,
                                          actividad.actividad ?? 'N/A',
                                        );
                                      } else if (value == 'editar') {
                                        final result = await Navigator.push<
                                          bool
                                        >(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    FormularioActividadScreen(
                                                      actividadExistente:
                                                          actividad,
                                                    ),
                                          ),
                                        );

                                        if (result == true && mounted) {
                                          Provider.of<ActividadViewModel>(
                                            context,
                                            listen: false,
                                          ).fetchActividades();
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarAFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Actividad'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No hay actividades registradas',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón "+" para crear la primera',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ActividadViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al cargar actividades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade600),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    viewModel.fetchActividades();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    viewModel.diagnosticarConexion();
                  },
                  icon: const Icon(Icons.network_check),
                  label: const Text('Diagnóstico'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navegarAFormulario() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const FormularioActividadScreen(),
      ),
    );

    if (result == true && mounted) {
      Provider.of<ActividadViewModel>(
        context,
        listen: false,
      ).fetchActividades();
    }
  }

  Future<void> _confirmarEliminar(String? id, String nombre) async {
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Estás seguro de eliminar la actividad "$nombre"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Eliminando actividad...'),
            duration: Duration(seconds: 1),
          ),
        );

        final success = await Provider.of<ActividadViewModel>(
          context,
          listen: false,
        ).eliminarActividad(id);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Actividad "$nombre" eliminada exitosamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Provider.of<ActividadViewModel>(
            context,
            listen: false,
          ).fetchActividades();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al eliminar la actividad: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildFiltros(ActividadViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros de búsqueda',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedCategoriaId = null;
                    _selectedEncargadoId = null;
                  });
                },
                icon: const Icon(Icons.clear_all, size: 20),
                label: const Text('Limpiar'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar por nombre',
              hintText: 'Escribe el nombre de la actividad',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedCategoriaId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Categoría',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            hint: const Text('Todas las categorías'),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Todas las categorías'),
              ),
              ...viewModel.categorias.map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria.id,
                  child: Text(categoria.nombre),
                );
              }).toList(),
            ],
            onChanged: (newValue) {
              setState(() {
                _selectedCategoriaId = newValue;
              });
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedEncargadoId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Encargado',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            hint: const Text('Todos los encargados'),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Todos los encargados'),
              ),
              ...viewModel.encargados.map((encargado) {
                return DropdownMenuItem<String>(
                  value: encargado.id,
                  child: Text(
                    '${encargado.nombres} ${encargado.apellido1}'.trim(),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ],
            onChanged: (newValue) {
              setState(() {
                _selectedEncargadoId = newValue;
              });
            },
          ),
        ],
      ),
    );
  }
}
