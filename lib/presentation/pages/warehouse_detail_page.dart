import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/widgets.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/api_constants.dart';

class WarehouseDetailPage extends StatefulWidget {
  final int idWarehouse;

  const WarehouseDetailPage({
    super.key,
    required this.idWarehouse,
  });

  static const routeName = '/warehouse-detail';

  @override
  State<WarehouseDetailPage> createState() => _WarehouseDetailPageState();
}

class _WarehouseDetailPageState extends State<WarehouseDetailPage> {
  // Datos del almacén cargados desde la API
  Map<String, dynamic>? _warehouseData;
  List<dynamic> _boxes = [];
  List<dynamic> _packs = [];
  List<dynamic> _warehouses = []; // Sub-almacenes
  bool _isLoading = true;
  String? _errorMessage;
  
  // Búsqueda de cajas
  final TextEditingController _boxSearchController = TextEditingController();
  List<dynamic> _filteredBoxes = [];
  
  // Búsqueda de paquetes
  final TextEditingController _packSearchController = TextEditingController();
  List<dynamic> _filteredPacks = [];
  
  // Selección de sub-almacén y productos
  Map<String, dynamic>? _selectedSubWarehouse;
  Set<int> _selectedBoxes = {}; // Índices de cajas seleccionadas
  Set<int> _selectedPacks = {}; // Índices de paquetes seleccionados
  Map<int, int> _boxQuantities = {}; // Cantidades de cajas seleccionadas (índice -> cantidad)
  Map<int, int> _packQuantities = {}; // Cantidades de paquetes seleccionadas (índice -> cantidad)
  
