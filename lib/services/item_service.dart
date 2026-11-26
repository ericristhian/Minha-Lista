import '../models/item.dart';
import '../supabase_client.dart';

/// Todo acesso à tabela items fica aqui (SELECT, INSERT, UPDATE, DELETE).
/// Não filtramos por user_id no SELECT: o RLS já faz isso no banco.
class ItemService {
  const ItemService();

  /// SELECT: lista os itens do usuário conectado (mais novos primeiro).
  Future<List<Item>> listItems() async {
    final rows = await supabase
        .from('items')
        .select('id, name, user_id, created_at')
        .order('created_at', ascending: false);
    return rows.map<Item>(Item.fromMap).toList();
  }

  /// INSERT: grava o item associando user_id ao usuário da sessão.
  Future<void> addItem(String name) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw StateError('Nenhum usuário conectado.');
    }
    await supabase.from('items').insert({
      'name': name.trim(),
      'user_id': user.id,
    });
  }

  /// UPDATE: renomeia um item (filtro .eq obrigatório).
  Future<void> renameItem(String itemId, String newName) async {
    await supabase
        .from('items')
        .update({'name': newName.trim()})
        .eq('id', itemId);
  }

  /// DELETE: remove um item (filtro .eq obrigatório).
  Future<void> deleteItem(String itemId) async {
    await supabase.from('items').delete().eq('id', itemId);
  }
}
