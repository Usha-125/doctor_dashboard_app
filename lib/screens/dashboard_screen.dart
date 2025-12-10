// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    // If not signed in, redirect to login (safe guard)
    if (user == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(child: Text(user.email ?? '—')),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await _auth.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream all documents in the 'users' collection
        stream: _db.collection('users').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = (doc.data() as Map<String, dynamic>? ) ?? {};
              final displayName = (data['name']?.toString().trim().isNotEmpty == true)
                  ? data['name'].toString()
                  : 'No Name';

              return ListTile(
                title: Text(displayName),
                subtitle: Text('ID: ${doc.id}'),
                trailing: data['createdAt'] != null
                    ? Text(_formatTimestamp(data['createdAt']))
                    : null,
                onTap: () {
                  // Navigate and pass id+data as arguments
                  Navigator.pushNamed(
                    context,
                    '/patientDetails',
                    arguments: {
                      'id': doc.id,
                      'data': data,
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Optional quick dialog to add a user document (creates users collection doc)
  // Remove it if you don't want client-side creation
  void _showAddUserDialog(BuildContext context) {
    final nameC = TextEditingController();
    final ageC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add user (patient)'),
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
            await _db.collection('users').add({
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

  // Helper to display Firestore serverTimestamp fields in a readable way.
  static String _formatTimestamp(dynamic ts) {
    try {
      if (ts is Timestamp) {
        final dt = ts.toDate().toLocal();
        return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      // If ts is a Map (web sometimes) or int millis
      if (ts is Map && ts['_seconds'] != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch((ts['_seconds'] as int) * 1000).toLocal();
        return dt.toString().split('.')[0];
      }
      if (ts is int) {
        final dt = DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
        return dt.toString().split('.')[0];
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
