import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CompanyDetailsPage extends StatefulWidget {
  final String companyId;
  final VoidCallback? onBack;
  const CompanyDetailsPage({Key? key, required this.companyId, this.onBack})
    : super(key: key);

  @override
  State<CompanyDetailsPage> createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage> {
  Map<String, dynamic>? company;
  List products = [];
  bool isLoadingCompany = true;
  bool isLoadingProducts = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    try {
      await Future.wait([_fetchCompanyDetails(), _fetchCompanyProducts()]);
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  Future<void> _fetchCompanyDetails() async {
    try {
      final url = Uri.parse(
        'https://mfkapi.runasp.net/api/company/${widget.companyId}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          company = data;
          isLoadingCompany = false;
        });
      } else {
        setState(() => isLoadingCompany = false);
      }
    } catch (e) {
      setState(() {
        isLoadingCompany = false;
        _hasError = true;
      });
    }
  }

  Future<void> _fetchCompanyProducts() async {
    try {
      final url = Uri.parse(
        'https://mfkapi.runasp.net/api/products/${widget.companyId}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data;
          isLoadingProducts = false;
        });
      } else {
        setState(() => isLoadingProducts = false);
      }
    } catch (e) {
      setState(() {
        isLoadingProducts = false;
        _hasError = true;
      });
    }
  }

  Widget _buildShimmerInfoCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
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

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.grey.shade800, Colors.grey.shade900]
                : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 17,
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageData, {double height = 140}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageData == null) {
      return _placeholderImage(height: height, isDark: isDark);
    }

    try {
      if (imageData.startsWith('/9j') || imageData.startsWith('iVBORw0K')) {
        final bytes = base64Decode(imageData);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
          ),
        );
      } else if (imageData.startsWith('http') ||
          imageData.startsWith('https')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageData,
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: height,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
            errorBuilder: (context, error, stackTrace) =>
                _placeholderImage(height: height, isDark: isDark),
          ),
        );
      } else {
        return _placeholderImage(height: height, isDark: isDark);
      }
    } catch (e) {
      return _placeholderImage(height: height, isDark: isDark);
    }
  }

  Widget _placeholderImage({required double height, required bool isDark}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey.shade800, Colors.grey.shade900]
              : [Colors.grey.shade100, Colors.grey.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = product['name']?.toString().trim() ?? 'منتج';
    final price = product['price']?.toString() ?? '';
    final imageData = product['path'];
    final isFeatured = product['isFeatured'] ?? false;

    return Container(
      margin: const EdgeInsets.all(2),
      child: Card(
        elevation: 6,
        shadowColor: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.shade300.withOpacity(0.5),
        color: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // يمكنك إضافة تفاصيل المنتج هنا
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // صورة المنتج
                Container(
                  height: 120,
                  child: Stack(
                    children: [
                      _buildImage(imageData, height: 120),
                      if (isFeatured)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'مميز',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // معلومات المنتج
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        if (price.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$price د.ع',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Icon(
                                  Icons.shopping_cart_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
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

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: isDark ? Colors.red.shade300 : Colors.red.shade600,
            ),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoadingCompany = true;
                  isLoadingProducts = true;
                  _hasError = false;
                });
                _fetchCompanyData();
              },
              icon: Icon(
                Icons.refresh_rounded,
                color: isDark ? Colors.tealAccent : Colors.white,
              ),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: isDark ? Colors.tealAccent : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                backgroundColor: isDark
                    ? Colors.teal.withOpacity(0.2)
                    : Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProducts() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 70,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات حالياً',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إضافة المنتجات قريباً',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    if (_hasError) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black,
              size: 22,
            ),
            onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
          ),
          title: const Text('تفاصيل الشركة'),
          centerTitle: true,
        ),
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
            size: 22,
          ),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
        title: Text(
          isLoadingCompany ? 'جاري التحميل...' : 'تفاصيل الشركة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.tealAccent : Colors.blue.shade600,
              size: 22,
            ),
            onPressed: isLoadingCompany || isLoadingProducts
                ? null
                : () {
                    setState(() {
                      isLoadingCompany = true;
                      isLoadingProducts = true;
                    });
                    _fetchCompanyData();
                  },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCompanyData,
        color: isDark ? Colors.tealAccent : Colors.blue,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة معلومات الشركة
              if (isLoadingCompany)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isDark ? Colors.grey.shade900 : Colors.blue.shade50,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 150,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                )
              else if (company != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.grey.shade900, Colors.grey.shade800]
                          : [Colors.blue.shade50, Colors.blue.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.blue.shade100,
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // شعار الشركة
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.tealAccent
                                : Colors.blue.shade400,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _buildImage(
                            company!['companyLogo'],
                            height: 100,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // اسم الشركة
                      Text(
                        company!['companyName'] ?? 'غير معروف',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.blue.shade900,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // وصف الشركة
                      Text(
                        company!['companyInfo'] ?? 'شركة رائدة في السوق المحلي',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.blue.shade700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      // زر التواصل
                      ElevatedButton.icon(
                        onPressed: () {
                          // إضافة منطق التواصل
                        },
                        icon: Icon(
                          Icons.message_rounded,
                          color: isDark ? Colors.tealAccent : Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          'تواصل مع الشركة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.tealAccent : Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.teal.withOpacity(0.2)
                              : Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.tealAccent.withOpacity(0.3)
                                  : Colors.blue.shade400,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // معلومات تفصيلية
              if (isLoadingCompany)
                Column(
                  children: List.generate(
                    4,
                    (index) => _buildShimmerInfoCard(),
                  ),
                )
              else if (company != null)
                Column(
                  children: [
                    _buildInfoCard(
                      '📞 رقم الهاتف',
                      company!['companyPhone'] ?? 'غير متوفر',
                      Icons.phone_rounded,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      '⚙️ الحالة',
                      company!['companyState'].toString() == '1'
                          ? 'نشطة'
                          : 'غير نشطة',
                      company!['companyState'].toString() == '1'
                          ? Icons.check_circle_rounded
                          : Icons.pause_circle_filled_rounded,
                      company!['companyState'].toString() == '1'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      '👁 عدد المشاهدات',
                      '${company!['companyViews'] ?? 0}',
                      Icons.visibility_rounded,
                      Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      '📅 تاريخ الإنشاء',
                      company!['companyCreateDate'] ?? 'غير معروف',
                      Icons.calendar_month_rounded,
                      Colors.blue,
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              // عنوان المنتجات
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'منتجات الشركة',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.blueGrey.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (products.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.teal.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.tealAccent.withOpacity(0.3)
                                : Colors.blue.shade300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${products.length} منتج',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.tealAccent
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // عرض المنتجات
              if (isLoadingProducts)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 1 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: isSmallScreen ? 1.5 : 0.8,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 80,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else if (products.isEmpty)
                _buildEmptyProducts()
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 1 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isSmallScreen ? 1.4 : 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(products[index]);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
