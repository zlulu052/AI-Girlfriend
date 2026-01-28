import 'package:flutter/material.dart';

class MinePage extends StatefulWidget {
  const MinePage({Key? key}) : super(key: key);

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED), // 微信经典的灰背景
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView(
          children: [
            // 1. 头部个人信息区
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 16),
              child: Row(
                children: [
                  // 头像
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/boyfriend.webp'), // 这里填你的头像路径
                        fit: BoxFit.cover,
                      ),
                    ),
                    // 如果头像加载失败，显示灰色方块，不显示红字
                    child: Image.asset('assets/images/boyfriend.webp', fit: BoxFit.cover,
                        errorBuilder: (c,e,s) => Container(color: Colors.grey[300], child: Icon(Icons.person, size: 40, color: Colors.grey))),
                  ),
                  const SizedBox(width: 20),
                  // 名字和微信号
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("斌斌", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Text("微信号：wxid_888888", style: TextStyle(fontSize: 14, color: Colors.grey)),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey)
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.qr_code, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 2. 支付/服务 (使用 Icon 替代 Image，消除红字)
            _buildListItem(icon: Icons.wechat, iconColor: const Color(0xFF2BAD13), title: "服务"),
            const SizedBox(height: 8),

            // 3. 收藏、朋友圈等
            _buildListItem(icon: Icons.collections_bookmark_outlined, iconColor: Colors.orange, title: "收藏"),
            const Divider(height: 1, indent: 60, color: Color(0xFFEEEEEE)), // 分割线
            _buildListItem(icon: Icons.image_outlined, iconColor: Colors.blue, title: "朋友圈"),
            const Divider(height: 1, indent: 60, color: Color(0xFFEEEEEE)),
            _buildListItem(icon: Icons.card_giftcard, iconColor: Colors.blueAccent, title: "卡包"),
            const Divider(height: 1, indent: 60, color: Color(0xFFEEEEEE)),
            _buildListItem(icon: Icons.emoji_emotions_outlined, iconColor: Colors.orangeAccent, title: "表情"),

            const SizedBox(height: 8),

            // 4. 设置
            _buildListItem(icon: Icons.settings_outlined, iconColor: Colors.blueGrey, title: "设置"),
          ],
        ),
      ),
    );
  }

  // 封装的列表项，统一使用 Icon，绝对不会报错
  Widget _buildListItem({required IconData icon, required Color iconColor, required String title}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black))),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}