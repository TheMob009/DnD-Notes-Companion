import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  final String developerEmail;

  const FeedbackPage({super.key, required this.developerEmail});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  late Future<List<Question>> _futureQuestions;
  final Map<String, dynamic> _answers = {}; // id -> value

  @override
  void initState() {
    super.initState();
    _futureQuestions = _loadQuestions();
  }

  Future<List<Question>> _loadQuestions() async {
    final raw = await rootBundle.loadString('assets/questions.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> list = data['questions'] as List<dynamic>;
    return list.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tu opinión')),
      body: FutureBuilder<List<Question>>(
        future: _futureQuestions,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error al cargar preguntas: ${snap.error}'));
          }
          final questions = snap.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '¡Gracias por ayudarnos a mejorar!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Puedes dejar tu identificación si quieres que te contactemos.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Identificación
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tu nombre (opcional)',
                          prefixIcon: Icon(Icons.badge),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Tu correo (opcional)',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preguntas
              ...questions.map((q) => _buildQuestionCard(q, cs)),

              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Enviar por correo'),
                onPressed: () => _sendByEmail(questions),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(Question q, ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (q.type == QuestionType.rating)
              _RatingRow(
                min: q.min ?? 1,
                max: q.max ?? 5,
                value: (_answers[q.id] as int?) ?? 0,
                onChanged: (v) => setState(() => _answers[q.id] = v),
              )
            else
              TextField(
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu respuesta...',
                ),
                onChanged: (v) => _answers[q.id] = v,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendByEmail(List<Question> questions) async {
    // Construir cuerpo del correo
    final b = StringBuffer();
    if (_nameCtrl.text.trim().isNotEmpty) {
      b.writeln('Nombre: ${_nameCtrl.text.trim()}');
    }
    if (_emailCtrl.text.trim().isNotEmpty) {
      b.writeln('Correo: ${_emailCtrl.text.trim()}');
    }
    if (_nameCtrl.text.trim().isNotEmpty || _emailCtrl.text.trim().isNotEmpty) {
      b.writeln('');
    }
    b.writeln('Respuestas:');
    for (final q in questions) {
      final v = _answers[q.id];
      final valueStr = v == null || (v is String && v.trim().isEmpty)
          ? '(sin respuesta)'
          : v.toString();
      b.writeln('• ${q.title}');
      b.writeln('   → $valueStr');
    }

    final subject = 'Feedback DnD Notes Companion';
    final body = b.toString();

    final uri = Uri(
      scheme: 'mailto',
      path: widget.developerEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    if (!await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el correo.')),
      );
    }
  }
}

enum QuestionType { rating, text }

class Question {
  final String id;
  final QuestionType type;
  final String title;
  final int? min;
  final int? max;

  Question({
    required this.id,
    required this.type,
    required this.title,
    this.min,
    this.max,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final t = (json['type'] as String).toLowerCase().trim();
    return Question(
      id: json['id'] as String,
      type: t == 'rating' ? QuestionType.rating : QuestionType.text,
      title: json['title'] as String,
      min: json['min'] as int?,
      max: json['max'] as int?,
    );
  }
}

/// Fila de rating simple 1..5 (o el rango que venga)
class _RatingRow extends StatelessWidget {
  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;

  const _RatingRow({
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      children: List.generate(max - min + 1, (i) {
        final v = min + i;
        final selected = v == value;
        return ChoiceChip(
          label: Text('$v'),
          selected: selected,
          onSelected: (_) => onChanged(v),
          selectedColor: cs.primaryContainer,
        );
      }),
    );
  }
}
