import 'package:storage_space/storage_space.dart';

class StorageService {
  Future<StorageSpace> getStorageDetails() async {
    try {
      // We still pass a threshold because the plugin requires it, 
      // but we will ignore the plugin's 'lowOnSpace' result.
      return await getStorageSpace(
        lowOnSpaceThreshold: 2 * 1024 * 1024 * 1024, 
        fractionDigits: 0,
      );
    } catch (e) {
      throw Exception("Failed to get storage");
    }
  }
}