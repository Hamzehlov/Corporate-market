import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompaniesPage extends StatefulWidget {
  final ValueChanged<String>? onCompanySelected;
  const CompaniesPage({Key? key, this.onCompanySelected}) : super(key: key);

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  List companies = [];
  bool isLoadingCompanies = true;
  bool _hasError = false;
  final _scrollController = ScrollController();
  final _shimmerGradient = const LinearGradient(
    colors: [Color(0xFFEBEBF4), Color(0xFFF4F4F4), Color(0xFFEBEBF4)],
    stops: [0.1, 0.3, 0.4],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  @override
  void initState() {
    super.initState();
    fetchCompanies();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // يمكن إضافة تحميل للمزيد من البيانات هنا (Infinite Scroll)
    }
  }

  Future<void> fetchCompanies() async {
    setState(() {
      _hasError = false;
    });
    try {
      final url = Uri.parse('https://mfkapi.runasp.net/api/company');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          companies = data;
          isLoadingCompanies = false;
        });
      } else {
        setState(() {
          isLoadingCompanies = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingCompanies = false;
        _hasError = true;
      });
    }
  }

  ImageProvider? _decodeImage(String? base64String) {
    try {
      if (base64String == null || base64String.isEmpty) return null;
      final cleaned = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      final bytes = base64Decode(cleaned);
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }

  // 1. تأثير Shimmer مبنى يدوياً
  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // شيمر للصورة الدائرية
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _shimmerGradient,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // شيمر لعنوان الشركة
                      Container(
                        width: double.infinity,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: _shimmerGradient,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // شيمر للوصف
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: _shimmerGradient,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: _shimmerGradient,
                        ),
                      ),
                      const Spacer(),
                      // شيمر لمعلومات الاتصال
                      Container(
                        width: 150,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: _shimmerGradient,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 2. تصميم بطاقة الشركة المُحسّن
  Widget _buildCompanyCard(Map company, bool isDarkMode) {
    final coverImage = _decodeImage(company['companyCover']);
    final logoImage = _decodeImage(company['companyLogo']);
    final isActive = company['isActive'] == true;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 4,
        shadowColor: isDarkMode
            ? Colors.teal.withOpacity(0.3)
            : Colors.blue.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () {
            widget.onCompanySelected?.call(company['id'].toString());
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isDarkMode
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey.shade900, Colors.grey.shade800],
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // رأس البطاقة مع الصورة
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                  ),
                  child: Stack(
                    children: [
                      if (coverImage != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: FadeInImage(
                            image: coverImage,
                            placeholder: AssetImage(
                              isDarkMode
                                  ? 'assets/placeholder_dark.png'
                                  : 'assets/placeholder_light.png',
                            ),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 120,
                          ),
                        ),
                      // شارة الحالة
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(20),
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
                                isActive ? Icons.check_circle : Icons.cancel,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isActive ? 'نشطة' : 'غير نشطة',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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
                // محتوى البطاقة
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الشعار
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode ? Colors.tealAccent : Colors.blue,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 34,
                          backgroundColor: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.white,
                          backgroundImage: logoImage,
                          child: logoImage == null
                              ? Icon(
                                  Icons.business,
                                  size: 30,
                                  color: isDarkMode
                                      ? Colors.tealAccent
                                      : Colors.blue,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // معلومات الشركة
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // اسم الشركة
                            Text(
                              company['companyName'] ?? 'اسم الشركة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // وصف الشركة
                            Text(
                              company['companyInfo'] ?? 'لا يوجد وصف',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryColor,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            // معلومات الاتصال
                            _buildContactInfo(
                              Icons.phone,
                              company['companyPhone'] ?? 'غير متوفر',
                              isDarkMode,
                            ),
                            const SizedBox(height: 6),
                            _buildContactInfo(
                              Icons.email,
                              company['email'] ?? 'غير متوفر',
                              isDarkMode,
                            ),
                            const SizedBox(height: 6),
                            _buildContactInfo(
                              Icons.calendar_today,
                              company['companyCreateDate'] ?? 'غير متوفر',
                              isDarkMode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // زر الإجراء
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onCompanySelected?.call(company['id'].toString());
                    },
                    icon: Icon(
                      Icons.visibility,
                      color: isDarkMode ? Colors.tealAccent : Colors.white,
                    ),
                    label: Text(
                      'عرض منتجات الشركة',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.tealAccent : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.teal.withOpacity(0.2)
                          : Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDarkMode
                              ? Colors.tealAccent.withOpacity(0.3)
                              : Colors.blue.shade400,
                          width: 1,
                        ),
                      ),
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

  Widget _buildContactInfo(IconData icon, String text, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.tealAccent : Colors.blue.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 3. واجهة حالة الخطأ
  Widget _buildErrorState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDarkMode ? Colors.red.shade300 : Colors.red.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'فشل في تحميل البيانات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: fetchCompanies,
            icon: Icon(
              Icons.refresh,
              color: isDarkMode ? Colors.tealAccent : Colors.white,
            ),
            label: Text(
              'إعادة المحاولة',
              style: TextStyle(
                color: isDarkMode ? Colors.tealAccent : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode
                  ? Colors.teal.withOpacity(0.2)
                  : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'الشركات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDarkMode ? Colors.tealAccent : Colors.white,
            ),
            onPressed: isLoadingCompanies ? null : fetchCompanies,
          ),
        ],
      ),
      // 4. إضافة خاصية السحب للتحديث
      body: RefreshIndicator(
        onRefresh: fetchCompanies,
        color: isDarkMode ? Colors.tealAccent : Colors.blue,
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        child: _buildContent(isDarkMode),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (isLoadingCompanies) {
      // عرض تأثير الشيمر أثناء التحميل
      return ListView.builder(
        controller: _scrollController,
        itemCount: 6,
        itemBuilder: (context, index) => _buildShimmerItem(),
      );
    }

    if (_hasError) {
      return _buildErrorState(isDarkMode);
    }

    if (companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 64,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد شركات حالياً',
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    // العرض الرئيسي للبيانات
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: companies.length,
      itemBuilder: (context, index) {
        return _buildCompanyCard(companies[index], isDarkMode);
      },
    );
  }
}
