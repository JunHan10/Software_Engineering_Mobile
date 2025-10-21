class AppConfig {
  // For Android Emulator, use 10.0.2.2
  // For iOS Simulator, use localhost
  // For physical device, use your computer's IP address on the local network
  static const bool useEmulator = true;

  static String get baseUrl {
    if (useEmulator) {
      return 'http://10.0.2.2:3000'; // Android Emulator
    } else {
      // TODO: Replace with your computer's IP address when testing on physical device
      return 'http://192.168.1.22:3000';
    }
  }
}
