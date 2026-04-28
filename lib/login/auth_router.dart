import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../professor/home_page.dart';
import '../aluno/home_aluno_page.dart';
import '../services/database/usuarios_db.dart';

class AuthRouter extends StatelessWidget {
  final User user;

  const AuthRouter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: UsuariosDb.getTipo(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erro ao carregar perfil: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.data == 'aluno') {
          return const HomeAlunoPage();
        }

        return const HomePage();
      },
    );
  }
}
