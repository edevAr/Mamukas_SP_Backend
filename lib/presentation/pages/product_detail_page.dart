import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import 'product_management_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  static const routeName = '/product-detail';

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _product;
  bool _isEditing = false;
  
  // Controladores para los campos editables
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _product.name);
    _categoryController = TextEditingController(text: _product.category);
    _brandController = TextEditingController(text: _product.brand);
    _descriptionController = TextEditingController(text: _product.description);
    _priceController = TextEditingController(text: _product.price.toStringAsFixed(2));
    _stockController = TextEditingController(text: _product.stock.toString());
    _isAvailable = _product.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
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
        _categoryController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar precio y stock
    final price = double.tryParse(_priceController.text);
    final stock = int.tryParse(_stockController.text);

    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El precio debe ser un número válido mayor o igual a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El stock debe ser un número entero válido mayor o igual a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crear producto actualizado
    setState(() {
      _product = Product(
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        brand: _brandController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _product.icon,
        color: _product.color,
        price: price,
        stock: stock,
        isAvailable: _isAvailable,
      );
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Producto guardado exitosamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que deseas eliminar el producto "${_product.name}"? Esta acción no se puede deshacer.'),
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
                  content: Text('Producto "${_product.name}" eliminado exitosamente'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              // TODO: Llamar a la API para eliminar el producto
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
        title: 'Detalle del producto',
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
            
            // Detalles del producto
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del producto
                  _buildEditableField(
                    label: 'Nombre',
                    controller: _nameController,
                    icon: Icons.label_outline,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  
                  // Categoría y Marca en fila
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditableField(
                          label: 'Categoría',
                          controller: _categoryController,
                          icon: Icons.category_outlined,
                          isEditing: _isEditing,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEditableField(
                          label: 'Marca',
                          controller: _brandController,
                          icon: Icons.branding_watermark_outlined,
                          isEditing: _isEditing,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Precio y Stock en fila
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditableField(
                          label: 'Precio',
                          controller: _priceController,
                          icon: Icons.attach_money,
                          isEditing: _isEditing,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEditableField(
                          label: 'Stock',
                          controller: _stockController,
                          icon: Icons.inventory_2_outlined,
                          isEditing: _isEditing,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Disponibilidad
                  _buildAvailabilityField(),
                  const SizedBox(height: 16),
                  
                  // Descripción
                  _buildEditableField(
                    label: 'Descripción',
                    controller: _descriptionController,
                    icon: Icons.description_outlined,
                    isEditing: _isEditing,
                    maxLines: 4,
                  ),
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
    if (_product.images.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: ImageCarousel(
          images: _product.images,
          height: 250,
          autoPlay: false,
          showIndicators: true,
          showNavigationArrows: true,
          borderRadius: BorderRadius.circular(16),
        ),
      );
    } else {
      // Mostrar carousel con iconos del producto como placeholder
      return Container(
        margin: const EdgeInsets.all(16),
        height: 250,
        decoration: BoxDecoration(
          color: _product.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _product.icon,
                size: 80,
                color: _product.color,
              ),
              const SizedBox(height: 16),
              Text(
                _product.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _product.color,
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
              color: _product.color,
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

  Widget _buildAvailabilityField() {
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
              Icons.check_circle_outline,
              size: 24,
              color: _product.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disponibilidad',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Switch(
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                    activeColor: const Color(0xFF007AFF),
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
              Icons.check_circle_outline,
              size: 24,
              color: _product.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disponibilidad',
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
                      color: _isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isAvailable ? 'Disponible' : 'No disponible',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isAvailable ? Colors.green : Colors.red,
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
              onPressed: _deleteProduct,
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

