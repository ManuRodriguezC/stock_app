import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class ImageStorageService {
  static const String bucket = 'product-images';

  final SupabaseClient _supabase;

  ImageStorageService(this._supabase);

 
  Future<XFile?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    return picker.pickImage(source: source);
  }

  Future<String> uploadProductImage(XFile image,
      {required String userId}) async {
    final extension = _extensionOf(image);
    final contentType = _contentTypeOf(extension);

    final unique = DateTime.now().microsecondsSinceEpoch.toString();
    final fileName = '${unique}_${_randomSuffix()}.$extension';
    final path = 'products/$userId/$fileName';

    final bytes = await image.readAsBytes();

    await _supabase.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: false,
          ),
        );

    return path;
  }

  String getPublicUrl(String path) {
    return _supabase.storage
        .from(bucket)
        .getPublicUrl(path);
  }

  Future<void> deleteProductImage(String path) {
    return _supabase.storage.from(bucket).remove([path]);
  }

  String _extensionOf(XFile image) {
    final name = image.name.isNotEmpty ? image.name : image.path;
    final lastDot = name.lastIndexOf('.');
    if (lastDot == -1 || lastDot == name.length - 1) return 'jpg';

    final ext = name.substring(lastDot + 1).toLowerCase();
    const allowed = ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif', 'gif'];
    return allowed.contains(ext) ? ext : 'jpg';
  }

  String _contentTypeOf(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  String _randomSuffix() {
    final value = DateTime.now().microsecondsSinceEpoch.remainder(100000);
    return value.toString().padLeft(5, '0');
  }
}
