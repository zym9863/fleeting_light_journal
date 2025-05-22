# fleeting_light_journal

[English](README_EN.md) | 中文

浮光手札 - 一款情感记录与回顾的 Flutter 应用。

## 项目简介

本项目旨在帮助用户以卡片形式记录每日情感、回忆与重要时刻，支持多平台运行，界面简洁美观，支持本地数据持久化与本地通知提醒。

## 目录结构与主要模块

```
lib/
├── main.dart                   // 应用入口
├── models/                     // 数据模型
│   └── memory_card.dart        // 记忆卡片数据结构
├── screens/                    // 页面与界面
│   ├── home_screen.dart        // 首页，展示所有记忆卡片
│   ├── create_memory_card_screen.dart // 新建记忆卡片页面
│   └── memory_card_screen.dart // 记忆卡片详情页
├── services/                   // 业务逻辑与服务
│   ├── database_service.dart   // 数据库操作封装
│   └── notification_service.dart // 本地通知服务
├── theme/                      // 主题与样式
│   └── app_theme.dart          // 全局主题配置
└── widgets/                    // 可复用组件
    └── memory_card_item.dart   // 记忆卡片展示组件
```

### 主要功能模块说明
- **models/**：定义核心数据结构，如记忆卡片。
- **screens/**：包含主界面、卡片创建与详情等页面，负责 UI 展示与交互。
- **services/**：封装数据库操作（如增删查改）、本地通知等核心服务。
- **theme/**：统一管理应用主题、配色与字体。
- **widgets/**：抽象可复用的 UI 组件，提升开发效率。

## 快速开始

1. 克隆项目到本地

2. 安装依赖：
   ```bash
   flutter pub get
   ```
3. 运行项目：
   ```bash
   flutter run
   ```

## 依赖说明
- 状态管理：provider
- 数据持久化：sqflite、path_provider
- UI 组件与动画：flutter_staggered_grid_view、animations、flutter_markdown
- 本地通知：flutter_local_notifications
- 其他：intl、image_picker、cached_network_image 等

## 开发建议
- 遵循模块化、组件化开发，便于维护和扩展。
- 推荐使用 Provider 进行状态管理。
- 主题和样式统一在 theme 目录下配置。
- 数据库与通知等服务建议通过 services 目录下的服务类调用。

---

如需更多 Flutter 相关资料，可参考：
- [Flutter 官方文档](https://docs.flutter.dev/)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
