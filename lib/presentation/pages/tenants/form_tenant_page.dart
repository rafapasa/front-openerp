// lib/presentation/pages/tenants/form_tenant_page.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
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
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  bool _ativo = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.tenant != null) {
      _nomeController.text = widget.tenant!.nome;
      _cnpjController.text = widget.tenant!.cnpj ?? '';
      _emailController.text = widget.tenant!.email ?? '';
      _telefoneController.text = widget.tenant!.telefone ?? '';
      _enderecoController.text = widget.tenant!.endereco ?? '';
      _ativo = widget.tenant!.ativo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tenant == null ? 'Nova Empresa' : 'Editar Empresa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cnpjController,
                decoration: const InputDecoration(labelText: 'CNPJ'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              SwitchListTile(
                title: const Text('Ativo'),
                value: _ativo,
                onChanged: (value) {
                  setState(() {
                    _ativo = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _salvar,
                      child: const Text('Salvar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final tenant = TenantModel(
      id: widget.tenant?.id,
      nome: _nomeController.text.trim(),
      cnpj: _cnpjController.text.isNotEmpty ? _cnpjController.text.trim() : null,
      email: _emailController.text.isNotEmpty ? _emailController.text.trim() : null,
      telefone: _telefoneController.text.isNotEmpty ? _telefoneController.text.trim() : null,
      endereco: _enderecoController.text.isNotEmpty ? _enderecoController.text.trim() : null,
      ativo: _ativo,
    );

    try {
      final provider = context.read<TenantProvider>();
      if (widget.tenant == null) {
        await provider.criarTenant(tenant);
      } else {
        await provider.atualizarTenant(tenant);
      }

      if (provider.error == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salvo com sucesso!')),
        );
        Navigator.pop(context, true);
      } else if (provider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${provider.error}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }
}