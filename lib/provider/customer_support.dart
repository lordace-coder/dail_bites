import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsAppSupport() async {
  // Replace with your customer support phone number
  const phoneNumber = '+2348109294691';
  const message = 'Hello customer support!';

  const url = 'https://api.whatsapp.com/send?phone=$phoneNumber&text=$message';

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    // Handle the case when WhatsApp is not installed or the URL cannot be launched
    throw 'Could not launch WhatsApp';
  }
}

Future launchLink(String path) async {
  if (await canLaunchUrl(Uri.parse(path))) {
    await launchUrl(Uri.parse(path), mode: LaunchMode.externalApplication);
  } else {
    // Handle the case when WhatsApp is not installed or the URL cannot be launched
    throw 'Could not launch url';
  }
}
