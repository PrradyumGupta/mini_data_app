import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final List<TextEditingController> _line1Controllers = [];
  final List<TextEditingController> _line2Controllers = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('addresses');

    if (storedData != null) {
      final List decoded = jsonDecode(storedData);
      for (var item in decoded) {
        final parts = item.split('||');
        _line1Controllers.add(TextEditingController(text: parts[0]));
        _line2Controllers.add(TextEditingController(text: parts[1]));
      }
    }

    if (_line1Controllers.isEmpty) {
      _addAddress();
    }

    setState(() {});
  }

  void _addAddress() {
    setState(() {
      _line1Controllers.add(TextEditingController());
      _line2Controllers.add(TextEditingController());
    });
  }

  void _removeAddress(int index) {
    setState(() {
      _line1Controllers[index].dispose();
      _line2Controllers[index].dispose();
      _line1Controllers.removeAt(index);
      _line2Controllers.removeAt(index);
    });
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> data = [];

    for (int i = 0; i < _line1Controllers.length; i++) {
      final line1 = _line1Controllers[i].text.trim();
      final line2 = _line2Controllers[i].text.trim();

      if (line1.isNotEmpty || line2.isNotEmpty) {
        data.add('$line1||$line2');
      }
    }

    await prefs.setString('addresses', jsonEncode(data));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Addresses saved successfully ✅'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _line1Controllers) {
      c.dispose();
    }
    for (final c in _line2Controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Addresses'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _line1Controllers.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _line1Controllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Address Line 1',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _line2Controllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Address Line 2',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeAddress(index),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAddress,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _saveAddresses,
          child: const Text('Done'),
        ),
      ),
    );
  }
}
