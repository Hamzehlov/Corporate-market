import 'package:flutter/material.dart';
import '../pages/company_details_page.dart';

class ProductGrid extends StatelessWidget {
  final List products;
  final bool isLoading;
  final String? selectedCompanyId;
  final Function(String) onCompanySelected;

  ProductGrid({
    required this.products,
    required this.isLoading,
    required this.selectedCompanyId,
    required this.onCompanySelected,
  });

  final List<Color> cardColors = [
    const Color(0xFF667eea),
    const Color(0xFF764ba2),
    const Color(0xFFf093fb),
    const Color(0xFFf5576c),
    const Color(0xFF4facfe),
    const Color(0xFF00f2fe),
    const Color(0xFF43e97b),
    const Color(0xFF38f9d7),
  ];

  final List<IconData> productIcons = [
    Icons.shopping_bag_rounded,
    Icons.phone_iphone_rounded,
    Icons.computer_rounded,
    Icons.headset_rounded,
    Icons.watch_rounded,
    Icons.tablet_rounded,
    Icons.tv_rounded,
    Icons.camera_alt_rounded,
  ];

  Color getCardColor(int index) => cardColors[index % cardColors.length];

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
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        var product = filteredProducts[index];
        final color = getCardColor(index);

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
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      productIcons[index % productIcons.length],
                      size: 30,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['name'] ?? 'منتج',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
