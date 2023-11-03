import 'package:flutter/material.dart';
import 'dart:io'; //File函式

class ViewSignaturePage extends StatelessWidget {
  const ViewSignaturePage(this.imagePath, {super.key});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Signature'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context,imagePath);
            },
            icon: const Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: Center(
        child: Image.file(File(imagePath)), // 顯示已保存的畫布
      ),
    );
  }
}
