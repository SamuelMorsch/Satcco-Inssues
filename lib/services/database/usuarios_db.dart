import 'package:cloud_firestore/cloud_firestore.dart';

class UsuariosDb {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static CollectionReference get _usuarios => _db.collection('usuarios');
  static CollectionReference get _convites => _db.collection('convites');

  /// Retorna 'professor' ou 'aluno' para o uid dado.
  static Future<String> getTipo(String uid) async {
    final doc = await _usuarios.doc(uid).get();
    if (!doc.exists) return 'professor';
    return ((doc.data() as Map<String, dynamic>?)?['tipo'] as String?) ??
        'professor';
  }

  /// Lê o documento completo do usuário.
  static Future<DocumentSnapshot> getUsuario(String uid) =>
      _usuarios.doc(uid).get();

  /// Cria o documento do usuário no cadastro.
  static Future<void> saveUsuario({
    required String uid,
    required String nome,
    required String email,
    required String tipo,
  }) =>
      _usuarios.doc(uid).set({
        'nome': nome,
        'email': email,
        'tipo': tipo,
        'criado_em': FieldValue.serverTimestamp(),
      });

  /// Busca usuário por email (para verificar se existe conta).
  static Future<QuerySnapshot> findByEmail(String email) =>
      _usuarios.where('email', isEqualTo: email).get();

  /// Adiciona turmaIds ao array 'turmas' do usuário.
  static Future<void> addTurmas(String uid, List<String> turmaIds) =>
      _usuarios.doc(uid).update({
        'turmas': FieldValue.arrayUnion(turmaIds),
      });

  /// Remove um turmaId do array 'turmas' do usuário.
  static Future<void> removeTurma(String uid, String turmaId) =>
      _usuarios.doc(uid).update({
        'turmas': FieldValue.arrayRemove([turmaId]),
      });

  /// Processa convites pendentes no momento do cadastro (aluno ainda sem conta).
  /// Vincula aluno_id nos docs de aluno de cada turma e remove o convite.
  static Future<void> processarConvitesCadastro({
    required String uid,
    required String email,
  }) async {
    final conviteDoc = await _convites.doc(email).get();
    if (!conviteDoc.exists) return;

    final turmaIds = List<String>.from(
        (conviteDoc.data() as Map<String, dynamic>?)?['turma_ids'] as List? ??
            []);
    if (turmaIds.isEmpty) return;

    final batch = _db.batch();
    for (final turmaId in turmaIds) {
      batch.update(
        _db.collection('turmas').doc(turmaId).collection('alunos').doc(email),
        {'aluno_id': uid},
      );
    }
    batch.update(_usuarios.doc(uid), {
      'turmas': FieldValue.arrayUnion(turmaIds),
    });
    batch.delete(conviteDoc.reference);
    await batch.commit();
  }

  /// Processa convites pendentes quando o aluno já tem conta (no login).
  /// Retorna o userDoc atualizado.
  static Future<DocumentSnapshot> processarConvitesLogin({
    required String uid,
    required String email,
  }) async {
    var userDoc = await _usuarios.doc(uid).get();
    if (email.isEmpty) return userDoc;

    final conviteDoc = await _convites.doc(email).get();
    if (!conviteDoc.exists) return userDoc;

    final conviteTurmaIds = List<String>.from(
        (conviteDoc.data() as Map<String, dynamic>?)?['turma_ids'] as List? ??
            []);
    if (conviteTurmaIds.isEmpty) return userDoc;

    final batch = _db.batch();
    for (final turmaId in conviteTurmaIds) {
      final alunoRef = _db
          .collection('turmas')
          .doc(turmaId)
          .collection('alunos')
          .doc(email);
      final alunoDoc = await alunoRef.get();
      if (alunoDoc.exists) {
        batch.update(alunoRef, {'aluno_id': uid});
      }
    }
    batch.update(_usuarios.doc(uid), {
      'turmas': FieldValue.arrayUnion(conviteTurmaIds),
    });
    batch.delete(conviteDoc.reference);
    await batch.commit();

    return _usuarios.doc(uid).get();
  }
}
