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
    return const [];
  }

  /// Agrega un producto al pedido creando una nueva lista
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

// Proveedores derivados sencillos
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
      title: 'Pedido de Cafetería',
      debugShowCheckedModeBanner: false,
      // Estilo estándar y limpio por defecto de Android (Material)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
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
    // Requisito 4: ref.watch() para lista, cantidad e importe
    final pedido = ref.watch(pedidoProvider);
    final totalArticulos = ref.watch(totalArticulosProvider);
    final totalImporte = ref.watch(totalImporteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido de Cafetería'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título del catálogo
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Catálogo de Productos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Requisito 3: Lista simple con ListTile estándar de Android
          ...catalogoProductos.map(
            (producto) => ListTile(
              title: Text(producto.nombre),
              subtitle: Text('S/ ${producto.precio.toStringAsFixed(2)}'),
              trailing: ElevatedButton(
                key: Key('btn_agregar_${producto.id}'),
                onPressed: () {
                  ref.read(pedidoProvider.notifier).agregarProducto(producto);
                },
                child: const Text('Agregar'),
              ),
            ),
          ),

          const Divider(),

          // Sección de productos agregados al pedido
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Artículos en el Pedido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: pedido.isEmpty
                ? const Center(
                    child: Text(
                      'No hay productos en el pedido',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: pedido.length,
                    itemBuilder: (context, index) {
                      final item = pedido[index];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 12,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        title: Text(item.nombre),
                        trailing: Text(
                          'S/ ${item.precio.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    },
                  ),
          ),

          const Divider(height: 1),

          // Resumen y botón vaciar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cantidad de artículos:',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      '$totalArticulos',
                      key: const Key('total_articulos_text'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Importe total:',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      'S/ ${totalImporte.toStringAsFixed(2)}',
                      key: const Key('total_importe_text'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: const Key('btn_vaciar_pedido'),
                    onPressed: totalArticulos > 0
                        ? () {
                            ref.read(pedidoProvider.notifier).vaciarPedido();
                          }
                        : null,
                    child: const Text('Vaciar pedido'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
