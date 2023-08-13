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

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
// const messaging = getMessaging(firebaseApp);
// const analytics = getAnalytics(app);

console.log(`💪💪💪💪💪💪💪  inside sw.js  🔴 firebase has been setup`);
//
console.log(
  `💪💪💪💪💪💪💪 inside sw.js  🔴 setting up background messaging .....`
);

messaging.onBackgroundMessage(function (payload) {
  console.log(
    "[firebase-messaging-sw.js] 🔴 🔴 🔴 🔴 🔴 Received background message ",
    payload
  );
  // Customize notification here
  const notificationTitle = "Background Message Title";
  const notificationOptions = {
    body: "Background Message body.",
    icon: "/firebase-logo.png",
  };
  console.log("inside sw.js  🔴 Setting up to post message: " + payload);
  console.log("inside sw.js  🔴 clients: " + self.clients);

  self.clients.matchAll().then((clients) => {
    for (const client of clients) {
      client.postMessage(JSON.stringify(payload));
    }
  });

  self.registration.showNotification(notificationTitle, notificationOptions);
});
console.log(
  `💪💪💪💪💪💪💪 inside sw.js 🔴  setting up background messaging seems OK .....`
);
