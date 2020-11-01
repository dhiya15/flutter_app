import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class Sender{

  static Future<bool> sendingMail(String email, String subject, String msg) async{
    String _username = 'dido.dadi08@gmail.com';
    String _password = 'dayaadin1998';

    final smtpServer = gmail(_username, _password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    // Create our message.
    final message = Message()
      ..from = Address(_username, 'Pharmacie du village')
      ..recipients.add(email)
      ..subject = subject
      ..text = msg;
    bool x;
    try {
      await send(message, smtpServer);
      x = true;
    } on MailerException catch (e) {
      x = false;
    }
    return x;
  }

}