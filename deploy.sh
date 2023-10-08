echo "😡😡😡😡 build the app for the web 🌀🌀 ... "
echo "Remember to change 😡😡😡😡 const serverUrl  in index.html 😡😡😡😡"
flutter build web --release
echo "😡😡😡😡 deploy app hosting 🌀🌀 ..."
firebase deploy --only hosting
echo "🌀🌀🌀🌀🌀🌀Kasie Web App hopefully deployed!!"