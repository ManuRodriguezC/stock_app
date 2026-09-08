import 'package:flutter/material.dart';
import 'package:stock_app/core/theme/app_colors.dart';
import 'package:stock_app/models/product.dart';

// =============================================================================
// T10 - FORMULARIO DE PRODUCTO
//
// Pantalla para crear un producto nuevo o editar uno existente.
// Cuando el usuario guarda, la pantalla se cierra y devuelve el producto
// a la pantalla anterior (la lista de productos).
// =============================================================================

// StatefulWidget: se usa cuando la pantalla cambia mientras el usuario la usa.
// Aqui cambia porque el usuario escribe, elige categoria y mueve el switch.
class ProductFormScreen extends StatefulWidget {
  // Producto que se va a editar. Si llega null, el formulario crea uno nuevo.
  final Product? initialProduct;

  // Codigos de barras que ya existen, para no permitir repetidos.
  final List<String> existingBarcodes;

  const ProductFormScreen({
    super.key,
    this.initialProduct,
    this.existingBarcodes = const [],
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // Llave del formulario. Sirve para pedirle a Flutter que valide
  // todos los campos de una sola vez cuando se presiona Guardar.
  final _formKey = GlobalKey<FormState>();

  // Un controlador por campo de texto. Guarda y lee lo que el usuario escribe.
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minimumStockController = TextEditingController();

  // Opciones de la lista desplegable de categorias.
  final List<String> _categories = ['Bebidas', 'Snacks', 'Electrónica', 'General'];

  String _selectedCategory = 'General';
  bool _isActive = true;
  bool _isEditing = false;

  // initState se ejecuta una sola vez, cuando la pantalla se abre.
  // Si llego un producto para editar, se llenan los campos con sus datos.
  @override
  void initState() {
    super.initState();

    final producto = widget.initialProduct;
    if (producto == null) return; // Modo crear: los campos quedan vacios.

    _isEditing = true;
    _nameController.text = producto.name;
    _barcodeController.text = producto.barcode ?? '';
    _descriptionController.text = producto.description ?? '';
    _priceController.text = producto.unitPrice.toStringAsFixed(0);
    _stockController.text = producto.stock.toString();
    _minimumStockController.text = producto.minimumStock.toString();
    _isActive = producto.isActive;

    if (producto.category != null && _categories.contains(producto.category)) {
      _selectedCategory = producto.category!;
    }
  }

  // dispose libera los controladores cuando la pantalla se cierra,
  // para no dejar memoria ocupada.
  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // VALIDACIONES
  // Cada funcion recibe lo que el usuario escribio.
  // Si devuelve un texto, ese texto aparece en rojo debajo del campo.
  // Si devuelve null, el campo esta correcto.
  // ===========================================================================

  String? _validarNombre(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'El nombre es obligatorio';
    if (texto.length < 3) return 'Debe tener al menos 3 caracteres';
    return null;
  }

  String? _validarCodigoBarras(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'El código de barras es obligatorio';
    if (int.tryParse(texto) == null) return 'Solo se permiten números';
    if (texto.length < 8) return 'Debe tener al menos 8 dígitos';

    // Al editar, se permite que el producto conserve su propio codigo.
    final codigoPropio = widget.initialProduct?.barcode;
    if (texto != codigoPropio && widget.existingBarcodes.contains(texto)) {
      return 'Ya existe un producto con este código';
    }
    return null;
  }

  String? _validarPrecio(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'El precio es obligatorio';

    final numero = double.tryParse(texto);
    if (numero == null) return 'Ingresa un número válido';
    if (numero <= 0) return 'El precio debe ser mayor que cero';
    return null;
  }

  String? _validarStock(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'Este campo es obligatorio';

    final numero = int.tryParse(texto);
    if (numero == null) return 'Ingresa un número entero';
    if (numero < 0) return 'No puede ser negativo';
    return null;
  }

  // ===========================================================================
  // GUARDAR
  // ===========================================================================

  void _guardar() {
    // Cierra el teclado del celular.
    FocusScope.of(context).unfocus();

    // validate() ejecuta todas las validaciones de arriba.
    // Devuelve false si alguna fallo.
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los campos marcados en rojo'),
          backgroundColor: AppColors.stockLow,
        ),
      );
      return;
    }

    final ahora = DateTime.now();
    final descripcion = _descriptionController.text.trim();

    // Se arma el objeto Product con los datos del formulario.
    final producto = Product(
      // Al editar se conserva el id original. Al crear se genera uno nuevo.
      id: widget.initialProduct?.id ?? ahora.millisecondsSinceEpoch.toString(),
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      description: descripcion.isEmpty ? null : descripcion,
      category: _selectedCategory,
      unitPrice: double.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      minimumStock: int.parse(_minimumStockController.text.trim()),
      imageUrl: widget.initialProduct?.imageUrl,
      isActive: _isActive,
      createdAt: widget.initialProduct?.createdAt ?? ahora,
      updatedAt: ahora,
    );

