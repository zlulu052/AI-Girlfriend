import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimCommunityListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimFriendshipListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimGroupListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_application.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_change_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_change_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_receipt.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_status.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:wechat_flutter/provider/global_model.dart';
import 'package:wechat_flutter/tools/wechat_flutter.dart';

import '../pages/login/login_begin_page.dart';
import '../pages/root/root_page.dart';
import '../tools/event/im_event.dart';
import 'GenerateUserSig.dart';

// ✅ 确保这里是你的真实 ID 和 密钥
const int appId = 1600123425;
const String appKey = '9d7d856b091bfe830a753d8b6942f02e61f13c03964177252d241ba54d146293';

class ImLoginManager {
  static V2TimSDKListener? _sdkListener;
  static const int expireTime = 604800;
  static bool _isInitialized = false; // ✅ 标记是否初始化过

  static Future<bool> init(BuildContext context) async {
    if (_isInitialized) return true; // 如果已经初始化过，直接返回

    _sdkListener = V2TimSDKListener(
      onConnectFailed: (int code, String error) => log('连接失败: $code $error'),
      onConnectSuccess: () => log('连接成功'),
    );

    V2TimValueCallback<bool> initSDKRes = await TencentImSDKPlugin.v2TIMManager.initSDK(
      sdkAppID: appId,
      loglevel: LogLevelEnum.V2TIM_LOG_ALL,
      listener: _sdkListener!,
    );

    if (initSDKRes.code == 0) {
      debugPrint('IM 初始化成功');
      _isInitialized = true;
      addGroupListener();
      await addAdvancedMsgListener();
      addFriendshipListener();
      addConversationListener();
      return true;
    } else {
      debugPrint('IM 初始化失败: ${initSDKRes.desc}');
      return false;
    }
  }

  static Future<void> login(String userName, BuildContext context) async {
    // 🛠️ 第一步：强行执行初始化并等待结果
    bool isOk = await init(context);
    if (!isOk) {
      showToast('SDK初始化失败，请检查网络或配置');
      return;
    }

    // 🛠️ 第二步：稍微等待半秒钟，让 SDK 彻底就绪（防止 not init 报错）
    await Future.delayed(Duration(milliseconds: 500));

    final model = Provider.of<GlobalModel>(context, listen: false);

    GenerateDevUsersigForTest generateDevUsersigForTest =
    GenerateDevUsersigForTest(sdkappid: appId, key: appKey);
    String userSig = generateDevUsersigForTest.genSig(
        identifier: userName, expire: expireTime);

    V2TimCallback loginRes = await TencentImSDKPlugin.v2TIMManager
        .login(userID: userName, userSig: userSig);

    if (loginRes.code == 0) {
      model.account = userName;
      model.goToLogin = false;
      await SharedUtil.instance.saveString(Keys.account, userName);
      await SharedUtil.instance.saveBoolean(Keys.hasLogged, true);
      model.refresh();
      await Get.offAll(new RootPage());
    } else {
      // 如果报错仍是 not init，说明 SDKAppID 在底层没更新
      showToast('登录失败: ${loginRes.desc}');
    }
  }

  static Future<void> loginOut(BuildContext context) async {
    final model = Provider.of<GlobalModel>(context, listen: false);
    V2TimCallback call = await TencentImSDKPlugin.v2TIMManager.logout();
    if (call.code == 0) {
      model.goToLogin = true;
      _isInitialized = false; // 登出后重置状态
      model.refresh();
      await SharedUtil.instance.saveBoolean(Keys.hasLogged, false);
      await Get.offAll(new LoginBeginPage());
      showToast('登出成功');
    }
  }

  // --- 补充缺失的方法，确保编译通过 ---
  static void addConversationListener() {
    TencentImSDKPlugin.v2TIMManager.getConversationManager().addConversationListener(
      listener: V2TimConversationListener(),
    );
  }

  static void addFriendshipListener() {
    TencentImSDKPlugin.v2TIMManager.getFriendshipManager().addFriendListener(
      listener: V2TimFriendshipListener(),
    );
  }

  static Future<void> addAdvancedMsgListener() async {
    await TencentImSDKPlugin.v2TIMManager.getMessageManager().addAdvancedMsgListener(
      listener: V2TimAdvancedMsgListener(onRecvNewMessage: (msg) {
        eventBusNewMsg.value = EventBusNewMsg(msg.userID ?? msg.groupID!);
      }),
    );
  }

  static Future<void> addGroupListener() async {
    await TencentImSDKPlugin.v2TIMManager.addGroupListener(
      listener: V2TimGroupListener(),
    );
  }
}