// lib/presentation/pages/pedidos/pedidos_page.dart
// Refatorado eTools - Responsivo - só barra de filtros alterada
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/pages/pedidos/pedido_detalhe_modal.dart';
import 'package:front_openerp/presentation/pages/pedidos/pedidos_kanban.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _busca = TextEditingController();
  bool _quadro = true;

  String? _statusFilter;
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    _scrollController.addListener(_onScroll);
    _busca.addListener(() => setState(() {})); // pra busca local funcionar
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _busca.dispose();
    super.dispose();
  }

  Future<void> _loadData() async => await context.read<PedidoProvider>().loadPedidos();

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      final provider = context.read<PedidoProvider>();
      if (!provider.isLoadingMore && provider.hasMore) provider.loadMore();
    }
  }

  Future<void> _refreshData() async => await context.read<PedidoProvider>().refreshPedidos();

  String? _formatDate(DateTime? date) => date == null ? null : DateFormat('yyyy-MM-dd').format(date);

  Future<void> _applyFilters() async {
    await context.read<PedidoProvider>().loadPedidos(
      status: _statusFilter,
      dataInicio: _formatDate(_dataInicio),
      dataFim: _formatDate(_dataFim),
    );
  }

  Future<void> _clearFilters() async {
    setState(() {
      _statusFilter = null;
      _dataInicio = null;
      _dataFim = null;
      _busca.clear();
    });
    await context.read<PedidoProvider>().loadPedidos();
  }

  Future<void> _pickDate({required bool isInicio}) async {
    final now = DateTime.now();
    final initial = isInicio ? (_dataInicio ?? now.subtract(const Duration(days: 30))) : (_dataFim ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      locale: const Locale('pt', 'BR'),
    );
    if (picked == null) return;
    setState(() {
      if (isInicio) {
        _dataInicio = picked;
        if (_dataFim != null && _dataFim!.isBefore(picked)) _dataFim = picked;
      } else {
        _dataFim = picked;
        if (_dataInicio != null && _dataInicio!.isAfter(picked)) _dataInicio = picked;
      }
    });
    await _applyFilters();
  }

  bool get _hasActiveFilters =>
      _statusFilter != null || _dataInicio != null || _dataFim != null || _busca.text.isNotEmpty;

  String get _statusLabel {
    if (_statusFilter == null) return 'Todos';
    return StatusPedido.fromString(_statusFilter!).label;
  }

  // FILTRO LOCAL por nome e numero - tava faltando no seu main
  List<PedidoModel> _filtrados(List<PedidoModel> lista) {
    final termo = _busca.text.trim().toLowerCase();
    if (termo.isEmpty) return lista;
    return lista
        .where((p) => p.id.toString().toLowerCase().contains(termo) || p.clienteNome.toLowerCase().contains(termo))
        .toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Filtrar pedidos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Situação',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _statusChip(
                          label: 'Todos',
                          selected: _statusFilter == null,
                          onTap: () => setSheetState(() => _statusFilter = null),
                        ),
                        ...StatusPedido.values.map(
                          (s) => _statusChip(
                            label: s.label,
                            selected: _statusFilter == s.toStringValue(),
                            onTap: () => setSheetState(() => _statusFilter = s.toStringValue()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Período',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _dateField(
                            label: 'Data início',
                            value: _dataInicio,
                            onTap: () async {
                              await _pickDate(isInicio: true);
                              setSheetState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateField(
                            label: 'Data fim',
                            value: _dataFim,
                            onTap: () async {
                              await _pickDate(isInicio: false);
                              setSheetState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await _clearFilters();
                              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.border),
                              foregroundColor: AppColors.textGrey,
                            ),
                            child: const Text('Limpar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              await _applyFilters();
                              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Aplicar'),
                          ),
                        ),
                      ],
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

  Widget _statusChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _dateField({required String label, required DateTime? value, required VoidCallback onTap}) {
    final fmt = DateFormat('dd/MM/yyyy');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textGrey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null ? label : fmt.format(value),
                style: TextStyle(
                  fontSize: 13,
                  color: value == null ? AppColors.textGrey : AppColors.textDark,
                  fontWeight: value == null ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidoProvider>();
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildToolbar(provider, isWeb),
            if (_hasActiveFilters) _buildActiveFiltersBar(),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : provider.error != null
                  ? _buildError(provider.error!, context)
                  : provider.pedidos.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _refreshData,
                      child: _quadro
                          ? const PedidosKanban()
                          : (isWeb ? _buildWebTable(provider) : _buildMobileList(provider)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =================== SÓ ISSO AQUI MUDOU ===================
  Widget _buildToolbar(PedidoProvider provider, bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 12 : 12),
      decoration: isWeb ? AppTheme.cardDecoration : const BoxDecoration(color: Colors.white),
      child: isWeb
          ? Row(
              children: [
                // BUSCA por nome e numero
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _busca,
                    decoration: InputDecoration(
                      hintText: 'Buscar nome ou nº',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: _busca.text.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => _busca.clear())
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                // STATUS
                PopupMenuButton<String>(
                  onSelected: (status) async {
                    setState(() => _statusFilter = status == 'todos' ? null : status);
                    await _applyFilters();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'todos', child: Text('Todos')),
                    ...StatusPedido.values.map((s) => PopupMenuItem(value: s.toStringValue(), child: Text(s.label))),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _hasActiveFilters ? 'Filtros ($_statusLabel)' : 'Filtrar',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // DATAS
                SizedBox(
                  width: 135,
                  child: _dateField(label: 'Início', value: _dataInicio, onTap: () => _pickDate(isInicio: true)),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 135,
                  child: _dateField(label: 'Fim', value: _dataFim, onTap: () => _pickDate(isInicio: false)),
                ),
                const Spacer(),
                // TOGGLE KANBAN / LISTA
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _quadro = true),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _quadro ? AppColors.primary : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                          ),
                          child: Icon(
                            Icons.view_kanban_outlined,
                            size: 18,
                            color: _quadro ? Colors.white : AppColors.textGrey,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _quadro = false),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: !_quadro ? AppColors.primary : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                          ),
                          child: Icon(Icons.view_list, size: 18, color: !_quadro ? Colors.white : AppColors.textGrey),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_filtrados(provider.pedidos).length} pedidos',
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ],
            )
          : Column(
              children: [
                TextField(
                  controller: _busca,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou nº',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _busca.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => _busca.clear())
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _openFilterSheet,
                      icon: const Icon(Icons.filter_list, size: 16),
                      label: Text(_hasActiveFilters ? 'Filtros' : 'Filtrar', style: const TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => setState(() => _quadro = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _quadro ? AppColors.primary : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                              ),
                              child: Icon(
                                Icons.view_kanban_outlined,
                                size: 18,
                                color: _quadro ? Colors.white : AppColors.textGrey,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _quadro = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: !_quadro ? AppColors.primary : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                              ),
                              child: Icon(
                                Icons.view_list,
                                size: 18,
                                color: !_quadro ? Colors.white : AppColors.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildActiveFiltersBar() {
    final fmt = DateFormat('dd/MM/yyyy');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (_busca.text.isNotEmpty) _activeChip(label: 'Busca: ${_busca.text}', onRemove: () => _busca.clear()),
          if (_statusFilter != null)
            _activeChip(
              label: _statusLabel,
              onRemove: () async {
                setState(() => _statusFilter = null);
                await _applyFilters();
              },
            ),
          if (_dataInicio != null)
            _activeChip(
              label: 'De ${fmt.format(_dataInicio!)}',
              onRemove: () async {
                setState(() => _dataInicio = null);
                await _applyFilters();
              },
            ),
          if (_dataFim != null)
            _activeChip(
              label: 'Até ${fmt.format(_dataFim!)}',
              onRemove: () async {
                setState(() => _dataFim = null);
                await _applyFilters();
              },
            ),
          TextButton(
            onPressed: _clearFilters,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Limpar tudo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _activeChip({required String label, required VoidCallback onRemove}) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 4, bottom: 4),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close, size: 14, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
        const SizedBox(height: 16),
        Text('Erro ao carregar pedidos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textGrey),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _loadData, child: const Text('Tentar novamente')),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Nenhum pedido encontrado', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        if (_hasActiveFilters) ...[
          const SizedBox(height: 12),
          TextButton(onPressed: _clearFilters, child: const Text('Limpar filtros')),
        ],
      ],
    ),
  );

  Widget _buildMobileList(PedidoProvider provider) {
    final lista = _filtrados(provider.pedidos);
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: lista.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == lista.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return _PedidoCard(pedido: lista[index]);
      },
    );
  }

  Widget _buildWebTable(PedidoProvider provider) {
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM HH:mm');
    final lista = _filtrados(provider.pedidos);
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    'PEDIDO',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CLIENTE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
                Expanded(
                  child: Text(
                    'DATA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
                Expanded(
                  child: Text(
                    'ORIGEM',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'STATUS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'TOTAL',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              itemCount: lista.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (context, index) {
                final pedido = lista[index];
                return InkWell(
                  onTap: () => showPedidoDetalheModal(context, pedido.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            '#${pedido.id}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            pedido.clienteNome,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            dateFormat.format(pedido.createdAt),
                            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pedido.origemLabel,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(int.parse(pedido.statusColor.replaceFirst('#', '0xff')))
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              pedido.statusLabel,
                              style: TextStyle(
                                color: Color(int.parse(pedido.statusColor.replaceFirst('#', '0xff'))),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            numberFormat.format(pedido.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final PedidoModel pedido;
  const _PedidoCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: InkWell(
        onTap: () => showPedidoDetalheModal(context, pedido.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(int.parse(pedido.statusColor.replaceFirst('#', '0xff'))),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('#${pedido.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color(int.parse(pedido.statusColor.replaceFirst('#', '0xff'))).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pedido.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(int.parse(pedido.statusColor.replaceFirst('#', '0xff'))),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateFormat.format(pedido.createdAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(pedido.clienteNome, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                '${pedido.itens.length} itens • ${pedido.origemLabel}',
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      pedido.origemLabel,
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    numberFormat.format(pedido.total),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
