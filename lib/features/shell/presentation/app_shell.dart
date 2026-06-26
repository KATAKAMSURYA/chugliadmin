import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/reports/data/reports_repository.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);
    final pendingCount = reportsAsync.asData?.value
            .where((r) => r['status'] == 'Pending')
            .length ??
        0;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────
          Container(
            width: 280,
            color: const Color(0xFF1E1E1E),
            child: Column(
              children: [
                // Logo
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.shield,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Chugli Admin',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          Text(
                            'Enterprise Control',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    children: [
                      _SidebarItem(
                        icon: Icons.dashboard_outlined,
                        label: 'Dashboard',
                        isSelected:
                            GoRouterState.of(context).matchedLocation == '/',
                        onTap: () => context.go('/'),
                      ),
                      const SizedBox(height: 8),
                      _SidebarItem(
                        icon: Icons.people_outline,
                        label: 'Users',
                        isSelected: GoRouterState.of(context)
                            .matchedLocation
                            .startsWith('/users'),
                        onTap: () => context.go('/users'),
                      ),
                      const SizedBox(height: 8),
                      _SidebarItem(
                        icon: Icons.meeting_room_outlined,
                        label: 'Rooms',
                        isSelected: GoRouterState.of(context)
                            .matchedLocation
                            .startsWith('/rooms'),
                        onTap: () => context.go('/rooms'),
                      ),
                      const SizedBox(height: 8),
                      _SidebarItem(
                        icon: Icons.chat_bubble_outline,
                        label: 'Moderation',
                        badge: null,
                        isSelected: GoRouterState.of(context)
                            .matchedLocation
                            .startsWith('/moderation'),
                        onTap: () => context.go('/moderation'),
                      ),
                      const SizedBox(height: 8),
                      _SidebarItem(
                        icon: Icons.report_problem_outlined,
                        label: 'Reports',
                        badge: pendingCount > 0 ? pendingCount : null,
                        isSelected: GoRouterState.of(context)
                            .matchedLocation
                            .startsWith('/reports'),
                        onTap: () => context.go('/reports'),
                      ),
                      const SizedBox(height: 8),
                      _SidebarItem(
                        icon: Icons.analytics_outlined,
                        label: 'Analytics',
                        isSelected: GoRouterState.of(context)
                            .matchedLocation
                            .startsWith('/analytics'),
                        onTap: () => context.go('/analytics'),
                      ),
                      const SizedBox(height: 8),
                      _SidebarItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        isSelected: GoRouterState.of(context)
                            .matchedLocation
                            .startsWith('/settings'),
                        onTap: () => context.go('/settings'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF353534)),
                // Admin profile footer
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAdminProfile(context, user),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: Text(
                            (user?.email?.isNotEmpty == true)
                                ? user!.email![0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showAdminProfile(context, user),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.email ?? 'Admin',
                                style:
                                    Theme.of(context).textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'ROOT ADMIN',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 18),
                        color: const Color(0xFF8F909E),
                        tooltip: 'Sign Out',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF201F1F),
                              title: const Text('Sign Out?'),
                              content: const Text(
                                  'Are you sure you want to sign out of the admin dashboard?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  child: const Text('Sign Out'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) context.go('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Main Content ──────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF131313),
                    border: Border(
                        bottom:
                            BorderSide(color: Color(0xFF353534), width: 1)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _pageTitle(
                            GoRouterState.of(context).matchedLocation),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 32),
                      // Global search
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: const Color(0xFF353534)),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Global system search...',
                              prefixIcon: const Icon(Icons.search,
                                  size: 20, color: Color(0xFF8F909E)),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: const Color(0xFF8F909E)),
                            ),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            onSubmitted: (query) {
                              if (query.trim().isNotEmpty) {
                                context.go('/users');
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Notifications
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            color: const Color(0xFFE5E2E1),
                            tooltip: 'Notifications',
                            onPressed: () =>
                                _showNotificationsPanel(context, pendingCount),
                          ),
                          if (pendingCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$pendingCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Settings
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        color: const Color(0xFFE5E2E1),
                        tooltip: 'Settings',
                        onPressed: () => context.go('/settings'),
                      ),
                      const SizedBox(width: 16),
                      Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFF353534)),
                      const SizedBox(width: 16),
                      // Admin profile chip
                      GestureDetector(
                        onTap: () => _showAdminProfile(context, user),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF353534)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Text(
                                  (user?.email?.isNotEmpty == true)
                                      ? user!.email![0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user?.email?.split('@').first ?? 'Admin',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Color(0xFF8F909E), size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Page Content
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _pageTitle(String path) {
    if (path == '/') return 'Dashboard';
    if (path.startsWith('/users')) return 'User Management';
    if (path.startsWith('/rooms')) return 'Room Management';
    if (path.startsWith('/moderation')) return 'Chat Moderation';
    if (path.startsWith('/reports')) return 'Reports';
    if (path.startsWith('/analytics')) return 'Analytics';
    if (path.startsWith('/settings')) return 'Settings';
    return 'Chugli Admin';
  }

  void _showNotificationsPanel(BuildContext context, int pendingCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF201F1F),
        title: Row(
          children: [
            Icon(Icons.notifications,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Notifications'),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pendingCount > 0)
                _NotifTile(
                  icon: Icons.report_problem_outlined,
                  iconColor: Theme.of(context).colorScheme.error,
                  title: '$pendingCount Pending Reports',
                  subtitle:
                      'Reports require your attention. Tap to review.',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go('/reports');
                  },
                )
              else
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 48, color: Color(0xFF50DAD1)),
                      SizedBox(height: 12),
                      Text('All clear! No pending notifications.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF8F909E))),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAdminProfile(BuildContext context, User? user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF201F1F),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                (user?.email?.isNotEmpty == true)
                    ? user!.email![0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Admin Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProfileRow(label: 'Email', value: user?.email ?? '—'),
            _ProfileRow(label: 'UID', value: user?.uid ?? '—'),
            _ProfileRow(label: 'Role', value: 'ROOT ADMIN'),
            _ProfileRow(
              label: 'Last Sign-In',
              value: user?.metadata.lastSignInTime != null
                  ? '${user!.metadata.lastSignInTime!.toLocal()}'
                      .substring(0, 16)
                  : '—',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/settings');
            },
            child: const Text('Settings'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131313),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF353534)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF8F909E), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF8F909E)),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF8F909E), fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final textStyle = isSelected
        ? theme.textTheme.titleSmall
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)
        : theme.textTheme.titleSmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? secondary : Colors.transparent,
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(4)),
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              icon,
              color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: textStyle)),
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
