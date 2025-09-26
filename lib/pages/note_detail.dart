import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'edit_note.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteTitle;
  final String noteDescription;
  final IconData noteIcon;
  final List<String> imagePaths;

  /// Lista de todas las notas para reconocer vínculos en la descripción
  final List<Map<String, dynamic>> allNotes;

  const NoteDetailPage({
    super.key,
    required this.noteTitle,
    required this.noteDescription,
    this.noteIcon = Icons.note,
    this.imagePaths = const [],
    this.allNotes = const [],
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  bool _isFavorite = false; // 👈 mock favorito

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(widget.noteIcon, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.noteTitle, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isFavorite ? "Quitar de favoritos" : "Añadir a favoritos",
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite
                      ? "Añadido a Favoritos (mock)"
                      : "Eliminado de Favoritos (mock)"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de descripción
            SizedBox(
              width: double.infinity,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 150),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Descripción:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildLinkedDescription(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título Imágenes
            const Text(
              "Imágenes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            // Galería o mensaje vacío
            if (widget.imagePaths.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.imagePaths
                    .map((path) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(path),
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          ),
                        ))
                    .toList(),
              )
            else
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "No hay imágenes",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Opciones",
        child: const Icon(Icons.more_vert),
        onPressed: () => _showOptions(context),
      ),
    );
  }

  /// Construye la descripción convirtiendo los títulos de otras notas en enlaces.
  Widget _buildLinkedDescription(BuildContext context) {
    if (widget.allNotes.isEmpty) {
      return Text(
        widget.noteDescription,
        style: Theme.of(context).textTheme.bodyLarge,
      );
    }

    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    final linkStyle = baseStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    final titles = widget.allNotes
        .map((n) => n["title"] as String)
        .where((t) => t.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    final text = widget.noteDescription;
    final lower = text.toLowerCase();

    int pos = 0;
    final spans = <TextSpan>[];

    while (pos < text.length) {
      int earliestIdx = -1;
      String? matchedTitle;
      Map<String, dynamic>? matchedNote;

      for (final title in titles) {
        final idx = lower.indexOf(title.toLowerCase(), pos);
        if (idx >= 0) {
          if (_hasWordBoundaries(lower, idx, idx + title.length)) {
            if (earliestIdx == -1 || idx < earliestIdx) {
              earliestIdx = idx;
              matchedTitle = title;
            }
          }
        }
      }

      if (earliestIdx == -1 || matchedTitle == null) {
        spans.add(TextSpan(text: text.substring(pos)));
        break;
      }

      if (earliestIdx > pos) {
        spans.add(TextSpan(text: text.substring(pos, earliestIdx)));
      }

      matchedNote = widget.allNotes.firstWhere(
        (n) => (n["title"] as String).toLowerCase() == matchedTitle!.toLowerCase(),
        orElse: () => {},
      );
      if (matchedNote.isEmpty) {
        spans.add(TextSpan(text: matchedTitle));
        pos = earliestIdx + matchedTitle.length;
        continue;
      }

      spans.add(
        TextSpan(
          text: matchedTitle,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailPage(
                    noteTitle: matchedNote!["title"] as String,
                    noteDescription: matchedNote["description"] as String,
                    noteIcon: matchedNote["icon"] as IconData,
                    allNotes: widget.allNotes,
                  ),
                ),
              );
            },
        ),
      );

      pos = earliestIdx + matchedTitle.length;
    }

    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }

  // Funcion que evita encontrar titulos dentro de una palabra.
  // Ej: Encontrar el titulo "Nos" dentro de la palabra "Nosotros"
  bool _hasWordBoundaries(String s, int start, int end) {
    bool isAlphaNum(String ch) =>
        // Se crea una expresion regular que permite identificar los siguientes caracteres.
        RegExp(r'[0-9A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').hasMatch(ch);

    final beforeOk = start == 0 || !isAlphaNum(s[start - 1]);
    final afterOk = end >= s.length || !isAlphaNum(s[end]);
    return beforeOk && afterOk;
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Editar"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNotePage(
                      noteTitle: widget.noteTitle,
                      noteContent: widget.noteDescription,
                      noteCategory: "Historia/Sesión",
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Eliminar", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar nota?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Nota eliminada (mock)")),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}
