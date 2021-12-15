import 'player.dart';
import 'person.dart';

class Chat {
  List<Message> messages;
  Person? botPersonality;

  Chat({
    required this.messages,
    this.botPersonality,
  });
}

class Message {
  String text;
  String? profileImage;
  String? image;
  dynamic author; //  can be of type Player or Person
  DateTime time;
  int? index;
  DateTime? timeAsked;
  Duration delayTime;

  Message({
    required this.text,
    required this.profileImage,
    required this.image,
    required this.author,
    required this.time,
    this.index,
    this.timeAsked,
    this.delayTime = const Duration(),
  }) : assert(author is Person || author is Player);

  factory Message.fromDict(dynamic dict) {
    return Message(
      text: dict['text'],
      profileImage: dict['profileImage'],
      image: dict['image'],
      author: dict['author'].containsKey('uid')
          ? Player.fromDict(dict['author'])
          : Person.fromDict(dict['author']),
      time: dict['time'].toDate(),
      timeAsked: dict['timeAsked']?.toDate(),
    );
  }
}
