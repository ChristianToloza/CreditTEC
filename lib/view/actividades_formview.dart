import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/viewModels/actividades_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:mobile/models/actividades_model.dart';
import 'package:mobile/widgets/app_drawer.dart';
import 'package:mobile/widgets/general_app_bar.dart';

class FormularioActividadScreen extends StatefulWidget {
  final Actividad? actividadExistente;

  const FormularioActividadScreen({Key? key, this.actividadExistente})
    : super(key: key);

  @override
  State<FormularioActividadScreen> createState() =>
      _FormularioActividadScreenState();
}

class _FormularioActividadScreenState extends State<FormularioActividadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actividadController = TextEditingController();
  final _creditosController = TextEditingController();
  final _ubicacionController = TextEditingController();

  String? _selectedCategoriaId;
  String? _selectedEncargadoId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ActividadViewModel>().cargarDatosFormulario();

      if (widget.actividadExistente != null) {
        setState(() {
          _actividadController.text = widget.actividadExistente!.actividad;
          _creditosController.text =
              widget.actividadExistente!.creditos.toString();
          _ubicacionController.text = widget.actividadExistente!.ubicacion;
          _selectedCategoriaId = widget.actividadExistente!.categoria.id;
          _selectedEncargadoId = widget.actividadExistente!.encargado.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeneralAppBar(),
      drawer: const AppDrawer(),
      body: Consumer<ActividadViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              _buildFormulario(viewModel),
              if (viewModel.isLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormulario(ActividadViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),

            _buildActividadField(),
            const SizedBox(height: 16),

            _buildCreditosField(),
            const SizedBox(height: 16),

            _buildUbicacionField(),
            const SizedBox(height: 16),

            _buildCategoriaDropdown(viewModel),
            const SizedBox(height: 16),

            _buildEncargadoDropdown(viewModel),
            const SizedBox(height: 24),

            _buildBotones(viewModel),
            const SizedBox(height: 16),

            _buildMessages(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.add_circle, color: theme.primaryColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Nueva Actividad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                Text(
                  'Completa todos los campos obligatorios',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.primaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadField() {
    return TextFormField(
      controller: _actividadController,
      decoration: InputDecoration(
        labelText: 'Nombre de la Actividad *',
        hintText: 'Ej: Conferencia de Tecnología',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.event),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (value.trim().length < 3) {
          return 'Debe tener al menos 3 caracteres';
        }
        return null;
      },
      textCapitalization: TextCapitalization.sentences,
      maxLength: 100,
    );
  }

  Widget _buildCreditosField() {
    return TextFormField(
      controller: _creditosController,
      decoration: InputDecoration(
        labelText: 'Créditos *',
        hintText: 'Ej: 1.5 o 2.0',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.star),
        helperText: 'Valor decimal entre 0.1 y 10.0',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        final double? creditos = double.tryParse(value);
        if (creditos == null) {
          return 'Ingresa un número válido';
        }
        if (creditos <= 0) {
          return 'Los créditos deben ser mayor a 0';
        }
        if (creditos > 10) {
          return 'Los créditos no pueden ser mayor a 10';
        }
        return null;
      },
    );
  }

  Widget _buildUbicacionField() {
    return TextFormField(
      controller: _ubicacionController,
      decoration: InputDecoration(
        labelText: 'Ubicación *',
        hintText: 'Ej: Auditorio Principal',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.location_on),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
      maxLength: 50,
    );
  }

  Widget _buildCategoriaDropdown(ActividadViewModel viewModel) {
    return DropdownButtonFormField<String>(
      value:
          _selectedCategoriaId != null &&
                  viewModel.categorias.any(
                    (cat) => cat.id == _selectedCategoriaId,
                  )
              ? _selectedCategoriaId
              : null,
      decoration: InputDecoration(
        labelText: 'Categoría *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.category),
      ),
      hint: const Text('Selecciona una categoría'),
      items:
          viewModel.categorias.map((categoria) {
            return DropdownMenuItem<String>(
              value: categoria.id,
              child: Text(categoria.nombre),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoriaId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Selecciona una categoría';
        }
        return null;
      },
    );
  }

  Widget _buildEncargadoDropdown(ActividadViewModel viewModel) {
    return DropdownButtonFormField<String>(
      value:
          _selectedEncargadoId != null &&
                  viewModel.encargados.any(
                    (enc) => enc.id == _selectedEncargadoId,
                  )
              ? _selectedEncargadoId
              : null,
      decoration: InputDecoration(
        labelText: 'Encargado *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.person),
      ),
      hint: const Text('Selecciona un encargado'),
      items:
          viewModel.encargados.map((encargado) {
            return DropdownMenuItem<String>(
              value: encargado.id,
              child: Text('${encargado.nombres} ${encargado.apellido1}'),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedEncargadoId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Selecciona un encargado';
        }
        return null;
      },
    );
  }

  Widget _buildBotones(ActividadViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: viewModel.isLoading ? null : _insertarActividad,
            icon: const Icon(Icons.save),
            label: Text(
              viewModel.isLoading ? 'Guardando...' : 'Guardar Actividad',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: viewModel.isLoading ? null : _limpiarFormulario,
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessages(ActividadViewModel viewModel) {
    if (viewModel.errorMessage == null && viewModel.successMessage == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (viewModel.errorMessage != null)
          _buildErrorMessage(viewModel.errorMessage!),
        if (viewModel.successMessage != null)
          _buildSuccessMessage(viewModel.successMessage!),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red.shade700)),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade600),
            onPressed: () => context.read<ActividadViewModel>().clearMessages(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.green.shade600),
            onPressed: () => context.read<ActividadViewModel>().clearMessages(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Guardando actividad...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _insertarActividad() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<ActividadViewModel>();

    // Obtener los datos de categoría y encargado
    final categoria = viewModel.obtenerCategoriaPorId(
      _selectedCategoriaId ?? '',
    );
    final encargado = viewModel.obtenerEncargadoPorId(
      _selectedEncargadoId ?? '',
    );

    // Validaciones si categoria o encargado son nulos
    if (categoria == null || encargado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La categoría o el encargado no se encontraron'),
        ),
      );
      print('Error: Categoria o encargado son null');
      return;
    }

    if (categoria.id.isEmpty || categoria.nombre.isEmpty) {
      print('Error: Los datos de la categoría están incompletos');
      return;
    }
    if (encargado.id.isEmpty ||
        encargado.nombres.isEmpty ||
        encargado.apellido1.isEmpty) {
      print('Error: Los datos del encargado están incompletos');
      return;
    }

    final success =
        widget.actividadExistente != null
            ? await viewModel.actualizarActividad(
              widget.actividadExistente!.id,
              Actividad(
                id: widget.actividadExistente!.id,
                actividad: _actividadController.text.trim(),
                creditos: double.parse(_creditosController.text),
                ubicacion: _ubicacionController.text.trim(),
                categoria: categoria,
                encargado: encargado,
              ),
            )
            : await viewModel.insertarActividad(
              actividad: _actividadController.text.trim(),
              creditos: double.parse(_creditosController.text),
              ubicacion: _ubicacionController.text.trim(),
              idCategoria: categoria.id,
              categoriaNombre: categoria.nombre,
              idEncargado: encargado.id,
              encargadoNombre: encargado.nombres,
              encargadoApellido1: encargado.apellido1,
              encargadoApellido2: encargado.apellido2 ?? '',
              correoEncargado: encargado.correo,
            );

    // Manejar el éxito de la operación
    if (success) {
      _limpiarFormulario();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.actividadExistente != null
                  ? 'Actividad actualizada exitosamente'
                  : 'Actividad creada exitosamente',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    }
  }

  void _limpiarFormulario() {
    _actividadController.clear();
    _creditosController.clear();
    _ubicacionController.clear();
    setState(() {
      _selectedCategoriaId = null;
      _selectedEncargadoId = null;
    });
    context.read<ActividadViewModel>().clearMessages();
  }

  @override
  void dispose() {
    _actividadController.dispose();
    _creditosController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
}
