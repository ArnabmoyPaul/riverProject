# River Project - Flutter Authentication with Node.js Backend

A Flutter application with Node.js backend that provides authentication and photo upload functionality.

## Features

- User authentication (Login/Register)
- Photo upload with captions
- Task management with subtasks
- Modern UI with Flutter
- RESTful API backend with Node.js

## Prerequisites

- Flutter SDK (latest stable version)
- Node.js (v14 or higher)
- npm (comes with Node.js)
- Android Studio or Xcode (for mobile development)
- A code editor (VS Code recommended)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ArnabmoyPaul/riverProject.git
cd riverProject
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Install Node.js Dependencies

Navigate to the server directory and install dependencies:

```bash
cd server
npm install
```

### 4. Run the Backend Server

In the server directory, start the Node.js server:

```bash
npm start
```

The server will run on `http://localhost:3000`

### 5. Run the Flutter App

In a new terminal, run the Flutter app:

```bash
flutter run
```

## Project Structure

```
riverProject/
├── lib/                    # Flutter source code
│   ├── screens/           # Screen components
│   └── widgets/           # Reusable widgets
├── server/                # Node.js backend
│   ├── routes/           # API routes
│   └── package.json      # Node.js dependencies
└── android/              # Android platform files
```

## API Endpoints

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/photos/upload` - Upload photos
- `GET /api/photos` - Get uploaded photos

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
