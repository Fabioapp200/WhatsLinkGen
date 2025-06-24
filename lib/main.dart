import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme_model.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const WhatsLinkGen());
}

String currPhoneNumber = "";

class WhatsLinkGen extends StatelessWidget {
  const WhatsLinkGen({Key? key}) : super(key: key);

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

Future<void> _launchURL() async {
  final Uri _url = Uri.parse("https://api.whatsapp.com/send?phone=${currPhoneNumber.substring(1)}");
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

class MainInterface extends StatefulWidget {
  const MainInterface({Key? key}) : super(key: key);

  @override
  State<MainInterface> createState() => _MainInterfaceState();
}

class _MainInterfaceState extends State<MainInterface> {
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                IntlPhoneField(
                  initialCountryCode: "BR",
                  onChanged: (phone) {
                    currPhoneNumber = phone.completeNumber;
                  },
                  disableLengthCheck: true,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    hintText: "12 3 4567-8910",
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text:
                                "https://api.whatsapp.com/send?phone=${currPhoneNumber.substring(1)}",
                          ),
                        );
                        // copied successfully
                      },
                      child: Text("Clipboard"),
                    ),
                    ElevatedButton(
                      onPressed: _launchURL,
                      child: const Text('Start Chatting!'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
