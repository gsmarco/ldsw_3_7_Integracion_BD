import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CovidDataTableScreen extends StatefulWidget {
  const CovidDataTableScreen({super.key});

  @override
  _CovidDataTableScreenState createState() => _CovidDataTableScreenState();
}

class _CovidDataTableScreenState extends State<CovidDataTableScreen> {
  List<dynamic> covidData = []; // Variable del tipo List para los datos de la API
  bool isLoading = true;

  @override
  void initState() {
    super.initState(); // Inicializa datos
    fetchCovidData(); // Carga los datos del COVID mediante la API del servicio
  }

  // Se define la Función asíncrona fetchCovidData mediante Future
  Future<void> fetchCovidData() async {
    final url = Uri.parse('https://api.covidtracking.com/v1/us/daily.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) { // Verifica el estatus del response de la api
        final List<dynamic> data = json.decode(response.body); // Decodifica el body del response
        setState(() {
          covidData = data.take(data.length).toList(); // Tomamos todos registros
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar datos');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(int date) {
    final dateString = date.toString();
    final year = dateString.substring(0, 4);
    final month = dateString.substring(4, 6);
    final day = dateString.substring(6, 8);
    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        toolbarHeight:50,
        title: Text('Actividad 3.6. Peticiones HTTP',
        style: TextStyle(fontWeight: FontWeight.bold, color:const Color.fromARGB(255, 167, 26, 16)))),
      body: isLoading ? Center(child: CircularProgressIndicator(
        color: Colors.orangeAccent,
        backgroundColor: Colors.blueGrey,
        value: 0.50,
      ))
          : CovidDataTable(data: covidData), // Rendeeriza la table de COVID
    );
  }
}

class CovidDataTable extends StatelessWidget {
  final List<dynamic> data;

  const CovidDataTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: PaginatedDataTable(
        header: Text('Últimos datos por día de COVID en USA', style: TextStyle(fontWeight: FontWeight.bold)),
        columns: [ // definición de las columnas
          DataColumn(label: buildHeader('Fecha')),
          DataColumn(label: buildHeader('Positivos')),
          DataColumn(label: buildHeader('Tot.Muertes')),
          DataColumn(label: buildHeader('Hospitalizados')),
          DataColumn(label: buildHeader('Muertes')),
        ],
        source: CovidDataSource(data),
        rowsPerPage: 10, // Indico que son 10 registros por página
        dataRowMaxHeight: 50,
        columnSpacing: 15, // Espaciado horizontal entre columnas
        showCheckboxColumn: false, //false,
      ),
    );
  }

// Función para el formateo de texto
  Text buildHeader(String text) {
    return Text(
      text,
      style: TextStyle(fontSize:15, fontWeight: FontWeight.bold, color: Colors.indigo),
    );
  }
}

class CovidDataSource extends DataTableSource {
  final List<dynamic> data;

  CovidDataSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];

    String formatDate(int date) {
      final dateString = date.toString();
      final year = dateString.substring(0, 4);
      final month = dateString.substring(4, 6);
      final day = dateString.substring(6, 8);
      return '$year-$month-$day';
    }

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(formatDate(item['date']))),
        DataCell(Text('${item['positive'] ?? 'N/A'}')),
        DataCell(Text('${item['death'] ?? 'N/A'}')),
        DataCell(Text('${item['hospitalizedCurrently'] ?? 'N/A'}')),
        DataCell(Text('${item['deathIncrease'] ?? 'N/A'}')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}
