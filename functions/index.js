const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const axios = require("axios");

// تهيئة Firebase Admin
admin.initializeApp();

// معلومات البوت الخاص بك
const TELEGRAM_TOKEN = "8522442058:AAGCBjr-hfwD6A79_VaTvBGpY2MW0S8Fr0E";

// الدالة السحابية لمراقبة تحديثات الطلبات
exports.onorderreadyforadmin = onDocumentUpdated("orders/{orderId}", async (event) => {
    const newData = event.data.after.data();
    const previousData = event.data.before.data();

    // 1. التأكد أن الحالة تغيرت الآن إلى الانتظار لموافقة المدير
    if (newData.status === "waiting_admin_confirmation" && previousData.status !== "waiting_admin_confirmation") {
        
        try {
            // 2. البحث عن المدراء المتاحين في مجموعة admins
            const adminsSnapshot = await admin.firestore()
                .collection("admins")
                .where("isActive", "==", true)
                .get();

            if (adminsSnapshot.empty) {
                console.log("لا يوجد مدراء متاحون حالياً.");
                return null;
            }

            // 3. اختيار مدير عشوائي لتوزيع المهام
            const adminsList = adminsSnapshot.docs;
            const randomIndex = Math.floor(Math.random() * adminsList.length);
            const selectedAdmin = adminsList[randomIndex].data();
            const adminDocId = adminsList[randomIndex].id;

            // 4. حجز الطلب للمدير المختار لمنع التكرار
            await admin.firestore().collection("orders").doc(event.params.orderId).update({
                assignedTo: adminDocId
            });

            // 5. تجهيز نص الرسالة الاحترافي
            const message = `
🔔 **طلب تحويل جديد بانتظار موافقتك**
---------------------------
👤 **الاسم:** ${newData.userFullName || "غير متوفر"}
📱 **الهاتف:** ${newData.userPhone || "غير متوفر"}
💰 **المبلغ:** ${newData.amount} د.ع
💳 **بطاقة الاستلام:** ${newData.receivingCard}
⏰ **الوقت:** ${new Date().toLocaleString('ar-EG')}
---------------------------
⚠️ يرجى الدخول للتطبيق لتأكيد التحويل المالي.
            `;

            // 6. إرسال الرسالة عبر تليجرام باستخدام Chat ID المخزن للمدير
            await axios.post(`https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage`, {
                chat_id: selectedAdmin.telegramChatId,
                text: message,
                parse_mode: "Markdown"
            });

            console.log(`تم توزيع الطلب بنجاح للمدير: ${selectedAdmin.adminName}`);

        } catch (error) {
            console.error("خطأ أثناء معالجة الطلب:", error);
        }
    }
    return null;
});