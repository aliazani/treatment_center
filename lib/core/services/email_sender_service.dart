import 'package:flutter_email_sender/flutter_email_sender.dart';

abstract class EmailSenderService {
  Future<void> send(Email email);
}
