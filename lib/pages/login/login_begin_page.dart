import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../root/root_page.dart';

class LoginBeginPage extends StatefulWidget {
  const LoginBeginPage({Key? key}) : super(key: key);

  @override
  State<LoginBeginPage> createState() => _LoginBeginPageState();
}

class _LoginBeginPageState extends State<LoginBeginPage> {
  @override
  void initState() {
    super.initState();
    // 3秒后跳转主页
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => const RootPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 地球图片
            Image.asset(
              'assets/images/bsc.webp',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(color: Colors.black),
            ),
            // 底部的“微信”文字
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "微信",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}