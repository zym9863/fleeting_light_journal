import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

import '../models/memory_card.dart';
import '../services/database_service.dart';
import 'memory_card_screen.dart';
import 'create_memory_card_screen.dart';
import '../widgets/memory_card_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  List<MemoryCard> _memoryCards = [];
  List<MemoryCard> _timeCapsules = [];
  String _currentFilter = '全部';
  List<String> _emotions = ['全部', '喜悦', '思念', '感动', '遗憾', '愤怒', '平静'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 加载数据
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cards = await _databaseService.getMemoryCards();
      final capsules = await _databaseService.getTimeCapsules();

      setState(() {
        _memoryCards = cards;
        _timeCapsules = capsules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    }
  }

  // 根据情感筛选卡片
  void _filterByEmotion(String emotion) {
    setState(() {
      _currentFilter = emotion;
    });

    if (emotion == '全部') {
      _loadData();
    } else {
      _filterCards(emotion);
    }
  }

  // 筛选卡片
  Future<void> _filterCards(String emotion) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cards = await _databaseService.getCardsByEmotion(emotion);

      setState(() {
        _memoryCards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('筛选数据失败: $e')),
        );
      }
    }
  }

  // 构建思慕卡片标签页
  Widget _buildMemoryCardsTab() {
    return Column(
      children: [
        // 情感筛选器
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // 增加垂直内边距
          child: SizedBox(
            height: 40, // 调整高度
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _emotions.length,
              itemBuilder: (context, index) {
                final emotion = _emotions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0), // 调整水平内边距
                  child: ChoiceChip(
                    label: Text(emotion, style: Theme.of(context).textTheme.bodySmall), // 使用主题文本样式
                    selected: _currentFilter == emotion,
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2), // 选中颜色
                    onSelected: (selected) {
                      if (selected) {
                        _filterByEmotion(emotion);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // 更圆的边角
                      side: BorderSide(
                        color: _currentFilter == emotion
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300, // 边框颜色
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: _currentFilter == emotion
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodySmall?.color, // 文本颜色
                      fontWeight: _currentFilter == emotion ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // 卡片列表
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _memoryCards.isEmpty
                  ? Center(child: Text('暂无思慕卡片，点击右下角按钮创建', style: Theme.of(context).textTheme.bodyMedium)) // 使用主题文本样式
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10, // 调整间距
                        crossAxisSpacing: 10, // 调整间距
                        padding: const EdgeInsets.all(10), // 调整内边距
                        itemCount: _memoryCards.length,
                        itemBuilder: (context, index) {
                          final card = _memoryCards[index];
                          return MemoryCardItem(
                            card: card,
                            onTap: () async {
                              // 查看卡片详情
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MemoryCardScreen(card: card),
                                ),
                              );

                              if (result == true) {
                                _loadData(); // 刷新数据
                              }
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // 构建时光胶囊标签页
  Widget _buildTimeCapsuleTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _timeCapsules.isEmpty
            ? Center(child: Text('暂无时光胶囊，创建卡片时可以设置为时光胶囊', style: Theme.of(context).textTheme.bodyMedium)) // 使用主题文本样式
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(10), // 调整内边距
                  itemCount: _timeCapsules.length,
                  itemBuilder: (context, index) {
                    final capsule = _timeCapsules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10), // 调整间距
                      elevation: Theme.of(context).cardTheme.elevation, // 使用主题定义的阴影
                      shape: Theme.of(context).cardTheme.shape, // 使用主题定义的形状
                      child: ListTile(
                        title: Text(
                          capsule.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium, // 使用主题文本样式
                        ),
                        subtitle: Text(
                          capsule.isLocked
                              ? '将在 ${DateFormat('yyyy-MM-dd').format(capsule.timeCapsuleDate!)} 解锁'
                              : '已解锁，点击查看',
                          style: Theme.of(context).textTheme.bodySmall, // 使用主题文本样式
                        ),
                        leading: CircleAvatar(
                          backgroundColor: capsule.isLocked
                              ? Colors.grey
                              : Theme.of(context).primaryColor, // 使用主题主色
                          child: Icon(
                            capsule.isLocked ? Icons.lock : Icons.lock_open,
                            color: Colors.white,
                          ),
                        ),
                        enabled: !capsule.isLocked,
                        onTap: capsule.isLocked
                            ? null
                            : () async {
                                // 查看已解锁的时光胶囊
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MemoryCardScreen(card: capsule),
                                  ),
                                );

                                if (result == true) {
                                  _loadData(); // 刷新数据
                                }
                              },
                      ),
                    );
                  },
                ),
              );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('浮光手札', style: Theme.of(context).appBarTheme.titleTextStyle), // 使用主题文本样式
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).appBarTheme.foregroundColor, // 选中标签颜色
          unselectedLabelColor: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.7), // 未选中标签颜色
          indicatorColor: Theme.of(context).appBarTheme.foregroundColor, // 指示器颜色
          tabs: const [
            Tab(text: '思慕卡片'),
            Tab(text: '时光胶囊'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).appBarTheme.foregroundColor), // 使用主题颜色
            onPressed: () {
              // 实现搜索功能
              showSearch(
                context: context,
                delegate: MemoryCardSearchDelegate(_databaseService),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 思慕卡片页面
          _buildMemoryCardsTab(),
          // 时光胶囊页面
          _buildTimeCapsuleTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 创建新卡片
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateMemoryCardScreen(),
            ),
          );

          if (result == true) {
            _loadData(); // 刷新数据
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 搜索代理
class MemoryCardSearchDelegate extends SearchDelegate<String> {
  final DatabaseService _databaseService;

  MemoryCardSearchDelegate(this._databaseService);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: Theme.of(context).primaryColor), // 使用主题颜色
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor), // 使用主题颜色
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<MemoryCard>>(
      future: _databaseService.getCardsByKeyword(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('搜索出错: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium)); // 使用主题文本样式
        }

        final cards = snapshot.data ?? [];

        if (cards.isEmpty) {
          return Center(child: Text('未找到相关卡片', style: Theme.of(context).textTheme.bodyMedium)); // 使用主题文本样式
        }

        return ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return ListTile(
              title: Text(card.title, style: Theme.of(context).textTheme.titleMedium), // 使用主题文本样式
              subtitle: Text(
                card.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall, // 使用主题文本样式
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor, // 使用主题主色
                child: Text(
                  card.emotion.substring(0, 1),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoryCardScreen(card: card),
                  ),
                );

                if (result == true) {
                  // 刷新搜索结果
                  close(context, query);
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // 简单实现，可以根据需要扩展
    return Center(child: Text('输入关键词搜索', style: Theme.of(context).textTheme.bodyMedium)); // 使用主题文本样式
  }
}
