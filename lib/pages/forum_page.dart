import 'package:flutter/material.dart';
import 'package:espresso_dreams/models/forum_class.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

// Estado de la página del foro
class _ForumPageState extends State<ForumPage> {
  List<ForumPost> posts = []; // Lista de publicaciones en el foro

  @override
  void initState() {
    super.initState();

    // Inicializa la lista de publicaciones con ejemplos
    posts = [
      ForumPost(
        'Usuario1',
        '¡Me encanta esta receta! Muy fácil de seguir.',
        comments: [
          '¡Increíble!',
          'Muy buena, gracias.'
        ], // Comentarios de ejemplo
        ratings: [5.0], // 5 estrellas
      ),
      ForumPost(
        'Usuario2',
        'Una receta muy buena.',
        comments: [], // Sin comentarios
        ratings: [5.0, 5.0, 5.0], // 3 calificaciones de 5 estrellas
      ),
    ];
  }

  // Agregar una nueva publicación
  void _addPost() {
    final TextEditingController contentController =
        TextEditingController(); // Controlador para el texto

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Publicación'),
          content: TextField(
            controller: contentController,
            decoration:
                const InputDecoration(labelText: 'Contenido de la publicación'),
            maxLines: 5, // Permitir múltiples líneas
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Agregar nueva publicación a la lista usando el método de la clase
                  posts.add(ForumPost.createPost(contentController.text));
                });
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  // Agregar un comentario a una publicación
  void _addComment(ForumPost post) {
    final TextEditingController commentController =
        TextEditingController(); // Controlador para el comentario

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Comentario'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(labelText: 'Comentario'),
            maxLines: 3, // Permitir múltiples líneas
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Agregar comentario a la publicación usando el nuevo método
                  post.addComment(commentController.text);
                });
                Navigator.of(context).pop(); // Cierra el diálogo
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
        backgroundColor:
            const Color.fromARGB(255, 174, 97, 71), // Color de fondo del AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: posts.length, // Número de publicaciones
          itemBuilder: (context, index) {
            final post = posts[index]; // Obtener la publicación actual
            final averageRating = post
                .calculateAverageRating(); // Calcular la calificación promedio
            final starCount =
                post.getStarCount(); // Obtener el número de estrellas

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Por: ${post.user}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)), // Mostrar el usuario
                    Text(
                        post.content), // Mostrar el contenido de la publicación
                    const SizedBox(height: 8),
                    // Mostrar comentarios
                    Text('Comentarios (${post.comments.length}):'),
                    for (var comment
                        in post.comments) // Mostrar cada comentario
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text('- $comment'),
                      ),
                    const SizedBox(
                        height: 8), // Espacio antes del botón de comentar
                    ElevatedButton(
                      onPressed: () {
                        _addComment(post); // agregar un comentario
                      },
                      child: const Text('Comentar'), // Texto del botón
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Calificación promedio: ${averageRating.toStringAsFixed(1)} (${post.ratings.length})'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (starIndex) {
                        return IconButton(
                          icon: Icon(
                            starIndex < starCount
                                ? Icons.star // Mostrar estrella llena
                                : Icons.star_border, // Mostrar estrella vacía
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            post.rate(starIndex + 1.0); // Agregar calificación
                            setState(() {}); // Forzar actualización del estado
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPost, // Boton flotante para agregar una publicación
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
        child: const Icon(Icons.add),
      ),
    );
  }
}
