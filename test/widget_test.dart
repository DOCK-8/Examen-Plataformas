import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cafeteria_app/main.dart';

void main() {
  testWidgets('Comprobación del funcionamiento según caso práctico del examen',
      (WidgetTester tester) async {
    // Montamos la aplicación con ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: CafeteriaApp(),
      ),
    );

    // Estado inicial: 0 artículos y S/ 0.00
    expect(find.text('0'), findsOneWidget);
    expect(find.text('S/ 0.00'), findsOneWidget);

    // Identificar botones de agregar
    final btnCafe = find.byKey(const Key('btn_agregar_1'));
    final btnSandwich = find.byKey(const Key('btn_agregar_2'));
    final btnVaciar = find.byKey(const Key('btn_vaciar_pedido'));

    // Agregamos dos cafés y un sándwich
    // Café 1: S/ 6.00
    await tester.tap(btnCafe);
    await tester.pump();

    // Café 2: S/ 6.00
    await tester.tap(btnCafe);
    await tester.pump();

    // Sándwich: S/ 9.00
    await tester.tap(btnSandwich);
    await tester.pump();

    // Comprobación solicitada en el examen:
    // "Deben mostrarse 3 artículos y un total de S/ 21,00."
    expect(find.text('3'), findsOneWidget);
    expect(find.text('S/ 21.00'), findsOneWidget);

    // "Luego pulse Vaciar pedido y compruebe que la cantidad y el importe regresen a cero."
    await tester.tap(btnVaciar);
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('S/ 0.00'), findsOneWidget);
  });
}
