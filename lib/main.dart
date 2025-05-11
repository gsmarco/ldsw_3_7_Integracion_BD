import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import 'firebase_options.dart'; // generado con flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Multimedia',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status = '';
  final String collectionName = "multimedia";

  // Mensaje de Alert
void _showAlert(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(); // CIERRA el diálogo correctamente
          },
          child: const Text('OK'),
        ),
      ],    
    ),
  );
}

  // Función para cargar datos desde un archivo JSON local
  Future<void> cargarDesdeArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final content = utf8.decode(result.files.single.bytes!);
      final List<dynamic> jsonData = json.decode(content);

      for (var item in jsonData) {
        await FirebaseFirestore.instance.collection(collectionName).add(item);
      }
        setState(() {
            status = 'Objeto JSON subido correctamente a Firestore.';
          });
        _showAlert(context, 'Éxito', status);

    } else {
        _showAlert(context, 'Error', 'No se seleccionó ningún archivo JSON.');
    }
  }

  // Función para mostrar los datos almacenados
  Future<void> mostrarDatos(BuildContext context) async {
    final snapshot = await FirebaseFirestore.instance.collection(collectionName).get();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Datos en Firestore'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Título: ${data['Title'] ?? 'Sin título'}", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Género: ${data['Genre'] ?? 'Desconocido'}"),
                      Text("Fecha lanzamiento: ${data['Released'] ?? 'Sin fecha'}"),
                    ],
                  ),
                ),
              ),
            );

            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar')),
        ],
      ),
    );
  }

  // Función para borrar todos los documentos
  Future<void> borrarDatos() async {
    final snapshot = await FirebaseFirestore.instance.collection(collectionName).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    _showAlert(context, 'Exito', 'Se borró la colección "multimedia".');
  }

  // UI de la aplicación
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carga de un archivo JSON a Firestore')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Utilizo un row para alinear horizontalmente tres botones Cargar JSON, Mostrar datos y Borrar datos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                // Botón para cargar un archivo JSON a la base de datos firestore de Firebase
                ElevatedButton(
                  onPressed: cargarDesdeArchivo,
                  child: const Text('Cargar JSON', style: TextStyle(fontWeight: FontWeight.bold),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[200]),
                ),
                const SizedBox(width: 15),
                // Botón para mostrar los documentos de la colección multimedia de firestore
                ElevatedButton(
                  onPressed: () => mostrarDatos(context),
                  child: Text('Mostrar Datos', style: TextStyle(fontWeight: FontWeight.bold),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100]),
                ),
                const SizedBox(width: 15),
                // Botón para borrar los documentos de la colección multimedia de firestore
                ElevatedButton(
                  onPressed: borrarDatos,
                  child: Text('Borrar datos', style: TextStyle(fontWeight: FontWeight.bold),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[200]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
