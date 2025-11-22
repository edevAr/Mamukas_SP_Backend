import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/widgets.dart';
import '../../domain/entities/user.dart';
import '../../core/constants/user_status.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/api_constants.dart';

class UserDetailPage extends StatefulWidget {
  final int idUser;

  const UserDetailPage({
    super.key,
    required this.idUser,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  // Datos del usuario cargados desde la API
  User? _user;
  List<String> _roles = [];
  List<String> _permissions = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Roles disponibles
  final List<String> _availableRoles = ['Admin', 'Manager', 'Employee', 'Viewer'];
  
  // Permisos disponibles
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

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = AuthService.accessToken;
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No hay token de autenticación disponible';
        });
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConstants.userDetails(widget.idUser)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('User details API response status: ${response.statusCode}');
        print('User details API response body: $responseBody');

        final decodedData = json.decode(responseBody);
        print('Decoded data type: ${decodedData.runtimeType}');

        // La API devuelve un JSON object con esta estructura:
        // {
        //   "success": true,
        //   "message": "...",
        //   "data": {
        //     "user": {...},           // Objeto con información del usuario
        //     "roles": [...],          // Array de roles
        //     "permissions": [...]     // Array de permisos
        //   }
        // }

        if (decodedData is Map && decodedData.containsKey('data')) {
          final data = decodedData['data'] as Map;
          
          // Mapear usuario
          if (data.containsKey('user') && data['user'] is Map) {
            final userData = data['user'] as Map<String, dynamic>;
            _user = _mapUserFromJson(userData);
          }

          // Mapear roles
          if (data.containsKey('roles')) {
            final rolesData = data['roles'];
            if (rolesData is List) {
              _roles = rolesData.map((role) {
                if (role is Map && role.containsKey('name')) {
                  return role['name'].toString();
                } else if (role is String) {
                  return role;
                } else if (role is Map && role.containsKey('roleName')) {
                  return role['roleName'].toString();
                }
                return role.toString();
              }).toList();
            } else if (rolesData is String) {
              _roles = [rolesData];
            }
          }

          // Mapear permisos
          if (data.containsKey('permissions')) {
            final permissionsData = data['permissions'];
            if (permissionsData is List) {
              _permissions = permissionsData.map((permission) {
                if (permission is Map && permission.containsKey('name')) {
                  return permission['name'].toString();
                } else if (permission is String) {
                  return permission;
                } else if (permission is Map && permission.containsKey('permissionName')) {
                  return permission['permissionName'].toString();
                }
                return permission.toString();
              }).toList();
            } else if (permissionsData is String) {
              _permissions = [permissionsData];
            }
          }

          print('Loaded user: ${_user?.name} ${_user?.lastName}');
          print('Roles: $_roles');
          print('Permissions: $_permissions');

          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Formato de respuesta inesperado';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar detalles del usuario: ${response.statusCode}';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar detalles del usuario: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading user details: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar detalles del usuario: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar detalles del usuario: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  User _mapUserFromJson(Map<String, dynamic> userData) {
    final idUser = userData['idUser'] is int
        ? userData['idUser'] as int
        : (userData['idUser'] as num?)?.toInt();

    final username = userData['username']?.toString() ?? '';
    final email = userData['email']?.toString();
    final name = userData['name']?.toString() ?? '';
    final lastName = userData['lastName']?.toString() ?? '';
    final ci = userData['ci']?.toString() ?? '';
    final age = (userData['age'] is int)
        ? userData['age'] as int
        : (userData['age'] as num?)?.toInt() ?? 0;

    // Mapear estado
    final statusStr = userData['status']?.toString() ?? 'Inactive';
    final userStatus = statusStr == 'Active' || statusStr == 'ACTIVE' || statusStr == 'active'
        ? UserStatus.active
        : UserStatus.inactive;

    return User(
      idUser: idUser,
      username: username,
      password: '', // No viene en la respuesta
      name: name,
      lastName: lastName,
      ci: ci,
      age: age,
      status: userStatus,
      email: email,
    );
  }

  // Mapa de permisos por rol (información falsa por ahora)
  Map<String, List<String>> get _rolePermissions => {
    'Admin': ['INVENTORY_*', 'USER_*', 'PRODUCTS_*', 'STORES_*', 'WAREHOUSES_*', 'SALES_*', 'MANAGER', 'REPORTS_VIEW'],
    'Manager': ['PRODUCT_VIEW', 'PRODUCT_EDIT', 'STORE_VIEW', 'STORE_MANAGEMENT', 'WAREHOUSE_VIEW', 'SALES_VIEW', 'REPORTS_VIEW'],
    'Employee': ['PRODUCT_VIEW', 'STORE_VIEW', 'WAREHOUSE_VIEW', 'SALES_VIEW'],
    'Viewer': ['PRODUCT_VIEW', 'STORE_VIEW', 'WAREHOUSE_VIEW'],
  };

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

  void _handleUpdate() {
    _showEditUserDialog();
  }
  
  void _showEditUserDialog() {
    if (_user == null) return;
    
    final nameController = TextEditingController(text: _user!.name);
    final lastNameController = TextEditingController(text: _user!.lastName);
    final usernameController = TextEditingController(text: _user!.username);
    final ciController = TextEditingController(text: _user!.ci);
    final ageController = TextEditingController(text: _user!.age.toString());
    final emailController = TextEditingController(text: _user!.email ?? '');

    // Estado inicial
    String selectedStatus = _user!.status == UserStatus.active ? 'Activo' : 'Inactivo';
    
    // Roles iniciales (múltiples roles desde la API)
    List<String> selectedRoles = List.from(_roles);
    
    // Permisos iniciales (combinar permisos de roles + permisos adicionales)
    List<String> selectedPermissions = List.from(_permissions);
    
    // Agregar permisos de los roles seleccionados
    for (String role in selectedRoles) {
      if (_rolePermissions.containsKey(role)) {
        for (String permission in _rolePermissions[role]!) {
          if (!selectedPermissions.contains(permission)) {
            selectedPermissions.add(permission);
          }
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Función para actualizar permisos cuando cambian los roles
          void updatePermissionsFromRoles() {
            setDialogState(() {
              // Guardar permisos adicionales (que no vienen de roles)
              List<String> additionalPermissions = [];
              for (String permission in selectedPermissions) {
                bool isFromAnyRole = false;
                for (String role in _rolePermissions.keys) {
                  if (_rolePermissions[role]!.contains(permission)) {
                    isFromAnyRole = true;
                    break;
                  }
                }
                if (!isFromAnyRole) {
                  additionalPermissions.add(permission);
                }
              }
              
              // Construir nueva lista de permisos: permisos de roles seleccionados + permisos adicionales
              List<String> newPermissions = List.from(additionalPermissions);
              
              // Agregar permisos de los roles seleccionados
              for (String role in selectedRoles) {
                if (_rolePermissions.containsKey(role)) {
                  for (String permission in _rolePermissions[role]!) {
                    if (!newPermissions.contains(permission)) {
                      newPermissions.add(permission);
                    }
                  }
                }
              }
              
              selectedPermissions = newPermissions;
            });
          }

          return AlertDialog(
            title: const Text('Editar Usuario'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ciController,
                      decoration: const InputDecoration(
                        labelText: 'CI',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ageController,
                      decoration: const InputDecoration(
                        labelText: 'Edad',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    // Estado - Combobox
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Activo', 'Inactivo'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    // Roles - Múltiple selección
                    const Text(
                      'Roles:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableRoles.map((role) {
                        final isSelected = selectedRoles.contains(role);
                        return FilterChip(
                          label: Text(role),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedRoles.add(role);
                              } else {
                                selectedRoles.remove(role);
                              }
                              updatePermissionsFromRoles();
                            });
                          },
                          selectedColor: _getRoleColor(role).withOpacity(0.2),
                          checkmarkColor: _getRoleColor(role),
                          labelStyle: TextStyle(
                            color: isSelected ? _getRoleColor(role) : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Permisos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Permisos:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            _showAddPermissionDialog(setDialogState, selectedPermissions);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Agregar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedPermissions.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'No hay permisos asignados',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: selectedPermissions.length,
                              itemBuilder: (context, index) {
                                final permission = selectedPermissions[index];
                                final isFromRole = _isPermissionFromRole(permission, selectedRoles);
                                
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    permission,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isFromRole)
                                        Tooltip(
                                          message: 'Permiso del rol',
                                          child: Icon(
                                            Icons.badge,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 18),
                                        color: Colors.red,
                                        onPressed: () {
                                          setDialogState(() {
                                            selectedPermissions.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validar campos
                  if (nameController.text.isEmpty ||
                      lastNameController.text.isEmpty ||
                      usernameController.text.isEmpty ||
                      ciController.text.isEmpty ||
                      ageController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor complete todos los campos requeridos'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // TODO: Implementar llamada a API para actualizar usuario
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Usuario actualizado: ${nameController.text} ${lastNameController.text}\n'
                        'Estado: $selectedStatus\n'
                        'Roles: ${selectedRoles.join(", ")}\n'
                        'Permisos: ${selectedPermissions.length}',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isPermissionFromRole(String permission, List<String> roles) {
    for (String role in roles) {
      if (_rolePermissions.containsKey(role)) {
        if (_rolePermissions[role]!.contains(permission)) {
          return true;
        }
      }
    }
    return false;
  }

  void _showAddPermissionDialog(
    StateSetter setDialogState,
    List<String> selectedPermissions,
  ) {
    final availableToAdd = _availablePermissions
        .where((p) => !selectedPermissions.contains(p))
        .toList();

    if (availableToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los permisos disponibles ya están asignados'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Permiso'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableToAdd.length,
            itemBuilder: (context, index) {
              final permission = availableToAdd[index];
              return ListTile(
                title: Text(permission),
                onTap: () {
                  setDialogState(() {
                    selectedPermissions.add(permission);
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _handleDelete() {
    if (_user == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${_user!.name} ${_user!.lastName}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar eliminación de usuario
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad de eliminación en desarrollo'),
                  backgroundColor: Colors.orange,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomTopBar(
          title: 'Detalle de Usuario',
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || _user == null) {
      return Scaffold(
        appBar: CustomTopBar(
          title: 'Detalle de Usuario',
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Error al cargar los detalles del usuario',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _loadUserDetails();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomTopBar(
        title: 'Detalle de Usuario',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información básica del usuario
            _buildSection(
              title: 'Información Personal',
              child: Column(
                children: [
                  _buildInfoRow('Nombre', '${_user!.name} ${_user!.lastName}'),
                  _buildInfoRow('Usuario', '@${_user!.username}'),
                  if (_user!.email != null)
                    _buildInfoRow('Email', _user!.email!),
                  _buildInfoRow('CI', _user!.ci),
                  _buildInfoRow('Edad', '${_user!.age} años'),
                  _buildInfoRow(
                    'Estado',
                    _user!.status.value,
                    valueColor: _user!.status == UserStatus.active
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Roles del usuario
            _buildSection(
              title: _roles.length == 1 ? 'Rol' : 'Roles',
              child: _roles.isEmpty
                  ? const Text(
                      'No hay roles asignados',
                      style: TextStyle(color: Colors.grey),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _roles.map((role) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getRoleColor(role).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.badge,
                                color: _getRoleColor(role),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                role,
                                style: TextStyle(
                                  color: _getRoleColor(role),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // Permisos del usuario
            _buildSection(
              title: 'Permisos',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'El usuario tiene ${_permissions.length} permisos asignados:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _permissions.isEmpty
                      ? const Text(
                          'No hay permisos asignados',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _permissions.map((permission) {
                            final isFromRole = _isPermissionFromRole(permission, _roles);
                            return Chip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isFromRole)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(
                                        Icons.badge,
                                        size: 14,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  Text(
                                    permission,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF007AFF).withOpacity(0.1),
                              labelStyle: const TextStyle(
                                color: Color(0xFF007AFF),
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleUpdate,
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('Actualizar'),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleDelete,
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

