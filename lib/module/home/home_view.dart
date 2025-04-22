import 'package:cccc1/common/theme/color.dart';
import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/storage.dart';
import 'home_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageService>(
      future: StorageService.instance,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }



        return Scaffold(
          backgroundColor: GlobalThemData.backgroundColor,
          appBar: AppBar(
            title: const Text('首页'),
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 轮播图部分
                  _buildCarousel(context),
                  SizedBox(height: 20.h),
                  
                  // 网站导航部分
                  _buildWebsiteNavigation(),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            key: const ValueKey('home_ai_chat_button'),
            onPressed: () => Get.toNamed(AppRoutes.AI_CHAT),
            backgroundColor: Theme.of(context).primaryColor,
            child: Container(
              width: 40.w,
              height: 40.w,
              child: Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建轮播图
  Widget _buildCarousel(BuildContext context) {
    return Container(
      height: 180.h,
      child: CarouselSlider.builder(
        itemCount: controller.banners.length,
        options: CarouselOptions(
          height: 200.h,
          viewportFraction: 0.95,
          initialPage: 0,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 2),
          autoPlayAnimationDuration: Duration(milliseconds: 1000),
          autoPlayCurve: Curves.easeInOut,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index, reason) {
            controller.currentBannerIndex.value = index;
          },
        ),
        itemBuilder: (context, index, realIndex) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              image: DecorationImage(
                image: AssetImage(controller.banners[index]["url"]),
                fit: BoxFit.fitWidth,
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建网站导航
  Widget _buildWebsiteNavigation() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '常用网站导航',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.0,
            ),
            itemCount: controller.websites.length,
            itemBuilder: (context, index) {
              final website = controller.websites[index];
              return _buildWebsiteItem(website);
            },
          ),
        ],
      ),
    );
  }

  // 构建网站导航项
  Widget _buildWebsiteItem(Map<String, dynamic> website) {
    return Hero(
      tag: 'website_${website['name']}',
      child: GestureDetector(
        onTap: () => controller.launchWebsite(website['url'], website['name']),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                website['icon'] as IconData,
                size: 32.sp,
                color: Theme.of(Get.context!).primaryColor,
              ),
              SizedBox(height: 8.h),
              Text(
                website['name'] as String,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}