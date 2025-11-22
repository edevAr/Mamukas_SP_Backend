class ApiConstants {
  // Base URL de la API
  static const String baseUrl = 'https://mamukas-erp-backend-6x7b.onrender.com';
  
  // Endpoints base
  static const String apiBaseUrl = '$baseUrl/api';
  
  // Endpoints específicos
  static const String authLogin = '$apiBaseUrl/auth/login';
  static const String authLogout = '$apiBaseUrl/auth/logout';
  
  // Endpoints de recursos
  static String users({int? page, int? size}) {
    if (page != null && size != null) {
      return '$apiBaseUrl/users?page=$page&size=$size';
    }
    return '$apiBaseUrl/users';
  }
  
  static String userDetails(int idUser) => '$apiBaseUrl/users/$idUser/details';
  
  static String stores({int? page, int? size}) {
    if (page != null && size != null) {
      return '$apiBaseUrl/stores?page=$page&size=$size';
    }
    return '$apiBaseUrl/stores';
  }
  
  static String storeById(int? idStore) {
    if (idStore == null) {
      throw ArgumentError('idStore cannot be null');
    }
    return '$apiBaseUrl/stores/$idStore';
  }
  
  static String warehouses({int? page, int? size}) {
    if (page != null && size != null) {
      return '$apiBaseUrl/warehouses?page=$page&size=$size';
    }
    return '$apiBaseUrl/warehouses';
  }
  
  static String warehouseDetails(int idWarehouse) => '$apiBaseUrl/warehouses/$idWarehouse/details';
  
  static String warehouseTransfer() => '$apiBaseUrl/warehouses/transfer';
  
  static String warehouseTransferReport() => '$apiBaseUrl/warehouses/transfer-report';
  
  static String products({int? page, int? size}) {
    if (page != null && size != null) {
      return '$apiBaseUrl/products?page=$page&size=$size';
    }
    return '$apiBaseUrl/products';
  }
  
  static String customers() => '$apiBaseUrl/customers';
  
  static String sales() => '$apiBaseUrl/sales';
  
  static String salesReport() => '$apiBaseUrl/sales/report';
}

