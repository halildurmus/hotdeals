# hotdeals-app

![GitHub top language](https://img.shields.io/github/languages/top/halildurmus/hotdeals-app?style=for-the-badge)
[![GitHub contributors](https://img.shields.io/github/contributors-anon/halildurmus/hotdeals-app?style=for-the-badge)](https://github.com/halildurmus/hotdeals-app/graphs/contributors)
[![GitHub issues](https://img.shields.io/github/issues/halildurmus/hotdeals-app?style=for-the-badge)](https://github.com/halildurmus/hotdeals-app/issues)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](https://github.com/halildurmus/hotdeals-app/blob/master/LICENSE)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?logo=linkedin&labelColor=blue&style=for-the-badge)](https://linkedin.com/in/halildurmus)
![Visits](https://badges.pufler.dev/visits/halildurmus/hotdeals-app?style=for-the-badge)

> **hotdeals-app** is an **online marketplace** app developed with **[Flutter](https://github.com/flutter/flutter)**.  
The app's **Backend** can be found **[here](https://github.com/halildurmus/hotdeals-backend)**.

## Table of Contents

* [Screenshots](#screenshots)
* [Features](#features)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
* [Roadmap](#roadmap)
* [Code Contributors](#code-contributors)
* [Contributing](#-contributing)
* [Author](#author)
* [License](#-license)
* [Acknowledgements](#acknowledgements)

## Screenshots

<p align="center">
    <img src="https://raw.githubusercontent.com/halildurmus/hotdeals-app/master/screenshots/home-dark.png" width="270">
    <img src="https://raw.githubusercontent.com/halildurmus/hotdeals-app/master/screenshots/deal-details1-dark.png" width="270">
    <img src="https://raw.githubusercontent.com/halildurmus/hotdeals-app/master/screenshots/deal-details2-dark.png" width="270">
    <img src="https://raw.githubusercontent.com/halildurmus/hotdeals-app/master/screenshots/chats-dark.png" width="270">
    <img src="https://raw.githubusercontent.com/halildurmus/hotdeals-app/master/screenshots/chat-dark.png" width="270">
    <img src="https://raw.githubusercontent.com/halildurmus/hotdeals-app/master/screenshots/profile-dark.png" width="270">
    <img src="https://raw.githubusercontent.com/halildurmus/hotdeals-app/master/screenshots/home-light.png" width="270">
    <img src="https://raw.githubusercontent.com/halildurmus/hotdeals-app/master/screenshots/deal-details1-light.png" width="270">
    <img src="https://raw.githubusercontent.com/halildurmus/hotdeals-app/master/screenshots/deal-details2-light.png" width="270">
</p>

## Features

- Social sign in with Facebook and Google (using Firebase Authentication)
- State management using [Provider](https://github.com/rrousselGit/provider)
- Service Locator using [get_it](https://github.com/fluttercommunity/get_it)
- Infinite scrolling pagination using [infinite_scroll_pagination](https://github.com/EdsonBueno/infinite_scroll_pagination)
- In-app messaging
- Notifications (using Firebase Cloud Messaging)
- Localization (l10n)
- Light and Dark theme
- Logging (using [loggy](https://github.com/infinum/floggy) and Firebase Crashlytics)

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

- You need to have **Flutter** installed on your pc.
  * [Install Flutter](https://flutter.dev/docs/get-started/install)
- You need to have [hotdeals-backend](https://github.com/halildurmus/hotdeals-backend) ready in your system.

### Installation

1. Clone the repo using: `git clone https://github.com/halildurmus/hotdeals-app.git`
2. Register the app on [Firebase](https://firebase.google.com).
3. Download the configuration file from the [Firebase Console](https://console.firebase.google.com) (google-services.json) and copy it into the `android/app` directory.
4. Open `android/app/src/main/res/values/strings.xml` file and change `facebook_app_id` and `fb_login_protocol_scheme` values with yours.
5. The environment configuration will be read from `config/dev_config.dart` by default unless you specify the environment using `--dart-define=ENV=prod` in the run args. Depending your environment, you may need to change `apiBaseUrl` inside the `dev_config.dart`.
6. To get the packages needed for the app, run:
```Dart
flutter pub get
```

## Usage

If you have a connected device or emulator running, you can run the app with:
```Dart
flutter run
```

## Roadmap

See the [open issues](https://github.com/halildurmus/hotdeals-app/issues) for a list of proposed features (and known issues).

## Code Contributors

This project exists thanks to all the people who contribute.

<a href="https://github.com/halildurmus/hotdeals-app/graphs/contributors">
  <img class="avatar" alt="halildurmus" src="https://github.com/halildurmus.png?v=4&s=96" width="48" height="48" />
</a>

## 🤝 Contributing

Contributions, issues and feature requests are welcome.  
Feel free to check [issues page](https://github.com/halildurmus/hotdeals-app/issues) if you want to contribute.

## Author

👤 **Halil İbrahim Durmuş**

- Github: [@halildurmus](https://github.com/halildurmus "halildurmus")

## 📝 License

This project is [MIT](https://github.com/halildurmus/hotdeals-app/blob/master/LICENSE) licensed.

## Acknowledgements
* Country Icons made by [Freepik](https://www.freepik.com "Freepik") from [www.flaticon.com](https://www.flaticon.com "Flaticon")
* [Img Shields](https://shields.io "Img Shields") 
* Preview mockups were created with [AppMockUp](https://app-mockup.com "AppMockUp")
