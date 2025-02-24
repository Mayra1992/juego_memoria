import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MemoriaApp());
}

class MemoriaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MemoriaPage(),
    );
  }
}

class MemoriaPage extends StatefulWidget {
  @override
  _MemoriaPageState createState() => _MemoriaPageState();
}

class _MemoriaPageState extends State<MemoriaPage> {
  List<String> imagenesBase = [
    'assets/images/abeja.png',
    'assets/images/gato.png',
    'assets/images/leon.png',
    'assets/images/perro.png',
    'assets/images/pollito.png',
    'assets/images/vaca.png',
  ];

  List<String> sonidosBase = [
    'sonidos/abeja.wav',
    'sonidos/gato.wav',
    'sonidos/leon.wav',
    'sonidos/perro.wav',
    'sonidos/pollito.wav',
    'sonidos/vaca.wav',
  ];

  late List<String> imagenes;
  late List<String> sonidos;
  late List<bool> volteadas;
  List<int> seleccionadas = [];
  int paresEncontrados = 0;
  bool enJuego = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _inicializarJuego();
  }

  void _inicializarJuego() {
    imagenes = [...imagenesBase, ...imagenesBase]; // Duplica las imágenes
    sonidos = [...sonidosBase, ...sonidosBase]; // Duplica los sonidos
    List<int> indices = List.generate(imagenes.length, (index) => index);
    indices.shuffle(); // Mezcla los índices

    // Ordena las imágenes y sonidos mezclados
    imagenes = indices.map((i) => imagenes[i]).toList();
    sonidos = indices.map((i) => sonidos[i]).toList();

    volteadas = List.filled(imagenes.length, true); // Muestra las imágenes al inicio
    seleccionadas.clear();
    paresEncontrados = 0;
    enJuego = false;

    // Oculta las imágenes después de 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        enJuego = true;
        volteadas = List.filled(imagenes.length, false);
      });
    });
  }

  void _seleccionarCarta(int index) {
    if (seleccionadas.length < 2 && !volteadas[index]) {
      setState(() {
        seleccionadas.add(index);
        volteadas[index] = true;
      });

      if (seleccionadas.length == 2) {
        Future.delayed(Duration(seconds: 1), () {
          _verificarPareja();
        });
      }
    }
  }

  void _verificarPareja() {
    if (imagenes[seleccionadas[0]] == imagenes[seleccionadas[1]]) {
      _audioPlayer.play(AssetSource(sonidos[seleccionadas[0]])); 
      paresEncontrados++;
    } else {
      _audioPlayer.play(AssetSource('sonidos/burla.mp3')); 
      setState(() {
        volteadas[seleccionadas[0]] = false;
        volteadas[seleccionadas[1]] = false;
      });
    }

    seleccionadas.clear();

    if (paresEncontrados == imagenesBase.length) {
      _mostrarMensajeFinal();
    }
  }

  void _mostrarMensajeFinal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¡Felicidades!'),
        content: Text('Has encontrado todas las parejas.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reiniciarJuego();
            },
            child: Text('Jugar de nuevo'),
          ),
        ],
      ),
    );
  }

  void _reiniciarJuego() {
    setState(() {
      _inicializarJuego();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memoria de Animales')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 columnas
                childAspectRatio: 1.0,
              ),
              itemCount: imagenes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => enJuego ? _seleccionarCarta(index) : null,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Image.asset(
                        volteadas[index] ? imagenes[index] : 'assets/images/interrogacion.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
