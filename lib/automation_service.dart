import 'package:telephony/telephony.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app_state.dart';
import 'mpesa_parser.dart';

class AutomationService {
  static final AutomationService instance = AutomationService._init();
  final Telephony telephony = Telephony.instance;

  AutomationService._init();

  Future<void> initialize() async {
    // 1. Request Permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.contacts,
    ].request();

    if (statuses[Permission.sms]!.isGranted) {
      _startSmsListener();
      _backfillSms();
    }

    if (statuses[Permission.contacts]!.isGranted) {
      _syncContacts();
    }
  }

  // Listen for incoming M-Pesa SMS in real-time
  void _startSmsListener() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        if (message.address?.toUpperCase() == 'MPESA') {
          _processMessage(message.body ?? '');
        }
      },
      listenInBackground: true,
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  // Scan existing inbox for past transactions
  Future<void> _backfillSms() async {
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      filter: SmsFilter.where(SmsColumn.ADDRESS).equals('MPESA'),
    );

    for (var msg in messages) {
      _processMessage(msg.body ?? '');
    }
  }

  void _processMessage(String body) {
    final parsed = MpesaParser.parse(body);
    if (parsed != null) {
      // Check if we already have this transaction by M-Pesa ID
      final exists =
          appState.transactions.any((t) => t.mpesaId == parsed['id']);
      if (!exists) {
        appState.addTransaction(
          parsed['title'],
          parsed['amount'],
          parsed['category'],
          mpesaId: parsed['id'],
          note: 'Auto-captured from SMS',
        );
      }
    }
  }

  Future<void> _syncContacts() async {
    // This could be used to enrich transaction data
    // e.g. mapping a phone number in M-Pesa SMS to a contact name
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      print('Synced ${contacts.length} contacts for intelligent matching');
    }
  }
}

// Global background handler for telephony
@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) {
  // Parsing in background requires careful state management
  // For now, it will be processed when the app returns to foreground
  // or via the backfill method.
  print('Background SMS received from: ${message.address}');
}
