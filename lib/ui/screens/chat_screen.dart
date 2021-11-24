import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'package:strix/business_logic/classes/player.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/business_logic/logic/chat_room_logic.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/ui/widgets/chat_message.dart';

class ChatScreen extends StatelessWidget {
  final Room roomData;
  //final bool newMessage;
  ChatScreen({
    Key? key,
    required this.roomData,
    //required this.newMessage,
  }) : super(key: key);

  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Authorization _authorization = serviceLocator<Authorization>();

  @override
  Widget build(BuildContext context) {
    Chat chatData = roomData.chat;
    return Stack(
      children: [
        Container(
          color: Colors.blueGrey[500],
          height: MediaQuery.of(context).size.height * 0.5,
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            child: SizedBox(
              //color: Colors.blue,
              height: MediaQuery.of(context).size.height * 0.08,
              child: Row(
                children: [
                  const Expanded(
                    flex: 25,
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.65,
                        heightFactor: 0.65,
                        child: FittedBox(
                          child: Icon(
                            Icons.message_outlined,
                            size: 75.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 60,
                          child: FittedBox(
                            child: Text(
                              'Field Agent John Mason',
                              style: TextStyle(fontSize: 100.0),
                            ),
                          ),
                        ),
                        Expanded(flex: 5, child: Container()),
                        const Expanded(
                            flex: 35,
                            child: FractionallySizedBox(
                              widthFactor: 0.7,
                              child: FittedBox(
                                child: Text(
                                  'encrypted secured chat',
                                  style: TextStyle(fontSize: 50.0),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 15,
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.08,
                  //color: Colors.red,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                    color: Colors.grey[900],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: chatData.messages.length,
                          reverse: true,
                          shrinkWrap: true,
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            List<Message> reversedList = chatData.messages.reversed.toList();
                            Message message = reversedList[index];
                            bool fromTeam = message.author is Player;
                            bool fromMe = fromTeam
                                ? _authorization.getCurrentUserID() == message.author.uid
                                : false;
                            bool delay =
                                (index == 0 && fromTeam == false && reversedList.length > 1 // &&
                                    //newMessage,
                                    )
                                    ? true
                                    : false;

                            return ChatMessage(
                              fromTeam: fromTeam,
                              fromMe: fromMe,
                              message: message,
                              delay: delay,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: Container()),
                              Expanded(
                                flex: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[800],
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: TextField(
                                    controller: _textController,
                                    textAlignVertical: TextAlignVertical.center,
                                    expands: true,
                                    maxLines: null,
                                    maxLength: roomData.maximumInputCharacters,
                                    //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                    decoration: const InputDecoration(
                                      hintText: 'Type your message here...',
                                      counterText: "",
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(child: Container()),
                              TextButton(
                                onPressed: () {
                                  if (_textController.text.isNotEmpty) {
                                    ChatRoomLogic()
                                        .addMessage(room: roomData, text: _textController.text);
                                    _textController.clear();
                                    _scrollController.animateTo(
                                      0.0,
                                      curve: Curves.easeOut,
                                      duration: const Duration(milliseconds: 300),
                                    );
                                  }
                                },
                                child: const FittedBox(
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.blueGrey,
                                    size: 35.0,
                                  ),
                                ),
                              ),
                              Expanded(child: Container()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
