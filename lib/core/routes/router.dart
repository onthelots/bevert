enum AppRouter {
  root(path: '/', name: 'root', subPath: '/'),
  splash(path: '/splash', name: 'splash', subPath: 'splash'),
  home(path: '/home', name: 'home', subPath: 'home'),

  // folderDetail
  folderDetail(path: '/home/folderDetail', name: 'folderDetail', subPath: 'folderDetail'),

  // Recording
  recording(path: '/home/recording', name: 'recording', subPath: 'recording'),

  // Summary
  summary(path: '/home/summary', name: 'summary', subPath: 'summary'),

  // Calendar
  calendar(path: '/settings/calendar', name: 'calendar', subPath: 'calendar'),

  // Settings (Drawer 대상)
  theme(path: '/settings/theme', name: 'theme', subPath: 'theme'),
  language(path: '/settings/language', name: 'language', subPath: 'language'),
  policy(path: '/settings/policy', name: 'policy', subPath: 'policy'),
  about(path: '/settings/about', name: 'about', subPath: 'about');

  const AppRouter({
    required this.path,
    required this.name,
    required this.subPath,
  });

  final String path;
  final String subPath;
  final String name;
}