    // pop cierra esta pantalla y le entrega el producto a la pantalla anterior.
    Navigator.pop(context, producto);
  }

  // ===========================================================================
  // INTERFAZ
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Barra superior con el titulo y la flecha para regresar.
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          _isEditing ? 'Editar producto' : 'Nuevo producto',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        // Form agrupa todos los campos para poder validarlos juntos.
        child: Form(
          key: _formKey,
          // Valida mientras el usuario escribe, no solo al presionar Guardar.
          autovalidateMode: AutovalidateMode.onUserInteraction,

          // ListView permite desplazar la pantalla cuando sale el teclado.
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _titulo('Información general'),

              _campo(
                etiqueta: 'Nombre del producto',
                controlador: _nameController,
                pista: 'Ej. Coca Cola 350ml',
                icono: Icons.inventory_2_outlined,
                validador: _validarNombre,
              ),

              _campo(
                etiqueta: 'Código de barras',
                controlador: _barcodeController,
                pista: 'Ej. 7501234567890',
                icono: Icons.qr_code_2_outlined,
                tecladoNumerico: true,
                validador: _validarCodigoBarras,
              ),

              _listaCategorias(),

              _campo(
                etiqueta: 'Descripción (opcional)',
                controlador: _descriptionController,
                pista: 'Detalle breve del producto',
                icono: Icons.notes_outlined,
                lineas: 3,
              ),

              const SizedBox(height: 8),
              _titulo('Precio e inventario'),

              _campo(
                etiqueta: 'Precio unitario',
                controlador: _priceController,
                pista: '0',
                icono: Icons.attach_money_rounded,
                tecladoNumerico: true,
                validador: _validarPrecio,
              ),

              // Row coloca los dos campos de stock uno al lado del otro.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _campo(
                      etiqueta: 'Stock inicial',
                      controlador: _stockController,
                      pista: '0',
                      icono: Icons.layers_outlined,
                      tecladoNumerico: true,
                      validador: _validarStock,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _campo(
                      etiqueta: 'Stock mínimo',
                      controlador: _minimumStockController,
                      pista: '0',
                      icono: Icons.warning_amber_rounded,
                      tecladoNumerico: true,
                      validador: _validarStock,
                    ),
                  ),
                ],
              ),

              _switchActivo(),
              const SizedBox(height: 24),
              _botonGuardar(),
              const SizedBox(height: 10),
              _botonCancelar(),
            ],
          ),
        ),
      ),
    );
  }

  // Titulo de seccion.
  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // Arma un campo de texto completo: etiqueta + caja de escritura.
  // Se hizo como funcion para no repetir este mismo bloque seis veces.
  Widget _campo({
    required String etiqueta,
    required TextEditingController controlador,
    required String pista,
    required IconData icono,
    String? Function(String?)? validador,
    bool tecladoNumerico = false,
    int lineas = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: controlador,
            validator: validador,
            keyboardType: tecladoNumerico ? TextInputType.number : TextInputType.text,
            maxLines: lineas,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: pista,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14.5),
              prefixIcon: Icon(icono, size: 20, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: _borde(AppColors.border),
              enabledBorder: _borde(AppColors.border),
              focusedBorder: _borde(AppColors.primary, grosor: 1.6),
              errorBorder: _borde(AppColors.stockLow),
              focusedErrorBorder: _borde(AppColors.stockLow, grosor: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  // Borde redondeado de los campos.
  OutlineInputBorder _borde(Color color, {double grosor = 1.2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: grosor),
    );
  }

  // Lista desplegable de categorias.
  Widget _listaCategorias() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categoría',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.category_outlined,
                  size: 20, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: _borde(AppColors.border),
              enabledBorder: _borde(AppColors.border),
              focusedBorder: _borde(AppColors.primary, grosor: 1.6),
            ),
            // Convierte la lista de textos en las opciones del desplegable.
            items: _categories.map((categoria) {
              return DropdownMenuItem<String>(
                value: categoria,
                child: Text(categoria),
              );
            }).toList(),
            // setState redibuja la pantalla con la nueva categoria elegida.
            onChanged: (valor) {
              if (valor != null) {
                setState(() {
                  _selectedCategory = valor;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Interruptor para marcar el producto como activo o inactivo.
  Widget _switchActivo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _isActive,
        onChanged: (valor) {
          setState(() {
            _isActive = valor;
          });
        },
        title: const Text(
          'Producto activo',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text(
          'Los inactivos no aparecen en el inventario',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  // Boton principal: valida y guarda.
  Widget _botonGuardar() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _guardar,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _isEditing ? 'Guardar cambios' : 'Crear producto',
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // Boton secundario: cierra la pantalla sin guardar.
  Widget _botonCancelar() {
    return SizedBox(
      height: 50,
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
        child: const Text(
          'Cancelar',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
