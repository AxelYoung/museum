import 'package:flutter/material.dart';
import 'package:museum/widgets/loading_sheet.dart'; // 确保导入正确的路径
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ScrollController _mainScrollController = ScrollController();
  double _scrollVelocity = 0.0;
  late AnimationController _animationController;
  bool hasPassedThreshold = false;

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_scrollListener);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _mainScrollController.removeListener(_scrollListener);
    _mainScrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_mainScrollController.position.atEdge) {
      bool isBottom = _mainScrollController.position.pixels != 0;
      if (isBottom) {
        _animationController.forward();
      }
    }
    _scrollVelocity = _mainScrollController.position.activity?.velocity ?? 0.0;
  }

  void _showMuseumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const MuseumSelectionDialog(),
    );
  }

  void _showIntroduction(BuildContext context) {
    // TODO: 显示博物馆简介
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('博物馆简介功能即将上线')),
    );
  }

  void _showMap(BuildContext context) {
    // TODO: 显示展馆地图
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('展馆地图功能即将上线')),
    );
  }

  void _showGuideService(BuildContext context) {
    // TODO: 显示讲解服务
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('讲解服务功能即将上线')),
    );
  }

  void _showBusinessHours(BuildContext context) {
    // TODO: 显示营业时间
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('营业时间功能即将上线')),
    );
  }

  void _showBookingStatus(BuildContext context) {
    // TODO: 显示预约情况
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('预约情况功能即将上线')),
    );
  }

  void _showOpenStatus(BuildContext context) {
    // TODO: 显示开放状态
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开放状态功能即将上线')),
    );
  }

  void _startGuide(BuildContext context) {
    // TODO: 进入讲解设置界面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('讲解设置功能即将上线')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: OutlinedButton.icon(
                    onPressed: () => _showMuseumDialog(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      side: BorderSide.none,
                      foregroundColor: Theme.of(context).colorScheme.onBackground,
                    ),
                    icon: const Icon(Icons.location_on),
                    label: const Text(
                      '三星堆博物馆',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '未配置',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            controller: _mainScrollController,
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      '三星堆博物馆',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AspectRatio(
                      aspectRatio: 2 / 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/museum_cover.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: _FeatureButton(
                                icon: Icons.info_outline,
                                label: '博物馆简介',
                                onTap: () => _showIntroduction(context),
                                showBorder: true,
                              ),
                            ),
                            Expanded(
                              child: _FeatureButton(
                                icon: Icons.map_outlined,
                                label: '展馆地图',
                                onTap: () => _showMap(context),
                                showBorder: true,
                              ),
                            ),
                            Expanded(
                              child: _FeatureButton(
                                icon: Icons.headset_mic_outlined,
                                label: '讲解服务',
                                onTap: () => _showGuideService(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _InfoCard(
                            icon: Icons.access_time,
                            title: '营业时间',
                            content: '09:00 - 17:30',
                            color: secondaryColor,
                            onTap: () => _showBusinessHours(context),
                          ),
                          const SizedBox(width: 12),
                          _InfoCard(
                            icon: Icons.confirmation_number_outlined,
                            title: '预约情况',
                            content: '可预约',
                            color: secondaryColor,
                            onTap: () => _showBookingStatus(context),
                          ),
                          const SizedBox(width: 12),
                          _InfoCard(
                            icon: Icons.door_front_door_outlined,
                            title: '开放状态',
                            content: '正常开放',
                            color: secondaryColor,
                            onTap: () => _showOpenStatus(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '开始讲解',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 13),
                              Text(
                                '请点击右侧按钮进入讲解设置界面，按照提示完成设置并开始导览。',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                          Positioned(
                            right: -4,
                            top: -4,
                            child: FloatingActionButton.small(
                              onPressed: () => _startGuide(context),
                              elevation: 2,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              child: const Icon(
                                Icons.arrow_forward,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '新闻界面',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 5, // 假设有5个新闻卡片
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Image.asset(
                                        'assets/images/museum_cover.jpg',
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: double.infinity,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '新闻标题 $index',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '这是新闻内容的简短描述。',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.mic),
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showBorder;

  const _FeatureButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
        },
        splashColor: colorScheme.primary.withOpacity(0.3),
        highlightColor: colorScheme.primary.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: showBorder
                ? Border(
                    right: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: colorScheme.onSurfaceVariant,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MuseumSelectionDialog extends StatefulWidget {
  const MuseumSelectionDialog({super.key});

  @override
  State<MuseumSelectionDialog> createState() => _MuseumSelectionDialogState();
}

class _MuseumSelectionDialogState extends State<MuseumSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> museums = [
    '三星堆博物馆',
    '成都金沙遗址博物馆',
    '四川博物院',
    '都江堰博物馆',
    '成都武侯祠博物馆',
    '杜甫草堂博物馆',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择博物馆',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SearchBar(
              controller: _searchController,
              hintText: '搜索博物馆',
              leading: const Icon(Icons.search),
              padding: const MaterialStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: museums.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.museum_outlined),
                    title: Text(museums[index]),
                    onTap: () {
                      Navigator.of(context).pop(museums[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;
  final VoidCallback onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
