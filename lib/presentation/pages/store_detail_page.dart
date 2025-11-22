import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import 'store_management_page.dart';

class StoreDetailPage extends StatefulWidget {
  final Store store;

  const StoreDetailPage({
    super.key,
    required this.store,
  });

  static const routeName = '/store-detail';

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  late Store _store;
  bool _isEditing = false;
  
  // Controladores para los campos editables
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _managerController;
  late TextEditingController _monthlySalesController;
  late TextEditingController _ratingController;
  bool _isOpen = true;

  @override
  void initState() {
    super.initState();
    _store = widget.store;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _store.name);
    _locationController = TextEditingController(text: _store.location);
    _managerController = TextEditingController(text: _store.manager);
    _monthlySalesController = TextEditingController(text: _store.monthlySales.toStringAsFixed(2));
    _ratingController = TextEditingController(text: _store.rating.toStringAsFixed(1));
    _isOpen = _store.isOpen;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _managerController.dispose();
    _monthlySalesController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Si se cancela la edición, restaurar valores originales
        _initializeControllers();
      }
    });
  }

  void _saveChanges() {
    // Validar campos
    if (_nameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _managerController.text.isEmpty ||
        _monthlySalesController.text.isEmpty ||
        _ratingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar ventas mensuales y rating
    final monthlySales = double.tryParse(_monthlySalesController.text);
    final rating = double.tryParse(_ratingController.text);

    if (monthlySales == null || monthlySales < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las ventas mensuales deben ser un número válido mayor o igual a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (rating == null || rating < 0 || rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El rating debe ser un número entre 0 y 5'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crear tienda actualizada
    setState(() {
      _store = Store(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        manager: _managerController.text.trim(),
        icon: _store.icon,
        color: _store.color,
        monthlySales: monthlySales,
        isOpen: _isOpen,
        rating: rating,
      );
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tienda guardada exitosamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteStore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tienda'),
        content: Text('¿Estás seguro de que deseas eliminar la tienda "${_store.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Volver a la lista
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tienda "${_store.name}" eliminada exitosamente'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              // TODO: Llamar a la API para eliminar la tienda
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Detalle de la tienda',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel de imágenes
            _buildImageCarousel(),
            
            // Detalles de la tienda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la tienda
                  _buildEditableField(
                    label: 'Nombre',
                    controller: _nameController,
                    icon: Icons.store_outlined,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  
                  // Ubicación
                  _buildEditableField(
                    label: 'Ubicación',
                    controller: _locationController,
                    icon: Icons.location_on_outlined,
                    isEditing: _isEditing,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Gerente
                  _buildEditableField(
                    label: 'Gerente',
                    controller: _managerController,
                    icon: Icons.person_outline,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  
                  // Ventas mensuales y Rating en fila
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditableField(
                          label: 'Ventas Mensuales',
                          controller: _monthlySalesController,
                          icon: Icons.attach_money,
                          isEditing: _isEditing,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEditableField(
                          label: 'Rating',
                          controller: _ratingController,
                          icon: Icons.star_outline,
                          isEditing: _isEditing,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Estado (Abierta/Cerrada)
                  _buildStatusField(),
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    // Si hay imágenes reales, usarlas; si no, crear placeholders con el icono
    if (_store.images.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: ImageCarousel(
          images: _store.images,
          height: 250,
          autoPlay: false,
          showIndicators: true,
          showNavigationArrows: true,
          borderRadius: BorderRadius.circular(16),
        ),
      );
    } else {
      // Mostrar carousel con iconos de la tienda como placeholder
      return Container(
        margin: const EdgeInsets.all(16),
        height: 250,
        decoration: BoxDecoration(
          color: _store.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _store.icon,
                size: 80,
                color: _store.color,
              ),
              const SizedBox(height: 16),
              Text(
                _store.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _store.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditing,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF007AFF),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: _store.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatusField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isEditing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.store_outlined,
              size: 24,
              color: _store.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _isOpen ? 'Abierta' : 'Cerrada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: _isOpen,
                        onChanged: (value) {
                          setState(() {
                            _isOpen = value;
                          });
                        },
                        activeColor: const Color(0xFF007AFF),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.store_outlined,
              size: 24,
              color: _store.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isOpen
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isOpen ? 'Abierta' : 'Cerrada',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isOpen ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return Column(
        children: [
          // Botón Guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Botón Cancelar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _toggleEditMode,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF007AFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF007AFF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          // Botón Editar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleEditMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Editar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Botón Eliminar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _deleteStore,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

