import * as functions from 'firebase-functions';

 // Start writing Firebase Functions
 // https://firebase.google.com/docs/functions/typescript

export const helloWorld = functions.https.onRequest((request, response) => {
 console.log('Hello!')
 response.send("Hello from Firebase!");
});

export const sendHelloNotificaiton = functions.https.onRequest((request,response) => {
    console.log('Hello notification!')
    response.send("You should have received a notification");
})
