// lib/presentation/pages/tenants/form_tenant_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/data/services/tenant_service.dart';
import 'package:front_openerp/presentation/providers/tenant_provider.dart';
import 'package:provider/provider.dart';

class FormTenantPage extends StatefulWidget {
  final TenantModel? tenant;

  const FormTenantPage({super.key, this.tenant});

  @override
  State<FormTenantPage> createState() => _FormTenantPageState();
}

class _FormTenantPageState extends State<FormTenantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  String? _segmentoSelecionado;

  final _wabaIdController = TextEditingController();
  final _whatsappPhoneIdController = TextEditingController();
  final _whatsappDisplayNumberController = TextEditingController();

  bool _isLoading = false;
  bool _isSearchingReceita = false;

  @override
  void initState() {
    super.initState();
    if (widget.tenant != null) {
      _preencherDados(widget.tenant!);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _wabaIdController.dispose();
    _whatsappPhoneIdController.dispose();
    _whatsappDisplayNumberController.dispose();
    super.dispose();
  }

  void _preencherDados(TenantModel tenant) {
    _nomeController.text = tenant.nome;
    _cnpjController.text = tenant.cnpj ?? '';
    _telefoneController.text = tenant.telefone ?? '';
    _enderecoController.text = tenant.endereco ?? '';
    _segmentoSelecionado = tenant.segmento;
    _wabaIdController.text = tenant.wabaId ?? '';
    _whatsappPhoneIdController.text = tenant.whatsappPhoneId ?? '';
    _whatsappDisplayNumberController.text = tenant.whatsappDisplayNumber ?? '';
  }

  Future<void> _buscarDadosReceita() async {
    final documento = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (documento.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um CNPJ ou CPF válido')),
      );
      return;
    }

    setState(() => _isSearchingReceita = true);

    try {
      final service = context.read<TenantService>();
      final dados = await service.buscarDadosReceita(documento);

      if (!mounted) return;

      setState(() {
        if (dados['nome'] != null) _nomeController.text = dados['nome'];
        if (dados['telefone'] != null) {
          _telefoneController.text = dados['telefone'];
        }
        if (dados['endereco'] != null) {
          _enderecoController.text = dados['endereco'];
        }
        _isSearchingReceita = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados da Receita carregados com sucesso!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearchingReceita = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao buscar dados: $e')));
    }
  }

  void _conectarWhatsapp() {
    // TODO: Implementar conexão com WhatsApp via Meta SDK
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento...')),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<TenantProvider>();
      bool success;

      final data = {
        'nome': _nomeController.text.trim(),
        'cnpj': _cnpjController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'segmento': _segmentoSelecionado,
        'waba_id': _wabaIdController.text.trim(),
        'whatsapp_phone_id': _whatsappPhoneIdController.text.trim(),
        'whatsapp_display_number': _whatsappDisplayNumberController.text.trim(),
      };

      if (widget.tenant == null) {
        success = await provider.createTenant(data);
      } else {
        success = await provider.updateTenant(widget.tenant!.id, data);
      }

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.tenant == null
                  ? 'Tenant criado com sucesso!'
                  : 'Tenant atualizado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatarCnpj(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length <= 3) return cleaned;
    if (cleaned.length <= 6) {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3)}';
    }
    if (cleaned.length <= 9) {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6)}';
    }
    if (cleaned.length <= 11) {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
    }
    return '${cleaned.substring(0, 2)}.${cleaned.substring(2, 5)}.${cleaned.substring(5, 8)}/${cleaned.substring(8, 12)}-${cleaned.substring(12, 14)}';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.tenant != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Tenant' : 'Novo Tenant'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.green,
              ),
              onPressed: _conectarWhatsapp,
              tooltip: 'Conectar WhatsApp',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📋 Dados do Tenant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o nome do tenant';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _cnpjController,
                              decoration: const InputDecoration(
                                labelText: 'CNPJ ou CPF',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.badge),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(14),
                              ],
                              onChanged: (value) {
                                final cleaned = value.replaceAll(
                                  RegExp(r'[^0-9]'),
                                  '',
                                );
                                _cnpjController.text = _formatarCnpj(cleaned);
                                _cnpjController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(
                                        offset: _cnpjController.text.length,
                                      ),
                                    );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _isSearchingReceita
                                ? const CircularProgressIndicator()
                                : ElevatedButton.icon(
                                    onPressed: _buscarDadosReceita,
                                    icon: const Icon(Icons.search),
                                    label: const Text('Buscar'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(0, 56),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _enderecoController,
                        decoration: const InputDecoration(
                          labelText: 'Endereço',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _segmentoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Segmento',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'geral',
                            child: Text('Geral'),
                          ),
                          DropdownMenuItem(
                            value: 'farmacia',
                            child: Text('Farmácia'),
                          ),
                          DropdownMenuItem(
                            value: 'mercado',
                            child: Text('Mercado'),
                          ),
                          DropdownMenuItem(
                            value: 'restaurante',
                            child: Text('Restaurante'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _segmentoSelecionado = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💬 WhatsApp Business',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _wabaIdController,
                        decoration: const InputDecoration(
                          labelText: 'WABA ID',
                          hintText: 'ID da conta WhatsApp Business',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.code),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _whatsappPhoneIdController,
                        decoration: const InputDecoration(
                          labelText: 'Phone ID *',
                          hintText: 'ID do número de telefone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_android),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o Phone ID do WhatsApp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _whatsappDisplayNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Exibição',
                          hintText: 'Número que aparece para o cliente',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.tenant != null)
                        ElevatedButton.icon(
                          onPressed: _conectarWhatsapp,
                          icon: const FaIcon(FontAwesomeIcons.whatsapp),
                          label: Text(
                            widget.tenant!.isWhatsappConnected
                                ? 'Gerenciar WhatsApp'
                                : 'Conectar WhatsApp',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? 'Atualizar' : 'Criar'),
                    ),
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
