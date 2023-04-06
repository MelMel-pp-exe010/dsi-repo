import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color.fromARGB(255, 241, 113, 141)),
      ),
      routes: {
        '/': (context) => const RandomWords(),
        '/editar':(context) => const EditScreen()
      }
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final WordRepository _suggestions = WordRepository();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _saved = <WordPair>[];
  bool cardModen = false;

  get child => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
            IconButton(
              onPressed: (() {
                setState(() {
                  if (cardModen == false) {
                    cardModen = true;
                  } else if (cardModen == true) {
                    cardModen = false;
                  }
                });
              }),
              tooltip:
                  cardModen ? 'List Vizualization' : 'Card Mode Vizualization',
              icon: Icon(Icons.auto_fix_normal_outlined),
            ),
          ],
        ),
        body: _buildSuggestions(cardModen));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context) {
        final pianotiles = _saved.map(
          (WordPair pair) {
            return ListTile(
              title: Text(
                pair.asPascalCase,
                style: _biggerFont,
              ),
            );
          },
        );
        final divided = pianotiles.isNotEmpty
            ? ListTile.divideTiles(
                context: context,
                tiles: pianotiles,
              ).toList()
            : <Widget>[];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Favoritas'),
          ),
          body: ListView(children: divided),
        );
      }),
    );
  }

  Widget _buildSuggestions(bool cardMode) {

    final WordRepository suggestions;

    if (cardMode == false) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;
          
          return _buildList(_suggestions.words[index], index);
        },
      );
    } else {
      return _cardList();
    }
  }

  Widget _buildList(WordPair pair, int index) {
    final alreadySaved = _saved.contains(_suggestions.words[
        index]); 
    return ListTile(
        title: Text(
          _suggestions._words[index].asPascalCase,
          style: _biggerFont,
        ),
        trailing: Column(
          children: [
            GestureDetector(
              onTap: () {
              setState(() {
                if (alreadySaved) {
                  _saved.remove(_suggestions._words[index]);
                } else {
                  _saved.add(_suggestions._words[index]);
                }
              });
            },
              child: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
                  color: alreadySaved ? Color.fromARGB(255, 37, 94, 117) : null,
                  semanticLabel: alreadySaved ? 'Remover dos favoritos' : 'Favoritar'),
            ),
          
          GestureDetector(
                  onTap: () async {
                    final updatedWord = await Navigator.pushReplacementNamed(context, '/editar', arguments: {'word': _suggestions.words[index]});
                    setState(() {
                      _suggestions.words[index] = updatedWord;
                    });
                  },
                  child: Icon(
                    Icons.edit,
                    color: alreadySaved ? Colors.red : null,
                    semanticLabel: alreadySaved ? "Remove from saved" : "Save",
                  ),
                ),

          ],
        ),
        );
  }

  Widget _cardList() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 8),
      itemCount: _suggestions.words.length,
      itemBuilder: (context, index) {
        //final index = i ~/ 2;
        return Column(
          children: [_buildList(_suggestions.words[index], index)],
        );
      },
    );
  }
}

class WordRepository {
  List<WordPair> _words = generateWordPairs().take(20).toList();

  get words => _words;
  set setWords (List<WordPair> newList) {
    _words = newList;
  }
}

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final word = args['word'];
    String? newWord = '';
    final controller = TextEditingController(text: word);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar palavra"),
      ),
      body: Center(
        child: Column(
          children: [
            TextFormField(
              controller: controller,
              onSaved: (value) {
                newWord = value;
              },
            ),
            ElevatedButton(onPressed: () {
              final form = Form.of(context);
              if(form.validate()){
                form.save();
                Navigator.pop(context, newWord);
              }
            }, child: const Text('Confirmar'))
          ],
        )
      ),
    );  }
}

