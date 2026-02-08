enum RouteNames { home, expenses }

extension RouteNamesExtension on RouteNames {
  String get path {
    switch (this) {
      case RouteNames.home:
        return '/';
      case RouteNames.expenses:
        return '/expenses';
    }
  }
}
