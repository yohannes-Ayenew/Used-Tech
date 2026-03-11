importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCIJH5XcrBuFYU-vvHEK0QmWGzV9QgP7eo",
  authDomain: "used-tech-market.firebaseapp.com",
  projectId: "used-tech-market",
  storageBucket: "used-tech-market.firebasestorage.app",
  messagingSenderId: "440923132786",
  appId: "1:440923132786:web:b11e21908ee28e0817c3eb",
  measurementId: "G-B06BQ79C5V",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Received background message ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
