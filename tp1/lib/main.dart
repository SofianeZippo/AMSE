import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart'; //nécessaire pour lire les fichiers csv où sont renseignées les données
import 'dart:math'; //nécessaire afin de manipuler l'aléatoire


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  int randomIndex = 0; // Déclare une variable pour l'index aléatoire.

  void getNext() {
    randomIndex = Random().nextInt(29)+1; // Générez un index aléatoire en évitant l'indice 0.
    notifyListeners();
  }

  var favorites = <int>[];

  void toggleFavorite(int index) {
    if (favorites.contains(index)) {
      favorites.remove(index);
    } else {
      favorites.add(index);
    }
    notifyListeners();
  }
}


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  List<List<dynamic>> csvData = [];
  int IndexData = 0;

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  Future<void> loadCsvData() async {
    final rawData = await rootBundle.loadString('assets/data.csv');
    final listData = CsvToListConverter().convert(rawData);

    setState(() {
      csvData = listData;
      print(csvData[3]);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(csvData: csvData,);
        break;
      case 1:
        page = PageFavoris(csvData: csvData, IndexData: IndexData);
        break;
      case 2:
        page = PageRecherche(csvData: csvData);
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Saphir"),
          ),
          body: Row(
            children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
          // Placer la barre de navigation en bas
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favoris',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Rechercher',
              ),
            ],
          ),
        );
      },
    );
  }
}

class GeneratorPage extends StatelessWidget {
  final List<List<dynamic>> csvData;

