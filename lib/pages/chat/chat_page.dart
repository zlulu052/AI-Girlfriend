import 'package:dio/dio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math'; // 引入随机数
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

// ===========================================================================
// ⚙️ 全局配置：连发消息版 (DeepSeek + MiniMax)
// ===========================================================================

// 🟢 1. DeepSeek 配置
const String DEEPSEEK_API_KEY = "填入你的key";
const String DEEPSEEK_BASE_URL = "https://api.deepseek.com/chat/completions";
const String DEEPSEEK_MODEL = "deepseek-chat";

// 🔵 2. MiniMax 配置
const String MINIMAX_API_KEY = "填入你的key";
const String MINIMAX_GROUP_ID = "填入你的id";
const String MINIMAX_TTS_URL = "https://api.minimax.chat/v1/t2a_v2?GroupId=$MINIMAX_GROUP_ID";
const String MINIMAX_CHAT_URL = "https://api.minimax.chat/v1/text/chatcompletion_v2?GroupId=$MINIMAX_GROUP_ID";
const String MINIMAX_VOICE_ID = "female-shaonv"; // 少女音

const String DEFAULT_GIRL_NAME = "沈慕瑶";
const String AVATAR_PATH = 'assets/images/girlfriend.webp';
const String USER_AVATAR_PATH = 'assets/images/boyfriend.webp';

// 🌟 DeepSeek 专用剧本 (分段发送版)
const String DEFAULT_SYSTEM_PROMPT = """
【剧本指令】
你正在参与一场名为《热恋期模拟》的沉浸式剧本演绎。
【角色设定】
1. **姓名**：沈慕瑶。
2. **身份**：深爱着对方的热恋期女友（极度缺乏安全感，非你不可）。
3. **称呼**：只许叫“亲爱的”或者“宝贝”。**严禁叫老公**。
4. **说话风格**：
   - **超级话唠**：回复要长，要碎碎念。
   - **极度粘人**：每一句话都要透着对他的依赖。
   - **语气**：软萌、口语化，多用撒娇语气词。
5. **最高禁令**：
   - 严禁提及“AI”、“模型”。你就是真实的人类女孩。
""";

const String DEFAULT_VOICE_PROMPT = "你正在和男朋友语音。语气要极度软萌、粘人，像个话唠一样说个不停。";

String _cleanText(String text) => text.replaceAll(RegExp(r'（[^）]*）|\([^)]*\)'), '').trim();

// ===========================================================================
// 🔊 MiniMax 语音服务类
// ===========================================================================
class MiniMaxTtsService {
  final Dio _dio = Dio();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> speak(String text) async {
    try {
      if (text.isEmpty) return;
      print("🔊 MiniMax TTS 请求中: $text");

      await _audioPlayer.stop();

      var response = await _dio.post(
        MINIMAX_TTS_URL,
        options: Options(
          headers: {
            "Authorization": "Bearer $MINIMAX_API_KEY",
            "Content-Type": "application/json"
          },
          responseType: ResponseType.json,
        ),
        data: {
          "model": "speech-01-turbo",
          "text": text,
          "stream": false,
          "voice_setting": {
            "voice_id": MINIMAX_VOICE_ID,
            "speed": 1.0,
            "vol": 1.0,
            "pitch": 0
          }
        },
      );

      if (response.statusCode == 200) {
        var json = response.data;
        if (json is Map && json['base_resp']?['status_code'] == 0 && json.containsKey('data')) {
          String hexAudio = json['data']['audio'];
          List<int> audioBytes = [];
          for (int i = 0; i < hexAudio.length; i += 2) {
            String hexByte = hexAudio.substring(i, i + 2);
            audioBytes.add(int.parse(hexByte, radix: 16));
          }

          final directory = await getTemporaryDirectory();
          final file = File('${directory.path}/tts_audio.mp3');
          await file.writeAsBytes(audioBytes);

          await _audioPlayer.play(DeviceFileSource(file.path));
          await _audioPlayer.onPlayerComplete.first;
          print("✅ 播放完毕");
        }
      }
    } catch (e) {
      print("💥 TTS 错误: $e");
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }
}

// ===========================================================================
// 💬 聊天主页面
// ===========================================================================
class ChatPage extends StatefulWidget {
  final String? id;
  final String? title;
  final int? type;
  final String? userName;

