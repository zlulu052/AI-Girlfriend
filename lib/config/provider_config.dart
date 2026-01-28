import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wechat_flutter/provider/global_model.dart';
import 'package:wechat_flutter/provider/login_model.dart'; // 确认这个路径正确

class ProviderConfig {
  static ProviderConfig? _instance;

  static ProviderConfig getInstance() {
    if (_instance == null) {
      _instance = ProviderConfig._internal();
    }
    return _instance!;
  }

  ProviderConfig._internal();

  // 全局模型
  ChangeNotifierProvider<GlobalModel> getGlobal(Widget child) {
    return ChangeNotifierProvider<GlobalModel>(
      create: (context) => GlobalModel(),
      child: child,
    );
  }

  // 登录模型 ✅ 这里的 <LoginModel> 必须和 LoginPage 里 Provider.of<LoginModel> 一致
  ChangeNotifierProvider<LoginModel> getLoginPage(Widget child) {
    return ChangeNotifierProvider<LoginModel>(
      create: (context) => LoginModel(),
      child: child,
    );
  }
}