import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// import { user } from 'firebase-functions/lib/providers/auth';


admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

 // Start writing Firebase Functions
 // https://firebase.google.com/docs/functions/typescript

export const helloWorld = functions.https.onRequest((request, response) => {
 console.log('Hello!')
 response.send("Hello from Firebase!");
});

export const sendToDevice = functions.firestore.document('test/{testId}').onCreate(async snapshot => {

    // const test = snapshot.data();
    // const querySnapshot = await db.collection('users').doc(test.id).get();
    // const tokens = querySnapshot.data['fcmTokens'];

    const fcmToken = 'fR7jC-UMKk6kpaxXEgDGp8:APA91bGnOih8eHcnYciNIsFJYYmlJUM3Pk6i7ymvOsx6VHa_0tGyMKuOlIHCgEP75ONKCYza_-KHBMzHiHE9j3VR7P93CGeMiagERI4pWpUDzVC4arsgwlQWlP-hVCwdDllN-9o071zj';

    const payload : admin.messaging.MessagingPayload = {

        notification : {
            title : 'Test1',
            body : 'Test body is here',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        },
    };

    


    return fcm.sendToDevice(fcmToken,payload).then((response) => {
        console.log('Successfully sent message:', response);
    })
    .catch((error) => {
      console.log('Error sending message:', error);
    });
    
});


export const sendPrivateMessageNotification = functions.firestore.document('chats/{chatId}/messages/{messageId}')
    .onCreate( async (snapshot, context) => {
        // We need to establish: - who is the sender (and their name), who it's going to, what the message said

        console.log(snapshot.data())

        const message = snapshot.data();

        const chat = await db.collection('chats').doc(context.params.chatId).get();
        const chatData = chat.data();

        var tokens;
        var senderName;

        if (chatData) {

            const pid = chatData['pid'];
            
            // If sender is the provider retrieve the chat user and their token
            if(pid == message.sender) {

                const user = await db.collection('users').doc(chatData['uid']).get();
                const userData = user.data();

                if(userData) {
                    senderName = userData['name'];
                    tokens = userData['fcmTokens'];
                }

            } else {
                //Otherwise the user sent the message so we need to find the tokens of the providers uid

                const provider = await db.collection('providers').doc(pid).get();
                const providerData = provider.data();

                if(providerData) {
                    const uid = providerData['uid'];

                    const user = await db.collection('users').doc(uid).get();
                    const userData = user.data();

                    if(userData) {
                        senderName = userData['name'];
                        tokens = userData['fcmTokens'];
                    }
                }

            }

            const payload : admin.messaging.MessagingPayload = {

                notification : {
                    title : senderName + 'Private Message',
                    body : message.text,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                },
            };

            if(tokens != null) {
                return fcm.sendToDevice(tokens,payload).then((response) => {
                    console.log('Successfully sent message:', response);
                })
                .catch((error) => {
                console.log('Error sending message:', error);
                });
            } else {
                return 0;
            }
            

    };
    
})