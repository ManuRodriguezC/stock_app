import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_app/core/theme/app_colors.dart';
import 'package:stock_app/models/product.dart';
import 'package:stock_app/repositories/product_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? initialProduct;
  final List<String> existingBarcodes;
  final ProductRepository productRepository;

  const ProductFormScreen(
      {super.key,
      this.initialProduct,
      this.existingBarcodes = const [],
      required this.productRepository});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minimumStockController = TextEditingController();

  final List<String> _categories = [
    'Bebidas',
    'Snacks',
    'Electrónica',
    'General'
  ];

  String _selectedCategory = 'General';
  bool _isActive = true;
  bool _isEditing = false;
  bool _isSaving = false;

  XFile? _selectedImage;
  bool _isUploadingImage = false;
  bool _imageRemoved = false;
  String? _existingImageUrlFuture;

  @override
  void initState() {
    super.initState();

    final producto = widget.initialProduct;
    if (producto == null) return;

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

    final path = producto.imageUrl;
    if (path != null && path.isNotEmpty) {
      _existingImageUrlFuture =
          widget.productRepository.getProductImageUrl(path);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await widget.productRepository.pickProductImage(source);
      if (image == null) return;

      setState(() {
        _selectedImage = image;
        _imageRemoved = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir la cámara/galería: $e'),
          backgroundColor: AppColors.stockLow,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageRemoved = true;
    });
  }

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

  // Los mensajes van cortos porque estos dos campos comparten el ancho
  // de la pantalla y un texto largo se corta.
  String? _validarStock(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'Obligatorio';

    final numero = int.tryParse(texto);
    if (numero == null) return 'Debe ser entero';
    if (numero < 0) return 'No puede ser negativo';
    return null;
  }

  // ===========================================================================
  // GUARDAR
  // ===========================================================================

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los campos marcados en rojo'),
          backgroundColor: AppColors.stockLow,
        ),
      );

      return;
    }

    // Si hay foto nueva, se sube primero a Supabase Storage y se guarda la
    // RUTA del objeto en image_url (el bucket es privado).
    String? imagePath;
    final oldImagePath = widget.initialProduct?.imageUrl;

    if (_selectedImage != null) {
      setState(() => _isUploadingImage = true);
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;

        if (userId == null) {
          throw Exception('No hay un usuario autenticado');
        }

        imagePath = await widget.productRepository.uploadProductImage(
          _selectedImage!,
          userId,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
            _isSaving = false;
          });
        }
      }
    } else if (!_imageRemoved) {
      // Al editar sin cambiar la foto, se conserva la ruta anterior.
      imagePath = widget.initialProduct?.imageUrl;
    }

    final producto = Product(
      id: widget.initialProduct?.id ?? '',
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      unitPrice: double.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      minimumStock: int.parse(_minimumStockController.text.trim()),
      imageUrl: imagePath,
      isActive: _isActive,
      createdAt: widget.initialProduct?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      Product productoGuardado;

      if (_isEditing) {
        productoGuardado =
            await widget.productRepository.updateProduct(producto);
      } else {
        productoGuardado =
            await widget.productRepository.createProduct(producto);
      }

      // Si se cambió o eliminó la imagen, borramos la anterior de Storage.
      if (_isEditing &&
          oldImagePath != null &&
          oldImagePath.isNotEmpty &&
          oldImagePath != imagePath) {
        try {
          await widget.productRepository.deleteProductImage(oldImagePath);
        } catch (deleteError) {
          debugPrint('No se pudo eliminar la imagen anterior: $deleteError');
        }
      }

      if (!mounted) return;

      Navigator.pop(context, productoGuardado);
    } catch (e, stackTrace) {
      debugPrint('ERROR CREANDO PRODUCTO: $e');
      debugPrint('STACK TRACE: $stackTrace');

      // Si la imagen se subió pero el producto falló, se borra para no
      // dejar archivos huérfanos en Storage.
      if (_selectedImage != null && imagePath != null) {
        try {
          await widget.productRepository.deleteProductImage(imagePath);
        } catch (deleteError) {
          debugPrint('ERROR BORRANDO IMAGEN HUÉRFANA: $deleteError');
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear producto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              _seccionFoto(),
              const SizedBox(height: 4),
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

  // ===========================================================================
  // SECCIÓN DE FOTO
  // ===========================================================================

  Widget _seccionFoto() {
    final existingPath = widget.initialProduct?.imageUrl;
    final showExisting = _selectedImage == null &&
        !_imageRemoved &&
        existingPath != null &&
        existingPath.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo('Foto del producto'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 96,
                height: 96,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: _previewFoto(existingPath, showExisting),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _botonFoto(
                      icono: Icons.photo_camera_outlined,
                      etiqueta: 'Tomar foto',
                      onPressed: _isUploadingImage
                          ? null
                          : () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(height: 8),
                    _botonFoto(
                      icono: Icons.photo_library_outlined,
                      etiqueta: 'Elegir de galería',
                      onPressed: _isUploadingImage
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                    ),
                    if (_selectedImage != null || showExisting) ...[
                      const SizedBox(height: 2),
                      TextButton.icon(
                        onPressed: _isUploadingImage ? null : _removeImage,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Quitar foto'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.stockLow,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewFoto(String? existingPath, bool showExisting) {
    final selected = _selectedImage;
    if (selected != null) {
      return Image.file(File(selected.path), fit: BoxFit.cover);
    }

    if (showExisting && _existingImageUrlFuture != null) {
      return FutureBuilder<String>(
        future: _existingImageUrlFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            return Image.network(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderFoto(),
            );
          }
          return _placeholderFoto(cargando: true);
        },
      );
    }

    return _placeholderFoto();
  }

  Widget _placeholderFoto({bool cargando = false}) {
    if (cargando) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 26, color: AppColors.textMuted),
        SizedBox(height: 4),
        Text('Sin foto',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _botonFoto({
    required IconData icono,
    required String etiqueta,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 38,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icono, size: 17),
        label: Text(etiqueta,
            style:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border, width: 1.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
            keyboardType:
                tecladoNumerico ? TextInputType.number : TextInputType.text,
            maxLines: lineas,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: pista,
              hintStyle:
                  const TextStyle(color: AppColors.textMuted, fontSize: 14.5),
              prefixIcon: Icon(icono, size: 20, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        onPressed: _isUploadingImage ? null : _guardar,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isUploadingImage
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Text('Subiendo imagen...',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              )
            : Text(
                _isEditing ? 'Guardar cambios' : 'Crear producto',
                style: const TextStyle(
                    fontSize: 15.5, fontWeight: FontWeight.w700),
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
