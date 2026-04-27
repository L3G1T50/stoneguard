import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> _entries = [];
  final _noteController = TextEditingController();
  int _painLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('journal_entries') ?? [];
    setState(() {
      _entries = raw
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList()
          .reversed
          .toList();
    });
  }

  Future<void> _saveEntry() async {
    if (_noteController.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('journal_entries') ?? [];
    final entry = {
      'date': DateTime.now().toIso8601String(),
      'pain': _painLevel,
      'note': _noteController.text.trim(),
    };
    raw.add(jsonEncode(entry));
    await prefs.setStringList('journal_entries', raw);
    _noteController.clear();
    setState(() => _painLevel = 1);
    _loadEntries();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Journal entry saved!')));
  }

  Future<void> _deleteEntry(int reversedIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('journal_entries') ?? [];
    // entries are shown reversed, so convert back
    final actualIndex = raw.length - 1 - reversedIndex;
    raw.removeAt(actualIndex);
    await prefs.setStringList('journal_entries', raw);
    _loadEntries();
  }

  Color _painColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How are you feeling today?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Pain Level: '),
                Expanded(
                  child: Slider(
                    value: _painLevel.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$_painLevel',
                    activeColor: _painColor(_painLevel),
                    onChanged: (v) => setState(() => _painLevel = v.round()),
                  ),
                ),
                Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Text(
                    '$_painLevel',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _painColor(_painLevel),
                        fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Notes (symptoms, water intake, diet, mood...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Entry'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white),
                onPressed: _saveEntry,
              ),
            ),
            const Divider(height: 24),
            const Text('Past Entries',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text('No entries yet. Start logging!'))
                  : ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  final date = DateTime.parse(e['date']);
                  final pain = e['pain'] as int;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _painColor(pain),
                        child: Text('$pain',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      title: Text(e['note']),
                      subtitle: Text(
                          '${date.month}/${date.day}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () => _deleteEntry(i),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}