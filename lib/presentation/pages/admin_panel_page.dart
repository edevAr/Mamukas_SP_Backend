import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/widgets.dart';
import '../../domain/entities/user.dart';
import '../../core/constants/user_status.dart';
import '../../core/services/auth_service.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../../core/utils/dependency_injection.dart' as di;

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  static const routeName = '/admin-panel';

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  // Listas de datos
  List<User> _users = [];
  List<Store> _stores = [];
  List<Warehouse> _warehouses = [];
  List<Product> _products = [];

  // Estados de carga
  bool _isLoadingUsers = false;
  bool _isLoadingStores = false;
  bool _isLoadingWarehouses = false;
  bool _isLoadingProducts = false;
  bool _usersInitialLoadStarted = false; // Flag para evitar múltiples cargas iniciales
  
  // Paginación de almacenes
  int _currentWarehousePage = 0;
  bool _hasMoreWarehousePages = true;
  bool _isLoadingMoreWarehouses = false;
  final ScrollController _warehouseScrollController = ScrollController();
  
  // Paginación de usuarios
  int _currentUserPage = 0;
  bool _hasMoreUserPages = true;
  bool _isLoadingMoreUsers = false;
  final ScrollController _userScrollController = ScrollController();
  
  // Paginación de tiendas
  int _currentStorePage = 0;
  bool _hasMoreStorePages = true;
  bool _isLoadingMoreStores = false;
  final ScrollController _storeScrollController = ScrollController();
  bool _storesInitialLoadStarted = false; // Flag para evitar múltiples cargas iniciales
  
  // Paginación de productos
  int _currentProductPage = 0;
  bool _hasMoreProductPages = true;
  bool _isLoadingMoreProducts = false;
  final ScrollController _productScrollController = ScrollController();
  bool _productsInitialLoadStarted = false; // Flag para evitar múltiples cargas iniciales
  
  // Roles y permisos
  final List<String> _availableRoles = ['Admin', 'Manager', 'Employee', 'Viewer'];
  final List<String> _availablePermissions = [
    'INVENTORY_*',
    'USER_*',
    'PRODUCTS_*',
    'STORES_*',
    'WAREHOUSES_*',
    'SALES_*',
    'MANAGER',
    'PRODUCT_VIEW',
    'PRODUCT_EDIT',
    'PRODUCT_DELETE',
    'STORE_VIEW',
    'STORE_MANAGEMENT',
    'WAREHOUSE_VIEW',
    'WAREHOUSE_MANAGEMENT',
    'REPORTS_VIEW',
  ];
  
  // Mapa para almacenar roles y permisos de usuarios
  final Map<int, String> _userRoles = {};
  final Map<int, List<String>> _userPermissions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    
    // Listener para scroll infinito de usuarios
    _userScrollController.addListener(_onUserScroll);
    
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _warehouseScrollController.dispose();
    _userScrollController.dispose();
    _storeScrollController.dispose();
    _productScrollController.dispose();
    super.dispose();
  }

  void _onWarehouseScroll() {
    if (_warehouseScrollController.position.pixels >=
        _warehouseScrollController.position.maxScrollExtent - 200) {
      // Cargar más cuando se está cerca del final (200px antes)
      if (!_isLoadingMoreWarehouses && _hasMoreWarehousePages && _currentTab == 2) {
        _loadMoreWarehouses();
      }
    }
  }
  
  void _onUserScroll() {
    // Verificar que el scroll controller tenga una posición válida
    if (!_userScrollController.hasClients) return;
    
    final position = _userScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      // Cargar más cuando se está cerca del final (200px antes)
      // Solo si estamos en el tab de usuarios, hay más páginas, y no se está cargando
      if (!_isLoadingMoreUsers && !_isLoadingUsers && _hasMoreUserPages && _currentTab == 0) {
        _loadMoreUsers();
      }
    }
  }
  
  void _onStoreScroll() {
    // Verificar que el scroll controller tenga una posición válida
    if (!_storeScrollController.hasClients) return;
    
    final position = _storeScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      // Cargar más cuando se está cerca del final (200px antes)
      // Solo si estamos en el tab de tiendas, hay más páginas, y no se está cargando
      if (!_isLoadingMoreStores && !_isLoadingStores && _hasMoreStorePages && _currentTab == 1) {
        _loadMoreStores();
      }
    }
  }
  
  void _onProductScroll() {
    // Verificar que el scroll controller tenga una posición válida
    if (!_productScrollController.hasClients) return;
    
    final position = _productScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      // Cargar más cuando se está cerca del final (200px antes)
      // Solo si estamos en el tab de productos, hay más páginas, y no se está cargando
      if (!_isLoadingMoreProducts && !_isLoadingProducts && _hasMoreProductPages && _currentTab == 3) {
        _loadMoreProducts();
      }
    }
  }
  
  Future<void> _loadMoreWarehouses() async {
    if (_isLoadingMoreWarehouses || !_hasMoreWarehousePages) return;
    
    setState(() {
      _isLoadingMoreWarehouses = true;
    });
    
    try {
      await _loadWarehouses(
        page: _currentWarehousePage + 1,
        size: 10,
        reset: false,
      );
    } finally {
      if (mounted) {
    setState(() {
          _isLoadingMoreWarehouses = false;
        });
      }
    }
  }
  
  Future<void> _loadMoreUsers() async {
    // Prevenir múltiples llamadas simultáneas
    if (_isLoadingMoreUsers || _isLoadingUsers || !_hasMoreUserPages) return;
    
    setState(() {
      _isLoadingMoreUsers = true;
    });
    
    try {
      await _loadUsers(
        page: _currentUserPage + 1,
        size: 10,
        reset: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMoreUsers = false;
        });
      }
    }
  }
  
  Future<void> _loadMoreStores() async {
    // Prevenir múltiples llamadas simultáneas
    if (_isLoadingMoreStores || _isLoadingStores || !_hasMoreStorePages) return;
    
    setState(() {
      _isLoadingMoreStores = true;
    });
    
    try {
      await _loadStores(
        page: _currentStorePage + 1,
        size: 10,
        reset: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMoreStores = false;
        });
      }
    }
  }
  
  Future<void> _loadMoreProducts() async {
    // Prevenir múltiples llamadas simultáneas
    if (_isLoadingMoreProducts || _isLoadingProducts || !_hasMoreProductPages) return;
    
    setState(() {
      _isLoadingMoreProducts = true;
    });
    
    try {
      await _loadProducts(
        page: _currentProductPage + 1,
        size: 10,
        reset: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMoreProducts = false;
        });
      }
    }
  }

  Future<void> _loadAllData() async {
    await _loadUsers(page: 0, reset: true);
  }

  Future<void> _loadUsers({int page = 0, int size = 10, bool reset = true}) async {
    if (reset) {
      setState(() => _isLoadingUsers = true);
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
          _users = [];
        }
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8080/api/users?page=$page&size=$size'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Users API response status: ${response.statusCode}');
        print('Users API response body: $responseBody');

        if (responseBody.isEmpty) {
          print('Response body is empty');
          if (reset) {
            _users = [];
          }
          if (mounted) {
            setState(() {
              _hasMoreUserPages = false;
            });
          }
          return;
        }

        final decodedData = json.decode(responseBody);
        print('Decoded data type: ${decodedData.runtimeType}');

        // La API devuelve un objeto JSON con esta estructura:
        // {
        //   "success": true,
        //   "message": "...",
        //   "data": {
        //     "content": [...],           // JSON array con los usuarios
        //     "totalElements": 300,
        //     "totalPages": 30,
        //     "currentPage": 0,
        //     "pageSize": 10,
        //     "hasNext": true,
        //     "hasPrevious": false
        //   }
        // }
        
        List<dynamic> data;
        bool hasNext = false;
        
        // Verificar que la respuesta es un objeto JSON (Map)
        if (decodedData is Map) {
          final responseObject = decodedData as Map;
          
          // Extraer el objeto 'data' que contiene la información de paginación
          if (responseObject.containsKey('data')) {
            final dataObject = responseObject['data'];
            
            if (dataObject is Map) {
              final paginationData = dataObject as Map;
              
              // Extraer el array de usuarios de la propiedad 'content' dentro de 'data'
              if (paginationData.containsKey('content')) {
                final contentArray = paginationData['content'];
                if (contentArray is List) {
                  data = contentArray;
                } else {
                  print('Error: content is not a List, type: ${contentArray.runtimeType}');
                  data = [];
                }
                
                // Extraer información de paginación desde 'data'
                if (paginationData.containsKey('hasNext')) {
                  hasNext = paginationData['hasNext'] == true;
                }
                
                // Log de información de paginación para debugging
                final totalElements = paginationData['totalElements'];
                final totalPages = paginationData['totalPages'];
                final currentPage = paginationData['currentPage'];
                final pageSize = paginationData['pageSize'];
                print('Paginated response - content: ${data.length} items, totalElements: $totalElements, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize, hasNext: $hasNext');
              } else {
                print('Error: data object does not contain "content" property. Available keys: ${paginationData.keys.toList()}');
                if (reset) {
                  _users = [];
                }
                if (mounted) {
                  setState(() {
                    _hasMoreUserPages = false;
                  });
                }
                return;
              }
            } else if (dataObject is List) {
              // Formato alternativo: data es directamente una lista (para compatibilidad)
              data = dataObject;
            } else {
              print('Error: data is not a Map or List, type: ${dataObject.runtimeType}');
              if (reset) {
                _users = [];
              }
              if (mounted) {
                setState(() {
                  _hasMoreUserPages = false;
                });
              }
              return;
            }
          } else {
            print('Error: Response object does not contain "data" property. Available keys: ${responseObject.keys.toList()}');
            if (reset) {
              _users = [];
            }
            if (mounted) {
              setState(() {
                _hasMoreUserPages = false;
              });
            }
            return;
          }
        } else if (decodedData is List) {
          // Formato simple de lista (para compatibilidad)
          data = decodedData;
        } else {
          print('Error: Response is not a JSON object or array. Type: ${decodedData.runtimeType}');
          if (reset) {
            _users = [];
          }
          if (mounted) {
            setState(() {
              _hasMoreUserPages = false;
            });
          }
          return;
        }

        print('Number of users received: ${data.length}');

        final newUsers = data.map((item) {
          print('Mapping user item: $item');

          // Obtener el ID del usuario
          final idUser = item['idUser'] is int
              ? item['idUser'] as int
              : (item['idUser'] as num?)?.toInt();

          // Obtener campos básicos
          final username = item['username']?.toString() ?? '';
          final email = item['email']?.toString();
          final name = item['name']?.toString() ?? '';
          final lastName = item['lastName']?.toString() ?? '';
          final ci = item['ci']?.toString() ?? '';
          final age = (item['age'] is int)
              ? item['age'] as int
              : (item['age'] as num?)?.toInt() ?? 0;

          // Mapear el estado - puede venir como status (1/0), active, inactive, pending
          UserStatus userStatus = UserStatus.active;
          if (item['active'] == true) {
            userStatus = UserStatus.active;
          } else if (item['inactive'] == true) {
            userStatus = UserStatus.inactive;
          } else if (item['pending'] == true) {
            userStatus = UserStatus.pendingActivation;
          } else if (item['status'] != null) {
            // Si viene como número (1 = active, 0 = inactive)
            final statusValue = item['status'];
            if (statusValue == 1 || statusValue == '1' || statusValue == 'Active') {
              userStatus = UserStatus.active;
            } else if (statusValue == 0 || statusValue == '0' || statusValue == 'Inactive') {
              userStatus = UserStatus.inactive;
            } else {
              userStatus = UserStatus.pendingActivation;
            }
          }

          // Guardar el rol en el mapa - normalizar para que coincida con los valores del dropdown
          final roleNameRaw = item['roleName']?.toString() ?? 'Employee';
          // Normalizar el rol: convertir "ADMIN" -> "Admin", "MANAGER" -> "Manager", etc.
          String normalizedRole = 'Employee';
          if (roleNameRaw.toUpperCase() == 'ADMIN') {
            normalizedRole = 'Admin';
          } else if (roleNameRaw.toUpperCase() == 'MANAGER') {
            normalizedRole = 'Manager';
          } else if (roleNameRaw.toUpperCase() == 'EMPLOYEE') {
            normalizedRole = 'Employee';
          } else if (roleNameRaw.toUpperCase() == 'VIEWER') {
            normalizedRole = 'Viewer';
          } else {
            // Si no coincide, intentar capitalizar la primera letra
            normalizedRole = roleNameRaw.isNotEmpty 
                ? roleNameRaw[0].toUpperCase() + roleNameRaw.substring(1).toLowerCase()
                : 'Employee';
          }
          
          if (idUser != null) {
            _userRoles[idUser] = normalizedRole;
          }

          print('Mapped user: $name $lastName - $username - status: $userStatus - role: $normalizedRole');

          return User(
            idUser: idUser,
            username: username,
            password: '', // No viene del API por seguridad
            name: name,
            lastName: lastName,
            ci: ci,
            age: age,
            status: userStatus,
            email: email,
            gender: null, // No viene del API
          );
        }).toList();

        print('New users mapped: ${newUsers.length}');

        if (mounted) {
          setState(() {
            if (reset) {
              _users = newUsers;
            } else {
              _users.addAll(newUsers);
            }
            _currentUserPage = page;
            _hasMoreUserPages = hasNext;
            print('State updated, users count: ${_users.length}, hasMore: $_hasMoreUserPages, page: $page');
          });
        }
      } else {
        print('Error loading users: ${response.statusCode} - ${response.body}');
        if (reset) {
          _users = [];
        }
        if (mounted) {
          setState(() {
            _hasMoreUserPages = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar usuarios: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading users: $e');
      if (reset) {
        _users = [];
      }
      if (mounted) {
        setState(() {
          _hasMoreUserPages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuarios: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted && reset) {
        setState(() => _isLoadingUsers = false);
      }
    }
  }

  Future<void> _loadStores({int page = 0, int size = 10, bool reset = true}) async {
    if (reset) {
      setState(() => _isLoadingStores = true);
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
          print('Response body is empty');
          if (reset) {
            _stores = [];
          }
          if (mounted) {
            setState(() {
              _hasMoreStorePages = false;
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
        //   "totalPages": 30,
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
            final totalPages = responseObject['totalPages'];
            final currentPage = responseObject['currentPage'];
            final pageSize = responseObject['pageSize'];
            print('Paginated response - content: ${data.length} items, totalElements: $totalElements, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize, hasNext: $hasNext');
          } else {
            print('Error: Response object does not contain "content" property. Available keys: ${responseObject.keys.toList()}');
            if (reset) {
              _stores = [];
            }
            if (mounted) {
              setState(() {
                _hasMoreStorePages = false;
              });
            }
            return;
          }
        } else if (decodedData is List) {
          // Formato simple de lista (para compatibilidad)
          data = decodedData;
        } else {
          print('Error: Response is not a JSON object or array. Type: ${decodedData.runtimeType}');
          if (reset) {
            _stores = [];
          }
          if (mounted) {
            setState(() {
              _hasMoreStorePages = false;
            });
          }
          return;
        }
        
        print('Number of stores received: ${data.length}');
        
        final newStores = data.map((item) {
          print('Mapping store item: $item');
          
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
          
          // Obtener ID de compañía
          final idCompany = item['idCompany'] is int
              ? item['idCompany'] as int?
              : (item['idCompany'] as num?)?.toInt();
          
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
          
          final store = Store(
            idStore: idStore,
            name: name,
            location: address,
            manager: managerUsername,
            icon: Icons.store,
            color: Store._getStoreColor(idStore ?? 0),
            monthlySales: 0.0, // No viene del API
            isOpen: isOpen,
            rating: rating,
            businessHours: businessHours,
            idCompany: idCompany,
          );
          
          print('Mapped store: ${store.name} - ${store.location} - isOpen: ${store.isOpen}');
          return store;
        }).toList();

        print('New stores mapped: ${newStores.length}');
        
        if (mounted) {
          setState(() {
            if (reset) {
              _stores = newStores;
            } else {
              _stores.addAll(newStores);
            }
            _currentStorePage = page;
            _hasMoreStorePages = hasNext;
            print('State updated, stores count: ${_stores.length}, hasMore: $_hasMoreStorePages, page: $page');
          });
        }
      } else {
        print('Error loading stores: ${response.statusCode} - ${response.body}');
        if (reset) {
          _stores = [];
        }
        if (mounted) {
          setState(() {
            _hasMoreStorePages = false;
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
          _hasMoreStorePages = false;
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
        setState(() => _isLoadingStores = false);
      }
    }
  }


  Future<void> _loadWarehouses({int page = 0, int size = 10, bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoadingWarehouses = true;
        _currentWarehousePage = 0;
        _hasMoreWarehousePages = true;
      });
    }
    
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        if (reset) {
          _warehouses = Warehouse.sampleWarehouses();
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
              _hasMoreWarehousePages = false;
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
                _hasMoreWarehousePages = false;
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
              _hasMoreWarehousePages = false;
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
            name: name,
            location: address,
            icon: Icons.warehouse,
            color: Warehouse._getWarehouseColor(idWarehouse ?? 0),
            productCount: productCount,
            isActive: isActive,
            capacity: 0, // No viene del API
          );
        }).toList();

        print('New warehouses mapped: ${newWarehouses.length}');

        if (mounted) {
          setState(() {
            if (reset) {
              _warehouses = newWarehouses;
            } else {
              _warehouses.addAll(newWarehouses);
            }
            _currentWarehousePage = page;
            // Usar hasNext de la respuesta si está disponible, sino calcular basado en cantidad recibida
            if (decodedData is Map && hasNext) {
              _hasMoreWarehousePages = hasNext;
            } else {
              // Si recibimos menos elementos que el tamaño solicitado, no hay más páginas
              _hasMoreWarehousePages = newWarehouses.length >= size;
            }
            print('State updated, warehouses count: ${_warehouses.length}, hasMore: $_hasMoreWarehousePages, page: $page');
          });
        }
      } else {
        print('Error loading warehouses: ${response.statusCode} - ${response.body}');
        if (reset) {
          _warehouses = [];
        }
        if (mounted) {
          setState(() {
            _hasMoreWarehousePages = false;
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
        _warehouses = Warehouse.sampleWarehouses();
      }
      if (mounted) {
        setState(() {
          _hasMoreWarehousePages = false;
        });
      }
    } finally {
      if (mounted && reset) {
        setState(() {
          _isLoadingWarehouses = false;
        });
      }
    }
  }

  Future<void> _loadProducts({int page = 0, int size = 10, bool reset = true}) async {
    if (reset) {
      setState(() => _isLoadingProducts = true);
    }
    
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        if (reset) {
          _products = Product.sampleProducts();
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
              _hasMoreProductPages = false;
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
        //   "totalPages": 30,
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
            final totalPages = responseObject['totalPages'];
            final currentPage = responseObject['currentPage'];
            final pageSize = responseObject['pageSize'];
            print('Paginated response - content: ${data.length} items, totalElements: $totalElements, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize, hasNext: $hasNext');
          } else {
            print('Error: Response object does not contain "content" property. Available keys: ${responseObject.keys.toList()}');
            if (reset) {
              _products = [];
            }
            if (mounted) {
              setState(() {
                _hasMoreProductPages = false;
              });
            }
            return;
          }
        } else if (decodedData is List) {
          // Formato simple de lista (para compatibilidad)
          data = decodedData;
        } else {
          print('Error: Response is not a JSON object or array. Type: ${decodedData.runtimeType}');
          if (reset) {
            _products = [];
          }
          if (mounted) {
            setState(() {
              _hasMoreProductPages = false;
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
            _currentProductPage = page;
            _hasMoreProductPages = hasNext;
            print('State updated, products count: ${_products.length}, hasMore: $_hasMoreProductPages, page: $page');
          });
        }
      } else {
        print('Error loading products: ${response.statusCode} - ${response.body}');
        if (reset) {
          _products = [];
        }
        if (mounted) {
          setState(() {
            _hasMoreProductPages = false;
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
        _products = Product.sampleProducts();
      }
      if (mounted) {
        setState(() {
          _hasMoreProductPages = false;
        });
      }
    } finally {
      if (mounted && reset) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Panel de Administración',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
          children: [
          // Pestañas
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF007AFF),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF007AFF),
              tabs: const [
                Tab(icon: Icon(Icons.people), text: 'Usuarios'),
              ],
            ),
          ),
          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab de Usuarios
  Widget _buildUsersTab() {
    // Cargar usuarios solo una vez si la lista está vacía y no se está cargando
    if (_users.isEmpty && !_isLoadingUsers && !_usersInitialLoadStarted) {
      _usersInitialLoadStarted = true;
      _loadUsers(page: 0, reset: true);
    }

    if (_isLoadingUsers && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildUsersList();
  }

  Widget _buildUsersList() {
    if (_users.isEmpty && !_isLoadingUsers) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay usuarios disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _userScrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _users.length + (_isLoadingMoreUsers ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _users.length) {
          final user = _users[index];
          return _buildUserCard(user);
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
    );
  }

  Widget _buildUserCard(User user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = _userRoles[user.idUser ?? 0] ?? 'Employee';
    final permissions = _userPermissions[user.idUser ?? 0] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF007AFF).withOpacity(0.1),
          child: Icon(Icons.person, color: const Color(0xFF007AFF)),
        ),
        title: Text(
          '${user.name} ${user.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            const SizedBox(height: 4),
            Text('@${user.username}'),
            const SizedBox(height: 4),
        Row(
          children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role,
                  style: TextStyle(
                      color: _getRoleColor(role),
                      fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.status == UserStatus.active
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.status.value,
                  style: TextStyle(
                      color: user.status == UserStatus.active ? Colors.green : Colors.red,
                      fontSize: 12,
                fontWeight: FontWeight.w600,
                  ),
              ),
            ),
          ],
        ),
            if (permissions.isNotEmpty) ...[
        const SizedBox(height: 8),
              Text(
                '${permissions.length} permisos',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
        children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF007AFF)),
              onPressed: () => _showEditUserDialog(user),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteUserDialog(user),
          ),
        ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.red;
      case 'Manager':
        return Colors.orange;
      case 'Employee':
        return Colors.blue;
      case 'Viewer':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);
    final lastNameController = TextEditingController(text: user.lastName);
    final usernameController = TextEditingController(text: user.username);
    final ciController = TextEditingController(text: user.ci);
    final ageController = TextEditingController(text: user.age.toString());
    final emailController = TextEditingController(text: user.email ?? '');

    // Obtener el rol y asegurarse de que esté en la lista de roles disponibles
    String roleFromMap = _userRoles[user.idUser ?? 0] ?? 'Employee';
    // Asegurarse de que el rol esté en la lista de roles disponibles
    String selectedRole = _availableRoles.contains(roleFromMap) 
        ? roleFromMap 
        : 'Employee';
    List<String> selectedPermissions = List.from(_userPermissions[user.idUser ?? 0] ?? []);
    UserStatus selectedStatus = user.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: ciController,
                  decoration: const InputDecoration(labelText: 'CI'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
              ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
                DropdownButtonFormField<UserStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: UserStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedStatus = value);
                    }
                  },
        ),
        const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: _availableRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
          onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedRole = value);
                    }
                  },
        ),
        const SizedBox(height: 16),
                const Text('Permisos:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availablePermissions.map((permission) {
                    final isSelected = selectedPermissions.contains(permission);
                    return FilterChip(
                      label: Text(permission, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            selectedPermissions.add(permission);
                          } else {
                            selectedPermissions.remove(permission);
                          }
            });
          },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
            ElevatedButton(
            onPressed: () async {
              try {
                final updatedUser = user.copyWith(
                  name: nameController.text,
                  lastName: lastNameController.text,
                  username: usernameController.text,
                  ci: ciController.text,
                  age: int.tryParse(ageController.text) ?? user.age,
                  email: emailController.text.isNotEmpty ? emailController.text : null,
                  status: selectedStatus,
                );

                // Actualizar roles y permisos localmente
                if (mounted) {
                  setState(() {
                    _userRoles[user.idUser ?? 0] = selectedRole;
                    _userPermissions[user.idUser ?? 0] = selectedPermissions;
                    
                    // Actualizar el usuario en la lista local
                    final index = _users.indexWhere((u) => u.idUser == user.idUser);
                    if (index != -1) {
                      _users[index] = updatedUser;
                    }
                  });
                }

                // TODO: Llamar al API para actualizar el usuario
                // await _updateUserViaAPI(updatedUser);

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario actualizado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar usuario: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Estás seguro que deseas eliminar a ${user.name} ${user.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (user.idUser != null) {
                  // TODO: Llamar al API para eliminar el usuario
                  // await _deleteUserViaAPI(user.idUser!);
                  
                  // Eliminar de la lista local
                  if (mounted) {
                    setState(() {
                      _users.removeWhere((u) => u.idUser == user.idUser);
                      _userRoles.remove(user.idUser);
                      _userPermissions.remove(user.idUser);
                    });
                  }
                }
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar usuario: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
            ),
          ],
        ),
    );
  }

  // Tab de Tiendas
  Widget _buildStoresTab() {
    // Cargar tiendas solo una vez si la lista está vacía y no se está cargando
    if (_stores.isEmpty && !_isLoadingStores && !_storesInitialLoadStarted) {
      _storesInitialLoadStarted = true;
      _loadStores(page: 0, reset: true);
    }

    if (_isLoadingStores && _stores.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stores.isEmpty && !_isLoadingStores) {
      return Center(
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
              onPressed: () {
                _storesInitialLoadStarted = false;
                _loadStores(page: 0, reset: true);
              },
              child: const Text('Recargar'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _storeScrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _stores.length + (_isLoadingMoreStores ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _stores.length) {
          final store = _stores[index];
          return _buildStoreCard(store);
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
    );
  }

  Widget _buildStoreCard(Store store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: store.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
          child: Icon(store.icon, color: store.color),
        ),
        title: Text(
          store.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(store.location),
            const SizedBox(height: 4),
            Text('Gerente: ${store.manager}'),
            const SizedBox(height: 4),
        Row(
          children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: store.isOpen
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    store.isOpen ? 'Abierta' : 'Cerrada',
                  style: TextStyle(
                      color: store.isOpen ? Colors.green : Colors.red,
                      fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Text(
                  '⭐ ${store.rating.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
      children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF007AFF)),
              onPressed: () => _showEditStoreDialog(store),
          ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteStoreDialog(store),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStoreDialog(Store store) {
    final nameController = TextEditingController(text: store.name);
    final locationController = TextEditingController(text: store.location);
    final managerController = TextEditingController(text: store.manager);
    final salesController = TextEditingController(text: store.monthlySales.toStringAsFixed(2));
    final ratingController = TextEditingController(text: store.rating.toStringAsFixed(1));
    final businessHoursController = TextEditingController(text: store.businessHours);
    bool isOpen = store.isOpen;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Tienda'),
          content: SingleChildScrollView(
      child: Column(
              mainAxisSize: MainAxisSize.min,
      children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
          maxLines: 2,
        ),
                TextField(
                  controller: managerController,
                  decoration: const InputDecoration(labelText: 'Gerente'),
                ),
                TextField(
                  controller: salesController,
                  decoration: const InputDecoration(labelText: 'Ventas Mensuales'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(labelText: 'Rating'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
                TextField(
                  controller: businessHoursController,
                  decoration: const InputDecoration(labelText: 'Horario de Atención'),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Tienda Abierta'),
                  value: isOpen,
                  onChanged: (value) => setDialogState(() => isOpen = value),
            ),
          ],
        ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (store.idStore == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: No se puede actualizar una tienda sin ID'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop();
                  return;
                }

                final token = AuthService.accessToken;
                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: No hay token de autenticación'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop();
                  return;
                }

                try {
                  // Llamar a la API para actualizar
                  final response = await http.put(
                    Uri.parse('http://localhost:8080/api/stores/${store.idStore}'),
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                    body: json.encode({
                      'name': nameController.text,
                      'address': locationController.text,
                      'status': isOpen ? 'Open' : 'Close',
                      'businessHours': store.businessHours,
                      'idCompany': store.idCompany,
                    }),
                  );

                  if (response.statusCode == 200) {
                    // Actualizar la lista local
                    final index = _stores.indexOf(store);
                    if (index != -1) {
            setState(() {
                        _stores[index] = Store(
                          idStore: store.idStore,
                          name: nameController.text,
                          location: locationController.text,
                          manager: managerController.text,
                          icon: store.icon,
                          color: store.color,
                          monthlySales: double.tryParse(salesController.text) ?? store.monthlySales,
                          isOpen: isOpen,
                          rating: double.tryParse(ratingController.text) ?? store.rating,
                          businessHours: store.businessHours,
                          idCompany: store.idCompany,
                        );
                      });
                    }

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tienda actualizada exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    throw Exception('Error ${response.statusCode}: ${response.body}');
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar tienda: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteStoreDialog(Store store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tienda'),
        content: Text('¿Estás seguro que deseas eliminar ${store.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (store.idStore == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error: No se puede eliminar una tienda sin ID'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.of(context).pop();
                return;
              }

              final token = AuthService.accessToken;
              if (token == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error: No hay token de autenticación'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.of(context).pop();
                return;
              }

              try {
                // Llamar a la API para eliminar
                final response = await http.delete(
                  Uri.parse('http://localhost:8080/api/stores/${store.idStore}'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                );

                if (response.statusCode == 200 || response.statusCode == 204) {
                  // Actualizar la lista local
                  setState(() => _stores.remove(store));

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tienda eliminada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  throw Exception('Error ${response.statusCode}: ${response.body}');
                }
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar tienda: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
            ),
          ],
        ),
    );
  }

  // Tab de Almacenes
  Widget _buildWarehousesTab() {
    if (_isLoadingWarehouses && _warehouses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_warehouses.isEmpty && !_isLoadingWarehouses) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warehouse_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay almacenes disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _warehouseScrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _warehouses.length + (_isLoadingMoreWarehouses ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _warehouses.length) {
          final warehouse = _warehouses[index];
          return _buildWarehouseCard(warehouse);
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
    );
  }

  Widget _buildWarehouseCard(Warehouse warehouse) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: warehouse.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(warehouse.icon, color: warehouse.color),
        ),
        title: Text(
          warehouse.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const SizedBox(height: 4),
            Text(warehouse.location),
            const SizedBox(height: 4),
        Row(
          children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: warehouse.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                ),
            child: Text(
                    warehouse.isActive ? 'Activo' : 'Inactivo',
              style: TextStyle(
                      color: warehouse.isActive ? Colors.green : Colors.red,
                      fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
                const SizedBox(width: 8),
                Text(
                  '${warehouse.productCount} productos',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Text(
                  '${warehouse.capacity}% capacidad',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF007AFF)),
              onPressed: () => _showEditWarehouseDialog(warehouse),
                  ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteWarehouseDialog(warehouse),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWarehouseDialog(Warehouse warehouse) {
    final nameController = TextEditingController(text: warehouse.name);
    final locationController = TextEditingController(text: warehouse.location);
    final productCountController = TextEditingController(text: warehouse.productCount.toString());
    final capacityController = TextEditingController(text: warehouse.capacity.toString());
    bool isActive = warehouse.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Almacén'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
      children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                  maxLines: 2,
                ),
        TextField(
                  controller: productCountController,
                  decoration: const InputDecoration(labelText: 'Cantidad de Productos'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(labelText: 'Capacidad (%)'),
                  keyboardType: TextInputType.number,
            ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Almacén Activo'),
                  value: isActive,
                  onChanged: (value) => setDialogState(() => isActive = value),
            ),
          ],
        ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final index = _warehouses.indexOf(warehouse);
                if (index != -1) {
            setState(() {
                    _warehouses[index] = Warehouse(
                      name: nameController.text,
                      location: locationController.text,
                      icon: warehouse.icon,
                      color: warehouse.color,
                      productCount: int.tryParse(productCountController.text) ?? warehouse.productCount,
                      isActive: isActive,
                      capacity: int.tryParse(capacityController.text) ?? warehouse.capacity,
                    );
                  });

                  // TODO: Llamar a la API para actualizar
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Almacén actualizado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteWarehouseDialog(Warehouse warehouse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Almacén'),
        content: Text('¿Estás seguro que deseas eliminar ${warehouse.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _warehouses.remove(warehouse));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Almacén eliminado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // Tab de Productos
  Widget _buildProductsTab() {
    // Cargar productos solo una vez si la lista está vacía y no se está cargando
    if (_products.isEmpty && !_isLoadingProducts && !_productsInitialLoadStarted) {
      _productsInitialLoadStarted = true;
      _loadProducts(page: 0, reset: true);
    }

    if (_isLoadingProducts && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty && !_isLoadingProducts) {
      return Center(
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
              onPressed: () {
                _productsInitialLoadStarted = false;
                _loadProducts(page: 0, reset: true);
              },
              child: const Text('Recargar'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _productScrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _products.length + (_isLoadingMoreProducts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _products.length) {
          final product = _products[index];
          return _buildProductCard(product);
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
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
      decoration: BoxDecoration(
            color: product.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
          child: Icon(product.icon, color: product.color),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const SizedBox(height: 4),
            Text('${product.category} - ${product.brand}'),
            const SizedBox(height: 4),
            Row(
        children: [
          Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007AFF),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Stock: ${product.stock}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.isAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
            child: Text(
                    product.isAvailable ? 'Disponible' : 'No disponible',
            style: TextStyle(
                      color: product.isAvailable ? Colors.green : Colors.red,
                      fontSize: 12,
              fontWeight: FontWeight.w600,
              ),
            ),
          ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF007AFF)),
              onPressed: () => _showEditProductDialog(product),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteProductDialog(product),
          ),
        ],
        ),
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final categoryController = TextEditingController(text: product.category);
    final brandController = TextEditingController(text: product.brand);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toStringAsFixed(2));
    final stockController = TextEditingController(text: product.stock.toString());
    bool isAvailable = product.isAvailable;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
      children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
        ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
        TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: 'Marca'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Producto Disponible'),
                  value: isAvailable,
                  onChanged: (value) => setDialogState(() => isAvailable = value),
        ),
      ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final index = _products.indexOf(product);
                if (index != -1) {
                  setState(() {
                    _products[index] = Product(
                      name: nameController.text,
                      category: categoryController.text,
                      brand: brandController.text,
                      description: descriptionController.text,
                      icon: product.icon,
                      color: product.color,
                      price: double.tryParse(priceController.text) ?? product.price,
                      stock: int.tryParse(stockController.text) ?? product.stock,
                      isAvailable: isAvailable,
                    );
                  });

                  // TODO: Llamar a la API para actualizar
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto actualizado exitosamente'),
                      backgroundColor: Colors.green,
      ),
    );
  }
              },
              child: const Text('Guardar'),
          ),
        ],
        ),
      ),
    );
  }

  void _showDeleteProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro que deseas eliminar ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _products.remove(product));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto eliminado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
        ),
        ],
      ),
    );
  }
}

// Modelos locales (si no están en otros archivos)
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
  });

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
    ];
  }
  
  // Helper para obtener colores diferentes según el ID
  static Color _getStoreColor(int id) {
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
}

class Warehouse {
  final String name;
  final String location;
  final IconData icon;
  final Color color;
  final int productCount;
  final bool isActive;
  final int capacity;

  Warehouse({
    required this.name,
    required this.location,
    required this.icon,
    required this.color,
    required this.productCount,
    required this.isActive,
    required this.capacity,
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
        name: 'Almacén Central',
        location: 'Av. Principal 123, Centro',
        icon: Icons.warehouse,
        color: Colors.blue,
        productCount: 1250,
        isActive: true,
        capacity: 85,
      ),
    ];
  }
}

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
        description: 'Lámpara LED de diseño moderno',
        icon: Icons.lightbulb_outline,
        color: Colors.amber,
        price: 89.99,
        stock: 45,
        isAvailable: true,
      ),
    ];
  }
}
