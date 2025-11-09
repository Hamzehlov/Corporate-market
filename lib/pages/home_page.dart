import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/product_grid.dart';
import 'companies_page.dart';
import 'company_details_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List products = [];
  List ads = []; // ✅ قائمة الإعلانات
  String? selectedCompanyId;
  bool isLoadingProducts = true;
  bool isLoadingAds = false; // ✅ حالة تحميل الإعلانات
  int _currentIndex = 0;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                ),
                style: const TextStyle(fontSize: 18),
                onSubmitted: (value) {
                  searchProducts(value);
                },
              )
            : const Text(
                'سوق الشركات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: Colors.grey.shade700,
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
        ],
      ),
      drawer: _buildDrawer(),
      body: _getBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ✅ القائمة الجانبية
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
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
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
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
                _buildDrawerItem(Icons.shopping_bag_rounded, 'المنتجات', 1),
                _buildDrawerItem(
                  Icons.business_center_rounded,
                  'الشركات',
                  2,
                  navigateToCompanies: true,
                ),
                _buildDrawerItem(Icons.campaign_rounded, 'الإعلانات', 3),
                const Divider(),
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
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.arrow_forward_rounded, color: Colors.blue.shade700)
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
    switch (_currentIndex) {
      case 0:
        return ProductGrid(
          products: products,
          isLoading: isLoadingProducts,
          selectedCompanyId: selectedCompanyId,
          onCompanySelected: (id) {
            setState(() {
              selectedCompanyId = id;
            });
          },
        );
      case 1:
        return _buildProductsPage();
      case 3:
        return _buildAdsPage();
      default:
        return const SizedBox();
    }
  }

  // ✅ صفحة المنتجات
  Widget _buildProductsPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text('صفحة المنتجات'),
          SizedBox(height: 10),
          Text('سيتم إضافة المحتوى قريباً'),
        ],
      ),
    );
  }

  // ✅ صفحة الإعلانات (تعديل كامل)
  Widget _buildAdsPage() {
    if (isLoadingAds) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ads.isEmpty) {
      return const Center(child: Text('لا توجد إعلانات حالياً'));
    }

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

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageWidget,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad['name'] ?? 'بدون اسم',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ad['desc'] ?? '',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'من: ${ad['createDate'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'إلى: ${ad['expireDate'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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

  // ✅ صورة افتراضية في حال غياب الصورة
  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
    );
  }

  // ✅ شريط التنقل السفلي
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CompaniesPage()),
          );
        } else {
          setState(() {
            _currentIndex = index;
            if (index == 3) fetchAds(); // ✅ عند فتح تبويب الإعلانات
          });
        }
      },
      selectedItemColor: Colors.blue.shade700,
      unselectedItemColor: Colors.grey.shade500,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_rounded),
          label: 'المنتجات',
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
