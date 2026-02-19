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
      final amount = _parseAmount(match.namedGroup('amount')!);
      return {
        'id': match.namedGroup('id'),
        'amount': -amount,
        'title': 'Paid to $receiver',
        'category': _guessCategory(receiver, -amount),
        'type': 'expense',
      };
    }

    return null;
  }

  static int _parseAmount(String val) {
    try {
      return (double.tryParse(val.replaceAll(',', '')) ?? 0.0).round();
    } catch (_) {
      return 0;
    }
  }

  static TxCategory _guessCategory(String receiver, int amount) {
    receiver = receiver.toUpperCase();
    final absAmount = amount.abs();

    // Amount based guessing for small transactions (1-250 KES)
    if (absAmount > 0 && absAmount <= 250) {
      if (receiver.contains('SAFARICON') || receiver.contains('AIRTIME')) {
        return TxCategory
            .entertainment; // Using entertainment as a proxy for airtime/small digital spends
      }
      return TxCategory.food;
    }

    if (receiver.contains('NAIVAS') ||
        receiver.contains('QUICKMART') ||
        receiver.contains('CARREFOUR') ||
        receiver.contains('CHANDARANA') ||
        receiver.contains('TUSKYS')) {
      return TxCategory.shopping;
    }
    if (receiver.contains('SHELL') ||
        receiver.contains('TOTAL') ||
        receiver.contains('RUBIS') ||
        receiver.contains('BOLT') ||
        receiver.contains('UBER') ||
        receiver.contains('MATATU') ||
        receiver.contains('PSV')) {
      return TxCategory.transport;
    }
    if (receiver.contains('KFC') ||
        receiver.contains('JAVA') ||
        receiver.contains('CHICKEN INN') ||
        receiver.contains('PIZZA INN') ||
        receiver.contains('GALITOS')) {
      return TxCategory.food;
    }
    if (receiver.contains('HOSPITAL') ||
        receiver.contains('PHARMACY') ||
        receiver.contains('CLINIC')) {
      return TxCategory.health;
    }
    if (receiver.contains('NETFLIX') ||
        receiver.contains('SPOTIFY') ||
        receiver.contains('SHOWMAX')) {
      return TxCategory.entertainment;
    }
    return TxCategory.other;
  }
}
