const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const TELEGRAM_TOKEN = "8522442058:AAGCBjr-hfwD6A79_VaTvBGpY2MW0S8Fr0E";

exports.onorderreadyforadmin = onDocumentUpdated("orders/{orderId}", async (event) => {
    const newData = event.data.after.data();
    const previousData = event.data.before.data();

    // التحقق من حالة الانتظار [cite: 216]
    if (newData.status === "waiting_admin_confirmation" && previousData.status !== "waiting_admin_confirmation") {
        try {
            // 1. جلب المدراء النشطين [cite: 217]
            const adminsSnapshot = await admin.firestore()
                .collection("admins")
                .where("isActive", "==", true)
                .orderBy("createdAt", "asc")
                .get();

            if (adminsSnapshot.empty) return null;

            const adminsList = adminsSnapshot.docs;
            let selectedAdminDoc;

            // 2. نظام التوزيع العادل (Round Robin) [cite: 218-223]
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
                const nextIndex = (lastAdminIndex + 1) % adminsList.length;
                selectedAdminDoc = adminsList[nextIndex];
            }

            let targetAdminData = selectedAdminDoc.data();
            let finalAdminId = selectedAdminDoc.id;

            // 3. منطق التحويل [cite: 224-226]
            if (targetAdminData.forwardTo) {
                const forwardDoc = await admin.firestore().collection("admins").doc(targetAdminData.forwardTo).get();
                if (forwardDoc.exists && forwardDoc.data().status !== "away") {
                    targetAdminData = forwardDoc.data();
                    finalAdminId = forwardDoc.id;
                }
            }

            // 4. تخصيص الطلب في قاعدة البيانات [cite: 226]
            await admin.firestore().collection("orders").doc(event.params.orderId).update({
                assignedTo: finalAdminId
            });

            const title = "🔔 طلب جديد مخصص لك";
            const body = `👤 العميل: ${newData.userFullName || "غير متوفر"}\n💰 المبلغ: ${newData.amount} د.ع`;

            // 5. إرسال إشعار التليجرام 
            if (targetAdminData.telegramChatId) {
                await axios.post(`https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage`, {
                    chat_id: targetAdminData.telegramChatId,
                    text: `*${title}*\n\n${body}`,
                    parse_mode: "Markdown"
                }).catch(e => console.error("خطأ تليجرام:", e.message));
            }

            // 6. الإضافة الجديدة: إرسال إشعار دفع للتطبيق (FCM)
            // هذا الجزء يضمن ظهور الإشعار داخل هاتفك
            const fcmToken = targetAdminData.fcmToken; // تأكد من تخزين هذا الحقل عند تسجيل الدخول
            if (fcmToken) {
                const message = {
                    notification: { title: title, body: body },
                    token: fcmToken,
                };
                await admin.messaging().send(message).catch(e => console.error("خطأ FCM:", e.message));
            }

        } catch (error) {
            console.error("خطأ في نظام التوزيع:", error);
        }
    }
    return null;
});