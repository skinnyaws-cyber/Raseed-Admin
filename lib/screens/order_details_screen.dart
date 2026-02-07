import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/services.dart';

class OrderDetailsScreen extends StatefulWidget {
  final QueryDocumentSnapshot order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = false;
  final Color _primaryColor = const Color(0xFFFF4757);
  final Color _textColor = const Color(0xFF2F3542);

  Future<void> _confirmOrder() async {
    if (widget.order['status'] == 'successful') return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الطلب", style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold)),
        content: const Text("هل أنت متأكد من إتمام هذا الطلب؟ سيتم تحويل الحالة إلى ناجح.", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text("تأكيد", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({
        'status': 'successful',
        'completed_at': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إكمال الطلب بنجاح ✅", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ: $e", style: const TextStyle(fontFamily: 'IBMPlexSansArabic')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("تم نسخ رقم البطاقة ✅", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
        backgroundColor: _textColor.withOpacity(0.8),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.order.data() as Map<String, dynamic>;
    final bool isPending = data['status'] == 'pending' || data['status'] == 'waiting_admin_confirmation';
    final String orderIdShort = widget.order.id.substring(0, 8).toUpperCase();

    // حساب المبلغ المطلوب إرساله من قبل المدير (المبلغ الكلي - العمولة)
    final double amount = (data['amount'] ?? 0).toDouble();
    final double commission = (data['commission'] ?? 0).toDouble();
    final double finalAmountToSend = amount - commission;

    String formattedDate = "غير متوفر";
    if (data['createdAt'] != null) {
      Timestamp timestamp = data['createdAt'];
      formattedDate = intl.DateFormat('yyyy/MM/dd - hh:mm a', 'en').format(timestamp.toDate());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text("تفاصيل الطلب #$orderIdShort", style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic', fontSize: 18)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isPending ? Icons.hourglass_top_rounded : Icons.check_circle_rounded, color: isPending ? Colors.orange : Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isPending ? "قيد الانتظار والمعالجة" : "مكتمل بنجاح",
                    style: TextStyle(
                      color: isPending ? Colors.orange[800] : Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildModernInfoRow(Icons.person_outline_rounded, "الاسم الكامل", data['userFullName'] ?? "غير معروف"),
                          const Divider(height: 30),
                          // تحديث المنطق الحسابي للمبلغ المطلوب إرساله 
                          _buildModernInfoRow(Icons.account_balance_rounded, "المبلغ المطلوب إرساله", "${intl.NumberFormat('#,###').format(finalAmountToSend)} د.ع", isImportant: true),
                          const Divider(height: 30),
                          _buildModernInfoRow(Icons.credit_card_rounded, "بطاقة الاستلام", data['receivingCard'] ?? "---", isCopyable: true),
                          const Divider(height: 30),
                          // استخدام المعرفات الصحيحة من قاعدة البيانات 
                          _buildModernInfoRow(Icons.compare_arrows_rounded, "طريقة التحويل", data['transferType'] ?? "---"),
                          const Divider(height: 30),
                          _buildModernInfoRow(Icons.phone_iphone_rounded, "رقم الهاتف", data['userPhone'] ?? "---"),
                          const Divider(height: 30),
                          _buildModernInfoRow(Icons.calendar_today_rounded, "وقت الإنشاء", formattedDate),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            if (isPending)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("تأكيد الطلب", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'IBMPlexSansArabic')),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value, {bool isImportant = false, bool isCopyable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isImportant ? _primaryColor.withOpacity(0.1) : const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isImportant ? _primaryColor : Colors.grey[600], size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600], fontFamily: 'IBMPlexSansArabic'),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isImportant ? _primaryColor : _textColor,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                      softWrap: true,
                    ),
                  ),
                  if (isCopyable)
                    IconButton(
                      onPressed: () => _copyToClipboard(value),
                      icon: Icon(Icons.copy_rounded, color: _primaryColor, size: 20),
                      tooltip: "نسخ القيمة",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}