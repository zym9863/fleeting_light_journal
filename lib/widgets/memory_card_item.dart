import 'package:flutter/material.dart';
import 'dart:io';
import '../models/memory_card.dart';

class MemoryCardItem extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onTap;

  const MemoryCardItem({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 根据情感标签选择颜色
    Color cardColor = _getColorByEmotion(card.emotion);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: Theme.of(context).cardTheme.elevation, // 使用主题定义的阴影
        color: Theme.of(context).cardColor, // 使用主题定义的卡片颜色
        shape: Theme.of(context).cardTheme.shape, // 使用主题定义的形状
        child: Container(
          padding: const EdgeInsets.all(16.0), // 增加内边距
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                card.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color), // 使用主题文本样式
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),

              // 内容预览
              Text(
                card.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color), // 使用主题文本样式
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),

              // 如果有图片，显示第一张图片
              if (card.imagePaths.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    File(card.imagePaths.first), // 直接传入File对象
                  ),
                ),

              const SizedBox(height: 8.0),

              // 底部信息：情感标签和创建时间
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 情感标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), // 调整内边距
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.15), // 调整透明度
                      borderRadius: BorderRadius.circular(20.0), // 更圆的边角
                    ),
                    child: Text(
                      card.emotion,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.bold,
                      ), // 使用主题文本样式
                    ),
                  ),

                  // 创建时间
                  Text(
                    _formatDate(card.createdAt),
                    style: Theme.of(context).textTheme.bodySmall, // 使用主题文本样式
                  ),
                ],
              ),
            ],
          ),
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

  // 格式化日期
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }
}
