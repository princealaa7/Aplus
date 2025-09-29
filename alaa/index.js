// استيراد مكتبات Firebase اللازمة
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// تهيئة Admin SDK
admin.initializeApp();

// أنشئ وظيفة يمكن الوصول إليها عبر رابط HTTP
exports.getUserData = functions.https.onRequest(async (req, res) => {
    // هذا الشرط يمنع أي شخص من تشغيل الوظيفة إلا إذا كان لديه المفتاح السري الصحيح
    // قم بتغيير "YOUR_SECRET_KEY" إلى كلمة سر قوية من اختيارك
    if (req.query.key !== "rewqrewqre") {
        return res.status(403).send("Unauthorized");
    }

    try {
        // الوصول إلى عقدة 'users' في قاعدة البيانات
        const usersRef = admin.database().ref('users');
        const snapshot = await usersRef.once('value');
        const usersData = snapshot.val();
        
        const usersList = {};

        // التحقق من وجود بيانات
        if (!usersData) {
            return res.status(200).send("No users found.");
        }

        // تكرار على كل مستخدم واستخراج اسمه ورقم هاتفه
        for (const uid in usersData) {
            // هذا الشرط يحل مشكلة الـ for-in loop
            if (Object.prototype.hasOwnProperty.call(usersData, uid)) {
                const userData = usersData[uid];
                // تأكد من وجود حقل 'name' و 'phone'
                if (userData.name && userData.phone) {
                    usersList[uid] = {
                        name: userData.name,
                        phone: userData.phone,
                    };
                }
            }
        }
        
        // إرسال قائمة ببيانات المستخدمين كاستجابة
        res.status(200).json(usersList);
    } catch (error) {
        console.error("Error fetching user data:", error);
        res.status(500).send("Internal Server Error");
    }
});