import 'dart:convert';
import 'package:flutter/material.dart';

class ProductGrid extends StatelessWidget {
  final List products;
  final bool isLoading;
  final String? selectedCompanyId;
  final Function(String) onCompanySelected;
  final VoidCallback? onViewAllProducts;
  final bool showFilter;
  final VoidCallback? onRefresh; // أضيفت هذه الخاصية

  const ProductGrid({
    super.key,
    required this.products,
    required this.isLoading,
    required this.selectedCompanyId,
    required this.onCompanySelected,
    this.onViewAllProducts,
    this.showFilter = true,
    this.onRefresh, // أضيفت هنا
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final screenWidth = MediaQuery.of(context).size.width;

    // إذا كان التحديث متاحاً، نعرض RefreshIndicator
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          onRefresh!();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: isDark ? Colors.tealAccent : Colors.blue,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        displacement: 20,
        edgeOffset: 10,
        strokeWidth: 2.5,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        child: _buildContent(
          context: context,
          isDark: isDark,
          isArabic: isArabic,
          screenWidth: screenWidth,
        ),
      );
    }

    return _buildContent(
      context: context,
      isDark: isDark,
      isArabic: isArabic,
      screenWidth: screenWidth,
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required bool isDark,
    required bool isArabic,
    required double screenWidth,
  }) {
    if (isLoading) {
      return _buildShimmerGrid(isDark, screenWidth);
    }

    if (products.isEmpty) {
      return _buildEmptyState(
        isDark: isDark,
        isArabic: isArabic,
        onRefresh: onRefresh,
      );
    }

    final filteredProducts = selectedCompanyId == null
        ? products
        : products
              .where((p) => p['companyId'].toString() == selectedCompanyId)
              .toList();

    return Column(
      children: [
        // Header مع زر عرض الكل
        if (onViewAllProducts != null && products.length > 6)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 350 ? 10 : 12,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'المنتجات المتاحة',
                      style: TextStyle(
                        fontSize: screenWidth < 350 ? 14 : 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (onRefresh != null) ...[
                      const SizedBox(width: 8),
                      // زر تحديث صغير بجانب العنوان
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.teal.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          border: Border.all(
                            color: isDark
                                ? Colors.tealAccent.withOpacity(0.3)
                                : Colors.blue.shade300,
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            onRefresh!();
                            // إضافة تأثير اهتزاز
                            _showRefreshFeedback(context, isDark);
                          },
                          icon: Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: isDark
                                ? Colors.tealAccent
                                : Colors.blue.shade600,
                          ),
                          padding: EdgeInsets.zero,
                          splashRadius: 15,
                        ),
                      ),
                    ],
                  ],
                ),
                if (filteredProducts.length > 6)
                  Text(
                    '${filteredProducts.length} منتج',
                    style: TextStyle(
                      fontSize: screenWidth < 350 ? 12 : 13,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

        // Grid المنتجات
        Expanded(
          child: _buildProductGrid(
            context: context,
            filteredProducts: filteredProducts,
            screenWidth: screenWidth,
            isDark: isDark,
            isArabic: isArabic,
          ),
        ),

        // زر تحديث في الأسفل (للشاشات الكبيرة فقط)
        if (onRefresh != null && screenWidth > 600 && !isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.teal.withOpacity(0.1),
                          Colors.teal.withOpacity(0.05),
                        ]
                      : [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.tealAccent.withOpacity(0.2)
                      : Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: TextButton.icon(
                onPressed: () {
                  onRefresh!();
                  _showRefreshFeedback(context, isDark);
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.tealAccent : Colors.blue,
                          ),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          key: const ValueKey('refresh_icon'),
                          color: isDark
                              ? Colors.tealAccent
                              : Colors.blue.shade600,
                        ),
                ),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLoading
                      ? Text(
                          'جاري التحديث...',
                          key: const ValueKey('loading_text'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.tealAccent
                                : Colors.blue.shade600,
                          ),
                        )
                      : Text(
                          'تحديث المنتجات',
                          key: const ValueKey('refresh_text'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.tealAccent
                                : Colors.blue.shade600,
                          ),
                        ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // دالة لعرض تأثير التحديث
  void _showRefreshFeedback(BuildContext context, bool isDark) {
    // تأثير اهتزاز بسيط
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.autorenew_rounded,
              color: isDark ? Colors.tealAccent : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            const Text('جاري تحديث المنتجات...'),
          ],
        ),
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.blue.shade600,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildProductGrid({
    required BuildContext context,
    required List filteredProducts,
    required double screenWidth,
    required bool isDark,
    required bool isArabic,
  }) {
    // دائماً نعرض كاردين جنب بعض حتى على أصغر الشاشات
    int crossAxisCount = 2;
    double aspectRatio = 0.75; // نسبة عمودية جيدة
    EdgeInsets padding;
    double spacing;

    if (screenWidth < 350) {
      // شاشات صغيرة جداً
      padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
      spacing = 6;
      aspectRatio = 0.8; // كارد أطول شوي
    } else if (screenWidth < 400) {
      padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8);
      spacing = 8;
      aspectRatio = 0.78;
    } else if (screenWidth < 500) {
      padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
      spacing = 10;
      aspectRatio = 0.76;
    } else {
      // شاشات متوسطة وكبيرة
      crossAxisCount = screenWidth > 700 ? 3 : 2;
      padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      spacing = 12;
      aspectRatio = screenWidth > 700 ? 0.8 : 0.75;
    }

    return GridView.builder(
      padding: padding,
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(
          product: filteredProducts[index],
          isDark: isDark,
          isArabic: isArabic,
          screenWidth: screenWidth,
        );
      },
    );
  }

  Widget _buildProductCard({
    required dynamic product,
    required bool isDark,
    required bool isArabic,
    required double screenWidth,
  }) {
    final name = product['name']?.toString().trim() ?? 'منتج';
    final price = product['price']?.toString() ?? '';
    final imageData = product['path'];
    final companyId = product['companyId']?.toString() ?? '';
    final isNew = product['isNew'] ?? false;
    final isFeatured = product['isFeatured'] ?? false;
    final rating = product['rating']?.toDouble() ?? 0.0;
    final hasDiscount = product['hasDiscount'] ?? false;
    final originalPrice = product['originalPrice']?.toString();

    // تحديد الأحجام بناءً على عرض الشاشة
    final bool isSmallScreen = screenWidth < 350;
    final double imageHeight = isSmallScreen ? 90 : 100;
    final double borderRadius = isSmallScreen ? 10 : 12;
    final double fontSizeTitle = isSmallScreen ? 11 : 12;
    final double fontSizePrice = isSmallScreen ? 10 : 11;

    return Container(
      margin: const EdgeInsets.all(2),
      child: Material(
        borderRadius: BorderRadius.circular(borderRadius),
        color: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 3,
        shadowColor: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.shade300.withOpacity(0.5),
        child: InkWell(
          onTap: () => onCompanySelected(companyId),
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: isDark
              ? Colors.teal.withOpacity(0.2)
              : Colors.blue.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // الصورة مع العلامات
                Stack(
                  children: [
                    // الصورة الرئيسية
                    Container(
                      height: imageHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(borderRadius),
                          topRight: Radius.circular(borderRadius),
                        ),
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                      ),
                      child: _buildProductImage(
                        imageData: imageData,
                        isDark: isDark,
                        isSmallScreen: isSmallScreen,
                        borderRadius: borderRadius,
                      ),
                    ),

                    // علامات خاصة
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Row(
                        children: [
                          if (isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'جديد',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 8 : 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isFeatured)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'مميز',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 8 : 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // التقييم
                    if (rating > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: isSmallScreen ? 10 : 12,
                                color: Colors.amber,
                              ),
                              SizedBox(width: isSmallScreen ? 2 : 3),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 9 : 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // معلومات المنتج
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم المنتج
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: fontSizeTitle,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.2,
                          ),
                        ),

                        // السعر
                        if (price.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasDiscount && originalPrice != null)
                                Text(
                                  '$originalPrice د.ع',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 8 : 9,
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 6 : 8,
                                  vertical: isSmallScreen ? 3 : 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [
                                            Colors.teal.shade700,
                                            Colors.teal.shade500,
                                          ]
                                        : [
                                            Colors.blue.shade600,
                                            Colors.blue.shade400,
                                          ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$price د.ع',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: fontSizePrice,
                                      ),
                                    ),
                                    Icon(
                                      Icons.shopping_cart_rounded,
                                      color: Colors.white,
                                      size: isSmallScreen ? 14 : 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        // أزرار الأفعال
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // زر الشركة
                            Expanded(
                              child: InkWell(
                                onTap: () => onCompanySelected(companyId),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 4 : 6,
                                    vertical: isSmallScreen ? 2 : 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.teal.withOpacity(0.1)
                                        : Colors.blue.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.tealAccent.withOpacity(0.3)
                                          : Colors.blue.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.store_rounded,
                                        size: isSmallScreen ? 12 : 14,
                                        color: isDark
                                            ? Colors.tealAccent
                                            : Colors.blue.shade700,
                                      ),
                                      SizedBox(width: isSmallScreen ? 2 : 4),
                                      Flexible(
                                        child: Text(
                                          'الشركة',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 10 : 11,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.tealAccent
                                                : Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: isSmallScreen ? 4 : 6),

                            // أزرار المفضلة
                            Row(
                              children: [
                                Container(
                                  width: isSmallScreen ? 26 : 28,
                                  height: isSmallScreen ? 26 : 28,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.pink.withOpacity(0.1)
                                        : Colors.pink.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.pink.shade300.withOpacity(
                                              0.3,
                                            )
                                          : Colors.pink.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.favorite_border_rounded,
                                      size: isSmallScreen ? 14 : 16,
                                      color: Colors.pink.shade600,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage({
    required dynamic imageData,
    required bool isDark,
    required bool isSmallScreen,
    required double borderRadius,
  }) {
    if (imageData == null || imageData.toString().isEmpty) {
      return _placeholderImage(isDark, isSmallScreen, borderRadius);
    }

    // تنظيف البيانات من الأحرف غير المرغوبة
    String cleanedImageData = imageData
        .toString()
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .replaceAll(' ', '')
        .trim();

    // محاولة التعرف على نوع الصورة
    bool isBase64 = false;
    bool isHttp = false;

    if (cleanedImageData.startsWith('iVBOR') ||
        cleanedImageData.startsWith('/9j') ||
        cleanedImageData.startsWith('R0lGOD') ||
        cleanedImageData.startsWith('SUkq') ||
        cleanedImageData.startsWith('UklGR')) {
      isBase64 = true;
    } else if (cleanedImageData.startsWith('http://') ||
        cleanedImageData.startsWith('https://')) {
      isHttp = true;
    }

    try {
      if (isBase64) {
        // إضافة padding إذا لزم الأمر
        if (cleanedImageData.length % 4 != 0) {
          cleanedImageData = cleanedImageData.padRight(
            cleanedImageData.length + (4 - cleanedImageData.length % 4),
            '=',
          );
        }

        // محاولة فك الترميز
        final bytes = base64Decode(cleanedImageData);

        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isSmallScreen ? 10 : 12),
            topRight: Radius.circular(isSmallScreen ? 10 : 12),
          ),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _placeholderImage(isDark, isSmallScreen, borderRadius);
            },
          ),
        );
      } else if (isHttp) {
        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isSmallScreen ? 10 : 12),
            topRight: Radius.circular(isSmallScreen ? 10 : 12),
          ),
          child: Image.network(
            cleanedImageData,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: isSmallScreen ? 90 : 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isSmallScreen ? 10 : 12),
                    topRight: Radius.circular(isSmallScreen ? 10 : 12),
                  ),
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: isDark ? Colors.tealAccent : Colors.blue,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _placeholderImage(isDark, isSmallScreen, borderRadius);
            },
          ),
        );
      } else {
        // إذا لم تكن صورة صالحة
        return _placeholderImage(isDark, isSmallScreen, borderRadius);
      }
    } catch (e) {
      return _placeholderImage(isDark, isSmallScreen, borderRadius);
    }
  }

  Widget _placeholderImage(
    bool isDark,
    bool isSmallScreen,
    double borderRadius,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isSmallScreen ? 10 : 12),
          topRight: Radius.circular(isSmallScreen ? 10 : 12),
        ),
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_size_select_actual_rounded,
              size: isSmallScreen ? 24 : 28,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              'صورة المنتج',
              style: TextStyle(
                fontSize: isSmallScreen ? 8 : 9,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(bool isDark, double screenWidth) {
    int crossAxisCount = screenWidth > 700 ? 3 : 2;

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 350 ? 8 : 12,
        vertical: screenWidth < 350 ? 8 : 12,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: screenWidth < 350 ? 8 : 12,
        crossAxisSpacing: screenWidth < 350 ? 8 : 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: screenWidth < 350 ? 90 : 100,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth < 350 ? 6 : 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: screenWidth < 350 ? 10 : 12,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: screenWidth < 350 ? 6 : 8),
                    Container(
                      width: screenWidth < 350 ? 50 : 60,
                      height: screenWidth < 350 ? 14 : 16,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: screenWidth < 350 ? 8 : 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: screenWidth < 350 ? 40 : 50,
                          height: screenWidth < 350 ? 18 : 22,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          width: screenWidth < 350 ? 26 : 28,
                          height: screenWidth < 350 ? 26 : 28,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required bool isDark,
    required bool isArabic,
    VoidCallback? onRefresh,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد منتجات حالياً',
                style: TextStyle(
                  fontSize: isArabic ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'قم بتصفح المتجر لاحقاً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isArabic ? 14 : 13,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              // زر التحديث في حالة عدم وجود منتجات
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: isDark ? Colors.tealAccent : Colors.white,
                ),
                label: Text(
                  'تحديث',
                  style: TextStyle(
                    fontSize: isArabic ? 14 : 13,
                    color: isDark ? Colors.tealAccent : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  backgroundColor: isDark
                      ? Colors.teal.withOpacity(0.2)
                      : Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
