import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Main App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. MÀN HÌNH CHÍNH (Main App)
// -----------------------------------------------------------------------------
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to the Main App!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SmsReaderScreen(),
                  ),
                );
              },
              child: const Text('Go to SMS Reader App'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactsReaderScreen(),
                  ),
                );
              },
              child: const Text('Go to contacts Reader App'),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. MÀN HÌNH ĐỌC TIN NHẮN (SMS Reader)
// -----------------------------------------------------------------------------
class SmsReaderScreen extends StatefulWidget {
  const SmsReaderScreen({super.key});

  @override
  State<SmsReaderScreen> createState() => _SmsReaderScreenState();
}

class _SmsReaderScreenState extends State<SmsReaderScreen> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _getSmsMessages();
  }

  Future<void> _getSmsMessages() async {
    var status = await Permission.sms.request();
    if (status.isGranted) {
      final messages = await _query.getAllSms;
      setState(() {
        _messages = messages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Reader')),
      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final sms = _messages[index];
          return ListTile(
            title: Text(
              sms.body ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Từ: ${sms.address}',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. MÀN HÌNH ĐỌC DANH BẠ (Contacts Reader)
// -----------------------------------------------------------------------------
class ContactsReaderScreen extends StatefulWidget {
  const ContactsReaderScreen({super.key});

  @override
  State<ContactsReaderScreen> createState() => _ContactsReaderScreenState();
}

class _ContactsReaderScreenState extends State<ContactsReaderScreen> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  Future<void> _getContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
      );
      setState(() {
        _contacts = contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts Reader')),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          final phone = contact.phones.isNotEmpty
              ? contact.phones.first.number
              : '';
          return ListTile(
            title: Text(
              contact.displayName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(phone, style: const TextStyle(color: Colors.grey)),
          );
        },
      ),
    );
  }
}