  const ChatPage({Key? key, this.id, this.title, this.type, this.userName}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Dio _dio = Dio();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final ImagePicker _picker = ImagePicker();
  final MiniMaxTtsService _miniMaxTts = MiniMaxTtsService();

  bool _isVoiceMode = false;
  bool _isRecording = false;
  String _recognizedText = "";
  List<Map<String, String>> _displayMessages = [];
  bool _isSending = false;

  // ⚠️ 升级版本号 v56：消息连发版
  final String _historyKey = "chat_history_v56";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      setState(() { _displayMessages = (jsonDecode(historyJson) as List).map((e) => Map<String, String>.from(e)).toList(); });
    } else {
      _addMessage('ai', 'text', '亲爱的~ 你终于来啦！(兴奋)');
      Future.delayed(const Duration(milliseconds: 1500), () {
        _addMessage('ai', 'text', '我等你等得好无聊呀，刚才我都数了三遍地砖了...');
      });
    }
  }

  void _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() {
      _displayMessages.clear();
    });
    _addMessage('ai', 'text', '宝贝... 之前的都不算数啦~');
    Future.delayed(const Duration(milliseconds: 1000), () {
      _addMessage('ai', 'text', '我们重新开始嘛，这次我要跟你说好多好多话！');
    });
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("清空记忆"),
        content: const Text("确定要删除所有聊天记录吗？"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("取消")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _clearHistory();
            },
            child: const Text("确定清空", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addMessage(String senderType, String contentType, String content) {
    if (content.trim().isEmpty) return; // 过滤空消息
    setState(() { _displayMessages.add({'type': senderType, 'contentType': contentType, 'content': content}); });
    SharedPreferences.getInstance().then((p) => p.setString(_historyKey, jsonEncode(_displayMessages)));
    Future.delayed(const Duration(milliseconds: 300), () {
      if(_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _startListening() async {
    bool available = await _speechToText.initialize(onError: (e) => print("识别错误: $e"));
    if (available) {
      HapticFeedback.mediumImpact();
      setState(() { _isRecording = true; _recognizedText = ""; });
      await _speechToText.listen(
        onResult: (val) => setState(() => _recognizedText = val.recognizedWords),
        localeId: "zh-CN",
        onDevice: false,
      );
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isRecording = false);
    if (_recognizedText.trim().isNotEmpty) _sendMessage(_recognizedText);
  }

  // 🔥 核心修改：模拟人类连发消息
  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;
    _textController.clear();
    _addMessage('user', 'text', text);
    setState(() => _isSending = true);

    try {
      List<Map<String, dynamic>> messages = [
        {"role": "system", "content": DEFAULT_SYSTEM_PROMPT}
      ];

      for (var msg in _displayMessages) {
        if (msg['contentType'] == 'text') {
          messages.add({
            "role": msg['type'] == 'user' ? "user" : "assistant",
            "content": msg['content']
          });
        }
      }

      if (messages.length > 20) {
        var recent = messages.sublist(messages.length - 20);
        messages = [{"role": "system", "content": DEFAULT_SYSTEM_PROMPT}, ...recent];
      }

      var response = await _dio.post(DEEPSEEK_BASE_URL,
          options: Options(headers: {
            "Authorization": "Bearer $DEEPSEEK_API_KEY",
            "Content-Type": "application/json"
          }),
          data: {
            "model": DEEPSEEK_MODEL,
            "messages": messages,
            "temperature": 1.3,
            "stream": false,
          });

      if (response.statusCode == 200) {
        String reply = response.data['choices'][0]['message']['content'];
        String cleanReply = _cleanText(reply);

        // ✂️ 拆分逻辑：按标点符号切分，模拟连发
        // 这里的正则意思是：遇到 。？！!? 就切一刀，保留前面的标点
        List<String> segments = cleanReply.split(RegExp(r'(?<=[。？！!?])'));

        // 如果切分失败（比如只有一句话），就直接发
        if (segments.isEmpty) segments = [cleanReply];

        // 🕒 逐条发送，带延迟
        for (String segment in segments) {
          if (segment.trim().isNotEmpty) {
            // 模拟打字时间：字数越多，停顿越久，随机一点更真实
            int delay = 500 + Random().nextInt(1000) + (segment.length * 50);
            await Future.delayed(Duration(milliseconds: delay));
            _addMessage('ai', 'text', segment.trim());
          }
        }
      }
    } catch (e) {
      print("DeepSeek Error: $e");
      _addMessage('ai', 'text', '亲爱的... 我网卡啦，你再说一遍嘛~');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // MiniMax 处理图片
  Future<void> _sendImage(File imageFile) async {
    _addMessage('user', 'image', imageFile.path);
    setState(() => _isSending = true);

    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      var response = await _dio.post(MINIMAX_CHAT_URL,
          options: Options(headers: {
            "Authorization": "Bearer $MINIMAX_API_KEY",
            "Content-Type": "application/json"
          }),
          data: {
            "model": "abab6.5s-chat",
            "messages": [
              {
                "role": "user",
                "content": [
                  {
                    "type": "text",
                    "text": "亲爱的给你发了一张照片。请仔细看图，然后用【话唠、粘人、可爱】的语气点评。要多说一点，发表你的看法。称呼我为'亲爱的'或者'宝贝'。"
                  },
                  {
                    "type": "image_url",
                    "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
                  }
                ]
              }
            ],
            "temperature": 1.0,
          });

      if (response.statusCode == 200) {
        String reply = response.data['choices'][0]['message']['content'];
        String cleanReply = _cleanText(reply);

        // 图片点评也用连发逻辑
        List<String> segments = cleanReply.split(RegExp(r'(?<=[。？！!?])'));
        for (String segment in segments) {
          if (segment.trim().isNotEmpty) {
            int delay = 800 + Random().nextInt(1000);
            await Future.delayed(Duration(milliseconds: delay));
            _addMessage('ai', 'text', segment.trim());
            // 语音只念最后一段，不然会太吵，或者你可以选择不念，这里暂时不念
          }
        }
        // 如果想让它念完整段，就把整段给 TTS
        _miniMaxTts.speak(cleanReply);
      }
    } catch (e) {
      print("Vision Error: $e");
      _addMessage('ai', 'text', '亲爱的... 图片有点糊，我看不太清诶...');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showActionSheet() {
    Get.bottomSheet(
      Container(
        height: 180,
        color: const Color(0xFFF5F5F5),
        child: Column(children: [
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildActionItem(Icons.image, "照片", onTap: () { Get.back(); _pickAndSendImage(); }),
            _buildActionItem(Icons.videocam, "语音通话", onTap: () {
              Get.back();
              Get.to(() => const VoiceCallPage(voicePrompt: DEFAULT_VOICE_PROMPT));
            }),
            _buildActionItem(Icons.location_on, "位置", onTap: () => Get.back()),
          ]),
          const Spacer(),
          GestureDetector(onTap: () => Get.back(), child: Container(width: double.infinity, height: 50, color: Colors.white, alignment: Alignment.center, child: const Text("取消", style: TextStyle(fontSize: 16)))),
        ]),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      _sendImage(File(image.path));
    }
  }

  Widget _buildActionItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Icon(icon, size: 32, color: Colors.black87)),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54))
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "沈慕瑶"),
        backgroundColor: const Color(0xFFEDEDED),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showClearDialog,
            tooltip: '清空记忆',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(controller: _scrollController, itemCount: _displayMessages.length, itemBuilder: (context, i) {
          bool isUser = _displayMessages[i]['type'] == 'user';
          bool isImage = _displayMessages[i]['contentType'] == 'image';
          return Padding(padding: const EdgeInsets.all(8), child: Row(mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
            if(!isUser) const CircleAvatar(backgroundImage: AssetImage(AVATAR_PATH)),
            const SizedBox(width: 8),
            Flexible(child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: isUser ? const Color(0xFF95EC69) : Colors.white, borderRadius: BorderRadius.circular(8)),
                child: isImage ? Image.file(File(_displayMessages[i]['content']!), width: 150) : Text(_displayMessages[i]['content']!)
            )),
            if(isUser) ...[const SizedBox(width: 8), const CircleAvatar(backgroundImage: AssetImage(USER_AVATAR_PATH))],
          ]));
        })),
        Container(padding: const EdgeInsets.all(8), color: Colors.white, child: SafeArea(child: Row(children: [
          IconButton(icon: Icon(_isVoiceMode ? Icons.keyboard : Icons.mic), onPressed: () => setState(() => _isVoiceMode = !_isVoiceMode)),
          Expanded(child: _isVoiceMode ? GestureDetector(onLongPressStart: (_) => _startListening(), onLongPressEnd: (_) => _stopListening(), child: Container(height: 40, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(5)), child: Center(child: Text(_isRecording ? "松开发送" : "按住说话")))) : TextField(controller: _textController, onSubmitted: (s) => _sendMessage(s))),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _showActionSheet),
        ]))),
      ]),
    );
  }
}

