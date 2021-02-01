import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'dart:math';
import 'dart:developer' as DEVELOPER;


class EncryptKeyFromKeystore {
  static String encryptionKey;

  Future<void> generateEncryptionKey() async {
    final _storage = FlutterSecureStorage();

    // await _storage.delete(key: 'encryptionKey');
    encryptionKey = await _storage.read(key: 'encryptionKey');
    if (encryptionKey == null) {
      encryptionKey = await randomKeyGenerator();
      await _storage.write(key: 'encryptionKey', value: encryptionKey);
      encryptionKey = await _storage.read(key: 'encryptionKey');
    }
    // DEVELOPER.log(encryptionKey);
  }

  Future<String> randomKeyGenerator() async {
    // final rand = Random();
    // final codeUnits = List.generate(20, (index) {
    //   return rand.nextInt(26) + 65;
    // });
    //
    // return String.fromCharCodes(codeUnits);

    final cryptor = new PlatformStringCryptor();
    String key = await cryptor.generateRandomKey();
    return key;
  }


}
