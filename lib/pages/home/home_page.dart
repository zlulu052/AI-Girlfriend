import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 引入 AI 聊天窗口
import '../chat/chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  // 🔥 伪造的聊天数据
  final List<Map<String, String>> _mockChats = [
    {
      "name": "沈慕瑶 (AI女友)",
      "msg": "[语音] 亲爱的，今晚想吃什么呀？",
      "time": "刚刚",
      "avatar": "assets/images/girlfriend.webp",
      "isTop": "true",
    },
    {
      "name": "文件传输助手",
      "msg": "[图片] IMG_20260121.jpg",
      "time": "19:08",
      "avatar": "assets/images/ic_file_transfer.webp",
      "isTop": "false",
    },
    {
      "name": "相亲相爱一家人 (8)",
      "msg": "妈妈: @所有人 周末都回来吃饭！炖了排骨。",
      "time": "18:20",
      "avatar": "group",
      "isTop": "false",
    },
    {
      "name": "技术部工作群",
      "msg": "张主管: 那个Bug修复了吗？收到请回复。",
      "time": "14:30",
      "avatar": "group",
      "isTop": "false",
    },
    {
      "name": "微信支付",
      "msg": "微信支付凭证：你向[美团外卖]支付了 28.50 元",
      "time": "昨天",
      "avatar": "pay",
      "isTop": "false",
    },
    {
      "name": "李强",
      "msg": "哥们，借你的书什么时候还？",
      "time": "星期一",
      "avatar": "person",
      "isTop": "false",
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // 🔴 删除了原本在这里的 appBar 代码，解决了重复显示的问题
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: _mockChats.length,
          itemBuilder: (context, index) {
            final chat = _mockChats[index];
            bool isTop = chat['isTop'] == "true";

            return InkWell(
              onTap: () {
                // 如果点击的是女友，跳转到女友聊天页
                if (chat['name']!.contains("沈慕瑶")) {
                  // 这里调用 ChatPage，传入 title 作为名字
                  Get.to(() => ChatPage(userName: "沈慕瑶", title: "沈慕瑶"));
                }
              },
              child: Container(
                color: isTop ? const Color(0xFFF7F7F7) : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey[200],
                      ),
                      child: _buildAvatar(chat['avatar']!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(chat['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              Text(chat['time']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chat['msg']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(String type) {
    if (type == "group") {
      return const Icon(Icons.people, color: Colors.grey);
    } else if (type == "pay") {
      return const Icon(Icons.payment, color: Colors.orange);
    } else if (type == "person") {
      return const Icon(Icons.person, color: Colors.grey);
    } else if (type.startsWith("assets")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(type, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person)),
      );
    }
    return const Icon(Icons.folder_shared, color: Colors.green);
  }
}