import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:flutter/rendering.dart'; //查看布局邊界
//圖示庫連結:https://api.flutter.dev/flutter/material/Icons-class.html

void main() {
  debugPaintSizeEnabled = false; //查看布局邊界。偵錯用
  runApp(const MyAppWrapper());
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyApp(), // 将BuildContext傳遞给MyApp
      debugShowCheckedModeBanner: false,
    );
  }
}

class TabChoice {
  final String name;
  final String codename;
  late int popularity;
  final String intro;
  final String image;

  TabChoice(
    this.name,
    this.codename,
    this.intro,
    this.image,
  ) {
    // 生成 50 到 100 之间的n隨機數
    final random = Random();
    popularity = random.nextInt(51) + 50;
  }
}

List<TabChoice> tabList = <TabChoice>[
  TabChoice(
    '洛伊德·佛傑',
    '<黃昏>',
    "本作主角，佛傑一家之主。在東國從事諜報活動的西國頂尖間諜，代號〈黃昏〉，為了成為間諜而捨棄自己的本名，現在使用伯林特綜合醫院精神科醫生洛伊德·佛傑的身分活動著。",
    'loid.png',
  ),
  TabChoice(
      '安妮亞·佛傑',
      '<實驗體007>',
      "本作主角之一，佛傑一家的最小成員。經歷某組織實驗而獲得讀心能力的超能力女童。洛伊德和約兒的養女，為了進入伊甸學園就讀而謊稱是6歲，但實際年齡應為4、5歲左右。",
      'anya.jpg'),
  TabChoice(
    '約兒·佛傑',
    '<睡美人>',
    "本作主角之一，佛傑一家主婦。舊姓布萊爾(Briar)，27歲。表面上是伯林特市政府的女性公務員，實際上是一名技藝高超的職業殺手，代號〈睡美人〉，隸屬於暗殺組織〈花園〉。",
    'yor.jpg',
  )
];

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Widget image(TabChoice tab) {
      return FittedBox(
        fit: BoxFit.contain,
        // 你可以選擇其他適當的fit模式，例如 BoxFit.fill
        alignment: Alignment.center,
        // 圖片對齊方式
        //從網路抓取圖片的語法:Image.network('https://titangene.github.io/images/cover/flutter.jpg')
        child: Image.asset(
          'assets/${tab.image}',
        ),
      );
    }

    //標題列區塊設定
    Widget titleSection(TabChoice tab, BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              child: Column(
                //文字並排
                crossAxisAlignment: CrossAxisAlignment.start, //靠左對齊
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      tab.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, //粗體
                      ),
                    ),
                  ),
                  Text(
                    tab.codename,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                incrementPopularity(tab);
              },
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              label: Text(
                '人氣值: ${tab.popularity}',
                style: const TextStyle(color: Colors.black54),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).primaryColorLight),
              ),
            ),
          ],
        ),
      );
    }

    //按鈕區塊設定
    Widget buttonSection(BuildContext context) {
      return Row(
        //按鈕布局
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(context, FontAwesomeIcons.phone, 'CALL'),
          _buildButtonColumn(context, FontAwesomeIcons.locationDot, 'LOCATION'),
          _buildButtonColumn(context, FontAwesomeIcons.message, 'MESSAGE'),
        ],
      );
    }

    Widget textSection(TabChoice tab) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Text(
          tab.intro,
          softWrap: true, //文字將在填充滿列寬後在單詞邊界處自動換行
        ),
      );
    }

    return DefaultTabController(
      //控制tabbar數量並管理狀態
      length: tabList.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SPY X Family'),
          bottom: TabBar(
            //每個tab對應到 tabList 中的一個元素，tab.name 被用作tab標籤的文字。
            tabs: tabList.map((tab) => Tab(text: tab.name)).toList(),
          ),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return TabBarView(
              //顯示與tab標籤相關的內容
              children: tabList.map((tab) {
                return ListView(
                  children: [
                    image(tab),
                    titleSection(tab, context), // 传递BuildContext
                    buttonSection(context),
                    textSection(tab),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  } //build

  Column _buildButtonColumn(BuildContext context, IconData icon, String label) {
    //圖示布局方式
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400, //文字粗細程度400為正常
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void incrementPopularity(TabChoice tab) {
    setState(() {
      tab.popularity++; // 增加popularity的值
    });
  }
}
