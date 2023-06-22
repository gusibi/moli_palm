import 'package:flutter/material.dart';

class ConversationCardDto {
  int id;
  String title;
  IconData icon;
  String? desc;
  String? prompt;
  String? modelName;

  ConversationCardDto({
    required this.id,
    required this.icon,
    required this.title,
    required this.prompt,
    required this.modelName,
    this.desc,
  });

  ConversationCardDto copy() {
    return ConversationCardDto(
      id: id,
      title: title,
      desc: desc,
      icon: icon,
      prompt: prompt,
      modelName: modelName,
    );
  }
}
