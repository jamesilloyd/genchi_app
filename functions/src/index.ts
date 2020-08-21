import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
// import { QueryDocumentSnapshot } from 'firebase-functions/lib/providers/firestore';

// import { user } from 'firebase-functions/lib/providers/auth';


admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

 // Start writing Firebase Functions
 // https://firebase.google.com/docs/functions/typescript


export const sendNewJobNotification = functions.firestore.document('tasks/{taskId}')
.onCreate(async (snapshot, context) => {

    const taskData = snapshot.data();

    const users = await db.collection('users').get();
    const usersData = users.docs;

    let allTokens: Array<string> = [];
    let taskTitle;
    let taskDesc;

    ///We need to grab all the tokens from the 'users' database 

    if(taskData && usersData) {
        for(const item of usersData){
            const deviceTokens: Array<string> = item.data()['fcmTokens'];
            
            if((deviceTokens !== undefined) && (deviceTokens.length !== 0)){
                for(const token of deviceTokens) {
                    if(token !== "") {
                        allTokens.push(token);
                    }
                }
                
            }
        }

        //Now need to find taskTitle and taskDesc
        taskTitle = taskData['title'];
        taskDesc = taskData['details'];

        console.log(taskTitle);
        console.log(taskDesc);
        console.log('DEVICE TOKENS',allTokens);

        const payload : admin.messaging.MessagingPayload = {

            notification : {
                title : 'New Job: ' + taskTitle,
                body : taskDesc,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                badge : '1'
            },
        };
    
        if(allTokens !== null) {
            return fcm.sendToDevice(allTokens,payload).then((response) => {
                console.log('Successfully sent message:', response);
            })
            .catch((error) => {
            console.log('Error sending message:', error);
            });
        } else {
            return 0;
        }

    }

})

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
    
})


export const sendPrivateMessageNotification = functions.firestore.document('chats/{chatId}/messages/{messageId}')
    .onCreate( async (snapshot, context) => {

        const message = snapshot.data();

        const chat = await db.collection('chats').doc(context.params.chatId).get();
        const chatData = chat.data();

        let tokens;
        let senderName;

        if (chatData) {

            //The user in the chat
            const user = await db.collection('users').doc(chatData['uid']).get();
            const userData = user.data();

            // Ther provider in the chat
            const pid = chatData['pid'];
            const provider = await db.collection('providers').doc(pid).get();
            const providerData = provider.data();

            if(userData && providerData) {

                if(pid == message.sender) {
                // If sender is the provider retrieve the providers name and the user token
                    senderName = providerData['name'];
                    tokens = userData['fcmTokens'];

                } else {
                //Otherwise the user sent the message so we need to find the tokens of the providers uid and the sender name
                    const providersUser = await db.collection('users').doc(providerData['uid']).get();
                    const providersUserData = providersUser.data();

                    if(providersUserData){
                        senderName = userData['name'];
                        tokens = providersUserData['fcmTokens'];
                    }
                }
            }

            const payload : admin.messaging.MessagingPayload = {

                notification : {
                    title : senderName + ' - Private Message',
                    body : message.text,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    badge : '1'
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


export const sendApplicationMessageNotification = functions.firestore.document('tasks/{taskId}/applicants/{applicantId}/messages/{messageId}')
.onCreate(async (snapshot, context) => {

    const message = snapshot.data();

    const application = await db.collection('tasks').doc(context.params.taskId).collection('applicants').doc(context.params.applicantId).get();
    const applicationData = application.data();

    const task = await db.collection('tasks').doc(context.params.taskId).get();
    const taskData = task.data();

    let tokens;
    let senderName;
    let taskTitle;

    ///How are we going to get tokens, senderName and taskTitle?

    ///taskTitle -> application -> task -> task.title

    if(applicationData && taskData) {

        //The user in the application
        const user = await db.collection('users').doc(applicationData['hirerid']).get();
        const userData = user.data();

        // Ther provider in the application
        const pid = applicationData['pid'];
        const provider = await db.collection('providers').doc(pid).get();
        const providerData = provider.data();

        if(userData && providerData) {

            if(pid == message.sender) {
                // If sender is the provider retrieve the providers name and the user token
                    senderName = providerData['name'];
                    tokens = userData['fcmTokens'];

                } else {
                //Otherwise the user sent the message so we need to find the tokens of the providers uid and the sender name
                    const providersUser = await db.collection('users').doc(providerData['uid']).get();
                    const providersUserData = providersUser.data();

                    if(providersUserData){
                        senderName = userData['name'];
                        tokens = providersUserData['fcmTokens'];
                    }
                }
        }

        //Now need to find taskTitle

        taskTitle = taskData['title'];


        const payload : admin.messaging.MessagingPayload = {

            notification : {
                title : senderName + ' - ' + taskTitle,
                body : message.text,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                badge : '1'
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

    }

})

// export const sendApplicationMessageNotification = functions.firestore.document('tasks/{taskId}/applicants/{applicantId}/messages/{messageId}')
// .onCreate(async (snapshot, context) => {

//     const message = snapshot.data();

//     const application = await db.collection('tasks').doc(context.params.taskId).collection('applicants').doc(context.params.applicationId).get();
//     const applicationData = application.data();

//     const task = await db.collection('tasks').doc(context.params.taskId).get();
//     const taskData = task.data();

//     let tokens;
//     let senderName;
//     let taskTitle;

//     ///taskTitle -> application -> task -> task.title

//     if(applicationData && taskData) {

//         //The hirer in the application
//         const hirer = await db.collection('users').doc(applicationData['hirerid']).get();
//         const hirerData = hirer.data();

//         // Ther applicant in the application
//         const applicantId = applicationData['applicantId'];
//         const applicant = await db.collection('users').doc(applicantId).get();
//         const applicantData = applicant.data();

//         if(hirerData && applicantData) {

//             if(applicantId == message.sender) {
//                 // If sender is the applicant retrieve the applicant's name and the hirer's token
//                     senderName = applicantData['name'];
//                     tokens = hirerData['fcmTokens'];

//                 } else {
//                 //Otherwise the hirer sent the message so we need to find the tokens of the applicant and the hirer's name
//                     senderName = hirerData['name'];
//                     tokens = applicantData['fcmTokens'];
//                 }
//         }

//         //Now need to find taskTitle

//         taskTitle = taskData['title'];


//         const payload : admin.messaging.MessagingPayload = {

//             notification : {
//                 title : senderName + ' - ' + taskTitle,
//                 body : message.text,
//                 clickAction: 'FLUTTER_NOTIFICATION_CLICK',
//                 badge : '1'
//             },
//         };
    
//         if(tokens != null) {
//             return fcm.sendToDevice(tokens,payload).then((response) => {
//                 console.log('Successfully sent message:', response);
//             })
//             .catch((error) => {
//             console.log('Error sending message:', error);
//             });
//         } else {
//             return 0;
//         }

//     }

// })