import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==========================================
// 1. MODELO
// Requisito 1: Modelo Producto con id, nombre y precio
// ==========================================
@immutable
class Producto {
  final String id;
  final String nombre;
  final double precio;

  const Producto({
    required this.id,
    required this.nombre,
    required this.precio,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Producto &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Catálogo constante de productos definidos en el examen
const List<Producto> catalogoProductos = [
  Producto(id: '1', nombre: 'Café americano', precio: 6.00),
  Producto(id: '2', nombre: 'Sándwich de pollo', precio: 9.00),
  Producto(id: '3', nombre: 'Jugo de naranja', precio: 7.00),
];

// ==========================================
// 2. GESTOR DE ESTADO (Notifier & NotifierProvider)
// Requisito 2: Administre la lista mediante Notifier y NotifierProvider.
// Lista inicial vacía.
// Requisito 4: Actualice creando una nueva lista (inmutabilidad).
// ==========================================
class PedidoNotifier extends Notifier<List<Producto>> {
  @override
  List<Producto> build() {
    // La lista inicial debe estar vacía
    return const [];
  }

  /// Agrega un producto al pedido creando una nueva lista inmutable
  void agregarProducto(Producto producto) {
    state = [...state, producto];
  }

  /// Requisito 5: Restablece el pedido a cero (lista vacía)
  void vaciarPedido() {
    state = const [];
  }
}

final pedidoProvider = NotifierProvider<PedidoNotifier, List<Producto>>(
  PedidoNotifier.new,
);

// Proveedores derivados para un rendimiento óptimo
final totalArticulosProvider = Provider<int>((ref) {
  final pedido = ref.watch(pedidoProvider);
  return pedido.length;
});

final totalImporteProvider = Provider<double>((ref) {
  final pedido = ref.watch(pedidoProvider);
  return pedido.fold<double>(0.0, (acum, prod) => acum + prod.precio);
});

// ==========================================
// 3. PUNTO DE ENTRADA
// ==========================================
void main() {
  runApp(
    // ProviderScope es obligatorio en la raíz para Riverpod
    const ProviderScope(
      child: CafeteriaApp(),
    ),
  );
}

class CafeteriaApp extends StatelessWidget {
  const CafeteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafetería - Pedido',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6F4E37), // Tono café
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CafeteriaScreen(),
    );
  }
}

// ==========================================
// 4. PANTALLA PRINCIPAL
// ==========================================
class CafeteriaScreen extends ConsumerWidget {
  const CafeteriaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Requisito 4: ref.watch() para cantidad de artículos e importe total
    final totalArticulos = ref.watch(totalArticulosProvider);
    final totalImporte = ref.watch(totalImporteProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pedido de Cafetería',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sección de Catálogo
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: catalogoProductos.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final producto = catalogoProductos[index];
                  return Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                            foregroundColor: colorScheme.primary,
                            child: Icon(_getIconForProduct(producto.nombre)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  producto.nombre,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'S/ ${producto.precio.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Requisito 3: Botón Agregar que suma 1 unidad
                          FilledButton.icon(
                            key: Key('btn_agregar_${producto.id}'),
                            onPressed: () {
                              ref
                                  .read(pedidoProvider.notifier)
                                  .agregarProducto(producto);
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agregar'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Resumen del pedido y botón Vaciar
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Métricas: Artículos e Importe Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cantidad de artículos',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalArticulos',
                            key: const Key('total_articulos_text'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Importe total',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'S/ ${totalImporte.toStringAsFixed(2)}',
                            key: const Key('total_importe_text'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Requisito 5: Botón Vaciar pedido
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      key: const Key('btn_vaciar_pedido'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: totalArticulos > 0
                          ? () {
                              ref.read(pedidoProvider.notifier).vaciarPedido();
                            }
                          : null,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text(
                        'Vaciar pedido',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForProduct(String nombre) {
    if (nombre.toLowerCase().contains('café')) return Icons.coffee;
    if (nombre.toLowerCase().contains('sándwich')) return Icons.lunch_dining;
    if (nombre.toLowerCase().contains('jugo')) return Icons.local_drink;
    return Icons.fastfood;
  }
}
