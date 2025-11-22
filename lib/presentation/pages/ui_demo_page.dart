import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../widgets/widgets.dart';
import '../widgets/permission_widget.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/api_constants.dart';
import 'demo_login_page.dart';
import 'warehouse_management_page.dart' show Warehouse, WarehouseManagementPage;
import 'store_management_page.dart' show Store, StoreManagementPage;
import 'product_management_page.dart';
import 'admin_panel_page.dart' hide Store, Warehouse;
import 'user_control_panel_page.dart';

// Modelo de datos de demostración
class DemoProduct {
  final int? idProduct;
  final String name;
  final double price;
  final double? originalPrice;
  final IconData icon;
  final Color color;
  final String? promoText;
  final bool hasPromo;
  final String imageUrl;
  final int? stock;

  DemoProduct({
    this.idProduct,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.icon,
    required this.color,
    this.promoText,
    this.hasPromo = false,
    required this.imageUrl,
    this.stock,
  });

  static List<DemoProduct> sampleProducts() {
    return [
      DemoProduct(
        name: 'Lámpara Elegante',
        price: 89.99,
        originalPrice: 129.99,
        icon: Icons.lightbulb_outline,
        color: Colors.amber,
        hasPromo: true,
        promoText: '30% OFF',
        imageUrl: 'https://picsum.photos/400/300?random=1',
      ),
      DemoProduct(
        name: 'Sofá Moderno',
        price: 1299.99,
        icon: Icons.chair_outlined,
        color: Colors.brown,
        imageUrl: 'https://picsum.photos/400/300?random=2',
      ),
      DemoProduct(
        name: 'Mesa de Café',
        price: 299.99,
        originalPrice: 399.99,
        icon: Icons.table_restaurant,
        color: Colors.orange,
        hasPromo: true,
        promoText: '25% OFF',
        imageUrl: 'https://picsum.photos/400/300?random=3',
      ),
      DemoProduct(
        name: 'Espejo Decorativo',
        price: 159.99,
        icon: Icons.looks,
        color: Colors.indigo,
        imageUrl: 'https://picsum.photos/400/300?random=4',
      ),
      DemoProduct(
        name: 'Plantas Naturales',
        price: 49.99,
        originalPrice: 69.99,
        icon: Icons.local_florist,
        color: Colors.green,
        hasPromo: true,
        promoText: 'OFERTA',
        imageUrl: 'https://picsum.photos/400/300?random=5',
      ),
      DemoProduct(
        name: 'Cojines Premium',
        price: 79.99,
        icon: Icons.weekend,
        color: Colors.purple,
        imageUrl: 'https://picsum.photos/400/300?random=6',
      ),
    ];
  }
}

class UIDemoPage extends StatefulWidget {
  const UIDemoPage({super.key});

  @override
  State<UIDemoPage> createState() => _UIDemoPageState();
}

class _UIDemoPageState extends State<UIDemoPage> {
  int _currentBottomIndex = 0;
  List<DemoProduct> _products = [];
  String _searchQuery = '';
  final Map<DemoProduct, int> _cart = {};
  double _cartTotal = 0.0;
  bool _isLoadingProducts = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  bool _hasMorePages = true;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingCart = false;
  
  // Stores state
  List<Store> _stores = [];
  String _storeSearchQuery = '';
  bool _isLoadingStores = true;
  bool _isLoadingMoreStores = false;
  int _currentStorePage = 0;
  bool _hasMoreStorePages = true;
  final ScrollController _storeScrollController = ScrollController();
  
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
  
  // Cart customer info controllers
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNitController = TextEditingController();
  
  // Report filters
  Store? _selectedReportStore;
  DateTime? _reportStartDate;
  DateTime? _reportEndDate;
  bool _isLoadingSalesReport = false;
  Map<String, dynamic>? _salesReportData;
  
  // Transfer report filters
  Warehouse? _selectedTransferWarehouse;
  DateTime? _transferStartDate;
  DateTime? _transferEndDate;
  List<Warehouse> _warehouses = []; // Lista de almacenes para el autocomplete
  bool _isLoadingWarehouses = false;
  bool _isLoadingTransfersReport = false;
  Map<String, dynamic>? _transfersReportData;
  
  // Global sales report filters
  bool _filterByStore = false; // Toggle para filtrar por tienda o ventas globales
  Store? _selectedGlobalReportStore;
  DateTime? _globalReportStartDate;
  DateTime? _globalReportEndDate;
  
