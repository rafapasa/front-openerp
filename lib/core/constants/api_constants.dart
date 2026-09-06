// lib/core/constants/api_constants.dart - Adicionar:

class ApiEndpoints {
  // ... endpoints existentes

  // ============================================================
  // 🏢 Tenants
  // ============================================================
  static const String tenants = '/tenants';
  static String tenantById(int id) => '/tenants/$id';
  static String tenantToggle(int id) => '/tenants/$id/toggle';
  static String tenantWhatsappConnect(int id) =>
      '/tenants/$id/whatsapp/connect';
  static String tenantWhatsappDisconnect(int id) =>
      '/tenants/$id/whatsapp/disconnect';
  static const String consultaReceita = '/consulta/receita';
}
