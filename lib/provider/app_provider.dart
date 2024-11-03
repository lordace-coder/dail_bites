class AppDataProvider {
  ///base class to store all constants and configuraton for the app
  bool debugMode = false;

  String get baseUrl =>
      debugMode ? 'http://10.0.2.2:8090' : 'https://dailbit.pockethost.io';

  // payment details
  String secretKey = 'sk_test_e40eecaa87be78830c7e8fa3f9b8b4ef900afe33';

  String publicKey = 'pk_test_14e8e01f8cbb1d3eb5dac7c17572364a42509fec';
}
