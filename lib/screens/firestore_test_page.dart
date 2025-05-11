import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  _FirestoreTestPageState createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  String data = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('multimedia')
          .doc('7yNUtOp2xlNb0HSGqGYG')
          .get();

      if (snapshot.exists) {
        setState(() {
          data = snapshot.data().toString();
        });
      } else {
        setState(() {
          data = 'Documento no encontrado';
        });
      }
    } catch (e) {
      setState(() {
        data = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Test')),
      body: Center(child: Text(data)),
    );
  }
}