  final List<String> _carouselImages = [
    'https://picsum.photos/800/400?random=1',
    'https://picsum.photos/800/400?random=2',
    'https://picsum.photos/800/400?random=3',
    'https://picsum.photos/800/400?random=4',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts(page: 0, reset: true);
    _scrollController.addListener(_onScroll);
    _storeScrollController.addListener(_onStoreScroll);
    _loadStores(page: 0, reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _storeScrollController.dispose();
    _customerNameController.dispose();
    _customerNitController.dispose();
    super.dispose();
  }
  
  void _onStoreScroll() {
    if (!_storeScrollController.hasClients) return;
    
    final maxScroll = _storeScrollController.position.maxScrollExtent;
    final currentScroll = _storeScrollController.position.pixels;
    
    // Cuando el usuario ha scrolleado al 80% del contenido, cargar más
    if (maxScroll > 0 && currentScroll >= maxScroll * 0.8) {
      if (!_isLoadingMoreStores && _hasMoreStorePages && !_isLoadingStores) {
        _loadMoreStores();
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // Mostrar/ocultar el carrito flotante según el scroll
    final shouldShowFloatingCart = currentScroll > 100; // Mostrar después de 100px de scroll
    if (_showFloatingCart != shouldShowFloatingCart) {
      setState(() {
        _showFloatingCart = shouldShowFloatingCart;
      });
    }
    
    // Cuando el usuario ha scrolleado al 80% del contenido, cargar más
    if (maxScroll > 0 && currentScroll >= maxScroll * 0.8) {
      if (!_isLoadingMore && _hasMorePages && !_isLoadingProducts) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadProducts({int page = 0, bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoadingProducts = true;
        _currentPage = 0;
        _hasMorePages = true;
        _products = [];
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final token = AuthService.accessToken;
      if (token == null) {
        // Si no hay token, usar productos de muestra
        _products = DemoProduct.sampleProducts();
        if (mounted) {
          setState(() {
            _isLoadingProducts = false;
            _isLoadingMore = false;
          });
        }
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConstants.products(page: page, size: 10)),
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
          print('Response body is empty, using sample products');
          if (reset) {
            _products = DemoProduct.sampleProducts();
          }
          if (mounted) {
            setState(() {
              _isLoadingProducts = false;
              _isLoadingMore = false;
              _hasMorePages = false;
            });
          }
          return;
        }

        final decodedData = json.decode(responseBody);
        print('Decoded data type: ${decodedData.runtimeType}');

        // La respuesta paginada tiene estructura { content: [...], totalElements, totalPages, etc. }
        List<dynamic> data;
        if (decodedData is Map && decodedData.containsKey('content')) {
          data = decodedData['content'] as List<dynamic>? ?? [];
          
          // Verificar si hay más páginas
          final totalPages = decodedData['totalPages'] is int
              ? decodedData['totalPages'] as int
              : (decodedData['totalPages'] as num?)?.toInt() ?? 0;
          _hasMorePages = (page + 1) < totalPages;
        } else if (decodedData is List) {
          data = decodedData;
          _hasMorePages = data.length >= 10; // Si recibimos menos de 10, no hay más páginas
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          data = decodedData['data'] as List<dynamic>? ?? [];
          _hasMorePages = data.length >= 10;
        } else {
          print('Unexpected response format: $decodedData');
          if (reset) {
            _products = DemoProduct.sampleProducts();
          }
          if (mounted) {
            setState(() {
              _isLoadingProducts = false;
              _isLoadingMore = false;
              _hasMorePages = false;
            });
          }
          return;
        }

        print('Number of products received: ${data.length}');
        print('Has more pages: $_hasMorePages');

        final newProducts = data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
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

          // Obtener el stock
          int? stock;
          if (item['stock'] != null) {
            stock = (item['stock'] is int)
                ? item['stock'] as int
                : (item['stock'] as num?)?.toInt();
          }

          // Obtener el estado
          final status = item['status']?.toString() ?? 'Inactive';
          final isActive = status == 'Active';

          // Asignar icono y color basado en el índice para mantener variedad visual
          final icons = [
            Icons.lightbulb_outline,
            Icons.chair_outlined,
            Icons.table_restaurant,
            Icons.looks,
            Icons.local_florist,
            Icons.weekend,
            Icons.inventory_2_outlined,
            Icons.shopping_bag_outlined,
          ];
          final colors = [
            Colors.amber,
            Colors.brown,
            Colors.orange,
            Colors.indigo,
            Colors.green,
            Colors.purple,
            Colors.blue,
            Colors.pink,
          ];
          
          final globalIndex = _products.length + index;
          final iconIndex = globalIndex % icons.length;
          final colorIndex = (idProduct ?? globalIndex) % colors.length;

          // Determinar si tiene promoción (algunos productos aleatoriamente)
          final hasPromo = (idProduct ?? globalIndex) % 3 == 0;
          final originalPrice = hasPromo ? price * 1.3 : null;
          final promoText = hasPromo ? '${((originalPrice! - price) / originalPrice * 100).toInt()}% OFF' : null;

          return DemoProduct(
            idProduct: idProduct,
            name: name,
            price: price,
            originalPrice: originalPrice,
            icon: icons[iconIndex],
            color: colors[colorIndex],
            hasPromo: hasPromo,
            promoText: promoText,
            imageUrl: 'https://picsum.photos/400/300?random=${idProduct ?? globalIndex}',
            stock: stock,
          );
        }).toList();

        if (mounted) {
          setState(() {
            if (reset) {
              _products = newProducts;
            } else {
              _products.addAll(newProducts);
            }
            _currentPage = page;
            _isLoadingProducts = false;
            _isLoadingMore = false;
            print('State updated, products count: ${_products.length}, page: $_currentPage');
          });
        }
      } else {
        print('Error loading products: ${response.statusCode} - ${response.body}');
        // Usar productos de muestra en caso de error solo si es reset
        if (reset) {
          _products = DemoProduct.sampleProducts();
        }
        if (mounted) {
          setState(() {
            _isLoadingProducts = false;
            _isLoadingMore = false;
            _hasMorePages = false;
          });
        }
      }
    } catch (e) {
      print('Error loading products: $e');
      // Usar productos de muestra en caso de error solo si es reset
      if (reset) {
        _products = DemoProduct.sampleProducts();
      }
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
          _isLoadingMore = false;
          _hasMorePages = false;
        });
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!_isLoadingMore && _hasMorePages) {
      await _loadProducts(page: _currentPage + 1, reset: false);
    }
  }

  Future<void> _loadStores({int page = 0, bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoadingStores = true;
        _currentStorePage = 0;
        _hasMoreStorePages = true;
        _stores = [];
      });
    } else {
      setState(() => _isLoadingMoreStores = true);
    }

    try {
      final token = AuthService.accessToken;
      if (token == null) {
        if (mounted) {
          setState(() {
            _isLoadingStores = false;
            _isLoadingMoreStores = false;
          });
        }
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConstants.stores(page: page, size: 10)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Stores API response status: ${response.statusCode}');

        if (responseBody.isEmpty) {
          if (mounted) {
            setState(() {
              _isLoadingStores = false;
              _isLoadingMoreStores = false;
              _hasMoreStorePages = false;
            });
          }
          return;
        }

        final decodedData = json.decode(responseBody);
        print('Decoded stores data type: ${decodedData.runtimeType}');

        List<dynamic> data;
        if (decodedData is Map && decodedData.containsKey('content')) {
          data = decodedData['content'] as List<dynamic>? ?? [];
          
          final totalPages = decodedData['totalPages'] is int
              ? decodedData['totalPages'] as int
              : (decodedData['totalPages'] as num?)?.toInt() ?? 0;
          _hasMoreStorePages = (page + 1) < totalPages;
        } else if (decodedData is List) {
          data = decodedData;
          _hasMoreStorePages = data.length >= 10;
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          data = decodedData['data'] as List<dynamic>? ?? [];
          _hasMoreStorePages = data.length >= 10;
        } else {
          print('Unexpected stores response format: $decodedData');
          if (mounted) {
            setState(() {
              _isLoadingStores = false;
              _isLoadingMoreStores = false;
              _hasMoreStorePages = false;
            });
          }
          return;
        }

        print('Number of stores received: ${data.length}');

        final newStores = data.map((item) {
          final status = item['status']?.toString() ?? 'Close';
          final isOpen = status == 'Open' || status == 'Active';
          
          final idStore = item['idStore'] is int 
              ? item['idStore'] as int
              : (item['idStore'] as num?)?.toInt();
          
          final name = item['name']?.toString() ?? 'Tienda ${idStore ?? 'N/A'}';
          final address = item['address']?.toString() ?? 'Sin dirección';
          final businessHours = item['businessHours']?.toString() ?? '';
          
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
          
          final idCompany = item['idCompany'] is int
              ? item['idCompany'] as int
              : (item['idCompany'] as num?)?.toInt();

          return Store(
            idStore: idStore,
            name: name,
            location: address,
            manager: managerUsername,
            icon: Icons.store,
            color: Store.getStoreColor(idStore ?? 0),
            monthlySales: 0.0,
            isOpen: isOpen,
            rating: rating,
            businessHours: businessHours,
            idCompany: idCompany,
          );
        }).toList();

        if (mounted) {
          setState(() {
            if (reset) {
              _stores = newStores;
            } else {
              _stores.addAll(newStores);
            }
            _currentStorePage = page;
            _isLoadingStores = false;
            _isLoadingMoreStores = false;
            print('State updated, stores count: ${_stores.length}, page: $_currentStorePage');
          });
        }
      } else {
        print('Error loading stores: ${response.statusCode} - ${response.body}');
        if (mounted) {
          setState(() {
            _isLoadingStores = false;
            _isLoadingMoreStores = false;
            _hasMoreStorePages = false;
          });
        }
      }
    } catch (e) {
      print('Error loading stores: $e');
      if (mounted) {
        setState(() {
          _isLoadingStores = false;
          _isLoadingMoreStores = false;
          _hasMoreStorePages = false;
        });
      }
    }
  }

  Future<void> _loadMoreStores() async {
    if (!_isLoadingMoreStores && _hasMoreStorePages) {
      await _loadStores(page: _currentStorePage + 1, reset: false);
    }
  }

  int? _getUserIdFromToken() {
    try {
      final token = AuthService.accessToken;
      if (token == null) return null;
      
      final payload = JwtDecoder.decode(token);
      final idUser = payload['idUser'];
      
      if (idUser is int) {
        return idUser;
      } else if (idUser is num) {
        return idUser.toInt();
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo idUser del token: $e');
      return null;
    }
  }

  Future<int?> _createCustomer(String name, String nit) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final requestBody = {
        'name': name,
        'nit': nit,
      };
      
      print('Creating customer with data: $requestBody');
      print('Token available: ${token != null}');

      final response = await http.post(
        Uri.parse(ApiConstants.customers()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Customer API response status: ${response.statusCode}');
      print('Customer API response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Customer created response: $responseData');
        
        // Obtener el customerId de la respuesta
        int? idCustomer;
        
        if (responseData is Map) {
          // El servidor retorna customerId
          if (responseData.containsKey('customerId')) {
            final id = responseData['customerId'];
            idCustomer = id is int ? id : (id as num?)?.toInt();
          } else if (responseData.containsKey('idCustomer')) {
            // Fallback por si acaso
            final id = responseData['idCustomer'];
            idCustomer = id is int ? id : (id as num?)?.toInt();
          } else if (responseData.containsKey('id')) {
            // Otro fallback
            final id = responseData['id'];
            idCustomer = id is int ? id : (id as num?)?.toInt();
          }
        }
        
        if (idCustomer == null) {
          print('Warning: No se encontró customerId en la respuesta: $responseData');
          throw Exception('El servidor no retornó el ID del cliente. Respuesta: ${response.body}');
        }
        
        print('Customer ID obtenido: $idCustomer');
        return idCustomer;
      } else {
        // Intentar extraer el mensaje de error del backend
        String errorMessage = 'Error al crear cliente: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map) {
            final message = errorData['message'] ?? errorData['error'] ?? errorData['detail'];
            if (message != null) {
              errorMessage = 'Error del servidor: $message';
            }
          }
        } catch (e) {
          errorMessage = 'Error al crear cliente: ${response.statusCode} - ${response.body}';
        }
        
        print('Error creating customer: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error creating customer: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error al crear cliente: ${e.toString()}');
    }
  }

  Future<void> _createSale({
    required int idProduct,
    required int idCustomer,
    required int idEmployeeStore,
    required int amount,
    required double subtotal,
    required double discount,
    required double total,
  }) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.sales()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'idProduct': idProduct,
          'idCustomer': idCustomer,
          'idEmployeeStore': idEmployeeStore,
          'amount': amount,
          'subtotal': subtotal,
          'discount': discount,
          'total': total,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Sale created successfully for product $idProduct');
      } else {
        print('Error creating sale: ${response.statusCode} - ${response.body}');
        throw Exception('Error al crear venta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating sale: $e');
      rethrow;
    }
  }

  Future<void> _processSale() async {
    ScaffoldMessengerState? scaffoldMessenger;
    
    try {
      // Obtener datos del cliente
      final customerName = _customerNameController.text.trim();
      final customerNit = _customerNitController.text.trim();

      // Obtener idUser del token
      final idUser = _getUserIdFromToken();
      if (idUser == null) {
        throw Exception('No se pudo obtener el ID del usuario del token');
      }

      // Mostrar indicador de carga
      if (mounted) {
        scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Procesando venta...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Crear cliente
      int? idCustomer;
      try {
        idCustomer = await _createCustomer(customerName, customerNit);
      } catch (e) {
        // Cerrar el mensaje de carga
        if (mounted && scaffoldMessenger != null) {
          scaffoldMessenger.hideCurrentSnackBar();
        }
        // El error ya fue lanzado con el mensaje específico del backend
        rethrow;
      }
      
      if (idCustomer == null) {
        // Cerrar el mensaje de carga
        if (mounted && scaffoldMessenger != null) {
          scaffoldMessenger.hideCurrentSnackBar();
        }
        throw Exception('No se pudo crear el cliente: el servidor no retornó un ID válido');
      }

      // Crear ventas por cada producto en el carrito
      for (final entry in _cart.entries) {
        final product = entry.key;
        final quantity = entry.value;

        if (product.idProduct == null) {
          print('Warning: Producto ${product.name} no tiene idProduct, saltando...');
          continue;
        }

        // Calcular subtotal, discount y total
        final subtotal = product.originalPrice != null 
            ? product.originalPrice! * quantity 
            : product.price * quantity;
        final discount = product.originalPrice != null
            ? (product.originalPrice! - product.price) * quantity
            : 0.0;
        final total = product.price * quantity;

        await _createSale(
          idProduct: product.idProduct!,
          idCustomer: idCustomer,
          idEmployeeStore: idUser, // idEmployeeStore es el idUser del token
          amount: quantity,
          subtotal: subtotal,
          discount: discount,
          total: total,
        );
      }

      // Cerrar el mensaje de carga
      if (mounted && scaffoldMessenger != null) {
        scaffoldMessenger.hideCurrentSnackBar();
      }

      // Cerrar el modal
      if (mounted) {
        Navigator.pop(context);
      }

      // Limpiar el carrito y campos
      setState(() {
        _cart.clear();
        _cartTotal = 0.0;
        _customerNameController.clear();
        _customerNitController.clear();
      });

      // Recargar productos para actualizar stocks
      await _loadProducts(page: 0, reset: true);

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Venta realizada exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 3000),
          ),
        );
      }
    } catch (e) {
      print('Error processing sale: $e');
      
      // Cerrar el mensaje de carga si aún está visible
      if (mounted && scaffoldMessenger != null) {
        scaffoldMessenger.hideCurrentSnackBar();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error al procesar la venta: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<List<SearchResult>> _searchStores(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filtered = _stores
        .where((store) => 
            store.name.toLowerCase().contains(query.toLowerCase()) ||
            store.location.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .map<SearchResult>((store) => SearchResult(
              title: store.name,
              subtitle: store.location,
              icon: store.icon,
              data: store,
            ))
        .toList();
    
    return filtered;
  }

  // Obtener productos filtrados según la búsqueda
  List<DemoProduct> get _filteredProducts {
    if (_searchQuery.trim().isEmpty) {
      return _products;
    }
    final query = _searchQuery.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(query);
    }).toList();
  }

  // Métodos helper para el bottom bar con permisos
  List<BottomBarItem> _getBottomBarItems() {
    final allItems = [
      const BottomBarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Inicio',
      ),
      const BottomBarItem(
        icon: Icons.store_outlined,
        activeIcon: Icons.store,
        label: 'Tiendas',
      ),
      const BottomBarItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Reportes',
      ),
      const BottomBarItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Perfil',
      ),
    ];
    
    // Si el usuario no es ADMIN o Employee, filtrar el item de Reportes (índice 2)
    if (AuthService.isAdmin || AuthService.isEmployee) {
      return allItems;
    } else {
      return allItems.where((item) => item.label != 'Reportes').toList();
    }
  }
  
  int _getAdjustedBottomIndex() {
    // Si el usuario no tiene permisos para Reportes y está en el índice 2 (Reportes),
    // redirigir al índice 0 (Inicio)
    if (!(AuthService.isAdmin || AuthService.isEmployee) && _currentBottomIndex == 2) {
      return 0; // Mostrar Inicio en lugar de Reportes
    }
    
    // Si el usuario tiene permisos, el índice se mantiene igual
    // Si no tiene permisos y está en un índice > 2, ajustar restando 1
    if (!(AuthService.isAdmin || AuthService.isEmployee) && _currentBottomIndex > 2) {
      return _currentBottomIndex - 1;
    }
    
    return _currentBottomIndex;
  }
  
  int _getActualIndexFromAdjusted(int adjustedIndex) {
    // Si el usuario no tiene permisos para Reportes, el índice ajustado
    // necesita mapearse al índice real
    if (!(AuthService.isAdmin || AuthService.isEmployee)) {
      // Si el índice ajustado es >= 2, significa que está en Perfil (que era índice 3)
      // entonces el índice real es adjustedIndex + 1
      if (adjustedIndex >= 2) {
        return adjustedIndex + 1;
      }
      // Si es menor a 2, el índice se mantiene igual
      return adjustedIndex;
    }
    
    // Si tiene permisos, el índice se mantiene igual
    return adjustedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Mamuka ERP Demo',
        showBackButton: false,
        leading: AuthService.isAdmin
            ? Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, size: 22),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificaciones'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 22),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      drawer: AuthService.isAdmin
          ? _buildDrawer()
          : null,
      body: Stack(
        children: [
          _buildBody(),
          // Carrito flotante
          if (_showFloatingCart && _cart.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildFloatingCart(),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _getAdjustedBottomIndex(),
        onTap: (index) {
          setState(() {
            _currentBottomIndex = _getActualIndexFromAdjusted(index);
          });
        },
        items: _getBottomBarItems(),
      ),
    );
  }

  void _updateCartTotal() {
    _cartTotal = _cart.entries
        .map((entry) => entry.key.price * entry.value)
        .fold(0.0, (sum, price) => sum + price);
  }

  void _addToCart(DemoProduct product) {
    setState(() {
      _cart[product] = (_cart[product] ?? 0) + 1;
      _updateCartTotal();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('${product.name} agregado al carrito'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPromotionalCarousel() {
    final promoProducts = _products.where((p) => p.hasPromo).toList();
    
    return Container(
      height: 220,
      margin: const EdgeInsets.all(16),
      child: PageView.builder(
        itemCount: promoProducts.length,
        itemBuilder: (context, index) {
          final product = promoProducts[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Imagen de fondo
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          product.color.withOpacity(0.8),
                          product.color.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  
                  // Badge de oferta
                  if (product.hasPromo)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.promoText ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  
                  // Contenido
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            product.icon,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (product.originalPrice != null) ...[
                                Text(
                                  '\$${product.originalPrice!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartSummary() {
    final totalItems = _cart.values.fold(0, (sum, qty) => sum + qty);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF007AFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_cart,
            color: const Color(0xFF007AFF),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalItems productos en el carrito',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Total: \$${_cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showCartDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ver Carrito',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCart() {
    final totalItems = _cart.values.fold(0, (sum, qty) => sum + qty);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$totalItems productos',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${_cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showCartDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF007AFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Ver Carrito',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppableProductCard(DemoProduct product) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen/Icono del producto
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: product.color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      product.icon,
                      size: 48,
                      color: product.color,
                    ),
                  ),
                  if (product.hasPromo)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.promoText ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Información del producto
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Precios
                  Row(
                    children: [
                      if (product.originalPrice != null) ...[
                        Text(
                          '\$${product.originalPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF007AFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Stock
                  if (product.stock != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          product.stock! > 0 ? Icons.inventory_2 : Icons.inventory_2_outlined,
                          size: 12,
                          color: product.stock! > 10 
                              ? Colors.green 
                              : product.stock! > 0 
                                  ? Colors.orange 
                                  : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            product.stock! > 0 
                                ? 'Stock: ${product.stock}' 
                                : 'Sin stock',
                            style: TextStyle(
                              fontSize: 10,
                              color: product.stock! > 10 
                                  ? Colors.green[700] 
                                  : product.stock! > 0 
                                      ? Colors.orange[700] 
                                      : Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Botón agregar al carrito - Solo visible para ADMIN o Employee
                  if (AuthService.isAdmin || AuthService.isEmployee) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (product.stock == null || product.stock! > 0)
                            ? () => _addToCart(product)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_shopping_cart, 
                              size: 14,
                              color: (product.stock == null || product.stock! > 0)
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                (product.stock == null || product.stock! > 0)
                                    ? 'Agregar'
                                    : 'Sin stock',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: (product.stock == null || product.stock! > 0)
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Si el usuario intenta acceder a Reportes (índice 2) sin permisos, redirigir a Inicio
    if (_currentBottomIndex == 2 && !(AuthService.isAdmin || AuthService.isEmployee)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentBottomIndex = 0;
          });
        }
      });
      return _buildHomePage();
    }
    
    switch (_currentBottomIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildSearchPage();
      case 2:
        return _buildReportsPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Carrusel de ofertas
        SliverToBoxAdapter(
          child: _buildPromotionalCarousel(),
        ),
        
        // Total del carrito y botón (solo mostrar si no está flotante)
        if (_cart.isNotEmpty && !_showFloatingCart)
          SliverToBoxAdapter(
            child: _buildCartSummary(),
          ),
        
        // Buscador
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              hintText: 'Buscar productos...',
              onSearch: _searchProducts,
              showOverlay: false,
              onQueryChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onResultSelected: (result) {
                final product = result.data as DemoProduct;
                _showProductDetail(product);
              },
            ),
          ),
        ),
        
        // Sección de productos
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _searchQuery.trim().isEmpty
                  ? 'Productos Destacados'
                  : 'Resultados de búsqueda (${_filteredProducts.length})',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        
        // Grilla de productos con botones de carrito
        _isLoadingProducts && _products.isEmpty
            ? SliverFillRemaining(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : _filteredProducts.isEmpty && _searchQuery.trim().isNotEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron productos',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta con otro término de búsqueda',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < _filteredProducts.length) {
                            return _buildShoppableProductCard(_filteredProducts[index]);
                          } else if (index == _filteredProducts.length && _isLoadingMore) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                        childCount: _filteredProducts.length + (_isLoadingMore ? 1 : 0),
                      ),
                    ),
                  ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildSearchPage() {
    return CustomScrollView(
      controller: _storeScrollController,
      slivers: [
        // Carrusel de tiendas con ofertas
        SliverToBoxAdapter(
          child: _buildStoresCarousel(),
        ),
        
        // Buscador
        SliverToBoxAdapter(
          child: Padding(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tienda seleccionada: ${store.name}'),
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Título de la sección
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _storeSearchQuery.trim().isEmpty
                  ? 'Todas las Tiendas'
                  : 'Resultados de búsqueda (${_filteredStores.length})',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        
        // Grilla de tiendas
        _isLoadingStores && _stores.isEmpty
            ? SliverFillRemaining(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : _filteredStores.isEmpty && _storeSearchQuery.trim().isNotEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron tiendas',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta con otro término de búsqueda',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _filteredStores.length) {
                        return _buildStoreCard(_filteredStores[index]);
                      } else if (index == _filteredStores.length && _isLoadingMoreStores) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    childCount: _filteredStores.length + (_isLoadingMoreStores ? 1 : 0),
                  ),
                ),
              ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildStoresCarousel() {
    // Filtrar tiendas con ofertas (rating > 4.5 o isOpen)
    final storesWithOffers = _stores.where((store) => 
      store.rating > 4.5 || store.isOpen
    ).toList();
    
    if (storesWithOffers.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: 220,
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      child: PageView.builder(
        itemCount: storesWithOffers.length,
        itemBuilder: (context, index) {
          final store = storesWithOffers[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  store.color,
                  store.color.withOpacity(0.7),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          store.icon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              store.location,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (store.rating > 0) ...[
                        const Icon(Icons.star, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          store.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          store.isOpen ? 'Abierta' : 'Cerrada',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreCard(Store store) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono de la tienda
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: store.color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      store.icon,
                      size: 48,
                      color: store.color,
                    ),
                  ),
                  if (store.rating > 4.5)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'OFERTA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Información de la tienda
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Rating y estado
                  Row(
                    children: [
                      if (store.rating > 0) ...[
                        Icon(Icons.star, size: 12, color: Colors.amber[700]),
                        const SizedBox(width: 2),
                        Text(
                          store.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: store.isOpen ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          store.isOpen ? 'Abierta' : 'Cerrada',
                          style: TextStyle(
                            fontSize: 9,
                            color: store.isOpen ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Ubicación
                  Flexible(
                    child: Text(
                      store.location,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsPage() {
    return CustomGridView<DemoProduct>(
      items: _products,
      crossAxisCount: 2,
      childAspectRatio: 0.75,
      controller: _scrollController,
      isLoading: _isLoadingProducts,
      onRefresh: () {
        _loadProducts(page: 0, reset: true);
      },
      itemBuilder: (product, index) {
        // Mostrar indicador de carga al final si está cargando más
        if (index == _products.length - 1 && _isLoadingMore) {
          return Column(
            children: [
              _buildProductCard(product),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildReportsPage() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // TabBar
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              labelColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF007AFF),
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  text: 'Reporte de Ventas',
                  icon: Icon(Icons.shopping_cart),
                ),
                Tab(
                  text: 'Reportes de Transferencias',
                  icon: Icon(Icons.swap_horiz),
                ),
                Tab(
                  text: 'Reporte de Ventas',
                  icon: Icon(Icons.trending_up),
                ),
              ],
            ),
          ),
          
          // TabBarView
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1: Reporte de Ventas
                _buildSalesReportTab(),
                
                // Tab 2: Reportes de Transferencias
                _buildTransfersReportTab(),
                
                // Tab 3: Reporte de Ventas (Globales)
                _buildGlobalSalesReportTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSalesReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con buscador (3/4) y botón (1/4)
          Row(
            children: [
              // Combobox con autocompletado para tiendas (3/4)
              Expanded(
                flex: 3,
                child: _buildStoreAutocomplete(),
              ),
              
              const SizedBox(width: 12),
              
              // Botón Generar Reporte (1/4)
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingSalesReport ? null : _generateSalesReport,
                  icon: _isLoadingSalesReport
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.description, size: 20),
                  label: Text(_isLoadingSalesReport ? 'Generando...' : 'Generar Reporte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Date pickers
          Row(
            children: [
              // Fecha inicial
              Expanded(
                child: _buildDatePicker(
                  label: 'Fecha Inicial',
                  selectedDate: _reportStartDate,
                  onDateSelected: (date) {
                    setState(() {
                      _reportStartDate = date;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Fecha final
              Expanded(
                child: _buildDatePicker(
                  label: 'Fecha Final',
                  selectedDate: _reportEndDate,
                  onDateSelected: (date) {
                    setState(() {
                      _reportEndDate = date;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Reporte con gráficos
          if (_isLoadingSalesReport)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_salesReportData != null)
            _buildSalesReport()
          else
            _buildEmptySalesReport(),
        ],
      ),
    );
  }
  
  Widget _buildFakeSalesReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título del reporte
        Text(
          'Reporte de Ventas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedReportStore != null
              ? 'Tienda: ${_selectedReportStore!.name}'
              : 'Todas las tiendas',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        if (_reportStartDate != null && _reportEndDate != null)
          Text(
            'Período: ${_reportStartDate!.day}/${_reportStartDate!.month}/${_reportStartDate!.year} - ${_reportEndDate!.day}/${_reportEndDate!.month}/${_reportEndDate!.year}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Gráfico de barras - Ventas por día (ocupa todo el ancho)
        _buildSalesByDayBarChartFromAPI(),
        
        const SizedBox(height: 24),
        
        // Gráficos de torta - Productos más y menos vendidos (debajo del gráfico de barras)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Productos más vendidos
            Expanded(
              child: _buildTopProductsPieChart(),
            ),
            const SizedBox(width: 16),
            // Productos menos vendidos
            Expanded(
              child: _buildBottomProductsPieChart(),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSalesByDayBarChartFromAPI() {
    // Obtener datos de dailySales de la API
    List<Map<String, dynamic>> data = [];
    
    if (_salesReportData != null && _salesReportData!.containsKey('dailySales')) {
      final dailySales = _salesReportData!['dailySales'] as List<dynamic>?;
      if (dailySales != null) {
        for (var item in dailySales) {
          if (item is Map) {
            final dateStr = item['date']?.toString();
            final sales = item['sales'] ?? item['total'] ?? 0.0;
            
            DateTime? date;
            if (dateStr != null) {
              try {
                date = DateTime.parse(dateStr);
              } catch (e) {
                print('Error parsing date: $dateStr');
              }
            }
            
            if (date != null) {
              final dayName = _getDayName(date.weekday);
              final salesValue = sales is num ? sales.toDouble() : 0.0;
              
              data.add({
                'date': date,
                'day': dayName,
                'dayNumber': date.day,
                'sales': salesValue,
              });
            }
          }
        }
      }
    }
    
    // Si no hay datos de la API, usar datos fake como fallback
    if (data.isEmpty && _reportStartDate != null && _reportEndDate != null) {
      final startDate = _reportStartDate!;
      final endDate = _reportEndDate!;
      final daysDifference = endDate.difference(startDate).inDays;
      
      for (int i = 0; i <= daysDifference && i < 30; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final dayName = _getDayName(currentDate.weekday);
        final sales = 1000.0 + (i * 150.0) + (i % 3 * 200.0);
        
        data.add({
          'date': currentDate,
          'day': dayName,
          'dayNumber': currentDate.day,
          'sales': sales,
        });
      }
    }
    
    if (data.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Seleccione un rango de fechas para ver las ventas por día',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }
    
    final maxSales = data.map((e) => e['sales'] as double).reduce((a, b) => a > b ? a : b);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ventas por Día',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280, // Aumentado de 250 a 280 para evitar overflow
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final barCount = data.length;
                  final spacing = 4.0;
                  
                  // Si hay muchas barras, permitir scroll horizontal
                  // Si hay pocas barras, distribuir uniformemente en todo el ancho
                  final minBarWidth = 20.0; // Reducido de 30.0 a 20.0 para barras más delgadas
                  final totalSpacing = spacing * (barCount - 1);
                  final requiredWidth = (minBarWidth * barCount) + totalSpacing;
                  
                  if (requiredWidth > availableWidth) {
                    // Muchas barras: scroll horizontal con barras de ancho fijo
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: data.map((item) {
                          final height = (item['sales'] as double) / maxSales;
                          return Padding(
                            padding: EdgeInsets.only(right: spacing),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: minBarWidth,
                                  height: 180 * height, // Reducido de 200 a 180 para evitar overflow
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6), // Reducido de 8 a 6
                                Text(
                                  item['day'] as String,
                                  style: TextStyle(
                                    fontSize: 10, // Reducido de 11 a 10
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 1), // Reducido de 2 a 1
                                Text(
                                  '${item['dayNumber']}',
                                  style: TextStyle(
                                    fontSize: 9, // Reducido de 10 a 9
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2), // Reducido de 4 a 2
                                Text(
                                  '\$${(item['sales'] as double).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 8, // Reducido de 9 a 8
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    // Pocas barras: distribuir uniformemente en todo el ancho
                    // Calcular ancho de barra más delgado (máximo 25px)
                    final calculatedBarWidth = ((availableWidth - totalSpacing) / barCount);
                    final barWidth = calculatedBarWidth.clamp(15.0, 25.0); // Barras más delgadas (15-25px)
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: data.map((item) {
                        final height = (item['sales'] as double) / maxSales;
                        return SizedBox(
                          width: barWidth,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 180 * height, // Reducido de 200 a 180 para evitar overflow
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6), // Reducido de 8 a 6
                                Text(
                                  item['day'] as String,
                                  style: TextStyle(
                                    fontSize: 10, // Reducido de 11 a 10
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 1), // Reducido de 2 a 1
                                Text(
                                  '${item['dayNumber']}',
                                  style: TextStyle(
                                    fontSize: 9, // Reducido de 10 a 9
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2), // Reducido de 4 a 2
                                Text(
                                  '\$${(item['sales'] as double).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 8, // Reducido de 9 a 8
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMostSoldProductWidget() {
    if (_salesReportData == null || !_salesReportData!.containsKey('mostSoldProduct')) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No hay datos del producto más vendido',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }
    
    final mostSoldProduct = _salesReportData!['mostSoldProduct'] as Map<String, dynamic>?;
    if (mostSoldProduct == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No hay datos del producto más vendido',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }
    
    final productName = mostSoldProduct['name']?.toString() ?? mostSoldProduct['productName']?.toString() ?? 'Producto desconocido';
    final totalSold = mostSoldProduct['totalSold'] ?? mostSoldProduct['quantity'] ?? mostSoldProduct['amount'] ?? 0;
    final totalRevenue = mostSoldProduct['totalRevenue'] ?? mostSoldProduct['revenue'] ?? mostSoldProduct['total'] ?? 0.0;
    final totalSoldValue = totalSold is num ? totalSold.toInt() : 0;
    final totalRevenueValue = totalRevenue is num ? totalRevenue.toDouble() : 0.0;
    
    // Crear datos para el gráfico de torta (100% del producto más vendido)
    final pieData = [
      {'name': productName, 'percentage': 100.0, 'color': Colors.blue},
    ];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Producto Más Vendido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Información del producto
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Total Vendidos', totalSoldValue.toString()),
                      const SizedBox(height: 8),
                      _buildInfoRow('Total Ganancias', '\$${totalRevenueValue.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Gráfico de torta
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [Colors.blue, Colors.blue.shade300],
                      stops: const [0.0, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Column(
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
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLeastSoldProductsPieChart() {
    List<Map<String, dynamic>> data = [];
    
    if (_salesReportData != null && _salesReportData!.containsKey('leastSoldProducts')) {
      final leastSoldProducts = _salesReportData!['leastSoldProducts'] as List<dynamic>?;
      if (leastSoldProducts != null) {
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.red,
          Colors.teal,
          Colors.indigo,
          Colors.amber,
          Colors.pink,
          Colors.cyan,
        ];
        
        for (int i = 0; i < leastSoldProducts.length; i++) {
          final item = leastSoldProducts[i];
          if (item is Map) {
            final name = item['name']?.toString() ?? item['productName']?.toString() ?? 'Producto desconocido';
            final sales = item['totalSold'] ?? item['quantity'] ?? item['amount'] ?? 0;
            final salesValue = sales is num ? sales.toInt() : 0;
            
            data.add({
              'name': name,
              'sales': salesValue,
              'color': colors[i % colors.length],
            });
          }
        }
      }
    }
    
    // Si no hay datos, usar datos fake como fallback
    if (data.isEmpty) {
      data = [
        {'name': 'Cable USB-C', 'sales': 3, 'color': Colors.blue},
        {'name': 'Adaptador HDMI', 'sales': 4, 'color': Colors.green},
        {'name': 'Base para Laptop', 'sales': 5, 'color': Colors.orange},
        {'name': 'Soporte Monitor', 'sales': 4, 'color': Colors.purple},
        {'name': 'Funda Tablet', 'sales': 3, 'color': Colors.red},
      ];
    }
    
    final totalSales = data.isEmpty ? 0 : data.map((e) => e['sales'] as int).reduce((a, b) => a + b);
    
    if (data.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No hay datos de productos menos vendidos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }
    
    // Calcular porcentajes
    final dataWithPercentage = data.map((item) {
      final percentage = totalSales > 0 ? ((item['sales'] as int) / totalSales * 100) : 0.0;
      return {
        ...item,
        'percentage': percentage,
      };
    }).toList();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Menos Vendidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: dataWithPercentage.map((e) => e['color'] as Color).toList(),
                        stops: _calculateStops(dataWithPercentage),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: dataWithPercentage.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: item['color'] as Color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${item['sales']} ventas (${(item['percentage'] as double).toStringAsFixed(1)}%)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Total: $totalSales ventas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getDayName(int weekday) {
    const days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    return days[weekday % 7];
  }
  
  Color _getWarehouseColor(int id) {
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
  
  Future<void> _generateSalesReport() async {
    if (_selectedReportStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione una tienda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_reportStartDate == null || _reportEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione las fechas inicial y final'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoadingSalesReport = true;
    });
    
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }
      
      // Formatear fechas en formato ISO 8601 con hora
      // startDate debe ser al inicio del día (00:00:00)
      final startDateTime = DateTime(
        _reportStartDate!.year,
        _reportStartDate!.month,
        _reportStartDate!.day,
        0,
        0,
        0,
      );
      // endDate debe ser al final del día (23:59:59)
      final endDateTime = DateTime(
        _reportEndDate!.year,
        _reportEndDate!.month,
        _reportEndDate!.day,
        23,
        59,
        59,
      );
      
      final startDateStr = startDateTime.toIso8601String();
      final endDateStr = endDateTime.toIso8601String();
      
      final requestBody = {
        'id_store': _selectedReportStore!.idStore,
        'startDate': startDateStr,
        'endDate': endDateStr,
      };
      
      print('Generating sales report with: $requestBody');
      
      final response = await http.post(
        Uri.parse(ApiConstants.salesReport()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      print('Sales report response status: ${response.statusCode}');
      print('Sales report response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        setState(() {
          _salesReportData = decodedData as Map<String, dynamic>;
          _isLoadingSalesReport = false;
        });
      } else {
        throw Exception('Error al generar reporte: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error generating sales report: $e');
      setState(() {
        _isLoadingSalesReport = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar reporte: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Widget _buildEmptySalesReport() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Seleccione una tienda y fechas, luego presione "Generar Reporte"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSalesReport() {
    if (_salesReportData == null) return _buildEmptySalesReport();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título del reporte
        Text(
          'Reporte de Ventas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedReportStore != null
              ? 'Tienda: ${_selectedReportStore!.name}'
              : 'Todas las tiendas',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        if (_reportStartDate != null && _reportEndDate != null)
          Text(
            'Período: ${_reportStartDate!.day}/${_reportStartDate!.month}/${_reportStartDate!.year} - ${_reportEndDate!.day}/${_reportEndDate!.month}/${_reportEndDate!.year}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Gráfico de barras - Ventas por día (ocupa todo el ancho)
        _buildSalesByDayBarChartFromAPI(),
        
        const SizedBox(height: 24),
        
        // Producto más vendido y productos menos vendidos
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Producto más vendido (1/2)
            Expanded(
              child: _buildMostSoldProductWidget(),
            ),
            const SizedBox(width: 16),
            // Productos menos vendidos (1/2)
            Expanded(
              child: _buildLeastSoldProductsPieChart(),
            ),
          ],
        ),
      ],
    );
  }
  
  List<double> _calculateStops(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return [0.0, 1.0];
    
    final totalSales = data.map((e) => e['sales'] as int).reduce((a, b) => a + b);
    final stops = <double>[0.0];
    double cumulative = 0.0;
    
    // Calcular stops acumulativos: necesitamos exactamente data.length stops
    // Cada stop representa dónde termina cada segmento de color
    for (int i = 0; i < data.length - 1; i++) {
      final sales = data[i]['sales'] as int;
      cumulative += sales / totalSales;
      stops.add(cumulative);
    }
    // El último stop siempre es 1.0
    stops.add(1.0);
    
    // Asegurar que tenemos exactamente data.length stops
    // Si tenemos data.length + 1 stops, eliminar el penúltimo
    if (stops.length == data.length + 1) {
      stops.removeAt(stops.length - 2);
      stops[stops.length - 1] = 1.0;
    } else if (stops.length < data.length) {
      // Si tenemos menos, completar con el último valor
      while (stops.length < data.length) {
        stops.add(stops.isEmpty ? 0.0 : stops.last);
      }
      stops[stops.length - 1] = 1.0;
    } else if (stops.length > data.length) {
      // Si tenemos más, eliminar los extras
      stops.removeRange(data.length, stops.length);
      stops[stops.length - 1] = 1.0;
    }
    
    return stops;
  }
  
  Widget _buildTopProductsPieChart() {
    final data = [
      {'name': 'Laptop HP Pavilion', 'sales': 45, 'percentage': 28.5, 'color': Colors.blue},
      {'name': 'Mouse Logitech MX', 'sales': 32, 'percentage': 20.3, 'color': Colors.green},
      {'name': 'Teclado Mecánico', 'sales': 28, 'percentage': 17.7, 'color': Colors.orange},
      {'name': 'Monitor 27"', 'sales': 22, 'percentage': 13.9, 'color': Colors.purple},
      {'name': 'Auriculares BT', 'sales': 18, 'percentage': 11.4, 'color': Colors.red},
      {'name': 'Otros', 'sales': 13, 'percentage': 8.2, 'color': Colors.grey},
    ];
    
    final totalSales = data.map((e) => e['sales'] as int).reduce((a, b) => a + b);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Más Vendidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Gráfico de torta simulado
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  // Círculo de torta simulado
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: data.map((e) => e['color'] as Color).toList(),
                        stops: _calculateStops(data),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Leyenda
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.take(5).map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: item['color'] as Color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item['sales']} ventas (${item['percentage']}%)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Total: $totalSales ventas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomProductsPieChart() {
    final data = [
      {'name': 'Cable USB-C', 'sales': 3, 'percentage': 15.8, 'color': Colors.blue},
      {'name': 'Adaptador HDMI', 'sales': 4, 'percentage': 21.1, 'color': Colors.green},
      {'name': 'Base para Laptop', 'sales': 5, 'percentage': 26.3, 'color': Colors.orange},
      {'name': 'Soporte Monitor', 'sales': 4, 'percentage': 21.1, 'color': Colors.purple},
      {'name': 'Funda Tablet', 'sales': 3, 'percentage': 15.7, 'color': Colors.red},
    ];
    
    final totalSales = data.map((e) => e['sales'] as int).reduce((a, b) => a + b);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Menos Vendidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Gráfico de torta simulado
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  // Círculo de torta simulado
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: data.map((e) => e['color'] as Color).toList(),
                        stops: _calculateStops(data),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Leyenda
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: item['color'] as Color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item['sales']} ventas (${item['percentage']}%)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Total: $totalSales ventas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopProductsTable() {
    final products = [
      {'name': 'Laptop HP Pavilion', 'sales': 45, 'revenue': 40495.55},
      {'name': 'Mouse Logitech MX', 'sales': 32, 'revenue': 3199.68},
      {'name': 'Teclado Mecánico', 'sales': 28, 'revenue': 2799.72},
      {'name': 'Monitor 27"', 'sales': 22, 'revenue': 4399.78},
      {'name': 'Auriculares Bluetooth', 'sales': 18, 'revenue': 1799.82},
    ];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Más Vendidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFF2F2F7),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  children: [
                    _buildTableCell('Producto', isHeader: true),
                    _buildTableCell('Ventas', isHeader: true),
                    _buildTableCell('Ingresos', isHeader: true),
                  ],
                ),
                // Rows
                ...products.map((product) {
                  return TableRow(
                    children: [
                      _buildTableCell(product['name'] as String),
                      _buildTableCell('${product['sales']}'),
                      _buildTableCell('\$${(product['revenue'] as double).toStringAsFixed(2)}'),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 12 : 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader
              ? Colors.grey[600]
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
        ),
      ),
    );
  }
  
  Widget _buildStoreAutocomplete() {
    return Autocomplete<Object>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _stores.cast<Object>();
        }
        final query = textEditingValue.text.toLowerCase();
        return _stores.where((store) {
          return store.name.toLowerCase().contains(query) ||
                 store.location.toLowerCase().contains(query);
        }).cast<Object>();
      },
      displayStringForOption: (Object store) {
        if (store is Store) {
          return store.name;
        }
        return '';
      },
      onSelected: (Object store) {
        if (store is Store) {
          setState(() {
            _selectedReportStore = store;
          });
        }
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Inicializar el controller con el valor actual si está seleccionado
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (textEditingController.text.isEmpty && _selectedReportStore != null) {
            textEditingController.text = _selectedReportStore!.name;
          }
        });
        
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: textEditingController,
          builder: (context, value, child) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Tienda',
                hintText: 'Buscar tienda...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.store,
                  color: Colors.grey[500],
                  size: 20,
                ),
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[500],
                          size: 18,
                        ),
                        onPressed: () {
                          textEditingController.clear();
                          setState(() {
                            _selectedReportStore = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontSize: 16),
            );
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Object> onSelected,
        Iterable<Object> options,
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
                  final store = options.elementAt(index);
                  if (store is! Store) return const SizedBox.shrink();
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: store.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.store, color: store.color, size: 20),
                    ),
                    title: Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      store.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    onTap: () {
                      onSelected(store);
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
  
  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: const Color(0xFF007AFF),
                  onPrimary: Colors.white,
                  onSurface: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Seleccionar fecha',
          prefixIcon: Icon(
            Icons.calendar_today,
            color: Colors.grey[500],
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          selectedDate != null
              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
              : 'Seleccionar fecha',
          style: TextStyle(
            fontSize: 16,
            color: selectedDate != null
                ? Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black
                : Colors.grey[500],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTransfersReportTab() {
    // Cargar almacenes si la lista está vacía
    if (_warehouses.isEmpty && !_isLoadingWarehouses) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadWarehousesForReport();
      });
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila con buscador (3/4) y botón (1/4)
          Row(
            children: [
              // Combobox con autocompletado para almacenes (3/4)
              Expanded(
                flex: 3,
                child: _buildWarehouseAutocomplete(),
              ),
              
              const SizedBox(width: 12),
              
              // Botón Generar Reporte (1/4)
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingTransfersReport ? null : _generateTransfersReport,
                  icon: _isLoadingTransfersReport
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.description, size: 20),
                  label: Text(_isLoadingTransfersReport ? 'Generando...' : 'Generar Reporte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Date pickers
          Row(
            children: [
              // Fecha inicial
              Expanded(
                child: _buildDatePicker(
                  label: 'Fecha Inicial',
                  selectedDate: _transferStartDate,
                  onDateSelected: (date) {
                    setState(() {
                      _transferStartDate = date;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Fecha final
              Expanded(
                child: _buildDatePicker(
                  label: 'Fecha Final',
                  selectedDate: _transferEndDate,
                  onDateSelected: (date) {
                    setState(() {
                      _transferEndDate = date;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Reporte con gráficos
          if (_isLoadingTransfersReport)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_transfersReportData != null)
            _buildTransfersByDayBarChartFromAPI()
          else
            _buildEmptyTransfersReport(),
        ],
      ),
    );
  }
  
  Future<void> _loadWarehousesForReport() async {
    if (_isLoadingWarehouses) return;
    
    setState(() {
      _isLoadingWarehouses = true;
    });
    
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        setState(() {
          _warehouses = [];
          _isLoadingWarehouses = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConstants.warehouses(page: 0, size: 100)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        List<dynamic> data = [];
        
        if (decodedData is Map && decodedData.containsKey('content')) {
          data = decodedData['content'] as List<dynamic>;
        } else if (decodedData is List) {
          data = decodedData;
        }

        final newWarehouses = data.map((item) {
          final idWarehouse = item['idWarehouse'] as int?;
          final name = item['name']?.toString() ?? 'Sin nombre';
          final address = item['address']?.toString() ?? 'Sin dirección';
          final status = item['status']?.toString() ?? 'Active';
          final productCount = item['products'] is int ? item['products'] as int : 0;
          final isActive = status.toLowerCase() == 'active';

          return Warehouse(
            idWarehouse: idWarehouse,
            name: name,
            location: address,
            icon: Icons.warehouse,
            color: _getWarehouseColor(idWarehouse ?? 0),
            productCount: productCount,
            isActive: isActive,
            capacity: 0,
          );
        }).toList();

        if (mounted) {
          setState(() {
            _warehouses = newWarehouses;
            _isLoadingWarehouses = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _warehouses = [];
            _isLoadingWarehouses = false;
          });
        }
      }
    } catch (e) {
      print('Error loading warehouses for report: $e');
      if (mounted) {
        setState(() {
          _warehouses = [];
          _isLoadingWarehouses = false;
        });
      }
    }
  }
  
  Widget _buildWarehouseAutocomplete() {
    return Autocomplete<Warehouse>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _warehouses;
        }
        final query = textEditingValue.text.toLowerCase();
        return _warehouses.where((warehouse) {
          return warehouse.name.toLowerCase().contains(query) ||
                 warehouse.location.toLowerCase().contains(query);
        });
      },
      displayStringForOption: (Warehouse warehouse) {
        return warehouse.name;
      },
      onSelected: (Warehouse warehouse) {
        setState(() {
          _selectedTransferWarehouse = warehouse;
        });
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (textEditingController.text.isEmpty && _selectedTransferWarehouse != null) {
            textEditingController.text = _selectedTransferWarehouse!.name;
          }
        });
        
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: textEditingController,
          builder: (context, value, child) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Almacén',
                hintText: 'Buscar almacén...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.warehouse,
                  color: Colors.grey[500],
                  size: 20,
                ),
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[500],
                          size: 18,
                        ),
                        onPressed: () {
                          textEditingController.clear();
                          setState(() {
                            _selectedTransferWarehouse = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontSize: 16),
            );
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Warehouse> onSelected,
        Iterable<Warehouse> options,
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
                  final warehouse = options.elementAt(index);
                  
                  return ListTile(
                    leading: Icon(warehouse.icon, color: warehouse.color),
                    title: Text(warehouse.name),
                    subtitle: Text(warehouse.location),
                    onTap: () => onSelected(warehouse),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _generateTransfersReport() async {
    if (_selectedTransferWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione un almacén'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_transferStartDate == null || _transferEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione las fechas inicial y final'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoadingTransfersReport = true;
    });
    
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }
      
      // Formatear fechas en formato ISO 8601 con hora
      // startDate debe ser al inicio del día (00:00:00)
      final startDateTime = DateTime(
        _transferStartDate!.year,
        _transferStartDate!.month,
        _transferStartDate!.day,
        0,
        0,
        0,
      );
      // endDate debe ser al final del día (23:59:59)
      final endDateTime = DateTime(
        _transferEndDate!.year,
        _transferEndDate!.month,
        _transferEndDate!.day,
        23,
        59,
        59,
      );
      
      final startDateStr = startDateTime.toIso8601String();
      final endDateStr = endDateTime.toIso8601String();
      
      final requestBody = {
        'id_warehouse': _selectedTransferWarehouse!.idWarehouse,
        'startDate': startDateStr,
        'endDate': endDateStr,
      };
      
      print('Generating transfers report with: $requestBody');
      
      final response = await http.post(
        Uri.parse(ApiConstants.warehouseTransferReport()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      print('Transfers report response status: ${response.statusCode}');
      print('Transfers report response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        setState(() {
          _transfersReportData = decodedData as Map<String, dynamic>;
          _isLoadingTransfersReport = false;
        });
      } else {
        throw Exception('Error al generar reporte: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error generating transfers report: $e');
      setState(() {
        _isLoadingTransfersReport = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar reporte: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Widget _buildEmptyTransfersReport() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swap_horiz,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Seleccione un almacén y fechas, luego presione "Generar Reporte"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTransfersByDayBarChartFromAPI() {
    // Obtener datos de dailyTransfers de la API
    List<Map<String, dynamic>> data = [];
    
    print('_buildTransfersByDayBarChartFromAPI called');
    print('_transfersReportData: $_transfersReportData');
    
    if (_transfersReportData != null && _transfersReportData!.containsKey('dailyTransfers')) {
      final dailyTransfers = _transfersReportData!['dailyTransfers'] as List<dynamic>?;
      print('dailyTransfers found: ${dailyTransfers?.length} items');
      
      if (dailyTransfers != null && dailyTransfers.isNotEmpty) {
        for (var item in dailyTransfers) {
          print('Processing item: $item');
          if (item is Map) {
            final dateStr = item['date']?.toString();
            final transferCount = item['transferCount'];
            final products = item['products'] as List<dynamic>?;
            
            print('dateStr: $dateStr, transferCount: $transferCount, products: $products');
            
            // Usar transferCount si está disponible, sino contar productos
            int totalProducts = 0;
            if (transferCount != null) {
              totalProducts = transferCount is num ? transferCount.toInt() : 0;
            } else if (products != null) {
              // Contar el total de productos transferidos en este día
              for (var product in products) {
                if (product is Map) {
                  final quantity = product['quantity'] ?? product['amount'] ?? product['units'] ?? 0;
                  totalProducts += quantity is num ? quantity.toInt() : 0;
                }
              }
            }
            
            print('totalProducts calculated: $totalProducts');
            
            DateTime? date;
            if (dateStr != null) {
              try {
                date = DateTime.parse(dateStr);
                print('Parsed date: $date');
              } catch (e) {
                print('Error parsing date: $dateStr, error: $e');
              }
            }
            
            if (date != null) {
              final dayName = _getDayName(date.weekday);
              
              data.add({
                'date': date,
                'day': dayName,
                'dayNumber': date.day,
                'transfers': totalProducts.toDouble(),
              });
              print('Added data point: ${date.day}/${date.month} - $totalProducts transfers');
            } else {
              print('Skipping item: date is null');
            }
          }
        }
      } else {
        print('dailyTransfers is null or empty');
      }
    } else {
      print('_transfersReportData is null or does not contain dailyTransfers');
      if (_transfersReportData != null) {
        print('Available keys: ${_transfersReportData!.keys.toList()}');
      }
    }
    
    print('Final data length: ${data.length}');
    
    // Si no hay datos de la API, usar datos fake como fallback
    if (data.isEmpty && _transferStartDate != null && _transferEndDate != null) {
      final startDate = _transferStartDate!;
      final endDate = _transferEndDate!;
      final daysDifference = endDate.difference(startDate).inDays;
      
      for (int i = 0; i <= daysDifference && i < 30; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final dayName = _getDayName(currentDate.weekday);
        final transfers = 50.0 + (i * 10.0) + (i % 3 * 15.0);
        
        data.add({
          'date': currentDate,
          'day': dayName,
          'dayNumber': currentDate.day,
          'transfers': transfers,
        });
      }
    }
    
    if (data.isEmpty) {
      print('No data to display in chart');
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay datos de transferencias para mostrar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_transfersReportData != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Datos recibidos pero sin información de transferencias',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    
    print('Data points to display: ${data.length}');
    print('Sample data: ${data.take(3).toList()}');
    
    final maxTransfers = data.map((e) => e['transfers'] as double).reduce((a, b) => a > b ? a : b);
    print('Max transfers: $maxTransfers');
    
    // Asegurar que maxTransfers sea al menos 1 para evitar división por cero
    final safeMaxTransfers = maxTransfers > 0 ? maxTransfers : 1.0;
    print('Safe max transfers: $safeMaxTransfers');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Transferencias por Día',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            if (_selectedTransferWarehouse != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Almacén: ${_selectedTransferWarehouse!.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final barCount = data.length;
                  final spacing = 4.0;
                  
                  final minBarWidth = 20.0;
                  final totalSpacing = spacing * (barCount - 1);
                  final requiredWidth = (minBarWidth * barCount) + totalSpacing;
                  
                  if (requiredWidth > availableWidth) {
                    // Muchas barras: scroll horizontal con barras de ancho fijo
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: data.map((item) {
                          final height = ((item['transfers'] as double) / safeMaxTransfers).clamp(0.0, 1.0);
                          final barHeight = (180 * height).clamp(0.0, 180.0);
                          return Padding(
                            padding: EdgeInsets.only(right: spacing),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: minBarWidth,
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['day'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${item['dayNumber']}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${(item['transfers'] as double).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    // Pocas barras: distribuir uniformemente en todo el ancho
                    final calculatedBarWidth = ((availableWidth - totalSpacing) / barCount);
                    final barWidth = calculatedBarWidth.clamp(15.0, 25.0);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: data.map((item) {
                        final height = ((item['transfers'] as double) / safeMaxTransfers).clamp(0.0, 1.0);
                        final barHeight = (180 * height).clamp(0.0, 180.0);
                        return SizedBox(
                          width: barWidth,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['day'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${item['dayNumber']}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${(item['transfers'] as double).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGlobalSalesReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con combobox (1/2) y toggle (1/2)
          Row(
            children: [
              // Combobox con autocompletado para tiendas (1/2)
              Expanded(
                flex: 1,
                child: _buildGlobalStoreAutocomplete(),
              ),
              
              const SizedBox(width: 12),
              
              // Toggle para habilitar/deshabilitar filtro por tienda (1/2)
              Expanded(
                flex: 1,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _filterByStore ? 'Filtrar ventas por tiendas' : 'Ventas globales',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        Switch(
                          value: _filterByStore,
                          onChanged: (value) {
                            setState(() {
                              _filterByStore = value;
                              if (!value) {
                                _selectedGlobalReportStore = null;
                              }
                            });
                          },
                          activeColor: const Color(0xFF007AFF),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Date pickers
          Row(
            children: [
              // Fecha inicial
              Expanded(
                child: _buildDatePicker(
                  label: 'Fecha Inicial',
                  selectedDate: _globalReportStartDate,
                  onDateSelected: (date) {
                    setState(() {
                      _globalReportStartDate = date;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Fecha final
              Expanded(
                child: _buildDatePicker(
                  label: 'Fecha Final',
                  selectedDate: _globalReportEndDate,
                  onDateSelected: (date) {
                    setState(() {
                      _globalReportEndDate = date;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Gráfico de barras - Ventas diarias (ocupa todo el ancho)
          _buildGlobalSalesByDayBarChart(),
          
          const SizedBox(height: 24),
          
          // Gráficos de torta - Productos más y menos vendidos (cada uno ocupa la mitad)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Productos más vendidos (1/2)
              Expanded(
                child: _buildGlobalTopProductsPieChart(),
              ),
              const SizedBox(width: 16),
              // Productos menos vendidos (1/2)
              Expanded(
                child: _buildGlobalBottomProductsPieChart(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGlobalStoreAutocomplete() {
    return IgnorePointer(
      ignoring: !_filterByStore,
      child: Opacity(
        opacity: _filterByStore ? 1.0 : 0.5,
        child: Autocomplete<Store>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (!_filterByStore) return const Iterable<Store>.empty();
            if (textEditingValue.text.isEmpty) {
              return _stores;
            }
            final query = textEditingValue.text.toLowerCase();
            return _stores.where((store) {
              return store.name.toLowerCase().contains(query) ||
                     store.location.toLowerCase().contains(query);
            });
          },
      displayStringForOption: (Store store) {
        return store.name;
      },
      onSelected: (Store store) {
        setState(() {
          _selectedGlobalReportStore = store;
        });
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (textEditingController.text.isEmpty && _selectedGlobalReportStore != null) {
            textEditingController.text = _selectedGlobalReportStore!.name;
          }
        });
        
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: textEditingController,
          builder: (context, value, child) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              enabled: _filterByStore,
              decoration: InputDecoration(
                labelText: 'Tienda',
                hintText: 'Buscar tienda...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.store,
                  color: _filterByStore ? Colors.grey[500] : Colors.grey[300],
                  size: 20,
                ),
                suffixIcon: value.text.isNotEmpty && _filterByStore
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[500],
                          size: 18,
                        ),
                        onPressed: () {
                          textEditingController.clear();
                          setState(() {
                            _selectedGlobalReportStore = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: !_filterByStore,
                fillColor: !_filterByStore ? Colors.grey[100] : null,
              ),
              style: TextStyle(
                fontSize: 16,
                color: _filterByStore ? null : Colors.grey[400],
              ),
            );
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Store> onSelected,
        Iterable<Store> options,
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
                  final store = options.elementAt(index);
                  
                  return ListTile(
                    leading: Icon(store.icon, color: store.color),
                    title: Text(store.name),
                    subtitle: Text(store.location),
                    onTap: () => onSelected(store),
                  );
                },
              ),
            ),
          ),
        );
      },
        ),
      ),
    );
  }
  
  Widget _buildGlobalSalesByDayBarChart() {
    // Generar datos de ventas por día dentro del rango de fechas
    List<Map<String, dynamic>> data = [];
    
    if (_globalReportStartDate != null && _globalReportEndDate != null) {
      final startDate = _globalReportStartDate!;
      final endDate = _globalReportEndDate!;
      final daysDifference = endDate.difference(startDate).inDays;
      
      // Generar datos fake para cada día en el rango
      for (int i = 0; i <= daysDifference && i < 30; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final dayName = _getDayName(currentDate.weekday);
        final sales = 1000.0 + (i * 150.0) + (i % 3 * 200.0); // Datos fake variados
        
        data.add({
          'date': currentDate,
          'day': dayName,
          'dayNumber': currentDate.day,
          'sales': sales,
        });
      }
    } else {
      // Si no hay fechas seleccionadas, mostrar últimos 7 días
      final today = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dayName = _getDayName(date.weekday);
        final sales = 1000.0 + (i * 150.0) + (i % 3 * 200.0);
        
        data.add({
          'date': date,
          'day': dayName,
          'dayNumber': date.day,
          'sales': sales,
        });
      }
    }
    
    if (data.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Seleccione un rango de fechas para ver las ventas por día',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }
    
    final maxSales = data.map((e) => e['sales'] as double).reduce((a, b) => a > b ? a : b);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ventas Diarias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            if (_selectedGlobalReportStore != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Tienda: ${_selectedGlobalReportStore!.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final barCount = data.length;
                  final spacing = 4.0;
                  
                  final minBarWidth = 20.0;
                  final totalSpacing = spacing * (barCount - 1);
                  final requiredWidth = (minBarWidth * barCount) + totalSpacing;
                  
                  if (requiredWidth > availableWidth) {
                    // Muchas barras: scroll horizontal con barras de ancho fijo
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: data.map((item) {
                          final height = (item['sales'] as double) / maxSales;
                          return Padding(
                            padding: EdgeInsets.only(right: spacing),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: minBarWidth,
                                  height: 180 * height,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['day'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${item['dayNumber']}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${(item['sales'] as double).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    // Pocas barras: distribuir uniformemente en todo el ancho
                    final calculatedBarWidth = ((availableWidth - totalSpacing) / barCount);
                    final barWidth = calculatedBarWidth.clamp(15.0, 25.0);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: data.map((item) {
                        final height = (item['sales'] as double) / maxSales;
                        return SizedBox(
                          width: barWidth,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 180 * height,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['day'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${item['dayNumber']}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${(item['sales'] as double).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGlobalTopProductsPieChart() {
    final data = [
      {'name': 'Laptop HP Pavilion', 'sales': 45, 'percentage': 28.5, 'color': Colors.blue},
      {'name': 'Mouse Logitech MX', 'sales': 32, 'percentage': 20.3, 'color': Colors.green},
      {'name': 'Teclado Mecánico', 'sales': 28, 'percentage': 17.7, 'color': Colors.orange},
      {'name': 'Monitor 27"', 'sales': 22, 'percentage': 13.9, 'color': Colors.purple},
      {'name': 'Auriculares BT', 'sales': 18, 'percentage': 11.4, 'color': Colors.red},
      {'name': 'Otros', 'sales': 13, 'percentage': 8.2, 'color': Colors.grey},
    ];
    
    final totalSales = data.map((e) => e['sales'] as int).reduce((a, b) => a + b);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Más Vendidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: data.map((e) => e['color'] as Color).toList(),
                        stops: _calculateStops(data),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.take(5).map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: item['color'] as Color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${item['sales']} ventas (${item['percentage']}%)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Total: $totalSales ventas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGlobalBottomProductsPieChart() {
    final data = [
      {'name': 'Cable USB-C', 'sales': 3, 'percentage': 15.8, 'color': Colors.blue},
      {'name': 'Adaptador HDMI', 'sales': 4, 'percentage': 21.1, 'color': Colors.green},
      {'name': 'Base para Laptop', 'sales': 5, 'percentage': 26.3, 'color': Colors.orange},
      {'name': 'Soporte Monitor', 'sales': 4, 'percentage': 21.1, 'color': Colors.purple},
      {'name': 'Funda Tablet', 'sales': 3, 'percentage': 15.7, 'color': Colors.red},
    ];
    
    final totalSales = data.map((e) => e['sales'] as int).reduce((a, b) => a + b);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Menos Vendidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: data.map((e) => e['color'] as Color).toList(),
                        stops: _calculateStops(data),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: item['color'] as Color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${item['sales']} ventas (${item['percentage']}%)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Total: $totalSales ventas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSalesPurchasesReport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        DateTime? selectedStartDate;
        DateTime? selectedEndDate;
        Store? selectedStore;
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_cart, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Reporte de Ventas y Compras',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenido
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selector de tienda
                          const Text(
                            'Tienda',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Store?>(
                            value: selectedStore,
                            decoration: InputDecoration(
                              hintText: 'Seleccionar tienda',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                            ),
                            items: [
                              const DropdownMenuItem<Store?>(
                                value: null,
                                child: Text('Todas las tiendas'),
                              ),
                              ..._stores.map((store) => DropdownMenuItem<Store?>(
                                value: store,
                                child: Text(store.name),
                              )),
                            ],
                            onChanged: (value) {
                              setModalState(() {
                                selectedStore = value;
                              });
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Selector de fecha inicio
                          const Text(
                            'Fecha Inicio',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setModalState(() {
                                  selectedStartDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                                  const SizedBox(width: 12),
                                  Text(
                                    selectedStartDate != null
                                        ? '${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}'
                                        : 'Seleccionar fecha',
                                    style: TextStyle(
                                      color: selectedStartDate != null ? null : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Selector de fecha fin
                          const Text(
                            'Fecha Fin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedStartDate ?? DateTime.now(),
                                firstDate: selectedStartDate ?? DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setModalState(() {
                                  selectedEndDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                                  const SizedBox(width: 12),
                                  Text(
                                    selectedEndDate != null
                                        ? '${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}'
                                        : 'Seleccionar fecha',
                                    style: TextStyle(
                                      color: selectedEndDate != null ? null : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Botón generar reporte
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Generando reporte de ventas y compras...'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                // TODO: Implementar llamada a API de reportes
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
                                'Generar Reporte',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTransfersReport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        DateTime? selectedStartDate;
        DateTime? selectedEndDate;
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Reporte de Transferencias',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenido
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filtros de Transferencias',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Selector de fecha inicio
                          const Text(
                            'Fecha Inicio',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setModalState(() {
                                  selectedStartDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                                  const SizedBox(width: 12),
                                  Text(
                                    selectedStartDate != null
                                        ? '${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}'
                                        : 'Seleccionar fecha',
                                    style: TextStyle(
                                      color: selectedStartDate != null ? null : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Selector de fecha fin
                          const Text(
                            'Fecha Fin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedStartDate ?? DateTime.now(),
                                firstDate: selectedStartDate ?? DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setModalState(() {
                                  selectedEndDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                                  const SizedBox(width: 12),
                                  Text(
                                    selectedEndDate != null
                                        ? '${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}'
                                        : 'Seleccionar fecha',
                                    style: TextStyle(
                                      color: selectedEndDate != null ? null : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Botón generar reporte
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Generando reporte de transferencias...'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                // TODO: Implementar llamada a API de reportes
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
                                'Generar Reporte',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGlobalSalesReport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        Store? selectedStore;
        bool showByStore = false;
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Ventas Globales del Día',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenido
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Opción de filtro
                          Row(
                            children: [
                              Switch(
                                value: showByStore,
                                onChanged: (value) {
                                  setModalState(() {
                                    showByStore = value;
                                    if (!value) {
                                      selectedStore = null;
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Filtrar por tienda',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          if (showByStore) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Tienda',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Store?>(
                              value: selectedStore,
                              decoration: InputDecoration(
                                hintText: 'Seleccionar tienda',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                              ),
                              items: _stores.map((store) => DropdownMenuItem<Store?>(
                                value: store,
                                child: Text(store.name),
                              )).toList(),
                              onChanged: (value) {
                                setModalState(() {
                                  selectedStore = value;
                                });
                              },
                            ),
                          ],
                          
                          const Spacer(),
                          
                          // Botón generar reporte
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      showByStore && selectedStore != null
                                          ? 'Generando reporte de ventas para ${selectedStore!.name}...'
                                          : 'Generando reporte de ventas globales...',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                // TODO: Implementar llamada a API de reportes
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
                                'Generar Reporte',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfilePage() {
    final username = AuthService.username ?? 'Usuario';
    final fullName = AuthService.fullName ?? username;
    final roleDisplay = AuthService.roleDisplayName;
    final email = AuthService.email;
    final initials = AuthService.initials;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar y nombre
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF007AFF),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            roleDisplay,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Información del usuario
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                width: 0.5,
              ),
            ),
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfoRow(
                    icon: Icons.person_outline,
                    label: 'Usuario',
                    value: username,
                  ),
                  if (email != null) ...[
                    const SizedBox(height: 12),
                    _buildProfileInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildProfileInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Rol',
                    value: roleDisplay,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Opciones de perfil
          _buildProfileOption(
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.settings_outlined,
            title: 'Configuración',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.logout_outlined,
            title: 'Cerrar Sesión',
            onTap: () {
              _showLogoutConfirmation();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(DemoProduct product) {
    return InkWell(
      onTap: () => _showProductDetail(product),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: product.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  product.icon,
                  size: 48,
                  color: product.color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : (isDark ? Colors.white70 : Colors.black87),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
      ),
    );
  }

  Future<List<SearchResult>> _searchProducts(String query) async {
    // Simular búsqueda con delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final filtered = _products
        .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .map((product) => SearchResult(
              title: product.name,
              subtitle: '\$${product.price.toStringAsFixed(2)}',
              icon: product.icon,
              data: product,
            ))
        .toList();
    
    return filtered;
  }

  void _showProductDetail(DemoProduct product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: product.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    product.icon,
                    size: 40,
                    color: product.color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF007AFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} agregado al carrito'),
                          duration: const Duration(milliseconds: 2000),
                        ),
                      );
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
                      'Agregar al Carrito',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Actualizar'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout_outlined,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión? Perderás todos los datos no guardados.',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
              ),
              const SizedBox(height: 20),
              Text(
                'Cerrando sesión...',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );

    // Simular tiempo de cierre de sesión
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Cerrar loading
      
      // Limpiar autenticación y permisos
      AuthService.logout();
      
      // Mostrar confirmación de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Sesión cerrada exitosamente',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      // Navegar a la pantalla de login después del éxito
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DemoLoginPage()),
          (route) => false,
        );
      });
    });
  }

  Widget _buildDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: Column(
        children: [
          // Header del drawer con información del usuario
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // Avatar del usuario con icono basado en rol
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    AuthService.isAdmin ? Icons.admin_panel_settings :
                    AuthService.isManager ? Icons.manage_accounts :
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                // Información del usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AuthService.username ?? 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AuthService.isAdmin ? 'Administrador' :
                        AuthService.isManager ? 'Gerente' : 'Usuario',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Debug info de permisos
          //const UserPermissionsDebugWidget(),
          
          // Lista de opciones del drawer con permisos
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Gestionar Almacenes - Solo con permiso específico
                PermissionWidget(
                  customPermissionCheck: () => AuthService.canManageWarehouses,
                  child: _buildDrawerItem(
                    icon: Icons.warehouse_outlined,
                    activeIcon: Icons.warehouse,
                    title: 'Gestionar Almacenes',
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WarehouseManagementPage(),
                        ),
                      );
                    },
                  ),
                ),
                
                // Gestionar Tiendas - Manager o Admin
                PermissionWidget(
                  customPermissionCheck: () => AuthService.canManageStores,
                  child: _buildDrawerItem(
                    icon: Icons.store_outlined,
                    activeIcon: Icons.store,
                    title: 'Gestionar Tiendas',
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StoreManagementPage(),
                        ),
                      );
                    },
                  ),
                ),
                
                // Gestionar Productos - Manager o Admin
                PermissionWidget(
                  customPermissionCheck: () => AuthService.canManageProducts,
                  child: _buildDrawerItem(
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2,
                    title: 'Gestionar Productos',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProductManagementPage(),
                        ),
                      );
                    },
                  ),
                ),
                
                // Reportes - Solo Admin o Manager
                PermissionWidget(
                  customPermissionCheck: () => AuthService.canViewReports,
                  child: _buildDrawerItem(
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics,
                    title: 'Reportes',
                    isSelected: _currentBottomIndex == 3,
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _currentBottomIndex = 3;
                      });
                    },
                  ),
                ),
                
                // Panel de Admin - Solo Administradores
                AdminOnlyWidget(
                  child: _buildDrawerItem(
                    icon: Icons.admin_panel_settings_outlined,
                    activeIcon: Icons.admin_panel_settings,
                    title: 'Panel de Administración',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const UserControlPanelPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Footer del drawer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.logout_outlined,
                  size: 20,
                  color: Colors.red,
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showLogoutConfirmation();
                  },
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildDrawerItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = const Color(0xFF007AFF);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? selectedColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected
              ? selectedColor
              : (isDark ? Colors.white70 : Colors.black87),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? selectedColor
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),
    );
  }

  void _showCartDetail() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            
            // Recalcular el total cada vez que se actualiza el modal
            final currentTotal = _cart.entries
                .map((entry) => entry.key.price * entry.value)
                .fold(0.0, (sum, price) => sum + price);
            
            // Validar campos del cliente
            final customerName = _customerNameController.text.trim();
            final customerNit = _customerNitController.text.trim();
            final isNitValid = customerNit.length >= 5 && customerNit.length <= 9;
            final isFormValid = customerName.isNotEmpty && customerNit.isNotEmpty && isNitValid;
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_cart, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Mi Carrito',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  
                  // Campos de información del cliente
                  if (_cart.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Cliente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _customerNameController,
                            decoration: InputDecoration(
                              hintText: 'Nombre del cliente',
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            onChanged: (_) => setModalState(() {}),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _customerNitController,
                            decoration: InputDecoration(
                              hintText: 'NIT del cliente (5-9 dígitos)',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              errorText: _customerNitController.text.isNotEmpty && 
                                        (_customerNitController.text.length < 5 || _customerNitController.text.length > 9)
                                  ? 'El NIT debe tener entre 5 y 9 dígitos'
                                  : null,
                            ),
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ],
                      ),
                    ),
                  
                  // Lista de productos en el carrito
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tu carrito está vacío',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final entry = _cart.entries.elementAt(index);
                              final product = entry.key;
                              final quantity = entry.value;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // Icono del producto
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: product.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        product.icon,
                                        color: product.color,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Información del producto
                                    Expanded(
                                      child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '\$${product.price.toStringAsFixed(2)} c/u',
                                          style: const TextStyle(
                                            color: Color(0xFF007AFF),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Controles de cantidad
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (quantity > 1) {
                                              _cart[product] = quantity - 1;
                                            } else {
                                              _cart.remove(product);
                                            }
                                            _updateCartTotal();
                                          });
                                          // Actualizar el modal también
                                          setModalState(() {});
                                        },
                                        icon: const Icon(Icons.remove_circle_outline),
                                        color: const Color(0xFF007AFF),
                                      ),
                                      Container(
                                        width: 40,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _cart[product] = quantity + 1;
                                            _updateCartTotal();
                                          });
                                          // Actualizar el modal también
                                          setModalState(() {});
                                        },
                                        icon: const Icon(Icons.add_circle_outline),
                                        color: const Color(0xFF007AFF),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(width: 8),
                                  
                                  // Precio total del item
                                  Text(
                                    '\$${(product.price * quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  ),
                  
                  // Footer con total y botones
                  if (_cart.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF8F9FA),
                        border: Border(
                          top: BorderSide(
                            color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${currentTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF007AFF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _cart.clear();
                                      _cartTotal = 0.0;
                                    });
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
                                    'Vaciar Carrito',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: isFormValid
                                      ? () async {
                                          await _processSale();
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF007AFF),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.grey[600],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
                                    'Proceder con la Venta',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}