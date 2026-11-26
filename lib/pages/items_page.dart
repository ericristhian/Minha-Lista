import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item.dart';
import '../services/item_service.dart';
import '../supabase_client.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final _service = const ItemService();
  List<Item> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _describe(Object e) {
    if (e is PostgrestException) return e.message;
    if (e is AuthException) return e.message;
    return 'Não foi possível concluir a operação.';
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // Carregando -> Sucesso -> Erro
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.listItems();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _describe(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run(Future<void> Function() action, String okMsg) async {
    try {
      await action();
      if (!mounted) return;
      _snack(okMsg);
      await _load();
    } catch (e) {
      if (!mounted) return;
      _snack(_describe(e));
    }
  }

  Future<void> _add() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NameDialog(title: 'Novo item'),
    );
    if (name == null) return;
    await _run(() => _service.addItem(name), 'Item adicionado');
  }

  Future<void> _edit(Item item) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          _NameDialog(title: 'Editar item', initialValue: item.name),
    );
    if (name == null || name == item.name) return;
    await _run(() => _service.renameItem(item.id, name), 'Item atualizado');
  }

  Future<void> _delete(Item item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir item?'),
        content: Text('"${item.name}" será removido.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() => _service.deleteItem(item.id), 'Item excluído');
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      // AuthGate volta para o login automaticamente.
    } catch (e) {
      if (mounted) _snack(_describe(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? 'estudante';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Lista'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('Olá, $email',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Novo item'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: _load, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('Nenhum item ainda. Toque em "Novo item".'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final item = _items[i];
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              title: Text(item.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _edit(item),
                  ),
                  IconButton(
                    tooltip: 'Excluir',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(item),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Diálogo com seu próprio controller (evita usar controller já descartado).
class _NameDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  const _NameDialog({required this.title, this.initialValue = ''});

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialValue);
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'O nome não pode ser vazio');
      return;
    }
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration:
            InputDecoration(labelText: 'Nome do item', errorText: _error),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(onPressed: _submit, child: const Text('Salvar')),
      ],
    );
  }
}
