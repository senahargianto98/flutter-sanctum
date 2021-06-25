import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sanctum/auth.dart';
import 'dart:convert';

class Book {
  final int id;
  final String title;
  final String author;
  Book({this.id, this.title, this.author});
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
    );
  }
}

class BookList extends StatefulWidget {
  @override
  _BookListState createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  Future<List<Book>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = fetchBooks();
  }

  final String apiUrl = "http://192.168.1.8:8000/api/book";
  Future<List<Book>> fetchBooks() async {
    List<Book> books = <Book>[];
    String token =
        await Provider.of<AuthProvider>(context, listen: false).getToken();
    final response = await http.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      for (int i = 0; i < data.length; i++) {
        books.add(Book.fromJson(data[i]));
      }
      return books;
    } else {
      throw Exception('Problem loading books');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Homepage'), actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Show Snackbar',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ]),
        body: Center(
          child: BookListBuilder(futureBooks: futureBooks),
        ),
      ),
    );
  }
}

class BookListBuilder extends StatelessWidget {
  const BookListBuilder({
    Key key,
    @required this.futureBooks,
  }) : super(key: key);

  final Future<List<Book>> futureBooks;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
        future: futureBooks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Expanded(
                child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                Book book = snapshot.data[index];
                return ListTile(
                  title: Text('${book.title}'),
                  subtitle: Text('${book.author}'),
                );
              },
            ));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        });
  }
}
