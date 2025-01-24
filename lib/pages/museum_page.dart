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
  late final PageController _pageController;

  final List<({IconData icon, String label})> _filterOptions = [
    (icon: Icons.account_balance, label: '历史文物'),
    (icon: Icons.brush, label: '艺术作品'),
    (icon: Icons.nature, label: '自然科学'),
    (icon: Icons.computer, label: '科技展品'),
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
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _indicatorController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updateIndicatorPosition() {
    setState(() {
      _indicatorPosition = Tween<double>(
        begin: _previousIndex * 100.0 + 50.0,
        end: _selectedIndex * 100.0 + 50.0,
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
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 16),
                Expanded(
                  flex: 5,
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
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
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
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 80,
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == _filterOptions.length) {
                    return SizedBox(
                      width: 100,
                      child: AnimatedBuilder(
                        animation: _indicatorController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_indicatorPosition?.value ?? (50 + _selectedIndex * 100.0), 0),
                            child: Container(
                              width: 30,
                              height: 2,
                              color: colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () {
                      _previousIndex = _selectedIndex;
                      setState(() => _selectedIndex = index);
                      _updateIndicatorPosition();
                      _pageController.jumpToPage(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: _buildFilterOption(
                          icon: _filterOptions[index].icon,
                          label: _filterOptions[index].label,
                          isSelected: index == _selectedIndex,
                          colorScheme: colorScheme,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                children: _filterOptions.map((option) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                              width: 1.0,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            leading: Icon(Icons.place, size: 32),
                            title: Text('推荐的\\${option.label}'),
                            subtitle: Text('历史文物名称 - 简短描述'),
                            trailing: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Image.asset(
                                  'assets/images/test2.png',
                                  width: 220,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SwitchListTile(
                            title: Text('是否根据位置来推荐展品'),
                            subtitle: Text('包括所有费用，税前'),
                            value: false, // Default value
                            onChanged: (bool value) {
                              // Handle switch state change
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                                child: Image.asset(
                                  'assets/images/museum_cover.jpg',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '新文物名称',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              '这是一个新的文物描述。',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary),
                                            SizedBox(width: 4),
                                            Text(
                                              '10.0m',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                                child: Image.asset(
                                  'assets/images/museum_cover.jpg',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '新文物名称',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              '这是一个新的文物描述。',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary),
                                            SizedBox(width: 4),
                                            Text(
                                              '10.0m',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
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
    required ColorScheme colorScheme,
  }) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
              ),
              child: Icon(
                icon,
                size: 32,
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
            if (isSelected)
              Container(
                width: 40,
                height: 2,
                color: colorScheme.primary,
              ),
          ],
        ),
        Positioned.fill(
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
