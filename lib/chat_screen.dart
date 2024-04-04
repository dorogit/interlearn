import 'dart:convert';
import 'dart:math';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intelearn/message.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Message> msgs = [];
  String conversationHistory = "";
  bool isTyping = false;

  void sendMsg() async {
    String text = controller.text.trim();
    controller.clear();
    if (text.isNotEmpty) {
      setState(() {
        msgs.insert(0, Message(true, text));
        // Update conversation history with the user's message
        isTyping = true;
      });
      try {
        var dio = Dio();
        var response = await dio.post(
          "https://6f6a8ddf67b4ba86e9bcaeae86213c90.serveo.net/v1/chat/completions",
          data: jsonEncode({
            "model": "Intel/neural-chat-7b-v3-1",
            "messages": [
              {"role": "user", "content": text}
            ]
          }),
          options: Options(headers: {"Content-Type": "application/json"}),
        );
        if (response.statusCode == 200) {
          var jsonResponse = response.data;
          setState(() {
            isTyping = false;
            msgs.insert(
                0,
                Message(
                    false,
                    jsonResponse["choices"][0]["message"]["content"]
                        .toString()
                        .trimLeft()));
            // Append the bot's response to the conversation history
            conversationHistory +=
                "User: $text\n You: ${jsonResponse["choices"][0]["message"]["content"].toString().trimLeft()}\n";
          });
        }
      } catch (err) {
        print(err);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Some error occurred, please try again! $err")),
        );
      }
    }
  }

  Widget currentLoadingAnimation =
      const SizedBox(); // Placeholder for the initial state

  final List<Widget Function()> loadingAnimations = [
    () => LoadingAnimationWidget.waveDots(color: Colors.white, size: 40),
    () => LoadingAnimationWidget.inkDrop(color: Colors.white, size: 40),
    () =>
        LoadingAnimationWidget.threeRotatingDots(color: Colors.white, size: 40),
    () =>
        LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 40),
    () =>
        LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 40),
    () => LoadingAnimationWidget.fallingDot(color: Colors.white, size: 40),
    () => LoadingAnimationWidget.discreteCircle(color: Colors.white, size: 40),
    () =>
        LoadingAnimationWidget.threeArchedCircle(color: Colors.white, size: 40),
    () => LoadingAnimationWidget.bouncingBall(color: Colors.white, size: 40),
    () => LoadingAnimationWidget.beat(color: Colors.white, size: 40),
    () =>
        LoadingAnimationWidget.threeRotatingDots(color: Colors.white, size: 40),
    () => LoadingAnimationWidget.twoRotatingArc(color: Colors.white, size: 40),
    () => LoadingAnimationWidget.horizontalRotatingDots(
        color: Colors.white, size: 50),
    () => LoadingAnimationWidget.newtonCradle(color: Colors.white, size: 40),
    () => LoadingAnimationWidget.stretchedDots(color: Colors.white, size: 40),
    () => LoadingAnimationWidget.halfTriangleDot(color: Colors.white, size: 40),
    () => LoadingAnimationWidget.dotsTriangle(color: Colors.white, size: 40),
  ];

  // Method to select a random loading animation
  void selectRandomLoadingAnimation() {
    final randomIndex = Random().nextInt(loadingAnimations.length);
    setState(() {
      currentLoadingAnimation = loadingAnimations[randomIndex]();
    });
  }

  @override
  void initState() {
    super.initState();
    selectRandomLoadingAnimation(); // Select an initial loading animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(33, 33, 33, 33),
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          title: const Text(
            'inteLearn',
            textScaler: TextScaler.linear(1.2),
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 193)),
          )),
      body: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: ListView.builder(
                controller: scrollController,
                itemCount: msgs.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: isTyping && index == 0
                          ? Column(
                              children: [
                                BubbleNormal(
                                  text: msgs[0].msg,
                                  isSender: true,
                                  color:
                                      const Color.fromARGB(255, 255, 255, 193),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 16, top: 4),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: currentLoadingAnimation),
                                )
                              ],
                            )
                          : BubbleNormal(
                              text: msgs[index].msg,
                              isSender: msgs[index].isSender,
                              color: msgs[index].isSender
                                  ? const Color.fromARGB(255, 255, 255, 193)
                                  : Colors.grey.shade200,
                            ));
                }),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        readOnly: isTyping,
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) {
                          sendMsg();
                        },
                        textInputAction: TextInputAction.send,
                        showCursor: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "Enter text"),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  sendMsg();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              )
            ],
          ),
        ],
      ),
    );
  }
}
