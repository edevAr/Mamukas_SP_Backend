import 'package:flutter/material.dart';

class CustomGridView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool isLoading;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final VoidCallback? onRefresh;

  const CustomGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16),
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.isLoading = false,
    this.emptyWidget,
    this.errorWidget,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingGrid();
    }

    if (items.isEmpty) {
      return emptyWidget ?? _buildEmptyState();
    }

    final gridView = GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getResponsiveCrossAxisCount(context),
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _GridItemWrapper(
          child: itemBuilder(items[index], index),
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          onRefresh!();
        },
        color: const Color(0xFF007AFF),
        child: gridView,
      );
    }

    return gridView;
  }

  int _getResponsiveCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > 1200) return crossAxisCount * 3;
    if (screenWidth > 800) return crossAxisCount * 2;
    if (screenWidth > 600) return crossAxisCount + 1;
    return crossAxisCount;
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _GridItemWrapper(
          child: _SkeletonLoader(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_view_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay elementos para mostrar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRefresh,
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    color: Color(0xFF007AFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GridItemWrapper extends StatelessWidget {
  final Widget child;

  const _GridItemWrapper({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _SkeletonLoader extends StatefulWidget {
  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          color: isDark 
              ? Colors.grey[800]!.withOpacity(_animation.value)
              : Colors.grey[300]!.withOpacity(_animation.value),
        );
      },
    );
  }
}