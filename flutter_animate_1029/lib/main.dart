import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const FadeAppTest());
}

const List<String> _image = <String>["Zenitsu.jpg", "Minato.jpg"];

class FadeAppTest extends StatelessWidget {
  const FadeAppTest({super.key});

  static const title = ' yellow flash !!';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const MyFadeTest(title: title),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyFadeTest extends StatefulWidget {
  const MyFadeTest({super.key, required this.title});

  final String title;

  @override
  State<MyFadeTest> createState() => _MyFadeTest();
}

//TickerProviderStateMixin提供了用於管理動畫控制器（Ticker）的功能
//with-->不必繼承即可使用其方法和功能
class _MyFadeTest extends State<MyFadeTest> with TickerProviderStateMixin {
  late AnimationController controller;
  late CurvedAnimation curve; //動畫效果
  bool isRunning = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 2000), //動畫的持續時間
      vsync: this, //確保AnimationController的更新與UI刷新保持同步
    );
    curve = CurvedAnimation(
      parent: controller,
      curve: Curves.bounceIn, //彈跳
    );
  }

  void _toggle() {
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        controller.repeat();
      } else {
        controller.stop();
      }
    });
  }

  void _onItemTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: FadeTransition(
            //控制子widget透明度的元件
            opacity: curve,
            child: FittedBox(
              child: Image.asset(
                "assets/${_image.elementAt(_selectedIndex)}",
              ),
            )),
      ),
      backgroundColor: Colors.yellow[50],
      floatingActionButton: FloatingActionButton(
        tooltip: isRunning ? 'stop' : 'start',
        onPressed: _toggle,
        child:
            isRunning ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
      ),
      //浮動按鈕位置
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        //底部按鈕
        items: const [
          //最少為兩個items
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.bolt), label: '我妻善逸'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.bullseye), label: '波風水門'),
        ],
        onTap: _onItemTap, //當作回調傳遞不加()。改變_selectedIndex的值
        currentIndex: _selectedIndex,
      ),
    );
  }
}
