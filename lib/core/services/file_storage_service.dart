import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

abstract class FileStorageService {
  Future<String> saveFile(File file, String filename);
  Future<void> deleteFile(String filepath);
}

class FileStorageServiceImpl implements FileStorageService {
  @override
  Future<String> saveFile(File file, String filename) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileExtension = path.extension(file.path);

    final targetName = filename.isEmpty
        ? '${DateTime.now().millisecondsSinceEpoch}$fileExtension'
        : '$filename$fileExtension';

    final savedImage = await file.copy('${appDir.path}/$targetName');
    return savedImage.path;
  }

  @override
  Future<void> deleteFile(String filepath) async {
    final file = File(filepath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
