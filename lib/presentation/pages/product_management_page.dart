import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/services/auth_service.dart';
import '../widgets/widgets.dart';
import 'product_detail_page.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  List<Product> _products = [];
  String _productSearchQuery = '';
  bool _isLoading = true;
  
  // Getter para productos filtrados según búsqueda
  List<Product> get _filteredProducts {
    if (_productSearchQuery.trim().isEmpty) {
      return _products;
    }
    final query = _productSearchQuery.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(query);
    }).toList();
  }
  
  // Paginación de productos
  int _currentPage = 0;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts(page: 0, reset: true);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Cargar más cuando se está cerca del final (200px antes)
      if (!_isLoadingMore && _hasMorePages && !_isLoading) {
        _loadMoreProducts();
      }
    }
  }
  
  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMorePages) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      await _loadProducts(
        page: _currentPage + 1,
        size: 10,
        reset: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadProducts({int page = 0, int size = 10, bool reset = true}) async {
    if (reset) {
      setState(() => _isLoading = true);
    }
    
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay token de autenticación disponible'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        if (reset) {
          _products = [];
        }
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8080/api/products?page=$page&size=$size'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Products API response status: ${response.statusCode}');
        print('Products API response body: $responseBody');

        if (responseBody.isEmpty) {
          print('Response body is empty');
          if (reset) {
            _products = [];
          }
          if (mounted) {
            setState(() {
              _hasMorePages = false;
            });
          }
          return;
        }

        final decodedData = json.decode(responseBody);
        print('Decoded data type: ${decodedData.runtimeType}');

        // La API devuelve un objeto JSON con paginación:
        // {
        //   "content": [...],           // JSON array con los productos
        //   "totalElements": 300,
        //   "currentPage": 0,
        //   "pageSize": 10,
        //   "hasNext": true,
        //   "hasPrevious": false
        // }
        
        List<dynamic> data;
        bool hasNext = false;
        
        // Verificar que la respuesta es un objeto JSON (Map)
        if (decodedData is Map) {
          final responseObject = decodedData as Map;
          
          // Extraer el array de productos de la propiedad 'content'
          if (responseObject.containsKey('content')) {
            final contentArray = responseObject['content'];
            if (contentArray is List) {
              data = contentArray;
            } else {
              print('Error: content is not a List, type: ${contentArray.runtimeType}');
              data = [];
            }
            
            // Extraer información de paginación
            if (responseObject.containsKey('hasNext')) {
              hasNext = responseObject['hasNext'] == true;
            }
            
            // Log de información de paginación para debugging
            final totalElements = responseObject['totalElements'];
            final currentPage = responseObject['currentPage'];
            final pageSize = responseObject['pageSize'];
            print('Paginated response - content: ${data.length} items, totalElements: $totalElements, currentPage: $currentPage, pageSize: $pageSize, hasNext: $hasNext');
          } else {
            print('Error: Response object does not contain "content" property. Available keys: ${responseObject.keys.toList()}');
            if (reset) {
              _products = [];
            }
            if (mounted) {
              setState(() {
                _hasMorePages = false;
              });
            }
            return;
          }
        } else {
          print('Error: Response is not a JSON object. Type: ${decodedData.runtimeType}');
          if (reset) {
            _products = [];
          }
          if (mounted) {
            setState(() {
              _hasMorePages = false;
            });
          }
          return;
        }

        print('Number of products received: ${data.length}');

        final newProducts = data.map((item) {
          print('Mapping product item: $item');

          // Obtener el ID del producto
          final idProduct = item['idProduct'] is int
              ? item['idProduct'] as int
              : (item['idProduct'] as num?)?.toInt();

          // Obtener el nombre
          final name = item['name']?.toString() ?? 'Producto ${idProduct ?? 'N/A'}';

          // Obtener el precio
          double price = 0.0;
          if (item['price'] != null) {
            price = (item['price'] is num)
                ? (item['price'] as num).toDouble()
                : double.tryParse(item['price'].toString()) ?? 0.0;
          }

          // Obtener el estado
          final status = item['status']?.toString() ?? 'Inactive';
          final isAvailable = status == 'Active';

          // Obtener fecha de expiración
          final expirationDate = item['expirationDate']?.toString();

          // Obtener stock si está disponible
          int stock = 0;
          if (item['stock'] != null) {
            stock = (item['stock'] is int)
                ? item['stock'] as int
                : (item['stock'] as num?)?.toInt() ?? 0;
          }

          // Mapear a Product con valores por defecto para campos que no vienen del API
          return Product(
            name: name,
            category: 'General', // No viene del API
            brand: 'Mamuka', // No viene del API
            description: expirationDate != null
                ? 'Fecha de expiración: $expirationDate'
                : 'Producto ${name}',
            icon: Icons.inventory_2_outlined,
            color: Product._getProductColor(idProduct ?? 0),
            price: price,
            stock: stock,
            isAvailable: isAvailable,
          );
        }).toList();

        print('New products mapped: ${newProducts.length}');

        if (mounted) {
          setState(() {
            if (reset) {
              _products = newProducts;
            } else {
              _products.addAll(newProducts);
            }
            _currentPage = page;
            _hasMorePages = hasNext;
            print('State updated, products count: ${_products.length}, hasMore: $_hasMorePages, page: $page');
          });
        }
      } else {
        print('Error loading products: ${response.statusCode} - ${response.body}');
        if (reset) {
          _products = [];
        }
        if (mounted) {
          setState(() {
            _hasMorePages = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar productos: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading products: $e');
      if (reset) {
        _products = [];
      }
      if (mounted) {
        setState(() {
          _hasMorePages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar productos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted && reset) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<SearchResult>> _searchProducts(String query) async {
    // Simular búsqueda con delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filtered = _filteredProducts
        .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .map((product) => SearchResult(
              title: product.name,
              subtitle: '${product.category} - \$${product.price.toStringAsFixed(2)}',
              icon: product.icon,
              data: product,
            ))
        .toList();
    
    return filtered;
  }


  void _showProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Lista de Productos',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: _isLoading && _filteredProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Buscador
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomSearchBar(
                    hintText: 'Buscar productos...',
                    onSearch: _searchProducts,
                    showOverlay: false,
                    onQueryChanged: (query) {
                      setState(() {
                        _productSearchQuery = query;
                      });
                    },
                    onResultSelected: (result) {
                      final product = result.data as Product;
                      _showProductDetail(product);
                    },
                  ),
                ),
                
                // Lista de productos
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No hay productos disponibles',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _loadProducts(page: 0, reset: true),
                                child: const Text('Recargar'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredProducts.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _filteredProducts.length) {
                              final product = _filteredProducts[index];
                              return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: product.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    product.icon,
                                    color: product.color,
                                    size: 28,
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.brand} • ${product.category}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF007AFF),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: product.isAvailable 
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Stock: ${product.stock}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: product.isAvailable 
                                                  ? Colors.green 
                                                  : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                onTap: () => _showProductDetail(product),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                tileColor: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF2C2C2E)
                                    : const Color(0xFFF8F9FA),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            );
                            } else {
                              // Indicador de carga al final
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2,
        onTap: (index) {
          // Navegación del bottom bar si es necesario
          if (index != 2) {
            Navigator.of(context).pop();
          }
        },
        items: const [
          BottomBarItem(
            icon: Icons.warehouse_outlined,
            activeIcon: Icons.warehouse,
            label: 'Almacenes',
          ),
          BottomBarItem(
            icon: Icons.store_outlined,
            activeIcon: Icons.store,
            label: 'Tiendas',
          ),
          BottomBarItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            label: 'Productos',
          ),
          BottomBarItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: 'Reportes',
          ),
        ],
      ),
      floatingActionButton: (AuthService.isAdmin || AuthService.isEmployee)
          ? FloatingActionButton(
              onPressed: _showCreateProductForm,
              backgroundColor: const Color(0xFF007AFF),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showCreateProductForm() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final brandController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        bool isAvailable = true;
        IconData selectedIcon = Icons.inventory_2_outlined;
        Color selectedColor = Colors.blue;
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Title
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nuevo Producto',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    
                    // Form
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                controller: nameController,
                                label: 'Nombre',
                                icon: Icons.label_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El nombre es requerido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: categoryController,
                                label: 'Categoría',
                                icon: Icons.category_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La categoría es requerida';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: brandController,
                                label: 'Marca',
                                icon: Icons.branding_watermark_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La marca es requerida';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: descriptionController,
                                label: 'Descripción',
                                icon: Icons.description_outlined,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La descripción es requerida';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: priceController,
                                      label: 'Precio',
                                      icon: Icons.attach_money,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'El precio es requerido';
                                        }
                                        if (double.tryParse(value) == null || double.parse(value) < 0) {
                                          return 'Precio inválido';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: stockController,
                                      label: 'Stock',
                                      icon: Icons.inventory_2_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'El stock es requerido';
                                        }
                                        if (int.tryParse(value) == null || int.parse(value) < 0) {
                                          return 'Stock inválido';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildAvailabilitySwitch(
                                value: isAvailable,
                                onChanged: (value) {
                                  setModalState(() {
                                    isAvailable = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Save button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final newProduct = Product(
                                name: nameController.text.trim(),
                                category: categoryController.text.trim(),
                                brand: brandController.text.trim(),
                                description: descriptionController.text.trim(),
                                icon: selectedIcon,
                                color: selectedColor,
                                price: double.parse(priceController.text),
                                stock: int.parse(stockController.text),
                                isAvailable: isAvailable,
                              );
                              
                              setState(() {
                                _products.add(newProduct);
                              });
                              
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Producto creado exitosamente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
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
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilitySwitch({
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 24,
                color: value ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                'Disponible',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF007AFF),
          ),
        ],
      ),
    );
  }
}

