import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

class FoodBridgeApp extends ConsumerWidget {
  const FoodBridgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FoodBridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        ErrorWidget.builder = (details) => Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '${details.exception}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
