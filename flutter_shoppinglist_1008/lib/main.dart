import 'package:flutter/material.dart';
//內建圖示庫:https://api.flutter.dev/flutter/material/Icons-class.html

class Product {
  const Product({required this.name});

  final String name;
}

//創建可接收兩個參數的函式型態
typedef CartChangedCallback = Function(Product product, bool inCart);

class ShoppingListItem extends StatelessWidget {
  ShoppingListItem({
    required this.product, //產品清單
    required this.inCart, //使否inCart，起始為false
    //_handleCartChanged()更新狀態的方法傳入ShoppingListItem的onCartChanged
    required this.onCartChanged,
  }) : super(key: ObjectKey(product));

  final Product product;
  final bool inCart;
  final CartChangedCallback onCartChanged; //可接收兩個參數的函式型態之變數

  Color _getColor(BuildContext context) {
    return inCart
        ? //三元運算符
        Colors.black38
        : Theme.of(context).primaryColor; //true執行 : false執行
  }

  TextStyle? _getTextStyle(BuildContext context) {
    if (!inCart) return null; //inCart==false-->不改文字型態
    return const TextStyle(
      //文字轉成灰色+刪除線
      color: Colors.black38,
      decoration: TextDecoration.lineThrough,
    );
  }

  //ShoppingListItem的build
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onCartChanged(product, inCart); //執行_handleCartChanged()更新狀態的方法
      },
      leading: CircleAvatar(
        backgroundColor: _getColor(context),
        child: Text(product.name[0]),
      ),
      title: Text(
        product.name,
        style: _getTextStyle(context),
      ),
    );
  }
}

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final _shoppingCart = <Product>{}; //contains用法限定set
  final List<Product> products = [];

  final Set<Product> selectedProducts = <Product>{};

  void _deleteSelectedProducts() {
    setState(() {
      for (final product in selectedProducts) {
        products.remove(product);
      }
      selectedProducts.clear(); // 清除已選擇的項目
    });
  }

  void _addProduct() {
    setState(() {
      // 定義一個控制用戶輸入字串的控制器
      final TextEditingController newProductController =
          TextEditingController();

      showDialog(
        //顯示對話框
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //警示對話框
            title: const Text('輸入新增產品項目'),
            content: TextField(
              controller: newProductController, //將內容傳送到newProductController
              decoration: const InputDecoration(labelText: '輸入產品名稱'), //提示文字
            ),
            actions: <Widget>[
              //按鈕選項
              TextButton(
                //文字按鈕
                onPressed: () {
                  Navigator.of(context).pop(); // 關閉對話框
                },
                child: const Text('取消新增'),
              ),
              TextButton(
                //文字按鈕
                onPressed: () {
                  // 在這裡獲取用戶輸入的產品名稱
                  final newProductName = newProductController.text;
                  // 確保輸入不為空才添加新產品
                  if (newProductName.isNotEmpty) {
                    setState(() {
                      products.add(Product(name: newProductName));
                    });
                  }
                  Navigator.of(context).pop(); // 關閉對話框
                },
                child: const Text('確定新增'),
              ),
            ],
          );
        },
      );
    });
  }

  void _handleCartChanged(Product product, bool inCart) {
    //回調函式
    //如未加入_shoppingCart，則進行新增。
    //同時更新狀態，使inCart=true
    setState(() {
      if (!inCart) {
        _shoppingCart.add(product);
      } else {
        _shoppingCart.remove(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('購物清單'),
        leading: const Icon(Icons.playlist_add_check_circle_outlined),
        actions: [
          IconButton(
            //垃圾桶
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('選擇要刪除的項目'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: products.map((product) {
                        return CheckboxListTile(
                          //勾選列表
                          title: Text(product.name),
                          value: selectedProducts.contains(product),
                          onChanged: (bool? value) {
                            //點擊觸發回調函式
                            setState(() {
                              if (value != null) {
                                //起始value為null
                                if (value) {
                                  selectedProducts.add(product);
                                } else {
                                  selectedProducts.remove(product);
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 關閉對話框
                        },
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 執行刪除操作
                          _deleteSelectedProducts();
                          Navigator.of(context).pop(); // 關閉對話框
                        },
                        child: const Text('確定'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete_forever,
                color: Colors.white, size: 30.0),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: products.map((product) {
          return ShoppingListItem(
            product: product, //從products清單中map出來的值
            inCart: _shoppingCart.contains(product), //inCart起始為false
            onCartChanged: _handleCartChanged,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        tooltip: "新增項目",
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Shopping App',
    theme: ThemeData(
      //APP主題
      primarySwatch: Colors.blue,
    ),
    home: const ShoppingList(),
    debugShowCheckedModeBanner: false,
  ));
}
