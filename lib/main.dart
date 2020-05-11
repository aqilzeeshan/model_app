import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() async {
  runApp(MyApp());
  //List<Article> list = await fetchArticles();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class Categories {
  String name;
  String image;
  String newsType;

  Categories({this.name, this.image, this.newsType});
}

//https://github.com/ashishrawat2911/Flutter-NewsWeb/blob/master/lib/src/ui/home_page.dart
List<Categories> loadCategories() {
  List<Categories> list = [
    //adding all the categories of news in the list
    new Categories(image: 'images/top_news.png', name: 'Top Headlines'),
    new Categories(image: 'images/science_news.png', name: 'Science'),
    new Categories(image: 'images/health_news.png', name: 'Health'),
    new Categories(image: 'images/tech_news.png', name: 'Technology'),
    new Categories(image: 'images/Scratch.png', name: 'Entertainment'),
    new Categories(image: 'images/sports_news.png', name: 'Sports'),
    new Categories(image: 'images/business_news.png', name: 'Business'),
    new Categories(image: 'images/politics_news.png', name: 'Politics')
  ];
  return list;
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Categories> list = loadCategories();
    List<MaterialColor> colors = [
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.blue,
      Colors.brown,
      Colors.deepPurple,
      Colors.orange,
      Colors.teal
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      ///////////////////////Generate grid of 8 items in 2 columns///////
      //https://flutter.dev/docs/cookbook/lists/grid-lists
      body: GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(8, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RaisedButton(
                //color: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  side: BorderSide(
                      color: colors[index], width: 3, style: BorderStyle.solid),
                ),
                elevation: 1.0,
                child: Column(
                  children: [
                    /*
                    Image(
                      image: AssetImage(list[index].image),
                    ),
                     */
                    SizedBox(
                      width: 20,
                      height: 65,
                    ),
                    Center(
                      child: Text(
                        '${list[index].name}',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  if (list[index].name == 'Tutorials') {
                    print('================>${list[index].name}');
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            YoutubeVideoTutorial()));
                  } else {
                    print('index is $index');
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => NewsListTabPage(
                              tabIndex: index,
                            )));
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NewsListTabPage extends StatelessWidget {
  final int tabIndex;
  NewsListTabPage({this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      initialIndex: this.tabIndex ?? 0,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Top News'),
              Tab(text: 'Science'),
              Tab(text: 'Health'),
              Tab(text: 'Technology'),
              Tab(text: 'Entertainment'),
              Tab(text: 'Sports'),
              Tab(text: 'Business'),
              Tab(text: 'Politics'),
            ],
          ),
          title: Text('Latest News'),
        ),
        body: TabBarView(
          children: [
            SectionPage('Top News', 'top_news'),
            SectionPage('Science', 'science'),
            SectionPage('Health', 'health'),
            SectionPage('Technolgoy', 'technology'),
            SectionPage('Entertainment', 'entertainment'),
            SectionPage('Sports', 'sports'),
            SectionPage('Business', 'business'),
            SectionPage('Politics', 'politics'),
          ],
        ),
      ),
    );
  }
}

class SectionPage extends StatefulWidget {
  final String title;
  final String newsType;

  SectionPage(this.title, this.newsType);

  @override
  _SectionPageState createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage>
    with AutomaticKeepAliveClientMixin<SectionPage> {
  List<Article> list = List();

  _loadList() async {
    String url;
    if (widget.newsType == "top_news") {
      url =
          'https://newsapi.org/v2/top-headlines?country=gb&apiKey=7d70f878517c4783a7f5715bc803937e#';
    } else {
      url =
          'https://newsapi.org/v2/top-headlines?country=gb&category=${widget.newsType}&apiKey=7d70f878517c4783a7f5715bc803937e#';
    }

    final response = await http.get(url);
    if (response.statusCode == 200) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          var jsonResponse = convert.jsonDecode(response.body);
          /* To check jsonResponse has json data
    print('Total Count: ${jsonResponse['totalResults']}.');
    //expressions come from beautiful json viewer
    print('Title: ${jsonResponse['articles'][0]['title']}');
    */
          var rest = jsonResponse["articles"] as List;
          //print(rest);
          list = rest.map<Article>((json) => Article.fromJson(json)).toList();
        });
      }
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  void initState() {
    _loadList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return list.length != 0
        ? listViewWidget(list)
        : Center(child: CircularProgressIndicator());
  }

  @override
  bool get wantKeepAlive => true;

  Widget listViewWidget(List<Article> article) {
    return Container(
      //child: Text(article[position].title),
      child: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, position) {
          return Card(
            child: ListTile(
              title: Text(
                '${article[position].title}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              leading: SizedBox(
                width: 100,
                height: 100,
                child: Image.network('${article[position].urlToImage}'),
              ),
              onTap: () => _onTapItem(context, article[position]),
            ),
          );
        },
      ),
    );
  }

  void _onTapItem(BuildContext context, Article article) {
    print(article.title);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => NewsDetails(article)));
  }
}

