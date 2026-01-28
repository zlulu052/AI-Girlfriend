import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/dictionary.dart';
import '../../im/model/contacts.dart';
import '../../tools/event/im_event.dart';
import '../../tools/wechat_flutter.dart';
import '../../ui/item/contact_item.dart';
import '../../ui/item/contact_view.dart';

// 🔥 确保引用了正确的聊天页面
import '../chat/chat_page.dart';

// ---------------------------------------------------------------------------
// ⚙️ 全局配置
// ---------------------------------------------------------------------------
const String GIRL_NAME = "沈慕瑶";
const String AVATAR_PATH = 'assets/images/girlfriend.webp';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});
  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> with AutomaticKeepAliveClientMixin {
  ScrollController? sC;
  final List<Contact> _contacts = <Contact>[];
  StreamSubscription<dynamic>? _msgStreamSubs;

  final List<ContactItem> _functionButtons = <ContactItem>[
    ContactItem(avatar: '${contactAssets}ic_new_friend.webp', title: '新的朋友'),
    ContactItem(avatar: '${contactAssets}ic_group.webp', title: '群聊'),
    ContactItem(avatar: '${contactAssets}ic_tag.webp', title: '标签'),
    ContactItem(avatar: '${contactAssets}ic_no_public.webp', title: '公众号'),
  ];

  Future<void> getContacts() async {
    final List<Contact> str = await ContactsPageData().listFriend();
    _contacts.clear();
    _contacts.addAll(str);
    _contacts.sort((a, b) => a.nameIndex.compareTo(b.nameIndex));
    sC = ScrollController();
    if (mounted) setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    sC?.dispose();
    _msgStreamSubs?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getContacts();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    _msgStreamSubs ??= eventBusNewMsg.listen((EventBusNewMsg onData) {
      getContacts();
    });
  }

  // 🔥 修复版入口：传参正确，高度对齐
  Widget _buildAiGirlfriendRow() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              // 🔴 关键修复：同时传入 userName 和 title，确保 ChatPage 初始化正确
              onTap: () => Get.to(() => ChatPage(
                userName: GIRL_NAME,
                title: GIRL_NAME,
                type: 1, // 传入默认类型防止报错
              )),
              child: Container(
                height: 54.0, // 标准高度
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    // 头像
                    Container(
                      width: 36.0, height: 36.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: const DecorationImage(
                          image: AssetImage(AVATAR_PATH),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 名字
                    const Text(
                      GIRL_NAME,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 分割线
          Container(
            height: 0.5,
            color: const Color(0xFFD8D8D8),
            margin: const EdgeInsets.only(left: 64),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('通讯录', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.black), onPressed: (){}),
        ],
      ),
      body: Column(
        children: [
          _buildAiGirlfriendRow(),
          Expanded(
            child: ContactView(
              sC: sC,
              functionButtons: _functionButtons,
              contacts: _contacts,
            ),
          ),
        ],
      ),
    );
  }
}