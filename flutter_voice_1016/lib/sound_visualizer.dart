import 'package:flutter/material.dart';

class SoundVisualizer extends StatefulWidget {
  const SoundVisualizer(this.soundLevels, this.width, this.height, {super.key});

  final List<double> soundLevels;
  final double width;

  final double height;

  @override
  State<SoundVisualizer> createState() => _SoundVisualizerState();
}

class _SoundVisualizerState extends State<SoundVisualizer> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: SoundWavePainter(widget.soundLevels),
    );
  }
}

class SoundWavePainter extends CustomPainter {
  final List<double> soundLevels;

  SoundWavePainter(this.soundLevels);

  @override
  void paint(Canvas canvas, Size size) {
    //聲波樣式設定
    final Paint paint = Paint() //new paint物件
      //等於paint.color、paint.style、paint.strokeWidth
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke //繪製方式。
      ..strokeWidth = 2.0;

    //y=0的位置在繪製區域的上方。
    final double centerY = size.height - (size.height / 12 * 2); //高度的2/12
    //聲音級別區間[-2,-10]
    final double yScale = size.height / 12; //声音级别的缩放。分12等分
    final Path path = Path(); //建構聲波路徑
    for (int i = 0; i < soundLevels.length; i++) {
      final double x = i.toDouble(); //X軸
      final double y = centerY - soundLevels[i] * yScale; //Y軸

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y); //從上一個點連接到現在的點
      }
    }

    //path-->路徑，paint-->設定繪圖方式
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    //當聲音級別發生變化時重新繪製聲音波形
    return true;
  }
}
