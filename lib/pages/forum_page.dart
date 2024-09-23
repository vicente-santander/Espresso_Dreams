import 'package:flutter/material.dart';
import 'recipes_page.dart'; // Asegúrate de que esta importación es correcta

class ForumPost {
  final String recipeName;
  final String user;
  final String content;
  final List<String> comments;
  final List<double> ratings; // Para calificaciones

  ForumPost(this.recipeName, this.user, this.content,
      {this.comments = const [], this.ratings = const []});
}

class ForumPage extends StatefulWidget {
  final Recipe? recipe; // Receta opcional para compartir

  const ForumPage({super.key, this.recipe});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<ForumPost> posts = [];

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      posts.add(ForumPost(
          widget.recipe!.name, 'Usuario Anónimo', '¡Prueba esta receta!'));
    }
  }

  void _showAddPostDialog() {
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Publicación'),
          content: TextField(
            controller: contentController,
            decoration:
                const InputDecoration(labelText: 'Contenido de la publicación'),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  posts.add(ForumPost(
                      widget.recipe?.name ?? 'Receta Sin Nombre',
                      'Usuario Anónimo',
                      contentController.text));
                });
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foro de Recetas'),
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.recipeName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Por: ${post.user}'),
                    Text(post.content),
                    const SizedBox(height: 8),
                    Text('Comentarios (${post.comments.length}):'),
                    for (var comment in post.comments)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text('- $comment'),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Lógica para agregar un comentario
                      },
                      child: const Text('Comentar'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
        child: const Icon(Icons.add),
      ),
    );
  }
}
