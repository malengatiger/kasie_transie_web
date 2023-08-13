import { initializeApp } from "firebase/app";
import { getMessaging } from "firebase/messaging/sw";
import { getAnalytics } from "firebase/analytics";

importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object
console.log(`💪💪💪💪💪💪💪setting up firebase .....`)

const firebaseApp = initializeApp({
  apiKey: "AIzaSyAdOBFxPS1TacnK5OZTU6VxOQ20Bq8Cyrg",
    authDomain: "thermal-effort-366015.firebaseapp.com",
    projectId: "thermal-effort-366015",
    storageBucket: "thermal-effort-366015.appspot.com",
    messagingSenderId: "79998394043",
    appId: "1:79998394043:web:af0eba9987ec6676d6139e",
    measurementId: "G-0668RQE3NY"
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = getMessaging(firebaseApp);
const analytics = getAnalytics(app);

console.log(`💪💪💪💪💪💪💪firebase has been setup: ${messaging}`)
//
getToken(messaging, { vapidKey: 'BA_kOc-IQrUlbie9djVLR-eU6ljeCVizMVs9hulFT7ed6ywWbQAZPWBwZWld15XAmdNPFewiFS5-J3xXqvU1lOs' }).then((currentToken) => {
  if (currentToken) {
    // Send the token to your server and update the UI if necessary
    console.log(`currentToken: ${currentToken}`)
    // ...
  } else {
    // Show permission request UI
    console.log('No registration token available. Request permission to generate one.');
    // ...
  }
}).catch((err) => {
  console.log('An error occurred while retrieving token. ', err);
  // ...
});
//
console.log(`💪💪💪💪💪💪💪setting up background messaging .....`)

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = 'Background Message Title';
  const notificationOptions = {
    body: 'Background Message body.',
    icon: '/firebase-logo.png'
  };

  self.registration.showNotification(notificationTitle,
    notificationOptions);
});