// Modelo de datos para productos
class Product {
  final String name;
  final String category;
  final String brand;
  final String description;
  final IconData icon;
  final Color color;
  final double price;
  final int stock;
  final bool isAvailable;
  final List<String> images;

  Product({
    required this.name,
    required this.category,
    required this.brand,
    required this.description,
    required this.icon,
    required this.color,
    required this.price,
    required this.stock,
    required this.isAvailable,
    this.images = const [],
  });
  
  // Helper para obtener colores diferentes según el ID
  static Color _getProductColor(int id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.amber,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[id % colors.length];
  }

  static List<Product> sampleProducts() {
    return [
      Product(
        name: 'Lámpara LED Moderna',
        category: 'Iluminación',
        brand: 'LightPro',
        description: 'Lámpara LED de diseño moderno con control remoto y múltiples tonalidades de luz.',
        icon: Icons.lightbulb_outline,
        color: Colors.amber,
        price: 89.99,
        stock: 45,
        isAvailable: true,
      ),
      Product(
        name: 'Sofá Moderno 3 Plazas',
        category: 'Muebles',
        brand: 'ComfortHome',
        description: 'Sofá de 3 plazas con tapizado en tela premium y estructura de madera maciza.',
        icon: Icons.weekend,
        color: Colors.brown,
        price: 1299.99,
        stock: 8,
        isAvailable: true,
      ),
      Product(
        name: 'Mesa de Centro Cristal',
        category: 'Muebles',
        brand: 'GlassDesign',
        description: 'Mesa de centro con superficie de cristal templado y patas de acero inoxidable.',
        icon: Icons.table_restaurant,
        color: Colors.blue,
        price: 299.99,
        stock: 0,
        isAvailable: false,
      ),
      Product(
        name: 'Espejo Decorativo Redondo',
        category: 'Decoración',
        brand: 'MirrorArt',
        description: 'Espejo decorativo con marco dorado y diseño minimalista perfecto para cualquier ambiente.',
        icon: Icons.circle_outlined,
        color: Colors.orange,
        price: 159.99,
        stock: 23,
        isAvailable: true,
      ),
      Product(
        name: 'Planta Monstera Deliciosa',
        category: 'Plantas',
        brand: 'GreenLife',
        description: 'Planta tropical de interior con hojas grandes y perforadas, ideal para decoración.',
        icon: Icons.local_florist,
        color: Colors.green,
        price: 49.99,
        stock: 67,
        isAvailable: true,
      ),
      Product(
        name: 'Cojines Decorativos Set x4',
        category: 'Textiles',
        brand: 'SoftComfort',
        description: 'Set de 4 cojines decorativos con diferentes texturas y colores complementarios.',
        icon: Icons.crop_square,
        color: Colors.purple,
        price: 79.99,
        stock: 34,
        isAvailable: true,
      ),
      Product(
        name: 'Cortinas Blackout Premium',
        category: 'Textiles',
        brand: 'WindowStyle',
        description: 'Cortinas blackout que bloquean 100% la luz con sistema de instalación fácil.',
        icon: Icons.view_column,
        color: Colors.indigo,
        price: 199.99,
        stock: 15,
        isAvailable: true,
      ),
      Product(
        name: 'Alfombra Persa Clásica',
        category: 'Textiles',
        brand: 'Heritage',
        description: 'Alfombra con diseño persa tradicional tejida a mano con materiales de alta calidad.',
        icon: Icons.crop_din,
        color: Colors.red,
        price: 449.99,
        stock: 3,
        isAvailable: true,
      ),
      Product(
        name: 'Velas Aromáticas Set x6',
        category: 'Aromas',
        brand: 'ScentWorld',
        description: 'Set de 6 velas aromáticas con fragancias naturales y duración de 40 horas cada una.',
        icon: Icons.local_fire_department,
        color: Colors.pink,
        price: 29.99,
        stock: 89,
        isAvailable: true,
      ),
      Product(
        name: 'Marco de Fotos Digital',
        category: 'Electrónicos',
        brand: 'PhotoFrame',
        description: 'Marco digital de 10 pulgadas con conectividad WiFi y almacenamiento en la nube.',
        icon: Icons.inbox,
        color: Colors.teal,
        price: 189.99,
        stock: 12,
        isAvailable: true,
      ),
      Product(
        name: 'Organizador de Escritorio',
        category: 'Oficina',
        brand: 'DeskPro',
        description: 'Organizador multifuncional con compartimentos para documentos, bolígrafos y accesorios.',
        icon: Icons.inbox,
        color: Colors.grey,
        price: 39.99,
        stock: 56,
        isAvailable: true,
      ),
      Product(
        name: 'Humidificador Ultrasónico',
        category: 'Electrónicos',
        brand: 'AirFresh',
        description: 'Humidificador silencioso con aromaterapia y luces LED de 7 colores.',
        icon: Icons.air,
        color: Colors.cyan,
        price: 69.99,
        stock: 0,
        isAvailable: false,
      ),
    ];
  }
}