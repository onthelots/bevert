class AppAsset {
  AppAsset._init();

  static final AppAsset _instance = AppAsset._init();

  factory AppAsset() {
    return _instance;
  }

  static final AppAssetIcon icon = AppAssetIcon();
}

/// Icon
class AppAssetIcon {
  AppAssetIcon._init();

  static final AppAssetIcon _instance = AppAssetIcon._init();

  factory AppAssetIcon() {
    return _instance;
  }

  final String icon_original = 'assets/icon/icon_original.png';
  final String icon_circle_light = 'assets/icon/icon_circle_light.png';
  final String icon_circle_dark = 'assets/icon/icon_circle_dark.png';
}