  // Modo edición
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedManagerUsername;
  String? _selectedStatus;
  List<Map<String, dynamic>> _availableUsers = [];
  bool _isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    _boxSearchController.addListener(_filterBoxes);
    _packSearchController.addListener(_filterPacks);
    _loadWarehouseDetails();
  }
  
  @override
  void dispose() {
    _boxSearchController.dispose();
    _packSearchController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  void _filterBoxes() {
    final query = _boxSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBoxes = List.from(_boxes);
      } else {
        _filteredBoxes = _boxes.where((box) {
          final product = box is Map 
              ? (box['product']?.toString() ?? '').toLowerCase()
              : '';
          return product.contains(query);
        }).toList();
      }
    });
  }
  
  void _filterPacks() {
    final query = _packSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPacks = List.from(_packs);
      } else {
        _filteredPacks = _packs.where((pack) {
          final product = pack is Map 
              ? (pack['product']?.toString() ?? '').toLowerCase()
              : '';
          return product.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadWarehouseDetails() async {
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
        Uri.parse(ApiConstants.warehouseDetails(widget.idWarehouse)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Warehouse details API response status: ${response.statusCode}');
        print('Warehouse details API response body: $responseBody');

        final decodedData = json.decode(responseBody);
        print('Decoded data type: ${decodedData.runtimeType}');

        // La API devuelve un JSON object con esta estructura:
        // {
        //   "idWarehouse": 10,
        //   "name": "...",
        //   "address": "...",
        //   "status": "...",
        //   "boxes": [...],      // Array de cajas
        //   "packs": [...]       // Array de paquetes
        // }

        if (decodedData is Map) {
          final warehouseData = decodedData as Map<String, dynamic>;
          final name = warehouseData['name']?.toString() ?? '';
          final address = warehouseData['address']?.toString() ?? '';
          final status = warehouseData['status']?.toString() ?? 'Inactive';
          final manager = warehouseData['warehouseManager']?.toString() ?? '';
          
          setState(() {
            _warehouseData = warehouseData;
            _boxes = decodedData['boxes'] is List ? List.from(decodedData['boxes']) : [];
            _packs = decodedData['packs'] is List ? List.from(decodedData['packs']) : [];
            _warehouses = decodedData['warehouses'] is List ? List.from(decodedData['warehouses']) : [];
            _filteredBoxes = List.from(_boxes);
            _filteredPacks = List.from(_packs);
            _isLoading = false;
            
            // Inicializar controllers con los datos cargados
            _nameController.text = name;
            _addressController.text = address;
            _selectedManagerUsername = manager.isNotEmpty ? manager : null;
            _selectedStatus = status;
          });

          print('Loaded warehouse: ${_warehouseData?['name']}');
          print('Warehouse Manager: ${_warehouseData?['warehouseManager']}');
          print('Sub-warehouses: ${_warehouses.length}');
          print('Boxes: ${_boxes.length}');
          print('Packs: ${_packs.length}');
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Formato de respuesta inesperado';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar detalles del almacén: ${response.statusCode}';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar detalles del almacén: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading warehouse details: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar detalles del almacén: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar detalles del almacén: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getWarehouseColor(int idWarehouse) {
    final colors = [
      const Color(0xFF007AFF),
      const Color(0xFF34C759),
      const Color(0xFFFF9500),
      const Color(0xFFFF3B30),
      const Color(0xFFAF52DE),
      const Color(0xFFFF2D55),
    ];
    return colors[idWarehouse % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomTopBar(
          title: 'Detalle del Almacén',
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || _warehouseData == null) {
      return Scaffold(
        appBar: CustomTopBar(
          title: 'Detalle del Almacén',
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Error al cargar los detalles del almacén',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _loadWarehouseDetails();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final idWarehouse = _warehouseData!['idWarehouse'] ?? widget.idWarehouse;
    final name = _warehouseData!['name']?.toString() ?? 'Sin nombre';
    final address = _warehouseData!['address']?.toString() ?? 'Sin dirección';
    final status = _warehouseData!['status']?.toString() ?? 'Inactive';
    final warehouseManager = _warehouseData!['warehouseManager']?.toString() ?? 'Sin gerente asignado';
    final isActive = status == 'Active' || status == 'ACTIVE' || status == 'active';
    final warehouseColor = _getWarehouseColor(idWarehouse is int ? idWarehouse : widget.idWarehouse);

    return Scaffold(
      appBar: CustomTopBar(
        title: 'Detalle del Almacén',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información básica del almacén
            _buildSection(
              title: 'Información del Almacén',
              child: Column(
                children: [
                  _isEditing
                      ? _buildEditableNameRow()
                      : _buildInfoRow('Nombre', name),
                  _isEditing
                      ? _buildEditableAddressRow()
                      : _buildInfoRow('Dirección', address),
                  _isEditing
                      ? _buildEditableManagerRow()
                      : _buildInfoRow('Gerente', warehouseManager),
                  _isEditing
                      ? _buildEditableStatusRow()
                      : _buildInfoRow(
                          'Estado',
                          isActive ? 'Activo' : 'Inactivo',
                          valueColor: isActive ? Colors.green : Colors.red,
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sub-almacenes (warehouses)
            if (_warehouses.isNotEmpty)
              _buildSection(
                title: 'Sub-Almacenes (${_warehouses.length})',
                child: _buildSubWarehouseAutocomplete(),
              ),

            if (_warehouses.isNotEmpty) const SizedBox(height: 24),

            // Cajas de productos
            _buildSection(
              title: 'Cajas (${_boxes.length})',
              child: Column(
                children: [
                  // Buscador de cajas
                  if (_boxes.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _boxSearchController,
                        builder: (context, value, child) {
                          return TextField(
                            controller: _boxSearchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar caja por producto...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
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
                                        _boxSearchController.clear();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ),
                  // Grilla de cajas
                  _filteredBoxes.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              _boxes.isEmpty
                                  ? 'No hay cajas en este almacén'
                                  : 'No se encontraron cajas',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _filteredBoxes.length,
                          itemBuilder: (context, index) {
                            final box = _filteredBoxes[index];
                            final isSelected = _selectedBoxes.contains(index);
                            return _buildBoxGridItem(box, index, isSelected);
                          },
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Paquetes de productos
            _buildSection(
              title: 'Paquetes (${_packs.length})',
              child: Column(
                children: [
                  // Buscador de paquetes
                  if (_packs.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _packSearchController,
                        builder: (context, value, child) {
                          return TextField(
                            controller: _packSearchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar paquete por producto...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
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
                                        _packSearchController.clear();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ),
                  // Grilla de paquetes
                  _filteredPacks.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              _packs.isEmpty
                                  ? 'No hay paquetes en este almacén'
                                  : 'No se encontraron paquetes',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _filteredPacks.length,
                          itemBuilder: (context, index) {
                            final pack = _filteredPacks[index];
                            final isSelected = _selectedPacks.contains(index);
                            return _buildPackGridItem(pack, index, isSelected);
                          },
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_isEditing) {
                        // Guardar cambios
                        _saveWarehouseChanges();
                      } else {
                        // Activar modo edición
                        setState(() {
                          _isEditing = true;
                        });
                        _loadUsers();
                      }
                    },
                    icon: Icon(_isEditing ? Icons.save : Icons.edit, size: 20),
                    label: Text(_isEditing ? 'Guardar' : 'Editar'),
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
                    onPressed: () {
                      _showDeleteConfirmation(name);
                    },
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
            
            // Espacio para la sección flotante
            if (_selectedSubWarehouse != null)
              const SizedBox(height: 100),
          ],
        ),
      ),
      // Sección flotante cuando se selecciona un sub-almacén
      bottomNavigationBar: _selectedSubWarehouse != null
          ? _buildFloatingActionSection()
          : null,
    );
  }
  
  Widget _buildFloatingActionSection() {
    final hasSelectedItems = _selectedBoxes.isNotEmpty || _selectedPacks.isNotEmpty;
    final selectedWarehouseName = _selectedSubWarehouse?['name']?.toString() ?? 'Almacén seleccionado';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Almacén seleccionado: $selectedWarehouseName',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar envío de productos
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Enviar productos a: $selectedWarehouseName\n'
                            'Cajas seleccionadas: ${_selectedBoxes.length}\n'
                            'Paquetes seleccionados: ${_selectedPacks.length}',
                          ),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send, size: 20),
                    label: const Text('Enviar productos a este almacén'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (hasSelectedItems) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showSelectedProductsDialog();
                      },
                      icon: const Icon(Icons.visibility, size: 20),
                      label: const Text('Ver productos seleccionados'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSelectedProductsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Productos Seleccionados'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedBoxes.isNotEmpty) ...[
                    const Text(
                      'Cajas:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ..._selectedBoxes.map((index) {
                      if (index < _filteredBoxes.length) {
                        final box = _filteredBoxes[index];
                        final product = box is Map ? (box['product']?.toString() ?? 'Sin producto') : 'Sin producto';
                        final currentQuantity = _boxQuantities[index] ?? 1;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Botón -
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setDialogState(() {
                                    final currentQty = _boxQuantities[index] ?? 1;
                                    if (currentQty > 1) {
                                      _boxQuantities[index] = currentQty - 1;
                                    }
                                  });
                                },
                                color: Colors.red,
                                iconSize: 24,
                              ),
                              // Input de cantidad
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  key: ValueKey('box_qty_${index}_${currentQuantity}'),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  ),
                                  controller: TextEditingController(text: currentQuantity.toString()),
                                  onChanged: (value) {
                                    final qty = int.tryParse(value) ?? 1;
                                    if (qty > 0) {
                                      setDialogState(() {
                                        _boxQuantities[index] = qty;
                                      });
                                    }
                                  },
                                ),
                              ),
                              // Botón +
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setDialogState(() {
                                    _boxQuantities[index] = (_boxQuantities[index] ?? 1) + 1;
                                  });
                                },
                                color: Colors.green,
                                iconSize: 24,
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 16),
                  ],
                  if (_selectedPacks.isNotEmpty) ...[
                    const Text(
                      'Paquetes:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ..._selectedPacks.map((index) {
                      if (index < _filteredPacks.length) {
                        final pack = _filteredPacks[index];
                        final product = pack is Map ? (pack['product']?.toString() ?? 'Sin producto') : 'Sin producto';
                        final currentQuantity = _packQuantities[index] ?? 1;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Botón -
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setDialogState(() {
                                    final currentQty = _packQuantities[index] ?? 1;
                                    if (currentQty > 1) {
                                      _packQuantities[index] = currentQty - 1;
                                    }
                                  });
                                },
                                color: Colors.red,
                                iconSize: 24,
                              ),
                              // Input de cantidad
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  key: ValueKey('pack_qty_${index}_${currentQuantity}'),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  ),
                                  controller: TextEditingController(text: currentQuantity.toString()),
                                  onChanged: (value) {
                                    final qty = int.tryParse(value) ?? 1;
                                    if (qty > 0) {
                                      setDialogState(() {
                                        _packQuantities[index] = qty;
                                      });
                                    }
                                  },
                                ),
                              ),
                              // Botón +
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setDialogState(() {
                                    _packQuantities[index] = (_packQuantities[index] ?? 1) + 1;
                                  });
                                },
                                color: Colors.green,
                                iconSize: 24,
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                  if (_selectedBoxes.isEmpty && _selectedPacks.isEmpty)
                    const Text('No hay productos seleccionados'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  // Cerrar la modal primero
                  Navigator.of(context).pop();
                  
                  // Llamar a la API de transferencia
                  await _transferProducts();
                  
                  // Deseleccionar todos los elementos y limpiar el panel flotante
                  setState(() {
                    _selectedBoxes.clear();
                    _selectedPacks.clear();
                    _boxQuantities.clear();
                    _packQuantities.clear();
                    _selectedSubWarehouse = null;
                  });
                },
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Enviar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
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
  
  Widget _buildEditableNameRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              'Nombre',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditableAddressRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              'Dirección',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditableManagerRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              'Gerente',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: _buildManagerAutocomplete(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditableStatusRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              'Estado',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Active', child: Text('Activo')),
                DropdownMenuItem(value: 'Inactive', child: Text('Inactivo')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildManagerAutocomplete() {
    return Autocomplete<Object>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _availableUsers.cast<Object>();
        }
        final query = textEditingValue.text.toLowerCase();
        return _availableUsers.where((user) {
          final name = user['name']?.toString() ?? '';
          final lastName = user['lastName']?.toString() ?? '';
          final username = user['username']?.toString() ?? '';
          final fullName = '$name $lastName'.toLowerCase();
          return fullName.contains(query) || username.toLowerCase().contains(query);
        }).cast<Object>();
      },
      displayStringForOption: (Object user) {
        if (user is Map) {
          final name = user['name']?.toString() ?? '';
          final lastName = user['lastName']?.toString() ?? '';
          final username = user['username']?.toString() ?? '';
          if (name.isNotEmpty || lastName.isNotEmpty) {
            return '$name $lastName'.trim();
          }
          return username;
        }
        return '';
      },
      onSelected: (Object user) {
        if (user is Map) {
          setState(() {
            _selectedManagerUsername = user['username']?.toString();
          });
        }
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Inicializar el controller con el valor actual si está vacío
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (textEditingController.text.isEmpty && _selectedManagerUsername != null) {
            final selectedUser = _availableUsers.firstWhere(
              (user) => user['username']?.toString() == _selectedManagerUsername,
              orElse: () => {'name': _selectedManagerUsername, 'username': _selectedManagerUsername},
            );
            final name = selectedUser['name']?.toString() ?? '';
            final lastName = selectedUser['lastName']?.toString() ?? '';
            final username = selectedUser['username']?.toString() ?? '';
            if (name.isNotEmpty || lastName.isNotEmpty) {
              textEditingController.text = '$name $lastName'.trim();
            } else {
              textEditingController.text = username;
            }
          }
        });
        
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: textEditingController,
          builder: (context, value, child) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Buscar gerente...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.person_search,
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
                            _selectedManagerUsername = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(fontSize: 14),
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
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = options.elementAt(index);
                  if (user is! Map) return const SizedBox.shrink();
                  
                  final name = user['name']?.toString() ?? '';
                  final lastName = user['lastName']?.toString() ?? '';
                  final username = user['username']?.toString() ?? '';
                  final fullName = '$name $lastName'.trim();
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person, color: Colors.blue, size: 20),
                    ),
                    title: Text(
                      fullName.isNotEmpty ? fullName : username,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: fullName.isNotEmpty
                        ? Text(
                            '@$username',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          )
                        : null,
                    onTap: () {
                      onSelected(user);
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
  
  Future<void> _loadUsers() async {
    if (_isLoadingUsers) return;
    
    setState(() {
      _isLoadingUsers = true;
    });
    
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        setState(() {
          _isLoadingUsers = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConstants.users(page: 0, size: 100)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final decodedData = json.decode(responseBody);

        List<dynamic> data = [];
        if (decodedData is Map) {
          if (decodedData.containsKey('data') && decodedData['data'] is Map) {
            final dataObj = decodedData['data'] as Map;
            if (dataObj.containsKey('content') && dataObj['content'] is List) {
              data = dataObj['content'] as List;
            }
          } else if (decodedData.containsKey('content') && decodedData['content'] is List) {
            data = decodedData['content'] as List;
          }
        } else if (decodedData is List) {
          data = decodedData;
        }

        setState(() {
          _availableUsers = data.map((item) {
            return {
              'idUser': item['idUser'],
              'name': item['name']?.toString() ?? '',
              'lastName': item['lastName']?.toString() ?? '',
              'username': item['username']?.toString() ?? '',
              'email': item['email']?.toString() ?? '',
            };
          }).toList();
          _isLoadingUsers = false;
        });
      } else {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }
  
  Future<void> _saveWarehouseChanges() async {
    // TODO: Implementar llamada a API para guardar cambios
    setState(() {
      _isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios guardados (funcionalidad en desarrollo)'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _transferProducts() async {
    if (_selectedSubWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un almacén de destino'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final toWarehouseId = _selectedSubWarehouse!['idWarehouse'];
    if (toWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID del almacén de destino no válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Construir el array de boxes
    List<Map<String, dynamic>> boxes = [];
    for (final index in _selectedBoxes) {
      if (index < _filteredBoxes.length) {
        final box = _filteredBoxes[index];
        if (box is Map) {
          // Intentar obtener id_box de diferentes campos posibles
          final idBox = box['id_box'] ?? box['idBox'] ?? box['id'];
          final quantity = _boxQuantities[index] ?? 1;
          
          if (idBox != null) {
            boxes.add({
              'id_box': idBox is int ? idBox : (idBox as num?)?.toInt(),
              'units_boxes': quantity,
            });
          } else {
            print('Warning: Box at index $index does not have id_box. Box data: $box');
          }
        }
      }
    }
    
    // Construir el array de packages
    List<Map<String, dynamic>> packages = [];
    for (final index in _selectedPacks) {
      if (index < _filteredPacks.length) {
        final pack = _filteredPacks[index];
        if (pack is Map) {
          // Obtener id_pack (el campo correcto que viene de la API)
          final idPack = pack['id_pack'] ?? pack['idPack'] ?? pack['id'];
          final quantity = _packQuantities[index] ?? 1;
          
          if (idPack != null) {
            packages.add({
              'id_package': idPack is int ? idPack : (idPack as num?)?.toInt(),
              'units_packages': quantity,
            });
          } else {
            print('Warning: Pack at index $index does not have id_pack. Pack data: $pack');
          }
        }
      }
    }
    
    if (boxes.isEmpty && packages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar al menos un producto para transferir'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Construir el body de la petición
    final requestBody = {
      'fromWarehouseId': widget.idWarehouse,
      'toWarehouseId': toWarehouseId is int ? toWarehouseId : (toWarehouseId as num?)?.toInt(),
      'boxes': boxes,
      'packages': packages,
    };
    
    print('Transfer request body: ${json.encode(requestBody)}');
    
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay token de autenticación disponible'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Mostrar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
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
              Text('Procesando transferencia...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
      
      final response = await http.post(
        Uri.parse(ApiConstants.warehouseTransfer()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      // Ocultar indicador de carga
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Recargar los detalles del almacén para actualizar los stocks
        await _loadWarehouseDetails();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transferencia realizada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        final errorBody = response.body;
        print('Error en transferencia: ${response.statusCode} - $errorBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al realizar la transferencia: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      print('Error en transferencia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al realizar la transferencia: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildBoxGridItem(dynamic box, int index, bool isSelected) {
    // Nueva estructura: product, amount, units_per_box, stock
    final product = box is Map ? (box['product']?.toString() ?? 'Sin producto') : 'Sin producto';
    final amount = box is Map ? (box['amount'] is int ? box['amount'] as int : (box['amount'] as num?)?.toInt() ?? 0) : 0;
    final unitsPerBox = box is Map ? (box['units_per_box'] is int ? box['units_per_box'] as int : (box['units_per_box'] as num?)?.toInt() ?? 0) : 0;
    final stock = box is Map ? (box['stock'] is int ? box['stock'] as int : (box['stock'] as num?)?.toInt() ?? 0) : 0;

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Color(0xFF007AFF), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedBoxes.remove(index);
              _boxQuantities.remove(index);
            } else {
              _selectedBoxes.add(index);
              _boxQuantities[index] = 1; // Inicializar cantidad en 1
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(height: 12),
                  // Producto
                  Text(
                    product,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Información
                  Text(
                    'Cajas: $amount',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Unid/caja: $unitsPerBox',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  // Stock
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          stock.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Indicador de selección
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF007AFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackGridItem(dynamic pack, int index, bool isSelected) {
    // Nueva estructura: product, amount, units_per_pack, stock
    final product = pack is Map ? (pack['product']?.toString() ?? 'Sin producto') : 'Sin producto';
    final amount = pack is Map ? (pack['amount'] is int ? pack['amount'] as int : (pack['amount'] as num?)?.toInt() ?? 0) : 0;
    final unitsPerPack = pack is Map ? (pack['units_per_pack'] is int ? pack['units_per_pack'] as int : (pack['units_per_pack'] as num?)?.toInt() ?? 0) : 0;
    final stock = pack is Map ? (pack['stock'] is int ? pack['stock'] as int : (pack['stock'] as num?)?.toInt() ?? 0) : 0;

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Color(0xFF007AFF), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedPacks.remove(index);
              _packQuantities.remove(index);
            } else {
              _selectedPacks.add(index);
              _packQuantities[index] = 1; // Inicializar cantidad en 1
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_bag, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(height: 12),
                  // Producto
                  Text(
                    product,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Información
                  Text(
                    'Paquetes: $amount',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Unid/paq: $unitsPerPack',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  // Stock
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          stock.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Indicador de selección
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF007AFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubWarehouseAutocomplete() {
    return Autocomplete<Object>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _warehouses.cast<Object>();
        }
        final query = textEditingValue.text.toLowerCase();
        return _warehouses.where((warehouse) {
          if (warehouse is Map) {
            final name = (warehouse['name']?.toString() ?? '').toLowerCase();
            return name.contains(query);
          }
          return false;
        }).cast<Object>();
      },
      displayStringForOption: (Object warehouse) {
        if (warehouse is Map) {
          return warehouse['name']?.toString() ?? 'Sin nombre';
        }
        return 'Sin nombre';
      },
      onSelected: (Object warehouse) {
        if (warehouse is Map) {
          setState(() {
            _selectedSubWarehouse = Map<String, dynamic>.from(warehouse);
          });
        }
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: textEditingController,
          builder: (context, value, child) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Buscar y seleccionar sub-almacén...',
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
                        },
                      )
                    : Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]!
                        : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]!
                        : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF007AFF),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFF2F2F7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
              ),
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
                  final warehouse = options.elementAt(index);
                  if (warehouse is! Map) return const SizedBox.shrink();
                  
                  final name = warehouse['name']?.toString() ?? 'Sin nombre';
                  final idWarehouse = warehouse['idWarehouse'];
                  final manager = warehouse['warehouseManager']?.toString() ?? 'Sin gerente';
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.warehouse, color: Colors.purple, size: 20),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (idWarehouse != null)
                          Text(
                            'ID: $idWarehouse',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        Text(
                          'Gerente: $manager',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    onTap: () {
                      onSelected(warehouse);
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

  void _showDeleteConfirmation(String warehouseName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Almacén'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el almacén "$warehouseName"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar eliminación de almacén
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
}
