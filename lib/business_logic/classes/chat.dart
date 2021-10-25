import 'player.dart';
import 'person.dart';

class Chat {
  List<Message> messages;

  Chat({required this.messages});
}

class Message {
  String text;
  String? profileImage;
  String? image;
  dynamic author; //  can be of type Player or Person
  DateTime time;

  Message({
    required this.text,
    required this.profileImage,
    required this.image,
    required this.author,
    required this.time,
  }) : assert(author is Person || author is Player);
}
