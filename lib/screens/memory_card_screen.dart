import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import '../models/memory_card.dart';
import '../services/database_service.dart';

class MemoryCardScreen extends StatefulWidget {
  final MemoryCard card;

  const MemoryCardScreen({super.key, required this.card});

  @override
  State<MemoryCardScreen> createState() => _MemoryCardScreenState();
}

class _MemoryCardScreenState extends State<MemoryCardScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late MemoryCard _card;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
  }

  // 删除卡片
  Future<void> _deleteCard() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _databaseService.deleteMemoryCard(_card.id!);
      if (mounted) {
        Navigator.pop(context, true); // 返回并刷新列表
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  // 确认删除对话框
  Future<void> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这张卡片吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 根据情感标签选择颜色
    Color cardColor = _getColorByEmotion(_card.emotion);

    return Scaffold(
      appBar: AppBar(
        title: Text(_card.title, style: Theme.of(context).appBarTheme.titleTextStyle), // 使用主题文本样式
        actions: [
          // 删除按钮
          IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).appBarTheme.foregroundColor), // 使用主题颜色
            onPressed: _isDeleting ? null : _confirmDelete,
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0), // 增加内边距
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和创建时间
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline, // 对齐基线
                    textBaseline: TextBaseline.alphabetic, // 设置基线
                    children: [
                      Expanded(
                        child: Text(
                          _card.title,
                          style: Theme.of(context).textTheme.titleLarge, // 使用主题文本样式
                        ),
                      ),
                      const SizedBox(width: 16.0), // 增加间距
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(_card.createdAt),
                        style: Theme.of(context).textTheme.bodySmall, // 使用主题文本样式
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 情感标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.15), // 调整透明度
                      borderRadius: BorderRadius.circular(20.0), // 更圆的边角
                    ),
                    child: Text(
                      _card.emotion,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.bold,
                      ), // 使用主题文本样式
                    ),
                  ),
                  const SizedBox(height: 24.0), // 增加间距

                  // 内容
                  Text(
                    _card.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6), // 使用主题文本样式，调整行高
                  ),
                  const SizedBox(height: 32.0), // 增加间距

                  // 图片列表
                  if (_card.imagePaths.isNotEmpty) ...[
                    Text(
                      '图片',
                      style: Theme.of(context).textTheme.titleMedium, // 使用主题文本样式
                    ),
                    const SizedBox(height: 12.0), // 调整间距
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0, // 调整间距
                        mainAxisSpacing: 12.0, // 调整间距
                      ),
                      itemCount: _card.imagePaths.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // 点击查看大图
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    backgroundColor: Colors.black, // 大图页面AppBar背景色
                                    iconTheme: const IconThemeData(color: Colors.white), // 返回按钮颜色
                                  ),
                                  body: Container(
                                    color: Colors.black, // 大图页面背景色
                                    child: Center(
                                      child: InteractiveViewer(
                                        child: Image.file(
                                          File(_card.imagePaths[index]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0), // 调整圆角
                            child: Image.file(
                              File(_card.imagePaths[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32.0), // 增加间距
                  ],

                  // 关键词标签
                  if (_card.keywords.isNotEmpty) ...[
                    Text(
                      '关键词',
                      style: Theme.of(context).textTheme.titleMedium, // 使用主题文本样式
                    ),
                    const SizedBox(height: 12.0), // 调整间距
                    Wrap(
                      spacing: 10.0, // 调整间距
                      runSpacing: 10.0, // 调整间距
                      children: _card.keywords.map((keyword) {
                        return Chip(
                          label: Text(keyword, style: Theme.of(context).textTheme.bodySmall), // 使用主题文本样式
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), // 使用主题颜色
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0), // 更圆的边角
                          ),
                          side: BorderSide.none, // 移除边框
                        );
                      }).toList(),
                    ),
                  ],

                  // 时光胶囊信息
                  if (_card.isTimeCapsule && _card.timeCapsuleDate != null) ...[
                    const SizedBox(height: 32.0), // 增加间距
                    Container(
                      padding: const EdgeInsets.all(18.0), // 增加内边距
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15), // 调整透明度
                        borderRadius: BorderRadius.circular(16.0), // 调整圆角
                        border: Border.all(color: Colors.amber.shade300, width: 1.5), // 调整边框
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _card.isLocked ? Icons.lock : Icons.lock_open,
                            color: Colors.amber.shade700, // 调整颜色
                            size: 28.0, // 调整图标大小
                          ),
                          const SizedBox(width: 12.0), // 调整间距
                          Expanded(
                            child: Text(
                              _card.isLocked
                                  ? '这是一个时光胶囊，将在 ${DateFormat('yyyy-MM-dd').format(_card.timeCapsuleDate!)} 解锁'
                                  : '这是一个已解锁的时光胶囊',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.amber.shade800), // 使用主题文本样式，调整颜色
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  // 根据情感标签返回对应的颜色
  Color _getColorByEmotion(String emotion) {
    switch (emotion) {
      case '喜悦':
        return Colors.amber;
      case '思念':
        return Colors.blue;
      case '感动':
        return Colors.pink;
      case '遗憾':
        return Colors.purple;
      case '愤怒':
        return Colors.red;
      case '平静':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
