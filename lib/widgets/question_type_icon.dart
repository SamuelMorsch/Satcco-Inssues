import 'package:flutter/material.dart';

/// Ícone circular colorido por tipo de pergunta.
/// [radius] padrão 20 (tamanho normal em listas); use 16 para listas compactas.
class QuestionTypeIcon extends StatelessWidget {
  final String tipo;
  final double radius;

  const QuestionTypeIcon({super.key, required this.tipo, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _bgColor,
      child: Icon(_icon, color: _fgColor, size: radius * 1.1),
    );
  }

  Color get _bgColor {
    switch (tipo) {
      case 'sim_nao':
        return const Color(0xFFE8F5E9);
      case 'verdadeiro_falso':
        return const Color(0xFFE0F7FA);
      case 'multipla_escolha':
        return const Color(0xFFEDE7F6);
      case 'texto':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  Color get _fgColor {
    switch (tipo) {
      case 'sim_nao':
        return Colors.green;
      case 'verdadeiro_falso':
        return Colors.teal;
      case 'multipla_escolha':
        return Colors.deepPurple;
      case 'texto':
        return Colors.orange;
      default:
        return Colors.blueAccent;
    }
  }

  IconData get _icon {
    switch (tipo) {
      case 'sim_nao':
        return Icons.check_circle_outline;
      case 'verdadeiro_falso':
        return Icons.rule;
      case 'multipla_escolha':
        return Icons.list_alt_outlined;
      case 'texto':
        return Icons.short_text;
      default:
        return Icons.linear_scale;
    }
  }
}

/// Retorna o rótulo legível para um tipo de pergunta.
String questionTypeLabel(String tipo) {
  switch (tipo) {
    case 'sim_nao':
      return 'Sim / Não';
    case 'verdadeiro_falso':
      return 'Verdadeiro ou Falso';
    case 'multipla_escolha':
      return 'Múltipla Escolha';
    case 'texto':
      return 'Texto livre';
    default:
      return 'Escala (0 a 10)';
  }
}
