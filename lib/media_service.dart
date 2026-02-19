import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'app_state.dart';
import 'dart:convert';
import 'dart:io' show File;

class MediaService {
  static final MediaService instance = MediaService._init();
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  MediaService._init();

  Future<Map<String, dynamic>?> scanReceipt() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image == null) return null;

      if (kIsWeb) {
        // ML Kit text recognition is not supported on Web in this package
        return {
          'title': 'Manual Receipt',
          'amount': 0,
          'category': TxCategory.shopping,
          'note': 'OCR is only supported on Android/iOS devices.',
        };
      }

      final inputImage = InputImage.fromFile(File(image.path));
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      return _parseReceipt(recognizedText.text);
    } catch (e) {
      debugPrint('Error scanning receipt: $e');
      return null;
    }
  }

  Future<String?> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image == null) return null;

      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error picking profile image: $e');
      return null;
    }
  }

  Map<String, dynamic>? _parseReceipt(String text) {
    // Simple logic to find the total amount in a receipt
    // Usually receipts have words like "TOTAL", "TOTAL DUE", "AMOUNT PAID"
    final lines = text.split('\n');
    int? amount;
    String? merchant;

    merchant = lines.first; // Guessing the first line is the merchant name

    final amountRegex = RegExp(
        r'(TOTAL|AMOUNT|KSH|CASH)[\s:]*(?<amount>[\d,]+\.?\d{0,2})',
        caseSensitive: false);

    for (var line in lines) {
      final match = amountRegex.firstMatch(line.toUpperCase());
      if (match != null) {
        final val = match.namedGroup('amount')?.replaceAll(',', '');
        if (val != null) {
          amount = double.tryParse(val)?.round();
          if (amount != null) break;
        }
      }
    }

    if (amount != null) {
      return {
        'title': 'Receipt at $merchant',
        'amount': -amount,
        'category': TxCategory.shopping,
        'note': 'Auto-captured from camera',
      };
    }
    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
