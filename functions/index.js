const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const TELEGRAM_TOKEN = "8522442058:AAGCBjr-hfwD6A79_VaTvBGpY2MW0S8Fr0E";

exports.onorderreadyforadmin = onDocumentUpdated("orders/{orderId}", async (event) => {
    const newData = event.data.after.data();
    const previousData = event.data.before.data();

    // التأكد من تحول الحالة إلى انتظار موافقة المدير [cite: 51]
    if (newData.status === "waiting_admin_confirmation" && previousData.status !== "waiting_admin_confirmation") {
        try {
            // 1. جلب المدراء النشطين مرتبين بالأقدمية 
            const adminsSnapshot = await admin.firestore()
                .collection("admins")
                .where("isActive", "==", true)
                .orderBy("createdAt", "asc")
                .get();

            if (adminsSnapshot.empty) return null;

            const adminsList = adminsSnapshot.docs;
            let selectedAdminDoc;

            // 2. تحديد من عليه الدور (نظام التوزيع العادل) 
            const lastOrderSnapshot = await admin.firestore()
                .collection("orders")
                .where("assignedTo", "!=", null)
                .orderBy("assignedTo")
                .orderBy("createdAt", "desc")
                .limit(1)
                .get();

            if (lastOrderSnapshot.empty) {
                selectedAdminDoc = adminsList[0];
            } else {
                const lastAdminId = lastOrderSnapshot.docs[0].data().assignedTo;
                const lastAdminIndex = adminsList.findIndex(doc => doc.id === lastAdminId);
                const nextIndex = (lastAdminIndex === -1) ? 0 : (lastAdminIndex + 1) % adminsList.length;
                selectedAdminDoc = adminsList[nextIndex];
            }

            let targetAdminData = selectedAdminDoc.data();
            let finalAdminId = selectedAdminDoc.id;

            // 3. منطق التحويل والحالة 
            if (targetAdminData.forwardTo) {
                const forwardDoc = await admin.firestore().collection("admins").doc(targetAdminData.forwardTo).get();
                if (forwardDoc.exists && forwardDoc.data().status !== "away") {
                    targetAdminData = forwardDoc.data();
                    finalAdminId = forwardDoc.id;
                }
            }

            // 4. حجز الطلب للمدير المختار في Firestore
            await admin.firestore().collection("orders").doc(event.params.orderId).update({
                assignedTo: finalAdminId
            });

            // 5. تنسيق الوقت لرسالة تليجرام
            const date = newData.createdAt ? newData.createdAt.toDate() : new Date();
            const timeStr = date.toLocaleString('ar-EG', { hour12: true });

            // 6. إرسال الإشعار بكافة التفاصيل 
            if (targetAdminData.telegramChatId) {
                const message = `
🔔 **طلب تحويل جديد بانتظار موافقتك**
---------------------------
👤 **الاسم:** ${newData.userFullName || "غير متوفر"}
📱 **الهاتف:** ${newData.userPhone|| "غير متوفر"}
💰 **المبلغ:** ${newData.amount || 0} د.ع
💳 **بطاقة الاستلام:** ${newData.receivingCard}
💵 **العمولة :** ${newData.commission}
⏰ **الوقت:** ${timeStr}
---------------------------
⚠️ يرجى الدخول للتطبيق لتأكيد التحويل المالي.
                `;

                await axios.post(`https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage`, {
                    chat_id: targetAdminData.telegramChatId,
                    text: message,
                    parse_mode: "Markdown"
                });
            }

        } catch (error) {
            console.error("خطأ في نظام التوزيع:", error.message);
        }
    }
    return null;
});