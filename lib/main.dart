import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

/*
* Sets up the wole app: it creates the app-wide state, names the app, defines visual theme and sets "home" widget (the starting point of my app).
* The app itself is a widget.
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { // Every widget needs a build. Is run everytime there is a change
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Bedtime Story Generator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(0, 114, 114, 1.0)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// Defines the apps state and ChangeNotifier notify other widgets about its own changes. See Provider above
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random(); // gives current a new WordPair
    notifyListeners(); // ensures that anyone watching MyAppState is notified
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView( // Scrollable list
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
            '${appState.favorites.length} favorites:'),
        ),
        for (var favorite in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(favorite.asLowerCase),
          )
      ],
    );

  }



}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage(); // Placeholder() - a handy widget that draws a crossed rectangle wherever you place it, marking that part of the UI as unfinished.
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
  }

    return LayoutBuilder(
      builder: (context, constraints) { // Builder callback is called every time the constraints change
        return Scaffold( // Nested tree of widgets
          body: Row(
            children: [
              SafeArea( // Ensures that its child is not obscured by a hardware notch or a status bar.
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600, // Makes it responsive
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex, // Selected index of zero selects the first destination
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded( // Greedy. Express layouts where some children take only as much space as they need
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget { // Stateless - They don't contain any mutable state of their own. None of the widgets can change itself—they must go through MyAppState.
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if(appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
        child: Column( // Basic layout widget
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
            SizedBox(height: 10), // Visual gap
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like')),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                  appState.getNext();
                }, child: Text('Next')),
              ],
            )
          ],
        ),
      );
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}", // While humans don't have problems identifying the two words in cheaphead, a screen reader might pronounce the ph in the middle of the word as f
        ),
      ),
    );
  }
}