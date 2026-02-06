import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'search_bar.dart';
import 'breadcrumb_nav.dart';

/// Shared AppBar: back when canPop, else optional fallback; optional drawer; optional actions.
/// Uses Theme.of(context).appBarTheme.
/// Enhanced with search functionality, breadcrumb navigation, and subtitle support.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showDrawer;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;
  final List<BreadcrumbItem>? breadcrumbs;

  const AppAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showDrawer = false,
    this.actions,
    this.leading,
    this.showSearch = false,
    this.onSearchChanged,
    this.onSearchTap,
    this.breadcrumbs,
  });

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (subtitle != null) height += 20;
    if (breadcrumbs != null && breadcrumbs!.isNotEmpty) height += 40;
    if (showSearch) height += 56;
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    Widget? leadingWidget = leading;
    if (leadingWidget == null) {
      if (showDrawer) {
        leadingWidget = IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold?.hasDrawer == true) scaffold!.openDrawer();
          },
        );
      } else if (canPop) {
        leadingWidget = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        );
      } else {
        leadingWidget = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        );
      }
    }

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (breadcrumbs != null && breadcrumbs!.isNotEmpty)
            BreadcrumbNav(items: breadcrumbs!),
          Text(title),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
        ],
      ),
      leading: leadingWidget,
      actions: [
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchTap,
            tooltip: 'Search',
          ),
        ...?actions,
      ],
      bottom: showSearch && onSearchChanged != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AppSearchBar(
                  hintText: 'Search...',
                  onChanged: onSearchChanged,
                ),
              ),
            )
          : null,
    );
  }
}
