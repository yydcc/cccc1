import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class HomeController extends GetxController {
  final currentBannerIndex = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startAutoPlay();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (currentBannerIndex.value >= banners.length - 1) {
        currentBannerIndex.value = 0;
      } else {
        currentBannerIndex.value++;
      }
    });
  }

  // 网站导航数据
  final List<Map<String,dynamic>> banners = [
    {
      "name":"AI批改",
      "url":"assets/images/banner1.png",
    },
    {
      "name":"学情分析",
      "url":"assets/images/banner2.jpg",
    },
    {
      "name":"随堂测验",
      "url":"assets/images/banner3.png",
    },
    {
      "name":"AI备忘录",
      "url":"assets/images/banner4.png",
    },

  ];


  final List<Map<String, dynamic>> websites = [
    {
      'name': '智慧教育平台',
      'url': 'https://www.zxx.edu.cn/',
      'icon': Icons.school,
    },
    {
      'name': '数字科技馆',
      'url': 'https://www.cdstm.cn/',
      'icon': Icons.science,
    },
    {
      'name': '学科网',
      'url': 'https://www.zxxk.com/',
      'icon': Icons.menu_book,
    },
    {
      'name': '古诗文网',
      'url': 'https://www.gushiwen.cn/',
      'icon': Icons.auto_stories,
    },
    {
      'name': "问题搜索",
      'url': 'https://www.wolframalpha.com/',
      'icon': Icons.search,
    },
    {
      'name': '在线翻译',
      'url': 'https://fanyi.youdao.com/#/TextTranslate',
      'icon': Icons.translate,
    },
  ];

  // 打开网站
  void launchWebsite(String url, String title) {
    try {
      // 检查URL格式
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      final uri = Uri.parse(url);
      
      Get.to(
        Scaffold(
          appBar: AppBar(
            title: Text(title),
            centerTitle: true,
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..loadRequest(uri)
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (request) {
                    if (request.url.startsWith('http://') || request.url.startsWith('https://')) {
                      return NavigationDecision.navigate;
                    }
                    return NavigationDecision.prevent;
                  },
                ),
              ),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('错误', '无法打开网页: $url');
    }
  }
} 