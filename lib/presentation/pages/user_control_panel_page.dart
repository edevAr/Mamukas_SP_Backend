import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/widgets.dart';
import '../../domain/entities/user.dart';
import '../../core/constants/user_status.dart';
import '../../core/services/auth_service.dart';
import 'user_detail_page.dart';

class UserControlPanelPage extends StatefulWidget {
  const UserControlPanelPage({super.key});

  static const routeName = '/user-control-panel';

  @override
  State<UserControlPanelPage> createState() => _UserControlPanelPageState();
}

class _UserControlPanelPageState extends State<UserControlPanelPage> {
  List<User> _users = [];
  String _userSearchQuery = '';
  bool _isLoadingUsers = false;
  
  // Getter para usuarios filtrados según búsqueda
  List<User> get _filteredUsers {
    if (_userSearchQuery.trim().isEmpty) {
      return _users;
    }
    final query = _userSearchQuery.toLowerCase();
    return _users.where((user) {
      return user.name.toLowerCase().contains(query) ||
             user.username.toLowerCase().contains(query) ||
             (user.email != null && user.email!.toLowerCase().contains(query));
    }).toList();
  }
  bool _usersInitialLoadStarted = false;
  
  // Paginación
  int _currentUserPage = 0;
  bool _hasMoreUserPages = true;
  bool _isLoadingMoreUsers = false;
  final ScrollController _userScrollController = ScrollController();
  
  // Mapa para almacenar roles y permisos de usuarios
  final Map<int, String> _userRoles = {};
  final Map<int, List<String>> _userPermissions = {};

  @override
  void initState() {
    super.initState();
    _userScrollController.addListener(_onUserScroll);
    _loadUsers(page: 0, reset: true);
  }

  @override
  void dispose() {
    _userScrollController.dispose();
    super.dispose();
  }

