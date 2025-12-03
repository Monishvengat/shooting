# My Flutter App

This project is a full-stack application that consists of a Flutter frontend and a Node.js backend with MongoDB as the database.

## Project Structure

```
my-flutter-app
├── flutter_app
│   ├── lib
│   │   ├── main.dart
│   │   ├── screens
│   │   │   └── home_screen.dart
│   │   ├── services
│   │   │   └── api_service.dart
│   │   └── models
│   │       └── index.dart
│   ├── pubspec.yaml
│   └── README.md
├── api
│   ├── src
│   │   ├── app.ts
│   │   ├── controllers
│   │   │   └── index.ts
│   │   ├── routes
│   │   │   └── index.ts
│   │   ├── models
│   │   │   └── index.ts
│   │   └── types
│   │       └── index.ts
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md
└── README.md
```

## Flutter App Setup

1. Navigate to the `flutter_app` directory.
2. Run `flutter pub get` to install the dependencies listed in `pubspec.yaml`.
3. Use `flutter run` to start the Flutter application.

## Node.js API Setup

1. Navigate to the `api` directory.
2. Run `npm install` to install the dependencies listed in `package.json`.
3. Start the server with `npm start` or `ts-node src/app.ts` if you have TypeScript installed globally.

## Usage

- The Flutter app communicates with the Node.js API to fetch and display data.
- Ensure that the Node.js server is running before starting the Flutter app to avoid connection issues.

## Contributing

Feel free to submit issues or pull requests for improvements or bug fixes.