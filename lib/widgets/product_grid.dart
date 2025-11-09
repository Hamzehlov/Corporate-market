import 'dart:convert';
import 'package:flutter/material.dart';
import '../pages/company_details_page.dart';

class ProductGrid extends StatelessWidget {
  final List products;
  final bool isLoading;
  final String? selectedCompanyId;
  final Function(String) onCompanySelected;

  const ProductGrid({
    required this.products,
    required this.isLoading,
    required this.selectedCompanyId,
    required this.onCompanySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (products.isEmpty)
      return const Center(child: Text('لا توجد منتجات حالياً'));

    List filteredProducts = selectedCompanyId == null
        ? products
        : products
              .where((p) => p['companyId'].toString() == selectedCompanyId)
              .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        final name = product['name'] ?? 'منتج';
        final price = product['price']?.toString() ?? '';
        final imageData = product['path'];

        Widget imageWidget;

        // ✅ تحويل Base64 إلى صورة
        if (imageData != null && imageData.toString().startsWith('iVBOR')) {
          try {
            final bytes = base64Decode(imageData);
            imageWidget = Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 140,
            );
          } catch (e) {
            imageWidget = _placeholderImage();
          }
        } else if (imageData != null &&
            (imageData.toString().startsWith('http') ||
                imageData.toString().startsWith('https'))) {
          imageWidget = Image.network(
            imageData,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 140,
            errorBuilder: (context, error, stackTrace) => _placeholderImage(),
          );
        } else {
          imageWidget = _placeholderImage();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompanyDetailsPage(
                  companyId: product['companyId'].toString(),
                ),
              ),
            );
          },
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ صورة المنتج مع ظل
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: imageWidget,
                  ),
                ),
                const SizedBox(height: 8),
                // اسم المنتج
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // السعر مع خلفية جذابة
                if (price.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$price د.ع',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                // زر عرض الشركة
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton.icon(
                      onPressed: () {
                        onCompanySelected(product['companyId'].toString());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompanyDetailsPage(
                              companyId: product['companyId'].toString(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.store_rounded, size: 18),
                      label: const Text('عرض الشركة'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                      ),
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

  Widget _placeholderImage() {
    return Container(
      height: 140,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
      ),
    );
  }
}
