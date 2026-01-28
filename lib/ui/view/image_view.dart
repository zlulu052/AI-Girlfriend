import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wechat_flutter/tools/wechat_flutter.dart';

class ImageView extends StatelessWidget {
  final String img;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isRadius;

  ImageView({
    required this.img,
    this.height,
    this.width,
    this.fit,
    this.isRadius = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (GetUtils.isURL(img)) {
      image = CachedNetworkImage(
        imageUrl: img,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorWidget: (context, url, error) => Image.asset(defIcon, width: width, height: height),
      );
    } else if (img.isNotEmpty && File(img).existsSync()) {
      image = Image.file(
        File(img),
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
      );
    } else if (img.startsWith('assets/')) {
      // ✅ 关键修改：如果没指定宽高，给一个默认的 25.0，防止图标巨大
      image = Image.asset(
        img,
        width: width ?? 25.0,
        height: height ?? 25.0,
        fit: fit ?? BoxFit.contain,
      );
    } else {
      image = Image.asset(defIcon, width: width ?? 25.0, height: height ?? 25.0);
    }

    if (isRadius) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: image,
      );
    }
    return image;
  }
}