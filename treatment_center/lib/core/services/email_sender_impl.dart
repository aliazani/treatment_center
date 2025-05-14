import 'package:flutter_email_sender/flutter_email_sender.dart' as fes;
import 'email_sender.dart';

class FlutterEmailSenderImpl implements EmailSender {
  @override
  Future<void> send(fes.Email email) {
    return fes.FlutterEmailSender.send(email);
  }
}
