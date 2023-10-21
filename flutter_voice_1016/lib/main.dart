import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart'; //偵測語音辨識錯誤的套件
import 'package:avatar_glow/avatar_glow.dart'; //mic動畫套件
import 'dart:math';
import 'package:flutter/foundation.dart'; //導入 kDebugMode 常量
import 'sound_visualizer.dart'; //聲音視覺化.dart

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter speech_to_text',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        //確保在不同設備上都有較好的外觀和使用體驗
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  bool _hasSpeech = false;

  //使用它來執行語音識別相關的操作，例如初始化語音識別、開始識別、停止識別等。
  final SpeechToText speech = SpeechToText(); //from speech_to_text package

  List<double> soundLevels = [0.0]; // 聲音視覺化清單
  double level = 0.0; //聲音級別，控制收音動畫的波動
  double minSoundLevel = double.infinity; // 初始化为正無限大
  double maxSoundLevel = double.negativeInfinity; // 初始化为負無限小

  final String _currentLocaleId = 'zh_TW'; //設定系統辨識的語言
  String _text = 'say something'; //初始body內容
  double _confidence = 1.0; //初始信賴水準

  void statusListener(String status) {
    // 在這個回調中處理語音識別的狀態變化
    if (kDebugMode) {
      print('語音識別狀態: $status'); // 只在 Debug 模式下调用 print
    }
    if (status == 'notListening') {
      // 語音識別已停止
      setState(() {
        _text = '語音識別已停止';
      });
    } else if (status == 'listening') {
      // 語音識別正在進行中
      setState(() {
        _text = '正在聆聽...';
      });
    }
  }

  void errorListener(SpeechRecognitionError error) {
    // 在這個回調中處理語音識別的錯誤
    setState(() {
      _text = '語音識別錯誤: ${error.errorMsg}';
    });
  }

  @override
  void initState() {
    //會在 StatefulWidget 創建後立即被調用
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    //async-->非同步方法
    /*
    await-->用于等待初始化操作完成。
    initialize-->初始化語音辨識。
    onStatus：是一個回調函數，當語音識別的狀態發生變化時，它會被調用。
    onError：是一個回調函數，當發生錯誤時，它會被調用。
    debugLogging-->debug日誌
     */
    var hasSpeech = await speech.initialize(
        onStatus: statusListener, onError: errorListener, debugLogging: false);
    if (!mounted) return; //确保小部件是否仍然挂载在界面上
    setState(() {
      _hasSpeech = hasSpeech; //是否成功初始化
    });
  }

  void stopListening() {
    speech.stop();
    _text = '已取消說話';
    setState(() {
      level = 0.0;
    });
  }

  void startListening() {
    _text = '我在聽';
    soundLevels.clear(); // 在开始新的语音识别前清空soundLevels列表
    speech.listen(
        //啟動語音辨識操作
        //val-->系統辨識到的結果
        onResult: (val) => setState(() {
              //成功辨識到語音時調用
              _text = val.recognizedWords; //assign辨識到的文字
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence; //assign信賴水準
              }
            }),
        //listenFor: const Duration(seconds: 5),//可設置強制停止時間
        pauseFor: const Duration(seconds: 5),
        //等待使用者停頓時間
        partialResults: true,
        //只在完整结果可用时觸發 onResult
        localeId: _currentLocaleId,
        //語言設定
        onSoundLevelChange: soundLevelListener,
        //聲音級別變化時調用
        cancelOnError: true,
        //發生錯誤取消辨識
        listenMode: ListenMode.confirmation //與使用者確認辨識結果
        );
    setState(() {});
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    if (kDebugMode) {
      print("sound level =$level。 聲音級別區間 $minSoundLevel ~ $maxSoundLevel ");
    }
    setState(() {
      //level變數assign後立即更新
      this.level = level;
      soundLevels.add(level); // 将 level 添加到 soundLevels 列表
    });
  }

  @override
  Widget build(BuildContext context) {
    //MediaQuery是Flutter中用于查询设备和屏幕信息的class
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width * 0.8; // 80% 屏幕宽度
    final height = screenSize.height * 0.1; // 10% 屏幕高度
    SoundVisualizer soundVisualizer =
        SoundVisualizer(soundLevels, width, height); //繪製聲音可視圖

    return Scaffold(
        appBar: AppBar(
          title: const Text('語音辨識APP'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          //動畫效果
          animate: speech.isListening,
          //bool值，控制動畫開關
          glowColor: Theme.of(context).primaryColor,
          endRadius: 100.0,
          //動畫結束半徑
          duration: const Duration(milliseconds: 2000),
          //每次動畫持續時間
          repeatPauseDuration: const Duration(milliseconds: 10),
          repeat: true,
          child: FloatingActionButton(
            onPressed: !_hasSpeech || speech.isListening
                ? stopListening //語音辨識初始化未完成 OR 聆聽中被點擊
                : startListening, //語音辨識初始化完成 OR 非聆聽中
            child: Icon(speech.isListening ? Icons.mic : Icons.mic_none),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Text(
                  //toStringAsFixed(1)-->將百分比值格式轉字串，並保留小數一位
                  'Confidence Level: ${(_confidence * 100.0).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: 400,
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 30),
                child: SingleChildScrollView(
                  child: Text(
                    _text,
                    style: const TextStyle(
                      fontSize: 26.0,
                      color: Colors.black,
                      //fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Container(
                  width: width,
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, //水平滾動
                    child: soundVisualizer,
                  ))
            ],
          ),
        ));
  }
}
