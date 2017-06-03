const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.sendPushNotification = functions.database.ref('/messages/{id}').onWrite(event => {
    const payload = {
      notification: {
          title: 'New message arrived',
          body: 'come check it',
          badge: '1',
          sound: 'default',
      }
    };
    return admin.database().ref('fcmToken').once('value').then(allToken => {
        if (allToken.val()) {
            const token = Object.keys(allToken.val());
            return admin.messaging().sendToDevice(token, payload).then(response => {

            });
        };
    });
});