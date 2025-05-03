import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyKey = 'encryption_key';
  static encrypt.Encrypter? _encrypter;

  // Initialize the encryption key
  static Future<void> init() async {
    String? keyString = await _storage.read(key: _keyKey);
    if (keyString == null) {
      // Generate a new key if none exists
      final key = encrypt.Key.fromSecureRandom(32); // AES-256 requires a 32-byte key
      keyString = base64UrlEncode(key.bytes);
      await _storage.write(key: _keyKey, value: keyString);
    }

    final key = encrypt.Key.fromBase64(keyString);
    final iv = encrypt.IV.fromLength(16); // AES requires a 16-byte IV
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  // Encrypt data
  static String encryptData(String data) {
    if (_encrypter == null) throw Exception('EncryptionService not initialized');
    final iv = encrypt.IV.fromLength(16);
    return _encrypter!.encrypt(data, iv: iv).base64;
  }

  // Decrypt data
  static String decryptData(String encryptedData) {
    if (_encrypter == null) throw Exception('EncryptionService not initialized');
    final iv = encrypt.IV.fromLength(16);
    return _encrypter!.decrypt64(encryptedData, iv: iv);
  }
}