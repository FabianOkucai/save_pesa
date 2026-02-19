import 'app_state.dart';

class MpesaParser {
  // Pattern 1: Paid to Merchant (Lipa na M-Pesa)
  // Example: SAK5123456 Confirmed. Ksh500.00 paid to NAIVAS. 18/02/26 9:15 PM. ... Transaction cost, Ksh15.00.
  static final paidRegExp = RegExp(
    r'(?<id>[A-Z0-9]{10})\sConfirmed\.\sKsh(?<amount>[\d,]+\.\d{2})\spaid\sto\s(?<receiver>.*?)\.\son\s(?<date>.*?)\.\sNew\sM-PESA\sbalance\sis\sKsh(?<balance>[\d,]+\.\d{2})\.\sTransaction\scost,\sKsh(?<cost>[\d,]+\.\d{2})',
    caseSensitive: false,
  );

  // Pattern 2: Sent to Person
  // Example: SAK5123458 Confirmed. Ksh200.00 sent to JANE DOE 0711111222 on 18/2/26 at 11:00 AM.
  static final sentRegExp = RegExp(
    r'(?<id>[A-Z0-9]{10})\sConfirmed\.\sKsh(?<amount>[\d,]+\.\d{2})\ssent\sto\s(?<receiver>.*?)\son\s(?<date>.*?)at\s(?<time>.*?)\.\sNew\sM-PESA\sbalance',
    caseSensitive: false,
  );

  // Pattern 3: Received from Person
  // Example: SAK5123457 Confirmed. You have received Ksh1,000.00 from JOHN DOE 0712345678 on 18/2/26 at 10:00 AM.
  static final receivedRegExp = RegExp(
    r'(?<id>[A-Z0-9]{10})\sConfirmed\.\sYou\shave\sreceived\sKsh(?<amount>[\d,]+\.\d{2})\sfrom\s(?<sender>.*?)\son\s(?<date>.*?)at\s(?<time>.*?)\.\sNew\sM-PESA\sbalance',
    caseSensitive: false,
  );

  static Map<String, dynamic>? parse(String body) {
    // Clean body by removing newlines
    final cleanBody = body.replaceAll('\n', ' ').replaceAll('\r', ' ');

    // Check Received
    var match = receivedRegExp.firstMatch(cleanBody);
    if (match != null) {
      return {
        'id': match.namedGroup('id'),
        'amount': _parseAmount(match.namedGroup('amount')!),
        'title': 'Received from ${match.namedGroup('sender')}',
        'category': TxCategory.salary, // Default category for income
        'type': 'income',
      };
    }

    // Check Paid/Sent
    match =
        paidRegExp.firstMatch(cleanBody) ?? sentRegExp.firstMatch(cleanBody);
    if (match != null) {
      final receiver = match.namedGroup('receiver') ?? '';
      return {
        'id': match.namedGroup('id'),
        'amount': -_parseAmount(match.namedGroup('amount')!),
        'title': 'Paid to $receiver',
        'category': _guessCategory(receiver),
        'type': 'expense',
      };
    }

    return null;
  }

  static int _parseAmount(String val) {
    return (double.parse(val.replaceAll(',', ''))).round();
  }

  static TxCategory _guessCategory(String receiver) {
    receiver = receiver.toUpperCase();
    if (receiver.contains('NAIVAS') ||
        receiver.contains('QUICKMART') ||
        receiver.contains('CARREFOUR')) {
      return TxCategory.shopping;
    }
    if (receiver.contains('SHELL') ||
        receiver.contains('TOTAL') ||
        receiver.contains('RUBIS') ||
        receiver.contains('BOLT') ||
        receiver.contains('UBER')) {
      return TxCategory.transport;
    }
    if (receiver.contains('KFC') ||
        receiver.contains('JAVA') ||
        receiver.contains('CHICKEN INN')) {
      return TxCategory.food;
    }
    if (receiver.contains('HOSPITAL') || receiver.contains('PHARMACY')) {
      return TxCategory.health;
    }
    return TxCategory.other;
  }
}
