import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:math';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية للتجربة (سنربطها بـ Firebase لاحقاً)
    final List<Map<String, dynamic>> dummyOrders = [
      {
        "name": "أحمد محمد",
        "phone": "07701234567",
        "amount": "25,000",
        "time": "0", // دقائق
        "isNew": true,
        "type": "Zain Cash"
      },
      {
        "name": "سارة علي",
        "phone": "07809876543",
        "amount": "10,000",
        "time": "5",
        "isNew": true,
        "type": "Asia Hawala"
      },
      {
        "name": "مصطفى كمال",
        "phone": "07505556666",
        "amount": "50,000",
        "time": "120",
        "isNew": false, // تم فتحه سابقاً
        "type": "MasterCard"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, // تأخذ خلفية Home
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "الطلبات الواردة",
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF2F3542),
          ),
        ),
        actions: [
          // زر تحديث سريع
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFF4757)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100), // مساحة سفلية للشريط العائم
        itemCount: dummyOrders.length,
        itemBuilder: (context, index) {
          final order = dummyOrders[index];
          return _buildOrderCard(order, context);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context) {
    // اختيار ميموجي عشوائي (أو بناءً على الرقم)
    // نفترض أن لديك صور assets/memoji/1.png ... assets/memoji/5.png
    final int memojiId = (order['phone'].hashCode % 5) + 1; 

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          // فتح التفاصيل (لاحقاً)
        },
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 100,
          borderRadius: 20,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // === 1. Memoji Sticker ===
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
                    ],
                  ),
                  child: ClipOval(
                    // استخدمنا Icon مؤقتاً إذا لم تضع الصور، استبدلها بـ Image.asset فور توفرها
                    // child: Image.asset('assets/memoji/$memojiId.png', fit: BoxFit.cover),
                    child: Center(child: Text("🤠", style: TextStyle(fontSize: 35))), 
                  ),
                ),
                
                const SizedBox(width: 16),

                // === 2. معلومات الطلب ===
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان
                      Text(
                        order['isNew'] ? "طلب جديد" : "تمت المشاهدة",
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 12,
                          color: order['isNew'] ? const Color(0xFFFF4757) : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // الاسم
                      Text(
                        order['name'],
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3542),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // المبلغ
                      Text(
                        "${order['amount']} د.ع",
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 14,
                          color: Color(0xFF2ED573), // أخضر للمال
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // === 3. الوقت والتنبيه ===
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // النقطة الحمراء (إذا جديد)
                    if (order['isNew'])
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4757),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4757).withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      )
                    else
                      const SizedBox(width: 12, height: 12), // للحفاظ على المحاذاة

                    // الوقت
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "منذ ${order['time']}د",
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
