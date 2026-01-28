import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login/login_begin_page.dart';

class StorageManager {
  static SharedPreferences? sp;
  static Future<void> init() async {
    sp = await SharedPreferences.getInstance();
  }
}

void main() {
  // 1. 确保 Flutter 引擎准备好
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 🔴 关键修改：不要在这里 await，直接启动 App！
  // 我们把初始化放到后台去跑，这样开屏界面就能瞬间弹出来
  StorageManager.init().then((_) {
    print("存储工具初始化完成");
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WeChat',
      theme: ThemeData(
          primaryColor: const Color(0xFFEDEDED),
          scaffoldBackgroundColor: const Color(0xFFEDEDED),
          useMaterial3: false,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Color(0xFFEDEDED),
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          )
      ),
      // 指向开屏页
      home: const LoginBeginPage(),
    );
  }
}