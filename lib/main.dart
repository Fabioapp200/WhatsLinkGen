import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const WhatsappLinkGen());
}

class WhatsappLinkGen extends StatelessWidget {
  const WhatsappLinkGen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainInterface(),
    );
  }
}

var currPhoneNumber = "";

class MainInterface extends StatelessWidget {
  const MainInterface({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Whatsapp Link Generator'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.more_vert),
        //     onPressed: () {},
        //   )
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                IntlPhoneField(
                  initialCountryCode: "BR",
                  onChanged: (phone) {
                    currPhoneNumber = phone.completeNumber;
                  },
                  disableLengthCheck: true,
                  decoration: InputDecoration(
                      labelText: "Phone Number", hintText: "12 3 4567-8910"),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _launchURL();
                    },
                    child: Text('Open chat on Whatsapp'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _launchURL() async {
  var _url =
      "https://api.whatsapp.com/send?phone=" + currPhoneNumber.substring(1);
  if (!await launch(_url)) throw 'Could not launch $_url';
}
