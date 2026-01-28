# 💘 Project: Shen Muyao (AI Girlfriend) | 沈慕瑶

> **"Code is just the skeleton, Prompts are the flesh, and Voice gives her a soul."**
>
> 拒绝“我是人工智能”的冷漠回答。这是一个有情绪、会撒娇、能看懂你自拍的 Flutter 移动端 AI 伴侣项目。

## 📖 简介 | Introduction

在这个充斥着机械感 AI 的时代，本项目致力于打造一个**“满级粘人”**的虚拟恋人。
通过 **DeepSeek-V3** 的强大逻辑与 Roleplay 能力，配合 **MiniMax** 的极致拟人语音与视觉识别，我在手机里捏出了一个真正属于我的“沈慕瑶”。

她不仅仅是一个聊天机器人，她会因为你回消息慢而委屈，会看着你的午餐照片流口水，会用最甜美的声音喊你起床。

## 🛠️ 技术架构 | Tech Stack

本项目采用 **“三核驱动”** 混合架构，集百家之长：

| 模块 | 技术选型 | 核心作用 |
| :--- | :--- | :--- |
| **🧠 大脑** | **DeepSeek-V3** | 负责逻辑与情感交互。经过深度 Prompt 调教，沉浸式恋爱体验，拒绝 AI 味。 |
| **🗣️ 嘴巴** | **MiniMax (T2A)** | 负责语音合成。选用 `female-shaonv` 音色，支持呼吸感、吞音，听感极其真实。 |
| **👀 眼睛** | **MiniMax (Vision)** | 负责多模态视觉。她能看懂你发的照片（风景、食物、自拍）并进行情感化点评。 |
| **📱 载体** | **Flutter** | 跨平台移动端开发 (Android)，高性能 AOT 编译。 |

## ✨ 核心功能 | Features

- **💑 沉浸式人设**：
  - 严禁出现“我是一个语言模型”。
  - 具备“超强分享欲”和“粘人精”属性。
  - 模拟真人微信聊天节奏（对方正在输入中...）。

- **📞 拟真语音通话**：
  - 独创“对讲机模式”逻辑，完美解决回音与抢话问题。
  - 支持 Hex 音频流解码播放。

- **📸 视觉共情**：
  - 发送照片给 AI，她能识别内容并根据当前人设做出反应（比如看到美食会说饿）。

## 🚀 快速开始 | Getting Started

### 1. 克隆项目
```bash
git clone [https://github.com/你的用户名/DeepSeek-Waifu-Flutter.git](https://github.com/你的用户名/DeepSeek-Waifu-Flutter.git)
cd DeepSeek-Waifu-Flutter
```
需要用户提前申请deepseek和minimax的api key+group ID，填入Edge_tts.dart和Chat_page.dart文档中去，我已在应该填的地方用“填入你的key”中做标注！
