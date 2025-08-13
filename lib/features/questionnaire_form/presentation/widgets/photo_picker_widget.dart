import 'dart:io'
    if (dart.library.html) 'package:treatment_center/core/providers/file_stub.dart'
    as io;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';

class PhotoPickerWidget extends StatefulWidget {
  final List<PhotoEntity> photos;
  final Function(List<PhotoEntity>) onPhotosChanged;
  final int maxPhotos;

  const PhotoPickerWidget({
    super.key,
    required this.photos,
    required this.onPhotosChanged,
    this.maxPhotos = 10,
  });

  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _showPhotoSourceDialog() async {
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Photo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _PhotoSourceOption(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Use camera to take a new photo',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),
                _PhotoSourceOption(
                  icon: Icons.photo_library,
                  title: 'Choose from Gallery',
                  subtitle: 'Select from photo gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
    );
  }

  Future<void> _takePhoto(ImageSource source) async {
    // try {
    //   final XFile? file = await _picker.pickImage(
    //     source: source,
    //     maxWidth: 1920,
    //     maxHeight: 1920,
    //     imageQuality: 85,
    //   );
    try {
      // ─── WEB + CAMERA PLUGIN ───────────────────────────────────────────
      if (kIsWeb && source == ImageSource.camera) {
        final XFile? file = await _captureWithWebCamera();
        if (file == null) return;
        await _addPickedFile(file, PhotoSource.camera);
        return;
      }

      // ─── EVERYWHERE ELSE – keep using image_picker ─────────────────────
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      // if (file != null) {
      //   final fileStats = await File(file.path).stat();
      if (file != null) {
        await _addPickedFile(
          file,
          source == ImageSource.camera
              ? PhotoSource.camera
              : PhotoSource.gallery,
        );
        // ─── file-size calculation works differently on Web ──────────
        // final int sizeBytes;
        // if (kIsWeb) {
        //   final Uint8List bytes = await file.readAsBytes();
        //   sizeBytes = bytes.length;
        // } else {
        //   final fileStats = await io.File(file.path).stat();
        //   sizeBytes = fileStats.size;
        // }
        // final photoEntity = PhotoEntity(
        //   id: DateTime.now().millisecondsSinceEpoch.toString(),
        //   fileName: path.basename(file.path),
        //   filePath: file.path,
        //   source:
        //       source == ImageSource.camera
        //           ? PhotoSource.camera
        //           : PhotoSource.gallery,
        //   // fileSizeBytes: fileStats.size,
        //   fileSizeBytes: sizeBytes,

        //   capturedAt: DateTime.now(),
        // );

        // final updatedPhotos = [...widget.photos, photoEntity];
        // widget.onPhotosChanged(updatedPhotos);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to capture photo: ${e.toString()}');
      }
    }
  }

  Future<XFile?> _captureWithWebCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return null;
      if (cameras.isEmpty) {
        _showErrorDialog('No camera available on this device.');
        return null;
      }

      // We push a new screen that hosts the live preview and
      // returns an `XFile` once the user presses the shutter button.
      return await Navigator.of(context).push<XFile>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => _WebCameraScreen(cameraDescription: cameras.first),
        ),
      );
    } catch (e) {
      _showErrorDialog('Unable to open camera: $e');
      return null;
    }
  }

  /// Common helper that turns an `XFile` into your `PhotoEntity`
  /// (works on every platform because we already have the Web stub above).
  Future<void> _addPickedFile(XFile file, PhotoSource src) async {
    final sizeBytes =
        kIsWeb
            ? (await file.readAsBytes()).length
            : (await io.File(file.path).stat()).size;

    final photo = PhotoEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: path.basename(file.path),
      filePath: file.path,
      source: src,
      fileSizeBytes: sizeBytes,
      capturedAt: DateTime.now(),
    );

    widget.onPhotosChanged([...widget.photos, photo]);
  }

  void _removePhoto(int index) {
    final updatedPhotos = [...widget.photos];
    updatedPhotos.removeAt(index);
    widget.onPhotosChanged(updatedPhotos);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showPhotoPreview(PhotoEntity photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PhotoPreviewScreen(photo: photo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAddMore = widget.photos.length < widget.maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Facility Photos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            if (canAddMore)
              OutlinedButton.icon(
                onPressed: _showPhotoSourceDialog,
                icon: const Icon(Icons.add_a_photo, size: 18),
                label: const Text('Add Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (widget.photos.isEmpty)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
            ),
            child: InkWell(
              onTap: canAddMore ? _showPhotoSourceDialog : null,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add facility photos',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Take photos or choose from gallery',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...widget.photos.asMap().entries.map((entry) {
                final index = entry.key;
                final photo = entry.value;
                return _PhotoThumbnail(
                  photo: photo,
                  onTap: () => _showPhotoPreview(photo),
                  onRemove: () => _removePhoto(index),
                );
              }),
              if (canAddMore) _AddPhotoButton(onTap: _showPhotoSourceDialog),
            ],
          ),

        if (widget.photos.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${widget.photos.length}/${widget.maxPhotos} photos',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _PhotoSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PhotoSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final PhotoEntity photo;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PhotoThumbnail({
    required this.photo,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child:
                    kIsWeb
                        ? Image.network(
                          photo.filePath,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, _, _) => const Icon(Icons.broken_image),
                        )
                        : Image.file(
                          io.File(photo.filePath) as dynamic,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, _, _) => const Icon(Icons.broken_image),
                        ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: theme.colorScheme.onError,
                  ),
                ),
              ),
            ),
            if (photo.source == PhotoSource.camera)
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
          color: theme.colorScheme.surface,
        ),
        child: Icon(
          Icons.add_a_photo,
          color: theme.colorScheme.onSurfaceVariant,
          size: 32,
        ),
      ),
    );
  }
}

class _PhotoPreviewScreen extends StatelessWidget {
  final PhotoEntity photo;

  const _PhotoPreviewScreen({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(photo.fileName),
      ),
      body: Center(
        child: InteractiveViewer(
          child:
              kIsWeb
                  ? Image.network(photo.filePath, fit: BoxFit.contain)
                  : Image.file(
                    io.File(photo.filePath) as dynamic,
                    fit: BoxFit.contain,
                  ),
        ),
      ),
    );
  }
}

class _WebCameraScreen extends StatefulWidget {
  const _WebCameraScreen({required this.cameraDescription});
  final CameraDescription cameraDescription;

  @override
  State<_WebCameraScreen> createState() => _WebCameraScreenState();
}

class _WebCameraScreenState extends State<_WebCameraScreen> {
  late CameraController _ctrl;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _ctrl = CameraController(
        widget.cameraDescription,
        ResolutionPreset.medium,
        enableAudio: false,
      )
      ..initialize().then((_) {
        if (mounted) setState(() => _initialised = true);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialised) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: CameraPreview(_ctrl)),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: IconButton(
              iconSize: 64,
              color: Colors.white,
              icon: const Icon(Icons.camera),
              onPressed: () async {
                final file = await _ctrl.takePicture();
                if (!mounted) return;
                if (!context.mounted) return;
                Navigator.of(context).pop<XFile>(file);
              },
            ),
          ),
        ],
      ),
    );
  }
}
