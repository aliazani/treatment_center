import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path/path.dart' as p;
import 'package:treatment_center/core/providers/save_path_resolver.dart';

void main() {
  const fileName = 'test.txt';
  const mimeType = 'text/plain';
  late Directory tempDir;
  late String exportDir;

  setUp(() {
    // Create a temp directory and override path provider

    tempDir = Directory.systemTemp.createTempSync();
    exportDir = p.join(tempDir.path, 'FVD_Assessments');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);

    // Mock getApplicationDocumentsDirectory to return our temp directory
    // when(
    // mockPathProvider.getApplicationDocumentsPath(),
    // ).thenAnswer((_) async => tempDir.path);
  });

  tearDown(() {
    // Clean up
    tempDir.deleteSync(recursive: true);
  });

  group('defaultSavePath (non-web)', () {
    test('creates directory and returns correct path', () async {
      final result = await defaultSavePath(
        fileName: fileName,
        mimeType: mimeType,
      );

      expect(result, equals(p.join(exportDir, fileName)));
      expect(Directory(exportDir).existsSync(), isTrue);
    });

    test('returns path when directory already exists', () async {
      Directory(exportDir).createSync(recursive: true);

      final result = await defaultSavePath(
        fileName: fileName,
        mimeType: mimeType,
      );

      expect(result, equals(p.join(exportDir, fileName)));
      expect(Directory(exportDir).existsSync(), isTrue);
    });
  });

  group('defaultSavePath (web)', () {
    FilePicker? originalPlatform;

    setUp(() {
      if (kIsWeb) {
        originalPlatform = FilePicker.platform;
      }
    });

    tearDown(() {
      if (kIsWeb && originalPlatform != null) {
        FilePicker.platform = originalPlatform!;
      }
    });

    test('returns selected path when user picks a path', () async {
      // Skip if not running web tests
      if (!kIsWeb) return;

      FilePicker.platform = FakeFilePickerPlatform(
        returnPath: '/foo/bar/$fileName',
      );

      final result = await defaultSavePath(
        fileName: fileName,
        mimeType: mimeType,
      );

      expect(result, equals('/foo/bar/$fileName'));
    });

    test('throws when user cancels without bytes', () async {
      // Skip if not running web tests
      if (!kIsWeb) return;

      FilePicker.platform = FakeFilePickerPlatform(returnPath: null);

      expect(
        () => defaultSavePath(fileName: fileName, mimeType: mimeType),
        throwsException,
      );
    });

    test('returns download URI when user cancels with bytes', () async {
      // Skip if not running web tests
      if (!kIsWeb) return;

      final fakeBytes = Uint8List.fromList([1, 2, 3]);
      FilePicker.platform = FakeFilePickerPlatform(returnPath: null);

      final result = await defaultSavePath(
        fileName: fileName,
        mimeType: mimeType,
        bytes: fakeBytes,
      );

      expect(result, equals('download:$fileName'));
    });
  });
}

// Fake FilePicker platform for testing
class FakeFilePickerPlatform extends FilePicker {
  final String? returnPath;

  FakeFilePickerPlatform({this.returnPath});

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    return returnPath;
  }

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return null;
  }

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async {
    return null;
  }
}

class FakePathProviderPlatform extends PathProviderPlatform {
  final String documentsPath;

  FakePathProviderPlatform(this.documentsPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;
}