  void _onUserScroll() {
    if (!_userScrollController.hasClients) return;
    
    final position = _userScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      if (!_isLoadingMoreUsers && !_isLoadingUsers && _hasMoreUserPages) {
        _loadMoreUsers();
      }
    }
  }

  Future<void> _loadMoreUsers() async {
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

  Future<void> _loadUsers({int page = 0, int size = 10, bool reset = true}) async {
    if (reset) {
      setState(() => _isLoadingUsers = true);
    }
    
    try {
      final token = AuthService.accessToken;
      if (token == null) {
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

        // La API devuelve un JSON object con paginación:
        // {
        //   "success": true,
        //   "message": "Users retrieved successfully",
        //   "data": {
        //     "content": [...],           // JSON array con los usuarios
        //     "totalElements": 300,
        //     "currentPage": 0,
        //     "pageSize": 10,
        //     "hasNext": true,
        //     "hasPrevious": false
        //   }
        // }
        
        List<dynamic> data;
        bool hasNext = false;
        
        if (decodedData is Map) {
          final responseObject = decodedData as Map;
          if (responseObject.containsKey('data') && responseObject['data'] is Map) {
            final paginationData = responseObject['data'] as Map;
            
            if (paginationData.containsKey('content')) {
              final contentArray = paginationData['content'];
              if (contentArray is List) {
                data = contentArray;
              } else {
                print('Error: content is not a List, type: ${contentArray.runtimeType}');
                data = [];
              }
              
              if (paginationData.containsKey('hasNext')) {
                hasNext = paginationData['hasNext'] == true;
              }
              
              final totalElements = paginationData['totalElements'];
              final currentPage = paginationData['currentPage'];
              final pageSize = paginationData['pageSize'];
              final totalPages = paginationData['totalPages'];
              print('Paginated response - content: ${data.length} items, totalElements: $totalElements, currentPage: $currentPage, pageSize: $pageSize, totalPages: $totalPages, hasNext: $hasNext');
            } else {
              print('Error: "data" object does not contain "content" property. Available keys: ${paginationData.keys.toList()}');
              data = [];
            }
          } else {
            print('Error: Response object does not contain "data" property or "data" is not a Map. Available keys: ${responseObject.keys.toList()}');
            data = [];
          }
        } else if (decodedData is List) {
          data = decodedData;
        } else {
          print('Error: Response is not a JSON object or array. Type: ${decodedData.runtimeType}');
          data = [];
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

          // Obtener el estado del usuario
          final statusStr = item['status']?.toString() ?? 'Inactive';
          final userStatus = statusStr == 'Active' || statusStr == 'ACTIVE'
              ? UserStatus.active
              : UserStatus.inactive;

          // Obtener el rol del usuario
          String roleName = 'Employee';
          if (item['role'] != null) {
            roleName = item['role'].toString();
          } else if (item['roleName'] != null) {
            roleName = item['roleName'].toString();
          }

          // Normalizar el nombre del rol
          String normalizedRole = roleName;
          if (roleName.toUpperCase() == 'ADMIN') {
            normalizedRole = 'Admin';
          } else if (roleName.toUpperCase() == 'MANAGER') {
            normalizedRole = 'Manager';
          } else if (roleName.toUpperCase() == 'EMPLOYEE') {
            normalizedRole = 'Employee';
          } else if (roleName.toUpperCase() == 'VIEWER') {
            normalizedRole = 'Viewer';
          } else {
            normalizedRole = 'Employee'; // Fallback
          }

          // Obtener permisos (por ahora vacío, luego se traerá de la API)
          List<String> permissions = [];

          final user = User(
            idUser: idUser,
            username: username,
            password: '', // No se incluye en la respuesta
            name: name,
            lastName: lastName,
            ci: ci,
            age: age,
            status: userStatus,
            email: email,
          );

          // Guardar rol y permisos en los mapas
          if (idUser != null) {
            _userRoles[idUser] = normalizedRole;
            _userPermissions[idUser] = permissions;
          }

          print('Mapped user: $name $lastName - $username - status: $userStatus - role: $normalizedRole');
          return user;
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

  Future<List<SearchResult>> _searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filtered = _users
        .where((user) => 
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.lastName.toLowerCase().contains(query.toLowerCase()) ||
            user.username.toLowerCase().contains(query.toLowerCase()) ||
            (user.email != null && user.email!.toLowerCase().contains(query.toLowerCase())))
        .take(10)
        .map<SearchResult>((user) => SearchResult(
              title: '${user.name} ${user.lastName}',
              subtitle: '@${user.username}',
              icon: Icons.person,
              data: user,
            ))
        .toList();
    
    return filtered;
  }

  void _onUserSelected(SearchResult result) {
    if (result.data is User) {
      final user = result.data as User;
      if (user.idUser != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserDetailPage(
              idUser: user.idUser!,
            ),
          ),
        );
      }
    }
  }

  void _onUserCardTap(User user) {
    if (user.idUser != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UserDetailPage(
            idUser: user.idUser!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Panel de Control',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          // Buscador de usuarios
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              hintText: 'Buscar usuarios...',
              onSearch: _searchUsers,
              showOverlay: false,
              onQueryChanged: (query) {
                setState(() {
                  _userSearchQuery = query;
                });
              },
              onResultSelected: _onUserSelected,
            ),
          ),
          // Lista de usuarios
          Expanded(
            child: _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (_isLoadingUsers && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredUsers.isEmpty && !_isLoadingUsers) {
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _usersInitialLoadStarted = false;
                _loadUsers(page: 0, reset: true);
              },
              child: const Text('Recargar'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _userScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredUsers.length + (_isLoadingMoreUsers ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _filteredUsers.length) {
          final user = _filteredUsers[index];
          return _buildUserCard(user);
        } else {
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
      child: InkWell(
        onTap: () => _onUserCardTap(user),
        borderRadius: BorderRadius.circular(12),
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
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
        return Colors.grey;
    }
  }
}

