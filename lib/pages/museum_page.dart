import 'package:flutter/material.dart';

class MuseumPage extends StatefulWidget {
  const MuseumPage({super.key});

  @override
  State<MuseumPage> createState() => _MuseumPageState();
}

class _MuseumPageState extends State<MuseumPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _indicatorController;
  late Animation<double> _indicatorPosition;
  int _previousIndex = 0;

  final List<({IconData icon, String label})> _filterOptions = [
    (icon: Icons.landscape, label: 'Amazing views'),
    (icon: Icons.beach_access, label: 'Beachfront'),
    (icon: Icons.pool, label: 'Amazing pools'),
    (icon: Icons.home, label: 'Farms'),
  ];

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _indicatorPosition = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  void _updateIndicatorPosition() {
    setState(() {
      _indicatorPosition = Tween<double>(
        begin: _previousIndex * 116.0,
        end: _selectedIndex * 116.0,
      ).animate(CurvedAnimation(
        parent: _indicatorController,
        curve: Curves.easeInOut,
      ));
    });
    _indicatorController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('博物馆'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: '搜索艺术品...',
                    leading: Icon(Icons.search),
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 16),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    side: MaterialStateProperty.all(
                      BorderSide(color: colorScheme.primary),
                    ),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward, color: colorScheme.onPrimary),
                    onPressed: () {
                      // 执行搜索操作
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 80,
              child: Stack(
                children: [
                  ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterOptions.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) => SizedBox(
                      width: 100,
                      child: _buildFilterOption(
                        icon: _filterOptions[index].icon,
                        label: _filterOptions[index].label,
                        isSelected: index == _selectedIndex,
                        onTap: () {
                          _previousIndex = _selectedIndex;
                          setState(() => _selectedIndex = index);
                          _updateIndicatorPosition();
                          // 滚动到选中项
                          _scrollController.animateTo(
                            index * 116.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        colorScheme: colorScheme,
                      ),
                    ),
                  ),
                  // 底部指示器
                  Positioned(
                    bottom: 0,
                    left: 35, // (100 - 30) / 2 = 35，使指示器居中
                    child: AnimatedBuilder(
                      animation: _indicatorController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_indicatorPosition?.value ?? (35 + _selectedIndex * 116.0), 0),
                          child: Container(
                            width: 30,
                            height: 2,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
            child: Icon(
              icon,
              size: 24,
            ),
          ),
          SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}