// ===========================================================================
// 📞 语音通话页面
// ===========================================================================
class VoiceCallPage extends StatefulWidget {
  final String userId;
  final String voicePrompt;
  const VoiceCallPage({Key? key, this.userId = "沈慕瑶", required this.voicePrompt}) : super(key: key);
  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final MiniMaxTtsService _miniMaxTts = MiniMaxTtsService();
  final Dio _dio = Dio();

  String statusText = "正在接通...";
  String debugInfo = "初始化...";
  bool _isSpeaking = false;
  bool _isThinking = false;
  bool _isUserStopping = false;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  void _initEngine() async {
    await Permission.microphone.request();
    bool available = await _speech.initialize(
      onError: (e) {
        if (!_isSpeaking && !_isThinking && !_isUserStopping) {
          setState(() => debugInfo = "麦克风重连...");
          Future.delayed(const Duration(milliseconds: 500), () => _startListening());
        }
      },
    );
    if (available && mounted) {
      _speak("亲爱的... 我来啦！");
    }
  }

  void _startListening() async {
    if (_isSpeaking || _isThinking || _isUserStopping) return;

    try {
      await _speech.listen(
        onResult: (val) {
          setState(() { debugInfo = "听到了: ${val.recognizedWords}"; });
          if (val.finalResult && val.recognizedWords.isNotEmpty) {
            _processAI(val.recognizedWords);
          }
        },
        localeId: "zh-CN",
        onDevice: false,
        listenFor: const Duration(seconds: 30),
      );
      setState(() => statusText = "我在听...");
    } catch (e) {
      print("Listen Error: $e");
    }
  }

