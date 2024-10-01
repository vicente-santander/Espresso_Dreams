class ForumPost {
  final String user; // Usuario que creó la publicación
  final String content; // Contenido de la publicación
  List<String> comments; // Lista de comentarios
  List<double> ratings; // Lista de calificaciones

  // Constructor de la clase
  ForumPost(this.user, this.content,
      {List<String>? comments, List<double>? ratings})
      : comments = comments ?? [], // Inicializa la lista de comentarios
        ratings = ratings ?? []; // Inicializa la lista de calificaciones

  // Método estático para crear una nueva publicación
  static ForumPost createPost(String content) {
    return ForumPost('Usuario X', content);
  }

  // Método para agregar un comentario a la publicación
  void addComment(String comment) {
    comments.add(comment); // Agregar el comentario a la lista
  }

  // Método para calificar la publicación
  void rate(double rating) {
    ratings.add(rating); // Agregar la calificación a la lista
  }

  // Método para calcular la calificación promedio de la publicación
  double calculateAverageRating() {
    if (ratings.isEmpty) return 0; // Retornar 0 si no hay calificaciones
    return ratings.reduce((a, b) => a + b) /
        ratings.length; // Calcular el promedio
  }

  // Método para obtener la cantidad de estrellas que se deben mostrar
  int getStarCount() {
    return calculateAverageRating()
        .floor(); // Redondear hacia abajo para mostrar el número correcto de estrellas
  }
}
