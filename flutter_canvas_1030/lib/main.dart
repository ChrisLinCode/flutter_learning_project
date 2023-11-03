import 'package:flutter/material.dart';
import 'dart:ui' as ui; //處理影像
import 'package:permission_handler/permission_handler.dart'; //請求管理權限
import 'package:path_provider/path_provider.dart'; //應用程式文件目錄
import 'dart:io'; //File函式
import 'view_page.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';//顏色選擇

void main() => runApp(const SignApp());

class SignApp extends StatelessWidget {
  const SignApp({super.key});

  static const title = '簽名APP';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const Signature(title: title),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Signature extends StatefulWidget {
  const Signature({super.key, required this.title});

  final String title;

  @override
  SignatureState createState() => SignatureState();
}

class SignatureState extends State<Signature> {
  //Offset在Flutter中用於表示位置數據。?-->可能為空
  List<Offset?> _points = <Offset>[];
  List<String> savedImagePaths = []; //導覽列清單
  late String filePath;
  Color _penColor = Colors.black; //筆色

  void clearSignature() {
    setState(() {
      _points.clear(); // 清空座標點列表
    });
  }

  //非同步函式通常返回一個 Future 對象
  Future<void> saveSignature() async {//非同步函式
    // await-->等待異步操作完成才繼續執行
    //畫布轉圖像
    final image = await captureCanvasToImage(
      Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      SignaturePainter(_points,_penColor),
    );
    //圖像轉數位格式。dart:ui套件
    final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      //正規化後的影像資料
      final buffer = byteData.buffer.asUint8List();
      //抓暫存目錄
      final directory = (await getTemporaryDirectory()).path;
      //加入時間亂數防止檔案覆蓋
      filePath = '$directory/signature_${DateTime.now().millisecondsSinceEpoch}.png';
      //將影像寫入檔案
      File(filePath).writeAsBytesSync(buffer);
      setState(() {
        savedImagePaths.add(filePath); //將路徑加入導覽清單
      });
    }
  }

  void showColorPickerDialog() {
    Color currentColor = _penColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('選擇畫筆顏色'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _penColor,
              onColorChanged: (color) {
                  currentColor = color; // 更新畫筆顏色
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('變更'),
              onPressed: () {
                setState(() {
                  _penColor = currentColor; // 將所選顏色設為畫筆顏色
                  _points.add(null);
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('返回'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              showColorPickerDialog();
            },
            icon: const Icon(Icons.border_color_outlined),
          ),
          IconButton(
            onPressed: clearSignature,
            icon: const Icon(Icons.restart_alt),
          ),
          IconButton(
            onPressed: () {
              saveSignature(); // 呼叫 saveSignature 函數
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: GestureDetector(
        //偵測使用者手勢
        //當用戶在屏幕上滑動手指時觸發
        onPanUpdate: (details) {
          setState(() {
            //localPosition-->手機螢幕位置映射成元件所占用的空間的對應位置
            Offset position = details.localPosition;
            //創建了一個 _points 列表的副本，再將localPosition加入，最後assign
            //..-->連鎖語法，節省使用暫存變數
            _points = List.from(_points)..add(position);
          });
        },
        //當用戶停止滑動手指時觸發
        onPanEnd: (details) => _points.add(null),
        child: CustomPaint(
          //自定義繪製元件
          painter: SignaturePainter(_points,_penColor),
          size: MediaQuery.of(context).size, //螢幕尺寸
        ),
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: savedImagePaths.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('存檔 ${index+1}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewSignaturePage(savedImagePaths[index]),
                  ),
                ).then((removedPath) {
                  if (removedPath != null) {//回傳了清單路徑
                    setState(() {
                      savedImagePaths.remove(removedPath); // 從清單中刪除返回的路徑
                      // 执行其他状态更新操作
                    });
                  }
                });
              },
            );
          },
        ),
      ),
    );
  }
}

//Future 是 Dart 中用於表示非同步操作的一個重要概念
Future<ui.Image?> captureCanvasToImage(Size size, CustomPainter signaturePainter) {
  final recorder = ui.PictureRecorder();//捕捉畫布上的筆跡
  final canvas = Canvas(recorder);//new 畫布物件
  //為了將這些已經存在於畫布上的筆跡捕捉為一個 ui.Picture
  signaturePainter.paint(canvas, size);
  //終止ui.PictureRecorder並返回一個ui.Picture物件
  final picture = recorder.endRecording();
  return picture.toImage(size.width.toInt(), size.height.toInt());
}

//CustomPainter-->自訂的繪製演算法
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  late Paint paintobj; // Paint 物件

  SignaturePainter(this.points,this.color){
    paintobj = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
  }

  @override
  void paint(Canvas canvas, Size size) { //paint 方法完成時，它將返回一個 ui.Picture 對象
    //將使用每個點和下一個點之間的線段來繪製筆跡，所以不需要處理最後一個點
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        //! 被放在一個變數後面時-->變數不會為空（null）
        canvas.drawLine(points[i]!, points[i + 1]!, paintobj);
      }
    }
  }

  //路徑不同、顏色不同-->重新繪製
  @override
  bool shouldRepaint(SignaturePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

// 请求权限。應用程式權限-->setting-->permission manager
Future<void> requestStoragePermission() async {
  await Permission.storage.request();
}

