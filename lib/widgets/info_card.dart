import 'dart:convert';
import 'package:flutter/material.dart';

class ProductGrid extends StatelessWidget {
  final List products;
  final bool isLoading;
  final Function(String) onCompanySelected;

  const ProductGrid({
    super.key,
    required this.products,
    required this.isLoading,
    required this.onCompanySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return const Center(child: Text('لا توجد منتجات حالياً'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68, // ✅ متوازن لكل الشاشات
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final name = product['name'] ?? 'منتج';
        final price = product['price']?.toString();
        final imageData = product['path'];

        Widget imageWidget = _buildImage(imageData);

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            onCompanySelected(product['companyId'].toString());
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ✅ الصورة مرنة
                Expanded(flex: 6, child: imageWidget),

                /// ✅ المحتوى
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),

                        if (price != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade700,
                                  Colors.blue.shade400,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$price د.ع',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),

                        const Spacer(),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton.icon(
                            onPressed: () {
                              onCompanySelected(
                                product['companyId'].toString(),
                              );
                            },
                            icon: const Icon(Icons.store_rounded, size: 16),
                            label: const Text(
                              'عرض الشركة',
                              style: TextStyle(fontSize: 13),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue.shade700,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ بناء الصورة بشكل مرن
  Widget _buildImage(String? imageData) {
    if (imageData != null && imageData.startsWith('iVBOR')) {
      try {
        final bytes = base64Decode(imageData);
        return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity);
      } catch (_) {
        return _placeholderImage();
      }
    } else if (imageData != null &&
        (imageData.startsWith('http') || imageData.startsWith('https'))) {
      return Image.network(
        imageData,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }
    return _placeholderImage();
  }

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
      ),
    );
  }
}
