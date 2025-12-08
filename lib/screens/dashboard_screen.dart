import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (user != null) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(child: Text(user.email ?? '—')),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('patients').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No patients yet'));
          final patients = docs.map((d) => Patient.fromDoc(d)).toList();
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, i) {
              final p = patients[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('Age: ${p.age ?? '—'}'),
                trailing: Text(p.createdAt != null ? DateTime.fromMillisecondsSinceEpoch((p.createdAt!.seconds * 1000)).toLocal().toString().split('.')[0] : ''),
                onTap: () => Navigator.pushNamed(context, '/patientDetails', arguments: p),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPatientDialog(context, db),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context, FirebaseFirestore db) {
    final nameC = TextEditingController();
    final ageC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: ageC, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () async {
            final name = nameC.text.trim();
            final age = int.tryParse(ageC.text.trim());
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter name')));
              return;
            }
            await db.collection('patients').add({
              'name': name,
              'age': age,
              'createdAt': FieldValue.serverTimestamp(),
            });
            Navigator.pop(ctx);
          }, child: const Text('Add')),
        ],
      ),
    );
  }
}
