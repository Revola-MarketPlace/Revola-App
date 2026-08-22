import 'package:flutter_test/flutter_test.dart';
import 'package:revola_app/core/providers/core_providers.dart';
import 'package:revola_app/core/storage/storage_service.dart';
import 'package:revola_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('RevolaApp smoke test', (WidgetTester tester) async {
    final storageService = StorageService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
        child: const RevolaApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(RevolaApp), findsOneWidget);
  });
}
