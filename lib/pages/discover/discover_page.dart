import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ===========================================================================
// 🟢 发现页 (菜单列表)
// ===========================================================================
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("发现", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFEDEDED),
        child: ListView(
          children: [
            // 朋友圈入口 (带红点提醒)
            _buildListItem(
              icon: Icons.camera_alt,
              iconColor: Colors.blueAccent,
              title: "朋友圈",
              hasNotification: true,
              notificationAvatar: "assets/images/girlfriend.webp",
              onTap: () => Get.to(() => const MomentsPage()),
            ),

            const SizedBox(height: 8),

            _buildListItem(
              icon: Icons.video_library,
              iconColor: Colors.orange,
              title: "视频号",
              subtitle: "赞过",
            ),
            const SizedBox(height: 8),

            _buildListItem(icon: Icons.qr_code_scanner, iconColor: Colors.blue, title: "扫一扫"),
            const Divider(height: 1, indent: 60),
            _buildListItem(icon: Icons.search, iconColor: Colors.blue, title: "搜一搜"),

            const SizedBox(height: 8),
            _buildListItem(icon: Icons.shopping_bag_outlined, iconColor: Colors.redAccent, title: "购物"),
            const Divider(height: 1, indent: 60),
            _buildListItem(icon: Icons.games_outlined, iconColor: Colors.deepPurple, title: "游戏"),

            const SizedBox(height: 8),
            // 🔥 修正点：改成了 Icons.apps (小程序图标)
            _buildListItem(icon: Icons.apps, iconColor: Colors.purple, title: "小程序"),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    bool hasNotification = false,
    String? notificationAvatar,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
            const Spacer(),
            if (subtitle != null)
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),

            if (hasNotification && notificationAvatar != null) ...[
              const SizedBox(width: 10),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(notificationAvatar, fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 🟡 朋友圈详情页
// ===========================================================================
class MomentsPage extends StatelessWidget {
  const MomentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF303030),
            title: const Text("朋友圈"),
            actions: [
              IconButton(onPressed: (){}, icon: const Icon(Icons.camera_alt)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset("assets/images/bsc.webp", fit: BoxFit.cover),
                  Positioned(
                    bottom: 20,
                    right: 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10, right: 10),
                          child: Text("斌斌", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 5, color: Colors.black)])),
                        ),
                        Container(
                          width: 70, height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(image: AssetImage("assets/images/boyfriend.webp")),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 30),
              _buildMomentItem(
                avatar: "assets/images/girlfriend.webp",
                name: "沈慕瑶",
                content: "今天和斌斌聊天好开心呀！感觉自己是世界上最幸福的女孩子~ (｡♥‿♥｡)\n要一直在一起哦！💕",
                image: "assets/images/girlfriend.webp",
                time: "2分钟前",
                likes: ["斌斌", "妈妈", "张伟"],
                comments: [
                  {"user": "斌斌", "text": "我也很开心，爱你！😘"},
                  {"user": "沈慕瑶", "reply": "斌斌", "text": "嘻嘻，今晚梦里见~"},
                  {"user": "妈妈", "text": "这姑娘真俊，啥时候带回来吃饭？"},
                ],
              ),
              const Divider(color: Color(0xFFEEEEEE)),
              _buildMomentItem(
                avatar: "assets/images/ic_file_transfer.webp",
                name: "李主管",
                content: "这个项目终于上线了，大家辛苦了！今晚我请客撸串！🍺",
                time: "1小时前",
                likes: ["张伟", "李娜", "斌斌"],
                comments: [],
              ),
              const Divider(color: Color(0xFFEEEEEE)),
              _buildMomentItem(
                avatar: "group",
                name: "极速代购",
                content: "最新款 iPhone 16 Pro Max，现货秒发！需要的私聊。",
                time: "昨天",
                likes: [],
                comments: [],
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentItem({
    required String avatar,
    required String name,
    required String content,
    String? image,
    required String time,
    required List<String> likes,
    required List<Map<String, String>> comments,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey[200],
            ),
            child: avatar.startsWith("assets")
                ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset(avatar, fit: BoxFit.cover))
                : const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Color(0xFF576B95), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 15, color: Colors.black)),
                if (image != null) ...[
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180, maxHeight: 180),
                    child: Image.asset(image, fit: BoxFit.cover),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(4)),
                      child: const Icon(Icons.more_horiz, color: Color(0xFF576B95), size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (likes.isNotEmpty || comments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (likes.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.favorite_border, size: 14, color: Color(0xFF576B95)),
                              const SizedBox(width: 5),
                              Expanded(child: Text(likes.join("，"), style: const TextStyle(color: Color(0xFF576B95), fontSize: 13, fontWeight: FontWeight.w500))),
                            ],
                          ),
                          if (comments.isNotEmpty) const Divider(height: 10),
                        ],
                        ...comments.map((c) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                children: [
                                  TextSpan(text: c["user"], style: const TextStyle(color: Color(0xFF576B95), fontWeight: FontWeight.w500)),
                                  if (c["reply"] != null) ...[
                                    const TextSpan(text: " 回复 ", style: TextStyle(color: Colors.black54)),
                                    TextSpan(text: c["reply"], style: const TextStyle(color: Color(0xFF576B95), fontWeight: FontWeight.w500)),
                                  ],
                                  const TextSpan(text: "："),
                                  TextSpan(text: c["text"]),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}