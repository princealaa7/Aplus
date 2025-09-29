const admin = require("firebase-admin");
admin.initializeApp();

const {onSchedule} = require("firebase-functions/v2/scheduler");

exports.sendInactivityNotification = onSchedule("0 0 * * *", async () => {
  const now = Date.now();
  const twentyFourHoursAgo = now - (24 * 60 * 60 * 1000);

  const usersRef = admin.database().ref("users");
  const snapshot = await usersRef
      .orderByChild("last_open_timestamp")
      .endAt(twentyFourHoursAgo)
      .once("value");

  const users = snapshot.val();
  if (!users) {
    console.log("No users found to send a notification to.");
    return null;
  }

  const tokens = [];
  for (const userId in users) {
    if (Object.prototype.hasOwnProperty.call(users, userId)) {
      const user = users[userId];
      if (user.fcmToken) {
        tokens.push(user.fcmToken);
      }
    }
  }

  const payload = {
    notification: {
      title: "هل اشتقت لتعلم الإنجليزية؟",
      body: "عد لتستكمل رحلتك التعليمية مع مساعدك الآلي الذكي! 📚🤖",
    },
  };

  return admin.messaging().sendToDevice(tokens, payload);
});
