import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/widgets.dart';
import 'store_detail_page.dart';
import '../../core/services/auth_service.dart';

class StoreManagementPage extends StatefulWidget {
  const StoreManagementPage({super.key});

  @override
  State<StoreManagementPage> createState() => _StoreManagementPageState();
}

class _StoreManagementPageState extends State<StoreManagementPage> {
  List<Store> _stores = [];
  String _storeSearchQuery = '';
  bool _isLoading = false;
  
  // Getter para tiendas filtradas según búsqueda
  List<Store> get _filteredStores {
    if (_storeSearchQuery.trim().isEmpty) {
      return _stores;
    }
    final query = _storeSearchQuery.toLowerCase();
    return _stores.where((store) {
      return store.name.toLowerCase().contains(query) ||
             store.location.toLowerCase().contains(query);
    }).toList();
  }
  
  // Paginación de tiendas
  int _currentPage = 0;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadStores(page: 0, reset: true);
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
        _loadMoreStores();
      }
    }
  }
  
  Future<void> _loadMoreStores() async {
    if (_isLoadingMore || !_hasMorePages) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      await _loadStores(
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

  Future<void> _loadStores({int page = 0, int size = 10, bool reset = true}) async {
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
          _stores = [];
        }
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8080/api/stores?page=$page&size=$size'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Stores API response status: ${response.statusCode}');
        print('Stores API response body: $responseBody');
        
        if (responseBody.isEmpty) {
          if (reset) {
            _stores = [];
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
        //   "content": [...],           // JSON array con las tiendas
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
          
          // Extraer el array de tiendas de la propiedad 'content'
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
              _stores = [];
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
            _stores = [];
          }
          if (mounted) {
            setState(() {
              _hasMorePages = false;
            });
          }
          return;
        }
        
        print('Number of stores received: ${data.length}');
        
        final newStores = data.map((item) {
          // Debug: imprimir todos los campos del item para ver qué viene del API
          print('Store item completo: $item');
          
          // Mapear los datos del API al modelo Store
          final status = item['status']?.toString() ?? 'Close';
          final isOpen = status == 'Open' || status == 'Active';
          
          // Obtener el ID de la tienda (puede ser int o long)
          final idStore = item['idStore'] is int 
              ? item['idStore'] as int
              : (item['idStore'] as num?)?.toInt();
          
          // Obtener el nombre, si no viene usar un nombre por defecto basado en el ID
          final name = item['name']?.toString() ?? 'Tienda ${idStore ?? 'N/A'}';
          
          // Obtener la dirección
          final address = item['address']?.toString() ?? 'Sin dirección';
          
          // Obtener horarios de negocio
          final businessHours = item['businessHours']?.toString() ?? '';
          
          // Obtener el username del gerente - intentar varios campos posibles
          String managerUsername = 'Sin gerente';
          if (item['manager'] != null) {
            managerUsername = item['manager'].toString();
          } else if (item['managerUsername'] != null) {
            managerUsername = item['managerUsername'].toString();
          } else if (item['managerName'] != null) {
            managerUsername = item['managerName'].toString();
          } else if (item['username'] != null) {
            managerUsername = item['username'].toString();
          } else if (item['employee'] != null && item['employee'] is Map) {
            final employee = item['employee'] as Map<String, dynamic>;
            managerUsername = employee['username']?.toString() ?? 
                             employee['name']?.toString() ?? 
                             'Sin gerente';
          } else if (item['user'] != null && item['user'] is Map) {
            final user = item['user'] as Map<String, dynamic>;
            managerUsername = user['username']?.toString() ?? 
                             user['name']?.toString() ?? 
                             'Sin gerente';
          }
          
          print('Manager username extraído: $managerUsername');
          
          // Obtener el rating - intentar varios campos posibles
          double rating = 0.0;
          if (item['rating'] != null) {
            rating = (item['rating'] is num) 
                ? (item['rating'] as num).toDouble() 
                : double.tryParse(item['rating'].toString()) ?? 0.0;
          } else if (item['rate'] != null) {
            rating = (item['rate'] is num) 
                ? (item['rate'] as num).toDouble() 
                : double.tryParse(item['rate'].toString()) ?? 0.0;
          }
          
          return Store(
            idStore: idStore,
            name: name,
            location: address,
            manager: managerUsername,
            icon: Icons.store,
            color: Store.getStoreColor(idStore ?? 0),
            monthlySales: 0.0, // No viene del API
            isOpen: isOpen,
            rating: rating,
            businessHours: businessHours,
          );
        }).toList();

        print('New stores mapped: ${newStores.length}');
        
        if (mounted) {
          setState(() {
            if (reset) {
              _stores = newStores;
            } else {
              _stores.addAll(newStores);
            }
            _currentPage = page;
            _hasMorePages = hasNext;
            print('State updated, stores count: ${_stores.length}, hasMore: $_hasMorePages, page: $page');
          });
        }
      } else {
        print('Error loading stores: ${response.statusCode} - ${response.body}');
        if (reset) {
          _stores = [];
        }
        if (mounted) {
          setState(() {
            _hasMorePages = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar tiendas: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading stores: $e');
      if (reset) {
        _stores = [];
      }
      if (mounted) {
        setState(() {
          _hasMorePages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar tiendas: ${e.toString()}'),
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

  Future<List<SearchResult>> _searchStores(String query) async {
    // Simular búsqueda con delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filtered = _stores
        .where((store) => store.name.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .map((store) => SearchResult(
              title: store.name,
              subtitle: store.location,
              icon: store.icon,
              data: store,
            ))
        .toList();
    
    return filtered;
  }


  void _showStoreDetail(Store store) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoreDetailPage(store: store),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Lista de Tiendas',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: _isLoading && _filteredStores.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Buscador
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomSearchBar(
                    hintText: 'Buscar tiendas...',
                    onSearch: _searchStores,
                    showOverlay: false,
                    onQueryChanged: (query) {
                      setState(() {
                        _storeSearchQuery = query;
                      });
                    },
                    onResultSelected: (result) {
                      final store = result.data as Store;
                      _showStoreDetail(store);
                    },
                  ),
                ),
                
                // Lista de tiendas
                Expanded(
                  child: _filteredStores.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No hay tiendas disponibles',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _loadStores(page: 0, reset: true),
                                child: const Text('Recargar'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredStores.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _filteredStores.length) {
                              final store = _filteredStores[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: store.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        store.icon,
                        color: store.color,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      store.name,
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
                          store.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Gerente: ${store.manager}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
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
                                color: store.isOpen 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                store.isOpen ? 'Abierta' : 'Cerrada',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: store.isOpen 
                                      ? Colors.green 
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${store.rating}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
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
                    onTap: () => _showStoreDetail(store),
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
        currentIndex: 1,
        onTap: (index) {
          // Navegación del bottom bar si es necesario
          if (index != 1) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateStoreForm,
        backgroundColor: const Color(0xFF007AFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateStoreForm() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final managerController = TextEditingController();
    final monthlySalesController = TextEditingController();
    final ratingController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        bool isOpen = true;
        IconData selectedIcon = Icons.store_outlined;
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
                            'Nueva Tienda',
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
                                icon: Icons.store_outlined,
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
                              _buildTextField(
                                controller: managerController,
                                label: 'Gerente',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El gerente es requerido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: monthlySalesController,
                                      label: 'Ventas Mensuales',
                                      icon: Icons.attach_money,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Las ventas son requeridas';
                                        }
                                        if (double.tryParse(value) == null || double.parse(value) < 0) {
                                          return 'Ventas inválidas';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: ratingController,
                                      label: 'Rating',
                                      icon: Icons.star_outline,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'El rating es requerido';
                                        }
                                        final rating = double.tryParse(value);
                                        if (rating == null || rating < 0 || rating > 5) {
                                          return 'Rating inválido (0-5)';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildStatusSwitch(
                                value: isOpen,
                                onChanged: (value) {
                                  setModalState(() {
                                    isOpen = value;
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
                              final newStore = Store(
                                name: nameController.text.trim(),
                                location: locationController.text.trim(),
                                manager: managerController.text.trim(),
                                icon: selectedIcon,
                                color: selectedColor,
                                monthlySales: double.parse(monthlySalesController.text),
                                isOpen: isOpen,
                                rating: double.parse(ratingController.text),
                                businessHours: '',
                              );
                              
                              setState(() {
                                _stores.add(newStore);
                              });
                              
                              // TODO: Llamar a la API para crear la tienda
                              // await _createStoreViaAPI(newStore);
                              
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tienda creada exitosamente'),
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
                Icons.store_outlined,
                size: 24,
                color: value ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                value ? 'Abierta' : 'Cerrada',
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

// Modelo de datos para tiendas
class Store {
  final int? idStore;
  final String name;
  final String location;
  final String manager;
  final IconData icon;
  final Color color;
  final double monthlySales;
  final bool isOpen;
  final double rating;
  final String businessHours;
  final int? idCompany;
  final List<String> images;

  Store({
    this.idStore,
    required this.name,
    required this.location,
    required this.manager,
    required this.icon,
    required this.color,
    required this.monthlySales,
    required this.isOpen,
    required this.rating,
    this.businessHours = '',
    this.idCompany,
    this.images = const [],
  });
  
  // Helper para obtener colores diferentes según el ID
  static Color getStoreColor(int id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[id % colors.length];
  }
  
  // Mantener compatibilidad con código existente
  static Color _getStoreColor(int id) => getStoreColor(id);

  static List<Store> sampleStores() {
    return [
      Store(
        idStore: 1,
        name: 'Mamuka Centro',
        location: 'Av. Principal 123, Centro Comercial Plaza',
        manager: 'Ana García',
        icon: Icons.store_mall_directory,
        color: Colors.blue,
        monthlySales: 45000,
        isOpen: true,
        rating: 4.8,
        businessHours: 'Lun-Vie: 9:00-18:00',
      ),
      Store(
        name: 'Mamuka Norte',
        location: 'Calle Norte 456, Mall del Norte',
        manager: 'Carlos Rodríguez',
        icon: Icons.storefront,
        color: Colors.green,
        monthlySales: 38500,
        isOpen: true,
        rating: 4.6,
      ),
      Store(
        name: 'Mamuka Sur',
        location: 'Av. Sur 789, Centro Comercial Sur',
        manager: 'María López',
        icon: Icons.store,
        color: Colors.orange,
        monthlySales: 42300,
        isOpen: true,
        rating: 4.7,
      ),
      Store(
        name: 'Mamuka Express',
        location: 'Terminal de Buses, Local 15',
        manager: 'José Martínez',
        icon: Icons.local_convenience_store,
        color: Colors.purple,
        monthlySales: 15600,
        isOpen: false,
        rating: 4.2,
      ),
      Store(
        name: 'Mamuka Premium',
        location: 'Zona Residencial, Av. Exclusiva 321',
        manager: 'Laura Sánchez',
        icon: Icons.shopping_bag,
        color: Colors.teal,
        monthlySales: 52000,
        isOpen: true,
        rating: 4.9,
      ),
      Store(
        name: 'Mamuka Outlet',
        location: 'Zona Industrial, Calle Fábrica 654',
        manager: 'Pedro González',
        icon: Icons.discount,
        color: Colors.red,
        monthlySales: 28900,
        isOpen: true,
        rating: 4.4,
      ),
      Store(
        name: 'Mamuka Online',
        location: 'Centro de Distribución Digital',
        manager: 'Sofía Herrera',
        icon: Icons.computer,
        color: Colors.indigo,
        monthlySales: 63000,
        isOpen: true,
        rating: 4.5,
      ),
      Store(
        name: 'Mamuka Mini',
        location: 'Barrio Residencial, Calle Pequeña 98',
        manager: 'Miguel Torres',
        icon: Icons.home_work,
        color: Colors.amber,
        monthlySales: 12500,
        isOpen: true,
        rating: 4.3,
      ),
    ];
  }
}