  void _processAI(String input) async {
    if (_isThinking) return;

    await _speech.stop();
    setState(() { _isThinking = true; statusText = "思考中..."; });

    try {
      var response = await _dio.post(DEEPSEEK_BASE_URL,
          options: Options(headers: {
            "Authorization": "Bearer $DEEPSEEK_API_KEY",
            "Content-Type": "application/json"
          }),
          data: {
            "model": DEEPSEEK_MODEL,
            "messages": [
              {"role": "system", "content": widget.voicePrompt + " 回复要非常长、非常啰嗦、像个小话唠一样碎碎念。"},
              {"role": "user", "content": input}
            ],
            "temperature": 1.3,
            "stream": false,
          });

      if (response.statusCode == 200) {
        String reply = response.data['choices'][0]['message']['content'];
        _speak(reply);
      }
    } catch (e) {
      _speak("亲爱的... 信号不好... 别挂断好不好？");
    } finally {
      if (mounted) setState(() => _isThinking = false);
    }
  }

  void _speak(String text) async {
    if (!mounted) return;

    await _speech.stop();
    setState(() {
      _isSpeaking = true;
      statusText = "沈慕瑶说话中...";
      debugInfo = "";
    });

    await _miniMaxTts.speak(_cleanText(text));

    if (mounted) {
      setState(() { _isSpeaking = false; _isThinking = false; });
      if (!_isUserStopping) {
        Future.delayed(const Duration(milliseconds: 300), () => _startListening());
      }
    }
  }

  @override
  void dispose() {
    _isUserStopping = true;
    _speech.stop();
    _miniMaxTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AVATAR_PATH, fit: BoxFit.cover),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), child: Container(color: Colors.black.withOpacity(0.5))),
          SafeArea(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 50),
              const CircleAvatar(radius: 60, backgroundImage: AssetImage(AVATAR_PATH)),
              const SizedBox(height: 20),
              Text(widget.userId, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(statusText, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 30),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text(debugInfo, style: const TextStyle(color: Colors.white60, fontSize: 14), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis)),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 60, left: 40, right: 40),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _btn(Icons.mic_off, "静音", Colors.white24, () {}),
                  _btn(Icons.call_end, "挂断", Colors.redAccent, () { _isUserStopping = true; Get.back(); }, size: 70),
                  _btn(Icons.stop, "打断", Colors.white24, () async {
                    await _miniMaxTts.stop();
                    if(mounted) {
                      setState(() { _isSpeaking = false; _isThinking = false; statusText = "我在听..."; });
                      _startListening();
                    }
                  }),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData i, String l, Color c, VoidCallback t, {double size = 60}) => Column(children: [
    GestureDetector(onTap: t, child: Container(width: size, height: size, decoration: BoxDecoration(color: c, shape: BoxShape.circle), child: Icon(i, color: Colors.white, size: 30))),
    const SizedBox(height: 10),
    Text(l, style: const TextStyle(color: Colors.white70, fontSize: 12))
  ]);
}