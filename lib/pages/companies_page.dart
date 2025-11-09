import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'company_details_page.dart';

class CompaniesPage extends StatefulWidget {
  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  List companies = [];
  bool isLoadingCompanies = true;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
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
        setState(() => isLoadingCompanies = false);
      }
    } catch (e) {
      setState(() => isLoadingCompanies = false);
    }
  }

  /// دالة تساعد على تحويل الـ Base64 إلى صورة
  ImageProvider? _decodeImage(String? base64String) {
    try {
      if (base64String == null || base64String.isEmpty) return null;

      // إزالة أي بادئة مثل "data:image/png;base64,"
      final cleaned = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;

      final bytes = base64Decode(cleaned);
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشركات'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: isLoadingCompanies
          ? const Center(child: CircularProgressIndicator())
          : companies.isEmpty
          ? const Center(child: Text('لا توجد شركات لعرضها'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];

                final coverImage = _decodeImage(company['companyCover']);
                final logoImage = _decodeImage(company['companyLogo']);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CompanyDetailsPage(companyId: company['id']),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // صورة الغلاف
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: coverImage != null
                              ? Image(
                                  image: coverImage,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 150,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                        ),

                        // تفاصيل الشركة
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue.shade100,
                                backgroundImage: logoImage,
                                child: logoImage == null
                                    ? Icon(
                                        Icons.business,
                                        color: Colors.blue.shade700,
                                        size: 30,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      company['companyName'] ?? 'اسم الشركة',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      company['companyInfo'] ?? 'لا يوجد وصف',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '📞 الهاتف: ${company['companyPhone'] ?? 'غير متوفر'}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '📧 البريد الإلكتروني: ${company['email'] ?? 'غير متوفر'}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '📅 تاريخ الإنشاء: ${company['companyCreateDate'] ?? 'غير متوفر'}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '🔹 الحالة: ${company['isActive'] == true ? 'نشطة' : 'غير نشطة'}',
                                      style: TextStyle(
                                        color: company['isActive'] == true
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
