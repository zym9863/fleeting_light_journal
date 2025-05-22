import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../models/memory_card.dart';
import '../services/database_service.dart';

class CreateMemoryCardScreen extends StatefulWidget {
  const CreateMemoryCardScreen({super.key});

  @override
  State<CreateMemoryCardScreen> createState() => _CreateMemoryCardScreenState();
}

class _CreateMemoryCardScreenState extends State<CreateMemoryCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _keywordsController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  
  String _selectedEmotion = '喜悦'; // 默认情感标签
  List<String> _emotions = ['喜悦', '思念', '感动', '遗憾', '愤怒', '平静'];
  List<String> _keywords = []; // 关键词列表
  List<File> _selectedImages = []; // 选择的图片列表
  bool _isTimeCapsule = false; // 是否为时光胶囊
  DateTime? _timeCapsuleDate; // 时光胶囊解锁日期
  bool _isSaving = false; // 是否正在保存

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  // 选择图片
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }

  // 拍摄照片
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('拍照失败: $e')),
      );
    }
  }

  // 移除图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 添加关键词
  void _addKeyword() {
    final keyword = _keywordsController.text.trim();
    if (keyword.isNotEmpty && !_keywords.contains(keyword)) {
      setState(() {
        _keywords.add(keyword);
        _keywordsController.clear();
      });
    }
  }

  // 移除关键词
  void _removeKeyword(String keyword) {
    setState(() {
      _keywords.remove(keyword);
    });
  }

  // 选择时光胶囊日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _timeCapsuleDate ?? now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 10)),
    );

    if (picked != null && picked != _timeCapsuleDate) {
      setState(() {
        _timeCapsuleDate = picked;
      });
    }
  }

  // 保存图片到应用目录
  Future<List<String>> _saveImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final List<String> savedPaths = [];
    final uuid = const Uuid();

    for (var image in _selectedImages) {
      final fileName = '${uuid.v4()}${path.extension(image.path)}';
      final savedPath = '${imagesDir.path}/$fileName';
      await image.copy(savedPath);
      savedPaths.add(savedPath);
    }

    return savedPaths;
  }

  // 保存卡片
  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        // 保存图片
        final imagePaths = await _saveImages();

        // 创建卡片对象
        final card = MemoryCard(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          imagePaths: imagePaths,
          emotion: _selectedEmotion,
          keywords: _keywords,
          createdAt: DateTime.now(),
          timeCapsuleDate: _isTimeCapsule ? _timeCapsuleDate : null,
          isTimeCapsule: _isTimeCapsule,
          isLocked: _isTimeCapsule, // 新创建的时光胶囊默认锁定
        );

        // 保存到数据库
        await _databaseService.insertMemoryCard(card);

        if (mounted) {
          Navigator.pop(context, true); // 返回并刷新列表
        }
      } catch (e) {
        setState(() {
          _isSaving = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存失败: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('创建思慕卡片', style: Theme.of(context).appBarTheme.titleTextStyle), // 使用主题文本样式
        actions: [
          // 保存按钮
          TextButton.icon(
            onPressed: _isSaving ? null : _saveCard,
            icon: Icon(Icons.save, color: Theme.of(context).appBarTheme.foregroundColor), // 使用主题颜色
            label: Text('保存', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor)), // 使用主题文本样式
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0), // 增加内边距
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '标题',
                        border: const OutlineInputBorder(),
                        labelStyle: Theme.of(context).textTheme.bodyMedium, // 使用主题文本样式
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0), // 聚焦边框颜色
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge, // 输入文本样式
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入标题';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0), // 增加间距

                    // 内容
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: '内容',
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                        labelStyle: Theme.of(context).textTheme.bodyMedium, // 使用主题文本样式
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0), // 聚焦边框颜色
                        ),
                      ),
                      maxLines: 8,
                      style: Theme.of(context).textTheme.bodyLarge, // 输入文本样式
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入内容';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0), // 增加间距

                    // 情感标签选择
                    Text(
                      '情感标签',
                      style: Theme.of(context).textTheme.titleMedium, // 使用主题文本样式
                    ),
                    const SizedBox(height: 10.0), // 调整间距
                    Wrap(
                      spacing: 10.0, // 调整间距
                      runSpacing: 10.0, // 调整间距
                      children: _emotions.map((emotion) {
                        return ChoiceChip(
                          label: Text(emotion, style: Theme.of(context).textTheme.bodySmall), // 使用主题文本样式
                          selected: _selectedEmotion == emotion,
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2), // 选中颜色
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedEmotion = emotion;
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0), // 更圆的边角
                            side: BorderSide(
                              color: _selectedEmotion == emotion
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300, // 边框颜色
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: _selectedEmotion == emotion
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodySmall?.color, // 文本颜色
                            fontWeight: _selectedEmotion == emotion ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20.0), // 增加间距

                    // 图片选择
                    Text(
                      '添加图片',
                      style: Theme.of(context).textTheme.titleMedium, // 使用主题文本样式
                    ),
                    const SizedBox(height: 10.0), // 调整间距
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('从相册选择'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12.0), // 调整内边距
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0), // 调整间距
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('拍照'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12.0), // 调整内边距
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0), // 调整间距
                    if (_selectedImages.isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10.0), // 调整间距
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0), // 调整圆角
                                    image: DecorationImage(
                                      image: FileImage(_selectedImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 10.0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.redAccent, // 调整颜色
                                      size: 28.0, // 调整大小
                                    ),
                                    onPressed: () => _removeImage(index),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20.0), // 增加间距

                    // 关键词
                    Text(
                      '添加关键词',
                      style: Theme.of(context).textTheme.titleMedium, // 使用主题文本样式
                    ),
                    const SizedBox(height: 10.0), // 调整间距
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _keywordsController,
                            decoration: InputDecoration(
                              labelText: '关键词',
                              border: const OutlineInputBorder(),
                              labelStyle: Theme.of(context).textTheme.bodyMedium, // 使用主题文本样式
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0), // 聚焦边框颜色
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge, // 输入文本样式
                            onFieldSubmitted: (_) => _addKeyword(), // 按回车键添加
                          ),
                        ),
                        const SizedBox(width: 12.0), // 调整间距
                        ElevatedButton(
                          onPressed: _addKeyword,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // 调整内边距
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('添加'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0), // 调整间距
                    Wrap(
                      spacing: 10.0, // 调整间距
                      runSpacing: 10.0, // 调整间距
                      children: _keywords.map((keyword) {
                        return Chip(
                          label: Text(keyword, style: Theme.of(context).textTheme.bodySmall), // 使用主题文本样式
                          onDeleted: () => _removeKeyword(keyword),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), // 使用主题颜色
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0), // 更圆的边角
                          ),
                          side: BorderSide.none, // 移除边框
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20.0), // 增加间距

                    // 时光胶囊设置
                    SwitchListTile(
                      title: Text('设为时光胶囊', style: Theme.of(context).textTheme.titleMedium), // 使用主题文本样式
                      subtitle: Text('在指定日期前锁定内容', style: Theme.of(context).textTheme.bodySmall), // 使用主题文本样式
                      value: _isTimeCapsule,
                      onChanged: (value) {
                        setState(() {
                          _isTimeCapsule = value;
                          if (value && _timeCapsuleDate == null) {
                            _timeCapsuleDate = DateTime.now().add(const Duration(days: 30));
                          }
                        });
                      },
                      activeColor: Theme.of(context).primaryColor, // 选中颜色
                    ),
                    if (_isTimeCapsule) ...[
                      ListTile(
                        title: Text('解锁日期', style: Theme.of(context).textTheme.titleMedium), // 使用主题文本样式
                        subtitle: Text(
                          _timeCapsuleDate != null
                              ? DateFormat('yyyy-MM-dd').format(_timeCapsuleDate!)
                              : '请选择日期',
                          style: Theme.of(context).textTheme.bodySmall, // 使用主题文本样式
                        ),
                        trailing: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor), // 使用主题颜色
                        onTap: () => _selectDate(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
