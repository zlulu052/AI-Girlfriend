import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class EdgeTtsService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Dio _dio = Dio();

  // ✅ Key (海螺 AI)
  final String _apiKey = "填入你的key";

  // ✅ Group ID
  final String _groupId = "2013606000870826069";

  // 🔄 【关键修改】切换回标准接口 (解决 2013 报错)
  // 这个接口参数是扁平的，服务器绝对能认出来
  final String _apiBaseUrl = "https://api.minimax.chat/v1/text_to_speech";

  // 👩 音色：female-shaonv (甜美少女音)
  // 虽然不是 voice-29，但在 Turbo 模型加持下，效果非常棒！
  final String _voiceId = "female-shaonv";

  Function? onComplete;

  EdgeTtsService() {
    _audioPlayer.onPlayerComplete.listen((event) {
      if (onComplete != null) onComplete!();
    });
  }

  Future<void> speak(String text) async {
    try {
      print("TTS: 正在请求 MiniMax (标准接口+Turbo模型)... ($text)");

      String url = "$_apiBaseUrl?GroupId=$_groupId";

      // 构造数据 (标准接口：扁平结构，没有 voice_setting 嵌套)
      Map<String, dynamic> payload = {
        // 🔥 核心：使用你付费的 Turbo 模型
        "model": "speech-02-turbo",

        // 扁平参数，绝对不会报 "voice_id required"
        "voice_id": _voiceId,
        "text": text,
        "speed": 1.0,
        "vol": 1.0,
        "pitch": 0
      };

      // 强制转 JSON，双重保险
      String jsonBody = jsonEncode(payload);

      Response response = await _dio.post(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            "Authorization": "Bearer $_apiKey",
            "Content-Type": "application/json",
          },
          receiveTimeout: const Duration(seconds: 15),
        ),
        data: jsonBody,
      );

      if (response.statusCode == 200) {
        // 检查是不是业务报错
        if (response.data.length < 1000) {
          try {
            String msg = utf8.decode(response.data);
            if (msg.contains("base_resp")) {
              print("TTS 业务报错: $msg");
              // 如果提示余额不足 (1008)，请等待充值到账
              if (msg.contains("balance")) print("💸 余额还没刷新，请稍等几分钟再试！");
              return;
            }
          } catch (e) {}
        }

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/minimax_turbo_std.mp3');
        if (await file.exists()) await file.delete();
        await file.writeAsBytes(response.data);

        print("TTS: ✅ 请求成功！播放 Turbo 少女音");
        await _audioPlayer.play(DeviceFileSource(file.path));
      } else {
        print("TTS HTTP 报错: ${response.statusCode}");
      }

    } catch (e) {
      print("TTS 严重错误 ❌: $e");
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }
}