class Usuario {
  String nombre;
  String correo;
  int numeroDeRecetas;
  double promedioDeRecetas;

  Usuario({
    required this.nombre,
    required this.correo,
    required this.numeroDeRecetas,
    required this.promedioDeRecetas,
  });

  // Método para editar la información del usuario
  void editarUsuario({required String nuevoNombre}) {
    nombre = nuevoNombre;
  }
}
