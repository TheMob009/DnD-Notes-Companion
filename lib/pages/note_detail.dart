import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'edit_note.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteTitle;
  final String noteDescription;
  final IconData noteIcon;
  final List<String> imagePaths;
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
  bool _isFavorite = false;
  late List<String> _imagePaths;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagePaths = List.from(widget.imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Volver",
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
            tooltip: "Tomar foto",
            icon: const Icon(Icons.camera_alt),
            onPressed: _takePhoto,
          ),
          IconButton(
            tooltip: "Compartir como PDF",
            icon: const Icon(Icons.ios_share),
            onPressed: _shareAsPdf,
          ),
          IconButton(
            tooltip: _isFavorite ? "Quitar de favoritos" : "Añadir a favoritos",
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite
                        ? "Añadido a Favoritos (mock)"
                        : "Eliminado de Favoritos (mock)",
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 20),
            const Text(
              "Imágenes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (_imagePaths.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _imagePaths
                    .map(
                      (path) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(path),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList(),
              )
            else
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: scheme.onSurfaceVariant,
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

  /// Permite tomar una foto con la cámara y añadirla a las imágenes de la nota.
  Future<void> _takePhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        setState(() {
          _imagePaths.add(picked.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto añadida correctamente")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al tomar foto: $e")),
      );
    }
  }

  /// Genera y comparte la nota como PDF.
  Future<void> _shareAsPdf() async {
    try {
      final doc = pw.Document();

      final imageWidgets = <pw.Widget>[];
      for (final path in _imagePaths) {
        final f = File(path);
        if (await f.exists()) {
          final bytes = await f.readAsBytes();
          imageWidgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.Image(pw.MemoryImage(bytes),
                    fit: pw.BoxFit.cover, width: double.infinity),
              ),
            ),
          );
        }
      }

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Text(widget.noteTitle,
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Text(widget.noteDescription),
            if (imageWidgets.isNotEmpty) pw.SizedBox(height: 16),
            if (imageWidgets.isNotEmpty)
              pw.Text('Imágenes:',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
            if (imageWidgets.isNotEmpty) pw.SizedBox(height: 8),
            ...imageWidgets,
          ],
        ),
      );

      final bytes = await doc.save();
      await Printing.sharePdf(
          bytes: bytes, filename: "${widget.noteTitle}.pdf");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo generar el PDF: $e')),
      );
    }
  }

  Widget _buildLinkedDescription(BuildContext context) {
    if (widget.allNotes.isEmpty) {
      return Text(widget.noteDescription,
          style: Theme.of(context).textTheme.bodyLarge);
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
        if (idx >= 0 && _hasWordBoundaries(lower, idx, idx + title.length)) {
          if (earliestIdx == -1 || idx < earliestIdx) {
            earliestIdx = idx;
            matchedTitle = title;
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

      spans.add(TextSpan(
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
      ));

      pos = earliestIdx + matchedTitle.length;
    }

    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }

  bool _hasWordBoundaries(String s, int start, int end) {
    bool isAlphaNum(String ch) =>
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
              title: const Text("Eliminar",
                  style: TextStyle(color: Colors.red)),
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