class NewsDetails extends StatefulWidget {
  final Article article;

  NewsDetails(this.article);

  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network('${widget.article.urlToImage}'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${widget.article.title}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${widget.article.description}',
                style: TextStyle(
                  fontSize: 19,
                ),
              ),
            ),
            MaterialButton(
              height: 50.0,
              color: Colors.grey,
              child: Text(
                "Read more...",
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        WebView(widget.article.url)));
              },
            )
          ],
        ),
      ),
    );
  }
}

class YoutubeVideoTutorial extends StatelessWidget {
  final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: '-r15pIKj1FU',
    flags: YoutubePlayerFlags(
      autoPlay: true,
      mute: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressColors: ProgressBarColors(
          playedColor: Colors.amber,
          handleColor: Colors.amberAccent,
        ),
      ),
    );
  }
}

class WebView extends StatefulWidget {
  final String url;
  WebView(this.url);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(),
      url: widget.url,
    );
  }
}

class NewsListPage extends StatelessWidget {
  final String title;
  final String newsType;

  NewsListPage(this.title, this.newsType);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Listtt'),
        backgroundColor: Colors.blueGrey[900],
      ),
      backgroundColor: Colors.lightGreen,
      body: FutureBuilder(
        future: fetchArticles(this.newsType),
        builder: (context, snapshot) {
          return snapshot.data != null
              ? listViewWidget(snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget listViewWidget(List<Article> article) {
    return Container(
      //child: Text(article[position].title),
      child: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, position) {
          return Card(
            child: ListTile(
              title: Text(
                '${article[position].title}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              leading: SizedBox(
                width: 100,
                height: 100,
                child: Image.network('${article[position].urlToImage}'),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<List<Article>> fetchArticles(String newsType) async {
  List<Article> list;

  String url;
  if (newsType == "top_news") {
    url =
        'https://newsapi.org/v2/top-headlines?country=gb&apiKey=7d70f878517c4783a7f5715bc803937e#';
  } else {
    url =
        'https://newsapi.org/v2/top-headlines?country=gb&category=$newsType&apiKey=7d70f878517c4783a7f5715bc803937e#';
  }

  // Await the http get response, then decode the json-formatted response.
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    /* To check jsonResponse has json data
    print('Total Count: ${jsonResponse['totalResults']}.');
    //expressions come from beautiful json viewer
    print('Title: ${jsonResponse['articles'][0]['title']}');
    */
    var rest = jsonResponse["articles"] as List;
    //print(rest);
    list = rest.map<Article>((json) => Article.fromJson(json)).toList();
    list.map((item) => print(item.title.toString()));

    /* To check list has Article objects*/
    //print('First Title:${list.first.title}');
    print('after:${list.length}');
    //list.forEach((element) => print(element.url));
    //print('Source:${list.first.source.name}');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
  return list;
}

class Article {
  Source source;
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  String publishedAt;
  String content;

  Article(
      {this.source,
      this.author,
      this.title,
      this.description,
      this.url,
      this.urlToImage,
      this.publishedAt,
      this.content});

  /* Without Factory function
  Article.fromJson(Map<String, dynamic> json) {
    source =
        json['source'] != null ? new Source.fromJson(json['source']) : null;
    author = json['author'];
    title = json['title'];
    description = json['description'];
    url = json['url'];
    urlToImage = json['urlToImage'];
    publishedAt = json['publishedAt'];
    content = json['content'];
  }
   */

  //we use the factory keyword when implementing a constructor that doesn’t always create a new instance of its class and that’s what we need right now.
  //Serialization simply means writing the data(which might be in an object) as a string, and Deserialization is the opposite of that. It takes the raw data and reconstructs the object model. While getting json response from API, we mostly will be dealing with the deserialization part.
  //Since the key is always a string and the value can be of any type, we keep it as dynamic to be on the safe side.
  //Deserialization
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source:
          json['source'] != null ? new Source.fromJson(json['source']) : null,
      author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      content: json['content'],
    );
  }
}

class Source {
  String id;
  String name;

  Source({this.id, this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(id: json['id'], name: json['name']);
  }
}
