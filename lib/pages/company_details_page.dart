import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CompanyDetailsPage extends StatefulWidget {
  final String companyId;
  const CompanyDetailsPage({Key? key, required this.companyId})
    : super(key: key);

  @override
  State<CompanyDetailsPage> createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage> {
  Map<String, dynamic>? company;
  List products = [];
  bool isLoadingCompany = true;
  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    fetchCompanyDetails();
    fetchCompanyProducts();
  }

  Future<void> fetchCompanyDetails() async {
    try {
      final url = Uri.parse(
        'https://mfkapi.runasp.net/api/company/${widget.companyId}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          company = {
            "companyName": data['companyName'],
            "companyPhone": data['companyPhone'],
            "companyInfo": data['companyInfo'],
            "companyCreateDate": data['companyCreateDate'],
            "companyViews": data['companyViews'],
            "companyState": data['companyState'],
            "companyCover": data['companyCover'],
            "companyLogo": data['companyLogo'],
          };
          isLoadingCompany = false;
        });
      } else {
        setState(() => isLoadingCompany = false);
      }
    } catch (e) {
      setState(() => isLoadingCompany = false);
    }
  }

  Future<void> fetchCompanyProducts() async {
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
      setState(() => isLoadingProducts = false);
    }
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
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
    if (imageData == null) return _placeholderImage(height: height);

    try {
      if (imageData.startsWith('/9j') || imageData.startsWith('iVBORw0K')) {
        final bytes = base64Decode(imageData);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: height,
        );
      } else if (imageData.startsWith('http') ||
          imageData.startsWith('https')) {
        return Image.network(
          imageData,
          fit: BoxFit.cover,
          width: double.infinity,
          height: height,
          errorBuilder: (context, error, stackTrace) =>
              _placeholderImage(height: height),
        );
      } else {
        return _placeholderImage(height: height);
      }
    } catch (e) {
      return _placeholderImage(height: height);
    }
  }

  Widget _placeholderImage({double height = 140}) {
    return Container(
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'تفاصيل الشركة',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.blue.shade100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // معلومات الشركة
            if (isLoadingCompany)
              const Center(child: CircularProgressIndicator())
            else if (company == null)
              const Center(
                child: Text(
                  'لم يتم العثور على بيانات الشركة',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              )
            else ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ClipOval(
                      child: _buildImage(company!['companyLogo'], height: 100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      company!['companyName'] ?? 'غير معروف',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'شركة رائدة في السوق المحلي',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue.shade700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // هنا ممكن تضيف كود فتح رسالة أو رقم الهاتف
                        // أو رابط تواصل
                      },
                      icon: const Icon(Icons.message_rounded),
                      label: const Text(
                        'تواصل مع الشركة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                '📞 رقم الهاتف',
                company!['companyPhone'] ?? 'غير متوفر',
                Icons.phone,
                Colors.green,
              ),
              _buildInfoCard(
                '⚙️ الحالة',
                company!['companyState'].toString() == '1'
                    ? 'نشطة'
                    : 'غير نشطة',
                company!['companyState'].toString() == '1'
                    ? Icons.check_circle
                    : Icons.pause_circle_filled,
                company!['companyState'].toString() == '1'
                    ? Colors.green
                    : Colors.orange,
              ),
              _buildInfoCard(
                '👁 عدد المشاهدات',
                '${company!['companyViews'] ?? 0}',
                Icons.visibility,
                Colors.purple,
              ),
              _buildInfoCard(
                '📅 تاريخ الإنشاء',
                company!['companyCreateDate'] ?? 'غير معروف',
                Icons.calendar_today,
                Colors.blue,
              ),
            ],

            const SizedBox(height: 24),

            // منتجات الشركة
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'منتجات الشركة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (isLoadingProducts)
              const Center(child: CircularProgressIndicator())
            else if (products.isEmpty)
              const Center(
                child: Text(
                  'لا توجد منتجات لهذه الشركة',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: _buildImage(
                              product['path'],
                              height: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(
                                product['name'] ?? 'اسم المنتج',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (product['price'] != null)
                                Text(
                                  '${product['price']} د.ع',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
