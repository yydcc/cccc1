# 墨智前端应用

## 项目简介
墨智前端应用是一个基于Flutter的智能教育辅助系统移动端应用，旨在通过现代化的UI设计和流畅的用户体验，为教师和学生提供便捷的教学和学习工具。应用集成了多种教育功能，包括作业管理、成绩分析、课堂测验、AI助手等，为用户提供全方位的教育支持。

## 核心功能
1. **智能教学辅助**
   - 作业管理：布置、提交、批改一体化
   - 成绩分析：可视化展示学生成绩趋势
   - 课堂测验：在线答题和自动评分
   - AI助手：智能问答和学习辅导
   - 学习计划：个性化学习提醒

2. **教学管理**
   - 班级管理：创建和管理班级
   - 成员管理：添加和管理班级成员
   - 资源管理：上传和共享教学资源
   - 通知管理：重要消息提醒

3. **智能导航**
   - 教育网站导航：整合优质教育资源
   - 学习工具推荐：根据学科推荐相关工具
   - 资源分类管理：智能分类和检索

4. **数据分析**
   - 成绩统计：多维度成绩分析
   - 学习报告：个性化学习报告
   - 教学反馈：实时教学效果评估

## 技术栈
- **核心框架**: Flutter 3.x
- **状态管理**: GetX
- **UI组件**: 
  - Material Design
  - Cupertino Design
  - 自定义组件
- **网络请求**: 
  - Dio
  - WebSocket
- **本地存储**: 
  - SharedPreferences
  - SQLite
- **工具库**:
  - ScreenUtil (屏幕适配)
  - CarouselSlider (轮播图)
  - WebView (网页浏览)
  - PermissionHandler (权限管理)
- **图表库**: FL Chart
- **文件处理**: FilePicker

## 主要功能
1. **用户界面**
   - 响应式布局
   - 主题切换
   - 多语言支持
   - 手势操作

2. **数据展示**
   - 图表可视化
   - 列表展示
   - 网格布局
   - 轮播展示

3. **文件处理**
   - 文件上传
   - 图片预览
   - 文档查看
   - 资源下载

4. **实时通信**
   - WebSocket连接
   - 消息推送
   - 在线状态

5. **安全特性**
   - Token认证
   - 数据加密
   - 权限控制

## 性能优化
- 页面懒加载
- 图片缓存
- 数据预加载
- 内存优化

## 开发环境要求
- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code
- Android SDK / iOS SDK

## 快速开始
1. 克隆项目
```bash
git clone [项目地址]
```

2. 安装依赖
```bash
flutter pub get
```


3. 运行项目

若要在本地运行项目，请启动后端服务后更改lib/utils/http.dart下的BASE_URL为对应后端服务端口地址

```bash
flutter run
```

## 项目结构
```
lib/
├── common/         # 公共组件和工具
├── module/         # 功能模块
├── routes/         # 路由配置
├── model/          # 数据模型
├── service/        # 服务层
├── theme/          # 主题配置
└── utils/          # 工具类
```

## 许可证
本项目采用 [Apache License 2.0](LICENSE)

## 版权声明
Copyright 2025 CCCC Project

## 贡献指南
github地址:https://github.com/yydcc/cccc1.git
欢迎提交Issue和Pull Request来帮助改进项目。

## 联系方式
如有问题，请通过Issue或Pull Request进行交流。
