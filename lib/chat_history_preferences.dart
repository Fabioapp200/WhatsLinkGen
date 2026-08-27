import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryPreferences {
  static const _historyKey = 'started_chat_numbers';
  static const _maximumEntries = 20;

  Future<List<String>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_historyKey) ?? <String>[];
  }

  Future<List<String>> add(String phoneNumber) async {
    final preferences = await SharedPreferences.getInstance();
    final history = preferences.getStringList(_historyKey) ?? <String>[];

    history
      ..remove(phoneNumber)
      ..insert(0, phoneNumber);

    final updatedHistory = history.take(_maximumEntries).toList();
    await preferences.setStringList(_historyKey, updatedHistory);
    return updatedHistory;
  }

  Future<List<String>> remove(String phoneNumber) async {
    final preferences = await SharedPreferences.getInstance();
    final history = preferences.getStringList(_historyKey) ?? <String>[];
    history.remove(phoneNumber);
    await preferences.setStringList(_historyKey, history);
    return history;
  }
}
