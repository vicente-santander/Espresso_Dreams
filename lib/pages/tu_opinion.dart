import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  List<dynamic> usabilidadQuestions = [];
  List<dynamic> contenidoQuestions = [];
  List<dynamic> compartirQuestions = [];
  String userName = '';
  String selectedGroup = '';
  String userRelationship = '';

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/validacion.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      usabilidadQuestions = jsonData['usabilidad'];
      contenidoQuestions = jsonData['contenido'];
      compartirQuestions = jsonData['compartir'];
    });
  }

  void updateQuestionValue(dynamic question, int value) {
    setState(() {
      question['valor'] = value;
    });
  }

  Future<void> sendFeedback() async {
    String emailBody =
        "Nombre: $userName\nGrupo: $selectedGroup\nRelación: $userRelationship\n\n";

    void addQuestionsToEmail(List<dynamic> questions, String category) {
      emailBody += "$category:\n";
      for (var question in questions) {
        emailBody += "${question['titulo']}: ${question['valor']} estrellas\n";
      }
      emailBody += "\n";
    }

    addQuestionsToEmail(usabilidadQuestions, "Usabilidad");
    addQuestionsToEmail(contenidoQuestions, "Contenido");
    addQuestionsToEmail(compartirQuestions, "Compartir");

    final Email email = Email(
      body: emailBody,
      subject: 'Retroalimentación de la Aplicación',
      recipients: ['vicentesantander503@gmail.com'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tu opinión"),
        backgroundColor: Colors.yellow[600], // Amarillo claro
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              onChanged: (value) => userName = value,
              decoration: const InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            DropdownButtonFormField<String>(
              value: selectedGroup.isNotEmpty ? selectedGroup : null,
              items: const [
                DropdownMenuItem(
                  value: 'Persona trabajando en su propio piloto',
                  child: Text('Persona trabajando en su propio piloto'),
                ),
                DropdownMenuItem(
                  value: 'Persona en la misma área de programación',
                  child: Text('Persona en la misma área de programación'),
                ),
                DropdownMenuItem(
                  value: 'Persona externa a conocimientos técnicos',
                  child: Text('Persona externa a conocimientos técnicos'),
                ),
              ],
              onChanged: (value) => setState(() => selectedGroup = value!),
              decoration: const InputDecoration(
                labelText: 'Grupo',
              ),
              isExpanded: true,
            ),
            TextField(
              onChanged: (value) => userRelationship = value,
              decoration: const InputDecoration(
                labelText: 'Relación (colega, familia, etc.)',
              ),
            ),
            buildQuestionSection("Usabilidad", usabilidadQuestions),
            buildQuestionSection("Contenido", contenidoQuestions),
            buildQuestionSection("Compartir", compartirQuestions),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: sendFeedback,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 251, 230, 137)), // Amarillo claro
              ),
              child: const Text("Enviar Retroalimentación"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuestionSection(String title, List<dynamic> questions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...questions.map((question) => buildQuestion(question)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildQuestion(dynamic question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question['titulo']),
        RatingBar.builder(
          initialRating: (question['valor'] ?? 0).toDouble(),
          minRating: 0,
          maxRating: 5,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.yellow, // Amarillo claro para las estrellas
          ),
          onRatingUpdate: (rating) =>
              updateQuestionValue(question, rating.toInt()),
        ),
      ],
    );
  }
}
