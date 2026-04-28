import 'package:cloud_firestore/cloud_firestore.dart';

class SessoesDb {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static CollectionReference get _col => _db.collection('sessoes_qrcode');

  /// Cria uma nova sessão QR e retorna o ID gerado.
  static Future<String> criar({
    required String formularioId,
    String? turmaId,
  }) async {
    final doc = await _col.add({
      'formulario_id': formularioId,
      'turma_id': ?turmaId,
      'status': 'ativa',
      'criado_em': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Encerra uma sessão QR ativa.
  static Future<void> encerrar(String sessaoId) =>
      _col.doc(sessaoId).update({'status': 'encerrada'});

  /// Lê o documento de uma sessão QR.
  static Future<DocumentSnapshot> getSessao(String sessaoId) =>
      _col.doc(sessaoId).get();
}
