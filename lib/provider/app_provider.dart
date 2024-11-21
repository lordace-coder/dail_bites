class AppDataProvider {
  ///base class to store all constants and configuraton for the app
  bool debugMode = false;

  String get baseUrl =>
      debugMode ? 'http://10.0.2.2:8090' : 'https://dailbit.pockethost.io';

  // payment details
  String secretKey = 'sk_live_d49665805a6d2df132a71ad27c6444672ed22034';

  String publicKey = 'pk_live_2fa14872e7ba93c85b153c1da420ba3ce1b8ecbf';
}
