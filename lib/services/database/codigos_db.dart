import 'package:cloud_firestore/cloud_firestore.dart';

/// Armazena e valida códigos de verificação temporários.
/// Coleção Firestore: codigos_verificacao/{email}
class CodigosDb {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static CollectionReference get _col =>
      _db.collection('codigos_verificacao');

  static const Duration _validade = Duration(minutes: 10);

  /// Salva (ou substitui) o código para [email].
  static Future<void> salvar({
    required String email,
    required String codigo,
  }) =>
      _col.doc(email).set({
        'codigo': codigo,
        'email': email,
        'expira_em': DateTime.now().add(_validade).millisecondsSinceEpoch,
      });

  /// Retorna true se [codigo] for correto e ainda não tiver expirado.
  static Future<bool> verificar({
    required String email,
    required String codigo,
  }) async {
    final doc = await _col.doc(email).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    final expiraEm = data['expira_em'] as int?;
    if (expiraEm != null &&
        DateTime.now().millisecondsSinceEpoch > expiraEm) {
      return false;
    }
    return data['codigo'] == codigo;
  }

  /// Remove o código após o cadastro ser concluído.
  static Future<void> remover(String email) => _col.doc(email).delete();
}
