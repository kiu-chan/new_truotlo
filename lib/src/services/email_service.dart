import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendEmail({
    required String name,
    required String email,
    required String phone,
    required String content,
  }) async {
    String username = 'khanhk66uet@gmail.com';
    String password = 'tsds yrui jurx gkwj';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Email từ ứng dụng trượt lở Bình Định')
      ..recipients.add('viendcnmtkhobac@gmail.com')
      ..subject = 'Bạn có một thông báo từ $name - ứng dụng trượt lở Bình Định'
      ..text = '''
Các thông tin được liên hệ bao gồm:

Tên người gửi: $name
Email: $email
Số điện thoại: $phone

Nội dung:
$content
''';

    try {
      await send(message, smtpServer);
    } on MailerException {
      rethrow;
    }
  }
}
