import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/route_names.dart';

void handleBottomNavTap(
  BuildContext context,
  int index,
  int currentIndex,
) {
  if (index == currentIndex) return;

  switch (index) {
    case 0:
      context.go(RouteNames.home);
      break;
    case 1:
      context.go(RouteNames.expenses);
      break;
    case 2:
      context.go(RouteNames.summary);
      break;
    case 3:
      context.go(RouteNames.settings);
      break;
  }
}
