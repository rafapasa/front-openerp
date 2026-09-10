import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/repositories/pedido_repository.dart';

class FakePedidoRepository implements PedidoRepository {
  final List<PedidoModel> store;
  StatusPedido? lastStatus;
  String? lastMotivo;
  int? lastId;

  FakePedidoRepository(this.store);

  @override
  Future<PaginatedResponse<PedidoModel>> getPedidos({
    int page = 1,
    int limit = 20,
    String? status,
    int? clienteId,
    String? dataInicio,
    String? dataFim,
    bool forceRefresh = false,
  }) async {
    return PaginatedResponse<PedidoModel>(
      data: List.of(store),
      total: store.length,
      page: page,
      limit: limit,
      pages: 1,
    );
  }

  @override
  Future<PedidoModel> getPedidoById(int id) async {
    return store.firstWhere((p) => p.id == id);
  }

  @override
  Future<PedidoModel> updateStatus(int id, StatusPedido status, {String? motivo}) async {
    lastId = id;
    lastStatus = status;
    lastMotivo = motivo;
    final index = store.indexWhere((p) => p.id == id);
    store[index] = store[index].copyWith(
      status: status,
      motivoCancelamento: motivo,
      updatedAt: DateTime.now(),
    );
    return store[index];
  }

  @override
  Future<void> clearCache() async {}
}
