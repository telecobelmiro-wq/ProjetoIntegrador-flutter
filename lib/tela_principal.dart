import 'package:flutter/material.dart';
import 'tela_profissional.dart';

class TelaPrincipal extends StatelessWidget {
  const TelaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Principal'),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  'Corte de cabelo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    '24/05/2026 - 14:00',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaProfissional()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 2, 2, 2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
