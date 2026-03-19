import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/checklist_item.dart';
import '../../../core/theme/app_colors.dart';
import 'checklist_photo.dart';

class ChecklistItemEditorPage extends StatefulWidget {
  const ChecklistItemEditorPage({
    super.key,
    required this.item,
    this.isNew = true,
  });

  final ChecklistItem item;
  final bool isNew;

  @override
  State<ChecklistItemEditorPage> createState() =>
      _ChecklistItemEditorPageState();
}

class _ChecklistItemEditorPageState extends State<ChecklistItemEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _photoUrl;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _photoUrl = widget.item.photoUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildPhotoPreview() {
    if (_photoBytes != null) {
      return Image.memory(
        _photoBytes!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    if (_photoUrl != null) {
      return ChecklistPhoto(photoUrl: _photoUrl!);
    }
    return const SizedBox.shrink();
  }

  bool get _hasPhoto => _photoBytes != null || _photoUrl != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Stap toevoegen' : 'Stap bewerken'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titel',
              border: OutlineInputBorder(),
            ),
            autofocus: widget.isNew,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Beschrijving (optioneel)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          if (_hasPhoto) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildPhotoPreview(),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton.filled(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() {
                      _photoUrl = null;
                      _photoBytes = null;
                    }),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.greyDark,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Foto (optioneel)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerij'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _save,
            icon: Icon(widget.isNew ? Icons.add : Icons.check),
            label: Text(widget.isNew ? 'Toevoegen' : 'Opslaan'),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titel is verplicht')),
      );
      return;
    }
    final updated = widget.item.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      photoUrl: () => _photoUrl,
    );
    Navigator.of(context).pop(updated);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (pickedFile != null && mounted) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoUrl = pickedFile.path;
      });
    }
  }
}
