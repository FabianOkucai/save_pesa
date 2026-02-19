import 'package:telephony/telephony.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app_state.dart';
import 'mpesa_parser.dart';
import 'models/notification.dart';

class AutomationService {
  static final AutomationService instance = AutomationService._init();
  final Telephony telephony = Telephony.instance;

  AutomationService._init();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      print('AutomationService: Requesting permissions...');
      Map<Permission, PermissionStatus> statuses = await [
        Permission.sms,
        Permission.contacts,
      ].request();

      if (statuses[Permission.sms]?.isGranted ?? false) {
        _startSmsListener();
        // Give the UI time to load before doing heavy history scan
        Future.delayed(const Duration(seconds: 3), () => _backfillSms());
      }

      if (statuses[Permission.contacts]?.isGranted ?? false) {
        _syncContacts();
      }
    } catch (e) {
      print('AutomationService: Error during initialize: $e');
    }
  }

  // Listen for incoming M-Pesa SMS in real-time
  void _startSmsListener() {
    try {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          print('AutomationService: New SMS from ${message.address}');
          if (message.address?.toUpperCase() == 'MPESA') {
            _processMessage(message.body ?? '');
          }
        },
        listenInBackground: true,
        onBackgroundMessage: backgroundMessageHandler,
      );
    } catch (e) {
      print('AutomationService: Error starting SMS listener: $e');
    }
  }

  // Scan existing inbox for past transactions
  Future<void> _backfillSms() async {
    try {
      List<SmsMessage> messages = await telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.ADDRESS).equals('MPESA'),
      );
      print(
          'AutomationService: Found ${messages.length} M-Pesa messages in inbox');

      List<TransactionItem> batch = [];
      final existingIds = appState.transactions.map((t) => t.mpesaId).toSet();

      for (var msg in messages) {
        final parsed = MpesaParser.parse(msg.body ?? '');
        if (parsed != null && !existingIds.contains(parsed['id'])) {
          final tx = TransactionItem(
            id: parsed['id'],
            title: parsed['title'],
            amount: parsed['amount'],
            date: DateTime.fromMillisecondsSinceEpoch(msg.date ?? 0),
            category: parsed['category'],
            note: 'Auto-captured from SMS history',
            mpesaId: parsed['id'],
          );
          batch.add(tx);
        }
      }

      if (batch.isNotEmpty) {
        print(
            'AutomationService: Adding batch of ${batch.length} new transactions');
        await appState.addTransactionsBatch(batch);
      }
    } catch (e) {
      print('AutomationService: Error during backfill: $e');
    }
  }

  void _processMessage(String body) {
    try {
      final parsed = MpesaParser.parse(body);
      if (parsed != null) {
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
          appState.addNotification(
            parsed['amount'] > 0 ? '💰 Income Received' : '💸 M-Pesa Payment',
            '${parsed['title']}: ${appState.currency} ${parsed['amount'].abs()}',
            NotificationType.transaction,
          );
        }
      }
    } catch (e) {
      print('AutomationService: Error processing message: $e');
    }
  }

  Future<void> _syncContacts() async {
    try {
      // Use shorter version to just get count first to test
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: false);
      print(
          'AutomationService: Synced ${contacts.length} contacts (no properties)');
    } catch (e) {
      print('AutomationService: Error syncing contacts: $e');
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
