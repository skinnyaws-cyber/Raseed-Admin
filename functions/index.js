const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const TELEGRAM_TOKEN = "8522442058:AAGCBjr-hfwD6A79_VaTvBGpY2MW0S8Fr0E";

exports.onorderreadyforadmin = onDocumentUpdated("orders/{orderId}", async (event) => {
    const newData = event.data.after.data();
    const previousData = event.data.before.data();

    // التأكد من تحول الحالة إلى الانتظار
    if (newData.status === "waiting_admin_confirmation" && previousData.status !== "waiting_admin_confirmation") {
        try {
            // 1. جلب المدراء النشطين مرتبين بالأقدمية (من الأقدم للأحدث)
            const adminsSnapshot = await admin.firestore()
                .collection("admins")
                .where("isActive", "==", true)
                .orderBy("createdAt", "asc")
                .get();

            if (adminsSnapshot.empty) return null;

            const adminsList = adminsSnapshot.docs;
            let selectedAdminDoc;

            // 2. تحديد من عليه الدور عبر فحص آخر طلب تم تخصيص مديراً له
            const lastOrderSnapshot = await admin.firestore()
                .collection("orders")
                .where("assignedTo", "!=", null)
                .orderBy("assignedTo") // للفلترة
                .orderBy("createdAt", "desc") // تاريخ إنشاء الطلب وليس تسجيل المدير
                .limit(1)
                .get();

            if (lastOrderSnapshot.empty) {
                // إذا كان هذا أول طلب في النظام، نبدأ بأقدم مدير
                selectedAdminDoc = adminsList[0];
            } else {
                const lastAdminId = lastOrderSnapshot.docs[0].data().assignedTo;
                const lastAdminIndex = adminsList.findIndex(doc => doc.id === lastAdminId);
                
                // الانتقال للمدير التالي في القائمة، وإذا وصلنا للنهاية نعود للأول (التكرار المستمر)
                const nextIndex = (lastAdminIndex + 1) % adminsList.length;
                selectedAdminDoc = adminsList[nextIndex];
            }

            let targetAdminData = selectedAdminDoc.data();
            let finalAdminId = selectedAdminDoc.id;

            // 3. منطق التحويل (Forwarding) والحالة (Status)
            // إذا كان المدير المختار قد حوّل طلباته
            if (targetAdminData.forwardTo) {
                const forwardDoc = await admin.firestore().collection("admins").doc(targetAdminData.forwardTo).get();
                if (forwardDoc.exists && forwardDoc.data().status !== "away") {
                    targetAdminData = forwardDoc.data();
                    finalAdminId = forwardDoc.id;
                }
            }

            // 4. حجز الطلب للمدير الذي عليه الدور
            await admin.firestore().collection("orders").doc(event.params.orderId).update({
                assignedTo: finalAdminId
            });

            // 5. إرسال الإشعار
            const message = `
🔔 **طلب مخصص لك (نظام الدور)**
---------------------------
👤 **الاسم:** ${newData.userFullName || "غير متوفر"}
💰 **المبلغ:** ${newData.amount} د.ع
---------------------------
⏰ يرجى المعالجة فوراً.
            `;

            await axios.post(`https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage`, {
                chat_id: targetAdminData.telegramChatId,
                text: message,
                parse_mode: "Markdown"
            });

        } catch (error) {
            console.error("خطأ في نظام التوزيع:", error);
        }
    }
    return null;
});