  GeneratorPage({required this.csvData});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    IconData icon;
    if (appState.favorites.contains(appState.randomIndex)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    String imageName = csvData[appState.randomIndex][csvData[0].length - 1];

    return Column(
      children: [
        SizedBox(height: 40),
        // Grand Titre et Sous-titre
        Text(
          'Bienvenue sur Saphir',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black,
                offset: Offset(3.0, 3.0),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Text(
            'Découvrez de nouvelles œuvres ou répertoriez celles que vous aimez déjà !!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black,
                  offset: Offset(3.0, 3.0),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Theme.of(context).colorScheme.secondaryFixedDim,
                elevation: 36,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/${imageName}',
                        width: 200,
                        height: 200,
                      ),
                      Text(
                        '${csvData[appState.randomIndex][0]}',
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(color: Theme.of(context).colorScheme.onSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleFavorite(appState.randomIndex);

                      if (appState.favorites.contains(appState.randomIndex)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Favori Ajouté!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Favori Retiré!')),
                        );
                      }
                    },
                    icon: Icon(icon),
                    label: Text("J'aime"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      appState.getNext(); // Appel pour obtenir un nouvel index aléatoire.
                    },
                    child: Text('Suivant'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class PageFavoris extends StatelessWidget {
  final List<List<dynamic>> csvData;
  final int IndexData;

  PageFavoris({required this.csvData, required this.IndexData});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.onSecondary);

    if (appState.favorites.isEmpty) {
      return Center(child: Text('Oh! Aucun Favoris ajoutés pour le moment :(', style: style, textAlign: TextAlign.center,));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Vous avez ${appState.favorites.length} favoris:'),
        ),
        for (var num in appState.favorites)
          ListTile(
            leading: Image.asset(
              'assets/images/${csvData[num][csvData[0].length-1]}',
              width: 40,
              height: 40,
            ),
            title: Text('${csvData[num][0]}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Ouvrir un Dialog avec les détails de l'élément
                showDialog(
                  context: context,
                  builder: (context) {
                    bool isFavorite = appState.favorites.contains(num);

                    return AlertDialog(
                      //scrollable: true,
                      title: Container(
                        color: Colors.blueGrey[50], // Arrière-plan personnalisé pour le titre
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Détails de l\'élément',
                          style: TextStyle(
                            color: Colors.black, // Titre en noir
                            fontWeight: FontWeight.bold, // Titre en gras
                          ),
                        ),
                      ),
                      content: SingleChildScrollView(  // Ajouter SingleChildScrollView ici
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/${csvData[num][csvData[0].length - 1]}',
                              width: 200,
                              height: 200,
                            ),
                            DataTable(
                              columns: const [
                                DataColumn(label: Text('')),
                                DataColumn(label: Text('')),
                              ],
                              rows: [
                                for (int i = 0; i < csvData[0].length - 2; i++)
                                  DataRow(cells: [
                                    DataCell(Text(
                                      '${csvData[0][i]}',
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                    )),
                                    DataCell(Text('${csvData[num][i]}')),
                                  ])
                              ],
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        // Bouton pour ajouter/retirer des favoris
                        TextButton(
                          onPressed: () {
                            appState.toggleFavorite(num);
                            Navigator.of(context).pop(); // Fermer le dialog
                          },
                          child: Text(
                            isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Bouton de fermeture
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fermer le dialog
                          },
                          child: Text(
                            'Fermer',
                            style: TextStyle(
                              color: Colors.blueAccent, // Texte du bouton en noir
                              fontWeight: FontWeight.bold, // Bouton en gras
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Détails'),
            ),
          ),
      ],
    );
  }
}


class PageRecherche extends StatefulWidget {
  final List<List<dynamic>> csvData;

  PageRecherche({required this.csvData});

  @override
  _PageRechercheState createState() => _PageRechercheState();
}

class _PageRechercheState extends State<PageRecherche> {
  TextEditingController _searchController = TextEditingController();
  List<List<dynamic>> _filteredData = [];
  String? _selectedDate;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _filteredData = widget.csvData;
  }


  void _filterSearchResults(String query) {
    List<List<dynamic>> results = [];
    if (query.isEmpty && _selectedDate == null && _selectedType == null) {
      results = List.from(widget.csvData); // Si la recherche est vide, on retourne toutes les données
    } else {
      results = widget.csvData.where((item) {
        // Filtrer par nom (colonne 0)
        bool matchesName = item[0].toString().toLowerCase().contains(query.toLowerCase());

        // Filtrer par date (colonne 1)
        bool matchesDate = _selectedDate == null || item[1].toString().toLowerCase() == _selectedDate.toString().toLowerCase();

        // Filtrer par type (colonne 2)
        bool matchesType = _selectedType == null || item[2].toString().toLowerCase() == _selectedType.toString().toLowerCase();

        return matchesName && matchesDate && matchesType;
      }).toList();
    }
    setState(() {
      _filteredData = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Pour gérer les favoris

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Recherchez un Média',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              _filterSearchResults(query);
            },
          ),
        ),
        
        // Filtres : Type et Date
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Filtrer par Type"),
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue;
                      _filterSearchResults(_searchController.text);
                    });
                  },
                  items: [
                    null, // Option pour ne pas filtrer
                    ...widget.csvData
                        .map((item) => item[2].toString())
                        .toSet()
                        .toList() // Éviter les doublons
                  ]
                      .map<DropdownMenuItem<String>>((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value ?? 'Tous'),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Filtrer par Date"),
                  value: _selectedDate,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDate = newValue;
                      _filterSearchResults(_searchController.text);
                    });
                  },
                  items: [
                    null, // Option pour ne pas filtrer
                    ...widget.csvData
                        .map((item) => item[1].toString())
                        .toSet()
                        .toList() // Éviter les doublons
                  ]
                      .map<DropdownMenuItem<String>>((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value ?? 'Toutes'),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),

        // Affichage des résultats filtrés
        Expanded(
          child: ListView.builder(
            itemCount: _filteredData.length,
            itemBuilder: (context, index) {
              var item = _filteredData[index];
              String imageName = item[item.length - 1]; // Nom du fichier image

              return ListTile(
                leading: Image.asset(
                  'assets/images/$imageName',
                  width: 40,
                  height: 40,
                ),
                title: Text(item[0]),  // Affiche le nom de l'élément
                subtitle: Text(item[2]), // Affiche le type de l'élément (colonne 2)
                trailing: ElevatedButton(
                  onPressed: () {
                    // Afficher les détails dans un Dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Détails'),
                          content: Column(
                            children: [
                              Image.asset(
                                'assets/images/$imageName',
                                width: 200,
                                height: 200,
                              ),
                              DataTable(
                                columns: const [
                                  DataColumn(label: Text('')),
                                  DataColumn(label: Text('')),
                                ],
                                rows: [
                                  for(int i=0;i<widget.csvData[0].length-2;i++)
                                    DataRow(cells: [
                                      DataCell(Text('${widget.csvData[0][i]}',style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text('${item[i]}'))
                                    ]),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            // Bouton pour ajouter/retirer des favoris
                            TextButton(
                              onPressed: () {
                                appState.toggleFavorite(item[widget.csvData[0].length -2]);
                                Navigator.of(context).pop(); // Fermer le dialog

                                // Afficher un SnackBar pour informer de l'ajout/retrait
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(appState.favorites.contains(index)
                                        ? 'Ajouté aux favoris!'
                                        : 'Retiré des favoris!'),
                                  ),
                                );
                              },
                              child: Text(
                                appState.favorites.contains(index)
                                    ? 'Retirer des favoris'
                                    : 'Ajouter aux favoris',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Bouton de fermeture
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Fermer le dialog
                              },
                              child: Text(
                                'Fermer',
                                style: TextStyle(
                                  color: Colors.blueAccent, // Texte du bouton en bleu
                                  fontWeight: FontWeight.bold, // Bouton en gras
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Détails'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
