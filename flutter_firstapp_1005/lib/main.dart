import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //提供狀態管理
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; //font_awesome圖示庫
//flutter內建圖示庫:https://api.flutter.dev/flutter/material/Icons-class.html

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
        theme: ThemeData(
          //簡易顏色設定語法primarySwatch: Colors.red,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
          textTheme: TextTheme(
            displayMedium: TextStyle(
                //onPrimary-->自動生成能夠在Primary顏色上清晰可見的顏色
                color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

//不同頁面都需要使用的方法可放在ChangeNotifier中，否則StatefulWidget即可
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  List<WordPair> history = [];

  void getNext() {
    history.add(current);
    current = WordPair.random();
    notifyListeners();
  }

  void goToPrevious() {
    if (history.isNotEmpty) {
      // 刪除最後一筆資料並assign給current
      current = history.removeLast();
      notifyListeners();
    }
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    //favorites是否擁有current
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState(); //生成可管理自身state的class
}

class _MyHomePageState extends State<MyHomePage> {
  //這是一個狀態而不是元件

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        //Placeholder()-->flutter內建，替代尚未設計的UI介面
        break;
      default: //其他
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "WordPair產生器",
          style: TextStyle(color: Colors.white),
        ),
        leading: Icon(FontAwesomeIcons.shuffle, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Row(
        children: [
          //在安全範圍內顯示APP內容，以确保应用程序内容不会被这些遮擋、覆蓋。
          SafeArea(
            child: NavigationRail(
              //導航欄
              extended: false, //自動調整寬度
              selectedIndex: selectedIndex, //起始預設值
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
              //被點選的索引值assignTo-->value
              onDestinationSelected: (value) {
                setState(() {
                  //通知_MyHomePageState進行狀態更新
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            //最大化可用空間
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //用來監聽和獲取與 MyAppState 的狀態
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    //favorites清單是否包含現在的wordPair
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair), //自訂義物件
          SizedBox(height: 10),
          Row(
            //只使用最小需求的空間，否則他會把上一層的COL撐開到最大
            mainAxisSize: MainAxisSize.min,
            children: [
              //新增
              ElevatedButton(
                onPressed: () {
                  appState.goToPrevious();
                },
                child: Text('Back'),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                //有圖示的按鈕
                onPressed: () {
                  //透過appState變數來使用MyAppState()中的toggleFavorite()方法
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  //透過appState變數來使用MyAppState()中的getNext()方法
                  appState.getNext();
                },
                child: Text('Next'),
              ),
              //navigate_next
            ],
          ),
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
    final theme = Theme.of(context); //取得APP的主題設定

    return Card(
        //以卡片型態顯示
        color: theme.colorScheme.primary,
        child: Padding(
          padding: EdgeInsets.all(20.0), //間接影響卡片大小
          child: Text(
            pair.asPascalCase,
            style: theme.textTheme.displayMedium,
          ),
        ));
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

    return ListView.builder(
      itemCount: appState.favorites.length,
      itemBuilder: (context, index) {
        WordPair pair = appState.favorites[index];
        return Dismissible(
          //左滑子元素以執行刪除操作的元件
          key: UniqueKey(), // 每個 Dismissible 必須有唯一的 key
          onDismissed: (direction) {
            //當用戶執行刪除操作時被調用
            appState.removeFavorite(pair);
          },
          background: Container(
            //左滑子元素時顯示的背景
            color: Colors.red,
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asPascalCase),
          ),
        );
      },
    );
  }
}
