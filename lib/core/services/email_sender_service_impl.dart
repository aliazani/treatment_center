import 'package:flutter_email_sender/flutter_email_sender.dart' as fes;
import 'email_sender_service.dart';

class EmailSenderServiceImpl implements EmailSenderService {
  @override
  Future<void> send(fes.Email email) {
    return fes.FlutterEmailSender.send(email);
  }
}
