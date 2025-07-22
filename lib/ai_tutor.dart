// lib/ai_tutor.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class AiTutorPage extends StatefulWidget {
  const AiTutorPage({Key? key}) : super(key: key);

  @override
  _AiTutorPageState createState() => _AiTutorPageState();
}

class _AiTutorPageState extends State<AiTutorPage> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "AI Tutor",
    profileImage:
    "https://cdn2.vectorstock.com/i/1000x1000/64/71/female-teacher-avatar-educacion-and-school-vector-38156471.jpg",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF48A9A6), // Added const
        centerTitle: true,
        title: const Text(
          "AI Tutor",
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              "https://i.pinimg.com/736x/ee/e1/d4/eee1d4114e36fa5f1dc7358c60f4b290.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: DashChat(
        inputOptions: InputOptions(trailing: [
          IconButton(
            onPressed: _sendMediaMessage,
            icon: const Icon(
              Icons.image,
            ),
          )
        ]),
        currentUser: currentUser,
        onSend: _sendMessage,
        messages: messages,
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini.streamGenerateContent(
        question,
        images: images,
      ).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;

        // Extract text from parts using the new structure for flutter_gemini 3.0.0
        String currentResponsePart = event.content?.parts?.fold(
            "", (previous, current) {
          if (current is TextPart) { // Check if the part is a TextPart
            return "$previous${current.text ?? ''}"; // Access .text from TextPart
          }
          // Handle other part types (e.g., FilePart, InlinePart) if necessary,
          // or just ignore them for text display.
          return previous;
        }) ?? "";


        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          lastMessage.text += currentResponsePart; // Append the new part
          setState(
                () {
              messages = [lastMessage!, ...messages];
            },
          );
        } else {
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: currentResponsePart, // Use the extracted part
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print('Error sending message to Gemini: $e'); // Added a more descriptive print
      // Optionally, add an error message to the chat UI
      setState(() {
        messages.insert(0, ChatMessage(user: geminiUser, createdAt: DateTime.now(), text: "Error: ${e.toString()}"));
      });
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}