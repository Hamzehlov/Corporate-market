import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/product_grid.dart';
import 'companies_page.dart';
import 'company_details_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? toggleTheme; // ✅ إضافة هذا السطر
  const HomePage({super.key, this.toggleTheme}); // تمرير الـ parameter

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildHeaderBanner() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blue.shade900, Colors.blue.shade700]
              : [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بك 👋',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اكتشف أفضل منتجات الشركات',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.shopping_cart_checkout,
            color: isDark ? Colors.white : Colors.white,
            size: 48,
          ),
        ],
      ),
    );
  }

  List products = [];
  List ads = []; // ✅ قائمة الإعلانات
  String? selectedCompanyId;
  bool isLoadingProducts = true;
  bool isLoadingAds = false; // ✅ حالة تحميل الإعلانات
  int _currentIndex = 0;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  // ✅ حالة الوضع الداكن المحلي للصفحة
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // ✅ دالة جلب المنتجات
  Future<void> fetchProducts() async {
    try {
      final url = Uri.parse('https://mfkapi.runasp.net/api/products');
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
      setState(() => isLoadingProducts = false);
    }
  }

  // ✅ دالة البحث
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      fetchProducts();
      return;
    }

    try {
      setState(() => isLoadingProducts = true);
      final url = Uri.parse(
        'https://mfkapi.runasp.net/api/products/search?query=$query',
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
      setState(() => isLoadingProducts = false);
    }
  }

  // ✅ دالة جلب الإعلانات
  Future<void> fetchAds() async {
    setState(() => isLoadingAds = true);
    try {
      final url = Uri.parse('https://mfkapi.runasp.net/api/ads');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ads = data;
          isLoadingAds = false;
        });
      } else {
        setState(() => isLoadingAds = false);
      }
    } catch (e) {
      setState(() => isLoadingAds = false);
    }
  }

  // ✅ واجهة الصفحة
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.grey.shade900
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade500,
                  ),
                ),
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onSubmitted: (value) {
                  searchProducts(value);
                },
              )
            : Text(
                'سوق الشركات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: isDarkMode ? Colors.white : Colors.grey.shade700,
            ),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  fetchProducts();
                }
                isSearching = !isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.brightness_6,
              color: isDarkMode ? Colors.white : Colors.grey.shade700,
            ),
            onPressed: widget.toggleTheme, // يستدعي دالة التبديل
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _getBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ✅ القائمة الجانبية
  Widget _buildDrawer() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.grey.shade800, Colors.grey.shade700]
                    : [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_rounded,
                      size: 40,
                      color: isDarkMode
                          ? Colors.grey.shade300
                          : Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'سوق الشركات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.home_rounded, 'الرئيسية', 0),
                _buildDrawerItem(
                  Icons.business_center_rounded,
                  'الشركات',
                  1,
                  navigateToCompanies: true,
                ),
                _buildDrawerItem(Icons.campaign_rounded, 'الإعلانات', 2),
                Divider(color: isDarkMode ? Colors.grey.shade700 : Colors.grey),
                _buildDrawerItem(Icons.settings_rounded, 'الإعدادات', -1),
                _buildDrawerItem(Icons.help_rounded, 'المساعدة', -1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ عنصر القائمة الجانبية
  Widget _buildDrawerItem(
    IconData icon,
    String title,
    int index, {
    bool navigateToCompanies = false,
  }) {
    final bool isSelected = _currentIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color iconColor;
    Color textColor;
    Color arrowColor;

    if (isSelected) {
      backgroundColor = isDarkMode ? Colors.grey.shade700 : Colors.blue.shade50;
      iconColor = isDarkMode ? Colors.white : Colors.blue.shade700;
      textColor = isDarkMode ? Colors.white : Colors.blue.shade700;
      arrowColor = isDarkMode ? Colors.white : Colors.blue.shade700;
    } else {
      backgroundColor = isDarkMode
          ? Colors.grey.shade800
          : Colors.grey.shade100;
      iconColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
      textColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
      arrowColor = iconColor;
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.arrow_forward_rounded, color: arrowColor)
          : null,
      onTap: () {
        Navigator.pop(context);
        if (navigateToCompanies) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CompaniesPage()),
          );
        } else if (index >= 0) {
          setState(() {
            _currentIndex = index;
            if (index == 3) fetchAds(); // ✅ عند فتح صفحة الإعلانات
          });
        }
      },
    );
  }

  // ✅ تحديد الصفحة الحالية
  Widget _getBody() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // إذا تم اختيار شركة، نعرض صفحة التفاصيل
    if (selectedCompanyId != null) {
      return CompanyDetailsPage(
        companyId: selectedCompanyId!,
        onBack: () {
          setState(() {
            selectedCompanyId = null; // الرجوع لقائمة الشركات
          });
        },
      );
    }

    switch (_currentIndex) {
      case 0: // الرئيسية
        return Column(
          children: [
            _buildHeaderBanner(),
            Expanded(
              child: Container(
                color: isDarkMode ? Colors.black : Colors.transparent,
                child: ProductGrid(
                  products: products,
                  isLoading: isLoadingProducts,
                  selectedCompanyId: selectedCompanyId,
                  onCompanySelected: (id) {
                    setState(() {
                      selectedCompanyId = id;
                    });
                  },
                ),
              ),
            ),
          ],
        );

      case 1: // الشركات
        return Container(
          color: isDarkMode ? Colors.black : Colors.transparent,
          child: CompaniesPage(
            onCompanySelected: (id) {
              setState(() {
                selectedCompanyId = id; // ⚡ عرض تفاصيل الشركة عند الاختيار
              });
            },
          ),
        );

      case 2: // الإعلانات
        return Container(
          color: isDarkMode ? Colors.black : Colors.transparent,
          child: _buildAdsPage(),
        );

      default:
        return const SizedBox();
    }
  }

  // ✅ صفحة المنتجات

  // ✅ صفحة الإعلانات (تعديل كامل)
  Widget _buildAdsPage() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.08);
    final titleColor = isDarkMode ? Colors.white : Colors.black;
    final descColor = isDarkMode ? Colors.white70 : Colors.grey.shade700;
    final iconColor = isDarkMode ? Colors.white70 : Colors.grey.shade500;

    if (isLoadingAds) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ads.isEmpty) {
      return Center(
        child: Text(
          'لا توجد إعلانات حالياً',
          style: TextStyle(color: titleColor),
        ),
      );
    }

    //نهاية صفحة الاعلانات

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        final String? path = ad['path'];
        Widget imageWidget;

        if (path != null && path.startsWith('iVBOR')) {
          try {
            final imageBytes = base64Decode(path);
            imageWidget = Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            );
          } catch (e) {
            imageWidget = _buildPlaceholderImage();
          }
        } else if (path != null &&
            (path.startsWith('http') || path.startsWith('https'))) {
          imageWidget = Image.network(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) =>
                _buildPlaceholderImage(),
          );
        } else {
          imageWidget = _buildPlaceholderImage();
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: cardColor,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: imageWidget,
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad['name'] ?? 'بدون اسم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ad['desc'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: descColor, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: iconColor),
                        const SizedBox(width: 6),
                        Text(
                          ad['createDate'] ?? '',
                          style: TextStyle(fontSize: 12, color: titleColor),
                        ),
                        const Spacer(),
                        Icon(Icons.timer, size: 14, color: iconColor),
                        const SizedBox(width: 6),
                        Text(
                          ad['expireDate'] ?? '',
                          style: TextStyle(fontSize: 12, color: titleColor),
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

  // ✅ صورة افتراضية في حال غياب الصورة
  Widget _buildPlaceholderImage() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final iconColor = isDarkMode ? Colors.white54 : Colors.grey;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Icon(Icons.image_not_supported, size: 60, color: iconColor),
      ),
    );
  }

  // ✅ شريط التنقل السفلي
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;

          if (index == 2) {
            // الآن الإعلانات هي الحالة رقم 2
            fetchAds();
          }
        });
      },
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(
        context,
      ).colorScheme.onSurface.withOpacity(0.6),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business_center_rounded),
          label: 'الشركات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign_rounded),
          label: 'الإعلانات',
        ),
      ],
    );
  }
}
