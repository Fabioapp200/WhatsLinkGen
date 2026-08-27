import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat_history_preferences.dart';
import 'theme_model.dart';

void main() {
  runApp(const WhatsLinkGen());
}

class WhatsLinkGen extends StatelessWidget {
  const WhatsLinkGen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'WhatsLink Generator',
            theme: ThemeData(
              brightness: themeNotifier.isDark
                  ? Brightness.dark
                  : Brightness.light,
              primarySwatch: Colors.green,
            ),
            debugShowCheckedModeBanner: false,
            home: const MainInterface(),
          );
        },
      ),
    );
  }
}

Uri _chatUrl(String phoneNumber) {
  final normalizedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
  return Uri.https('api.whatsapp.com', '/send', {'phone': normalizedNumber});
}

Future<void> _launchChat(String phoneNumber) async {
  final url = _chatUrl(phoneNumber);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

class MainInterface extends StatefulWidget {
  const MainInterface({super.key});

  @override
  State<MainInterface> createState() => _MainInterfaceState();
}

class _MainInterfaceState extends State<MainInterface> {
  final _historyPreferences = ChatHistoryPreferences();
  var _phoneNumber = '';
  var _history = <String>[];
  var _isLaunching = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _historyPreferences.load();
    if (mounted) {
      setState(() => _history = history);
    }
  }

  Future<void> _startChat(String phoneNumber) async {
    if (phoneNumber.replaceAll(RegExp(r'\D'), '').isEmpty || _isLaunching) {
      return;
    }

    setState(() => _isLaunching = true);
    try {
      await _launchChat(phoneNumber);
      final history = await _historyPreferences.add(phoneNumber);
      if (mounted) {
        setState(() => _history = history);
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLaunching = false);
      }
    }
  }

  Future<void> _removeFromHistory(String phoneNumber) async {
    final history = await _historyPreferences.remove(phoneNumber);
    if (mounted) {
      setState(() => _history = history);
    }
  }

  Future<void> _copyChatUrl() async {
    if (_phoneNumber.replaceAll(RegExp(r'\D'), '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a phone number first.')),
      );
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: _chatUrl(_phoneNumber).toString()),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat URL copied to clipboard.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('WhatsLink Generator'),
            actions: [
              IconButton(
                icon: Icon(
                  themeNotifier.isDark ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: () {
                  themeNotifier.isDark
                      ? themeNotifier.isDark = false
                      : themeNotifier.isDark = true;
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                IntlPhoneField(
                  initialCountryCode: "BR",
                  onChanged: (phone) {
                    _phoneNumber = phone.completeNumber;
                  },
                  disableLengthCheck: true,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    hintText: "12 3 4567-8910",
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _copyChatUrl,
                        child: Text('Copy to clipboard'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLaunching
                            ? null
                            : () => _startChat(_phoneNumber),
                        child: Text(
                          _isLaunching
                              ? 'Opening WhatsApp...'
                              : 'Start Chatting!',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Recent chats',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text('${_history.length}/20'),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: _history.isEmpty
                      ? const Center(
                          child: Text('Started chats will appear here.'),
                        )
                      : ListView.separated(
                          itemCount: _history.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final phoneNumber = _history[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.chat_outlined),
                              title: Text(phoneNumber),
                              onTap: _isLaunching
                                  ? null
                                  : () => _startChat(phoneNumber),
                              trailing: IconButton(
                                tooltip: 'Remove from history',
                                onPressed: () =>
                                    _removeFromHistory(phoneNumber),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
