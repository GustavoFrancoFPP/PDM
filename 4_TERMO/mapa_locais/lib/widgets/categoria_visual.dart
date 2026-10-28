import 'package:flutter/material.dart';

// Mantém os ícones e as cores de cada categoria iguais em todo o app.
IconData iconeCategoria(String categoria) {
  switch (categoria) {
    case 'Academia':
      return Icons.fitness_center;
    case 'Restaurante':
      return Icons.restaurant;
    case 'Hospital':
      return Icons.local_hospital;
    case 'Museu':
      return Icons.museum;
    case 'Parque':
      return Icons.park;
    case 'Escola':
      return Icons.school;
    case 'Hotel':
      return Icons.hotel;
    case 'Farmácia':
      return Icons.local_pharmacy;
    case 'Mercado':
      return Icons.shopping_cart;
    default:
      return Icons.place;
  }
}

Color corCategoria(String categoria) {
  switch (categoria) {
    case 'Academia':
      return Colors.orange.shade700;
    case 'Restaurante':
      return Colors.red.shade700;
    case 'Hospital':
      return Colors.green.shade700;
    case 'Museu':
      return Colors.purple.shade700;
    case 'Parque':
      return Colors.teal.shade700;
    case 'Escola':
      return Colors.blue.shade700;
    case 'Hotel':
      return Colors.brown.shade600;
    case 'Farmácia':
      return Colors.cyan.shade700;
    case 'Mercado':
      return Colors.amber.shade800;
    default:
      return Colors.blueGrey.shade600;
  }
}
