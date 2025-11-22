import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/services/auth_service.dart';
import '../widgets/widgets.dart';
import 'warehouse_detail_page.dart';
import 'product_management_page.dart';

class WarehouseManagementPage extends StatefulWidget {
  const WarehouseManagementPage({super.key});

  @override
  State<WarehouseManagementPage> createState() => _WarehouseManagementPageState();
}

class _WarehouseManagementPageState extends State<WarehouseManagementPage> {
  List<Warehouse> _warehouses = [];
  String _warehouseSearchQuery = '';
  bool _isLoading = true;
  
  // Getter para almacenes filtrados según búsqueda
  List<Warehouse> get _filteredWarehouses {
    if (_warehouseSearchQuery.trim().isEmpty) {
      return _warehouses;
    }
    final query = _warehouseSearchQuery.toLowerCase();
    return _warehouses.where((warehouse) {
      return warehouse.name.toLowerCase().contains(query) ||
             warehouse.location.toLowerCase().contains(query);
    }).toList();
  }
  
  // Paginación de almacenes
  int _currentPage = 0;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadWarehouses(page: 0, reset: true);
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
        _loadMoreWarehouses();
      }
    }
  }
  
  Future<void> _loadMoreWarehouses() async {
    if (_isLoadingMore || !_hasMorePages) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      await _loadWarehouses(
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

  Future<void> _loadWarehouses({int page = 0, int size = 10, bool reset = true}) async {
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
          _warehouses = [];
        }
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8080/api/warehouses?page=$page&size=$size'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Warehouses API response status: ${response.statusCode}');
        print('Warehouses API response body: $responseBody');

        if (responseBody.isEmpty) {
          print('Response body is empty');
          if (reset) {
            _warehouses = [];
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
        //   "content": [...],           // JSON array con los almacenes
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
          
          // Extraer el array de almacenes de la propiedad 'content'
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
              _warehouses = [];
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
            _warehouses = [];
          }
          if (mounted) {
            setState(() {
              _hasMorePages = false;
            });
          }
          return;
        }

        print('Number of warehouses received: ${data.length}');

        final newWarehouses = data.map((item) {
          print('Mapping warehouse item: $item');

          // Obtener el ID del almacén
          final idWarehouse = item['idWarehouse'] is int
              ? item['idWarehouse'] as int
              : (item['idWarehouse'] as num?)?.toInt();

          // Obtener el nombre
          final name = item['name']?.toString() ?? 'Almacén ${idWarehouse ?? 'N/A'}';

          // Obtener la dirección
          final address = item['address']?.toString() ?? 'Sin dirección';

          // Obtener el estado
          final status = item['status']?.toString() ?? 'Inactive';
          final isActive = status == 'Active';

          // Obtener el conteo de productos
          int productCount = 0;
          if (item['products'] != null) {
            productCount = (item['products'] is int)
                ? item['products'] as int
                : (item['products'] as num?)?.toInt() ?? 0;
          }

          print('Mapped warehouse: $name - $address - products: $productCount - isActive: $isActive');

          return Warehouse(
            idWarehouse: idWarehouse,
            name: name,
            location: address,
            icon: Icons.warehouse,
            color: Warehouse._getWarehouseColor(idWarehouse ?? 0),
            productCount: productCount,
            isActive: isActive,
            capacity: 0, // No viene del API
          );
        }).toList();

        if (mounted) {
          setState(() {
            if (reset) {
              _warehouses = newWarehouses;
            } else {
              _warehouses.addAll(newWarehouses);
            }
            _currentPage = page;
            _hasMorePages = hasNext;
            print('State updated, warehouses count: ${_warehouses.length}, hasMore: $_hasMorePages, page: $page');
          });
        }
      } else {
        print('Error loading warehouses: ${response.statusCode} - ${response.body}');
        if (reset) {
          _warehouses = [];
        }
        if (mounted) {
          setState(() {
            _hasMorePages = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar almacenes: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading warehouses: $e');
      if (reset) {
        _warehouses = [];
      }
      if (mounted) {
        setState(() {
          _hasMorePages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar almacenes: ${e.toString()}'),
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

  Future<List<SearchResult>> _searchWarehouses(String query) async {
    // Simular búsqueda con delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filtered = _filteredWarehouses
        .where((warehouse) => warehouse.name.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .map((warehouse) => SearchResult(
              title: warehouse.name,
              subtitle: warehouse.location,
              icon: warehouse.icon,
              data: warehouse,
            ))
        .toList();
    
    return filtered;
  }

  void _showWarehouseDetail(Warehouse warehouse) {
    if (warehouse.idWarehouse != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WarehouseDetailPage(idWarehouse: warehouse.idWarehouse!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Lista de Almacenes',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Buscador
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomSearchBar(
                    hintText: 'Buscar almacenes...',
                    onSearch: _searchWarehouses,
                    showOverlay: false,
                    onQueryChanged: (query) {
                      setState(() {
                        _warehouseSearchQuery = query;
                      });
                    },
                    onResultSelected: (result) {
                      final warehouse = result.data as Warehouse;
                      _showWarehouseDetail(warehouse);
                    },
                  ),
                ),
                
                // Lista de almacenes
                Expanded(
                  child: _isLoading && _filteredWarehouses.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredWarehouses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warehouse_outlined, size: 80, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay almacenes disponibles',
                                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _loadWarehouses(page: 0, reset: true),
                                    child: const Text('Recargar'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredWarehouses.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < _filteredWarehouses.length) {
                                  final warehouse = _filteredWarehouses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: warehouse.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        warehouse.icon,
                        color: warehouse.color,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      warehouse.name,
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
                          warehouse.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: warehouse.isActive 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                warehouse.isActive ? 'Activo' : 'Inactivo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: warehouse.isActive 
                                      ? Colors.green 
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${warehouse.productCount} productos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
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
                    onTap: () => _showWarehouseDetail(warehouse),
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
        currentIndex: 0,
        onTap: (index) {
          // Navegación del bottom bar si es necesario
          if (index != 0) {
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
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Buscar',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateWarehouseForm,
        backgroundColor: const Color(0xFF007AFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateWarehouseForm() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final productCountController = TextEditingController();
    final capacityController = TextEditingController();
    final quantityController = TextEditingController(text: '0');
    final productSearchController = TextEditingController();

    // Obtener lista de productos para el autocompletado
    final products = Product.sampleProducts();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        bool isActive = true;
        IconData selectedIcon = Icons.warehouse_outlined;
        Color selectedColor = Colors.blue;
        String selectedUnit = 'unidades'; // 'unidades', 'cajas', 'paquetes'
        Product? _selectedProduct; // Producto seleccionado (puede usarse para validación o guardado)
        
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
                            'Nuevo Almacén',
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
                                icon: Icons.warehouse_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El nombre es requerido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: locationController,
                                label: 'Ubicación',
                                icon: Icons.location_on_outlined,
                                maxLines: 2,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La ubicación es requerida';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Combobox y buscador de productos
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildUnitDropdown(
                                      value: selectedUnit,
                                      onChanged: (value) {
                                        setModalState(() {
                                          selectedUnit = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: _buildProductSearchField(
                                      controller: productSearchController,
                                      products: products,
                                      onProductSelected: (product) {
                                        setModalState(() {
                                          _selectedProduct = product;
                                          productSearchController.text = product.name;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Botones de incremento/decremento y campo de cantidad
                              Row(
                                children: [
                                  // Botón menos
                                  IconButton(
                                    onPressed: () {
                                      final currentValue = int.tryParse(quantityController.text) ?? 0;
                                      if (currentValue > 0) {
                                        setModalState(() {
                                          quantityController.text = (currentValue - 1).toString();
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.remove_circle_outline),
                                    iconSize: 32,
                                    color: const Color(0xFF007AFF),
                                  ),
                                  // Botón más
                                  IconButton(
                                    onPressed: () {
                                      final currentValue = int.tryParse(quantityController.text) ?? 0;
                                      setModalState(() {
                                        quantityController.text = (currentValue + 1).toString();
                                      });
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    iconSize: 32,
                                    color: const Color(0xFF007AFF),
                                  ),
                                  const SizedBox(width: 8),
                                  // Campo de texto editable
                                  Expanded(
                                    child: TextFormField(
                                      controller: quantityController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                      decoration: InputDecoration(
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
                                  ),
                                  const SizedBox(width: 8),
                                  // Etiqueta de unidad
                                  Text(
                                    selectedUnit,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white70 : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: productCountController,
                                      label: 'Cantidad de Productos',
                                      icon: Icons.inventory_2_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'La cantidad es requerida';
                                        }
                                        if (int.tryParse(value) == null || int.parse(value) < 0) {
                                          return 'Cantidad inválida';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: capacityController,
                                      label: 'Capacidad (%)',
                                      icon: Icons.storage_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'La capacidad es requerida';
                                        }
                                        final capacity = int.tryParse(value);
                                        if (capacity == null || capacity < 0 || capacity > 100) {
                                          return 'Capacidad inválida (0-100)';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildStatusSwitch(
                                value: isActive,
                                onChanged: (value) {
                                  setModalState(() {
                                    isActive = value;
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
                              // Usar _selectedProduct para validación futura si es necesario
                              // Por ahora se guarda el almacén sin validar producto específico
                              final newWarehouse = Warehouse(
                                name: nameController.text.trim(),
                                location: locationController.text.trim(),
                                icon: selectedIcon,
                                color: selectedColor,
                                productCount: int.parse(productCountController.text),
                                isActive: isActive,
                                capacity: int.parse(capacityController.text),
                              );
                              
                              // El producto seleccionado y la cantidad pueden usarse aquí
                              // Ejemplo: _selectedProduct?.name, quantityController.text, selectedUnit
                              
                              setState(() {
                                _warehouses.add(newWarehouse);
                              });
                              
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Almacén creado exitosamente'),
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

  Widget _buildStatusSwitch({
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
                Icons.warehouse_outlined,
                size: 24,
                color: value ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                value ? 'Activo' : 'Inactivo',
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

  Widget _buildUnitDropdown({
    required String value,
    required Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white : Colors.black87),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        items: const [
          DropdownMenuItem(
            value: 'unidades',
            child: Text('Unidades'),
          ),
          DropdownMenuItem(
            value: 'cajas',
            child: Text('Cajas'),
          ),
          DropdownMenuItem(
            value: 'paquetes',
            child: Text('Paquetes'),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildProductSearchField({
    required TextEditingController controller,
    required List<Product> products,
    required Function(Product) onProductSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Autocomplete<Product>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Product>.empty();
        }
        return products.where((product) =>
            product.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      displayStringForOption: (Product product) => product.name,
      onSelected: onProductSelected,
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            labelText: 'Buscar Producto',
            prefixIcon: const Icon(Icons.search, size: 20),
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
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Product> onSelected,
        Iterable<Product> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final product = options.elementAt(index);
                  return ListTile(
                    leading: Icon(
                      product.icon,
                      color: product.color,
                    ),
                    title: Text(product.name),
                    subtitle: Text('${product.category} - \$${product.price.toStringAsFixed(2)}'),
                    onTap: () {
                      onSelected(product);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// Modelo de datos para almacenes
class Warehouse {
  final int? idWarehouse;
  final String name;
  final String location;
  final IconData icon;
  final Color color;
  final int productCount;
  final bool isActive;
  final int capacity;
  final List<String> images;

  Warehouse({
    this.idWarehouse,
    required this.name,
    required this.location,
    required this.icon,
    required this.color,
    required this.productCount,
    required this.isActive,
    required this.capacity,
    this.images = const [],
  });
  
  // Helper para obtener colores diferentes según el ID
  static Color _getWarehouseColor(int id) {
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

  static List<Warehouse> sampleWarehouses() {
    return [
      Warehouse(
        idWarehouse: 1,
        name: 'Almacén Central',
        location: 'Av. Principal 123, Centro',
        icon: Icons.warehouse,
        color: Colors.blue,
        productCount: 1250,
        isActive: true,
        capacity: 85,
      ),
      Warehouse(
        idWarehouse: 2,
        name: 'Almacén Norte',
        location: 'Calle Norte 456, Zona Industrial',
        icon: Icons.business,
        color: Colors.green,
        productCount: 890,
        isActive: true,
        capacity: 72,
      ),
      Warehouse(
        idWarehouse: 3,
        name: 'Almacén Sur',
        location: 'Av. Sur 789, Distrito Sur',
        icon: Icons.store,
        color: Colors.orange,
        productCount: 645,
        isActive: true,
        capacity: 58,
      ),
      Warehouse(
        idWarehouse: 4,
        name: 'Almacén Este',
        location: 'Calle Este 321, Zona Este',
        icon: Icons.inventory,
        color: Colors.purple,
        productCount: 0,
        isActive: false,
        capacity: 0,
      ),
      Warehouse(
        idWarehouse: 5,
        name: 'Almacén Temporal',
        location: 'Depósito Temporal, Zona Libre',
        icon: Icons.home_work,
        color: Colors.teal,
        productCount: 234,
        isActive: true,
        capacity: 25,
      ),
      Warehouse(
        idWarehouse: 6,
        name: 'Almacén Express',
        location: 'Hub Logístico, Aeropuerto',
        icon: Icons.local_shipping,
        color: Colors.red,
        productCount: 567,
        isActive: true,
        capacity: 90,
      ),
    ];
  }
}