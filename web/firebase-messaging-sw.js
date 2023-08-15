importScripts(
  "https://www.gstatic.com/firebasejs/10.1.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.1.0/firebase-messaging-compat.js"
);

console.log("inside js file 💪💪💪💪💪💪💪  🔴 setting up firebase .....");

const firebaseConfig = {
  apiKey: "AIzaSyAdOBFxPS1TacnK5OZTU6VxOQ20Bq8Cyrg",
  authDomain: "thermal-effort-366015.firebaseapp.com",
  projectId: "thermal-effort-366015",
  storageBucket: "thermal-effort-366015.appspot.com",
  messagingSenderId: "79998394043",
  appId: "1:79998394043:web:af0eba9987ec6676d6139e",
  measurementId: "G-0668RQE3NY",
};
const firebaseApp = firebase.initializeApp(firebaseConfig);
console.log("initializeApp has executed, appId: " + firebaseApp.appId);
// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();
console.log(
  `💪💪💪💪💪💪💪  inside sw.js 🔴 firebase messaging has been setup: ${messaging.appId}`
);

//
console.log(
  `💪💪💪💪💪💪💪 inside sw.js  🔴 setting up background messaging .....`
);
//
function callDartMethod(mData) {
  console.log('🔴 🔴 🔴 callDartMethod to post fcm data started ...');
  const message = {
    type: 'CALL_DART_METHOD',
    mData: mData,
  };

  // Post the message to the Dart app
  window.parent.postMessage(message, '*');
}

messaging.onBackgroundMessage(function (payload) {
  console.log(
    "[firebase-messaging-sw.js] 🔴 🔴 🔴 🔴 🔴 Received background message! Heita! ",
    payload
  );

  console.log("inside sw.js  🔴 calling dart with FCM payload ... ");

  callDartMethod(payload);

  // console.log("inside sw.js  🔴 clients: " + self.clients);
  // Store the payload in localStorage ...
  // localStorage.setItem('fcm_message', JSON.stringify(payload));
  // console.log(`💪💪💪💪💪💪💪  inside sw.js  🔴 payload written to storage`);

  // self.clients.matchAll().then((clients) => {
  //   for (const client of clients) {
  //     console.log(`💪💪💪💪💪💪💪  inside sw.js  🔴 about to client.postMessage`);

  //     client.postMessage({ type: 'FCM_MESSAGE', payload: payload });
  //   }
  // });
 //
  // self.registration.showNotification(notificationTitle, notificationOptions);
});
console.log(
  `💪💪💪💪💪💪💪 inside sw.js 🔴  setting up background messaging seems OK .....`
);
