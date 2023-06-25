import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/palm_priovider.dart';

class BaseURLFormWidget extends StatefulWidget {
  const BaseURLFormWidget({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<BaseURLFormWidget> createState() => _BaseURLFormWidgetState();
}

class _BaseURLFormWidgetState extends State<BaseURLFormWidget> {
  late String baseURL;
  @override
  void initState() {
    super.initState();
    // baseURL = widget.defaultValue;    baseURL = "";
  }

  @override
  Widget build(BuildContext context) {
    final palmProvider =
        Provider.of<PalmSettingProvider>(context, listen: false);
    // var baseURL = widget.defaultValue;
    return TextFormField(
      controller: widget.controller,
      decoration: const InputDecoration(
        labelText: "Base URL",
        border: OutlineInputBorder(),
      ),

      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter base URL';
        }
        return null;
      },
      // style: TextStyle(),
      onChanged: (value) {
        setState(() {
          baseURL = value.toString();
        });
        palmProvider.setBaseURL(value.toString());
      },
      onSaved: (value) {
        baseURL = value.toString();
        palmProvider.setBaseURL(value.toString());
        print("baseURL: $baseURL");
      },
    );
  }
}

class ApiKeyFormWidget extends StatefulWidget {
  const ApiKeyFormWidget({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<ApiKeyFormWidget> createState() => _ApiKeyFormWidgetState();
}

class _ApiKeyFormWidgetState extends State<ApiKeyFormWidget> {
  bool isObscureText = true;
  @override
  Widget build(BuildContext context) {
    final palmProvider =
        Provider.of<PalmSettingProvider>(context, listen: false);
    var apiKey = "";
    return TextFormField(
      obscureText: isObscureText,
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: "API Key",
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            isObscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              isObscureText = !isObscureText;
            });
          },
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter API Key';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          apiKey = value.toString();
        });
        palmProvider.setApiKey(value.toString());
      },
      onSaved: (value) {
        apiKey = value.toString();
        palmProvider.setApiKey(value.toString());
        print("apiKey: $apiKey");
      },
    );
  }
}

class PromptMessageInputFormWidget extends StatefulWidget {
  const PromptMessageInputFormWidget({
    super.key,
    required this.textController,
    required this.onPressed,
  });
  final TextEditingController textController;
  final VoidCallback onPressed;

  @override
  State<PromptMessageInputFormWidget> createState() =>
      _PromptMessageInputFormWidgetState();
}

class _PromptMessageInputFormWidgetState
    extends State<PromptMessageInputFormWidget> {
  final _formKey = GlobalKey<FormState>();

  void _handleEnter() {
    final text = widget.textController.text.trim();
    if (text.isNotEmpty) {
      // 处理回车事件
      log('Enter: $text');
      widget.textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 60,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(child: Icon(Icons.cleaning_services_outlined)),
              const SizedBox(width: 8),
              Expanded(
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (event) {
                    if (event is RawKeyUpEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.enter) {
                        if (event.isShiftPressed) {
                          widget.textController.text += '\n';
                        } else {
                          _handleEnter();
                        }
                      }
                    }
                  },
                  child: TextFormField(
                    maxLines: 2,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    controller: widget.textController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      hintText: "Type your message",
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                  child: IconButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    widget.onPressed();
                  }
                },
                icon: const Icon(Icons.send),
              )),
              // const CircleAvatar(child: Icon(Icons.send)),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversationTitleFormWidget extends StatefulWidget {
  const ConversationTitleFormWidget({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<ConversationTitleFormWidget> createState() =>
      _ConversationTitleFormWidget();
}

class _ConversationTitleFormWidget extends State<ConversationTitleFormWidget> {
  @override
  Widget build(BuildContext context) {
    late final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final palmProvider =
        Provider.of<PalmSettingProvider>(context, listen: false);
    var currentTitle = palmProvider.getCurrentConversationTitle;
    return TextFormField(
      controller: widget.controller,
      decoration: const InputDecoration(
        labelText: "Chat Name",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.badge_outlined),
      ),
      style: TextStyle(
          color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter Chat Name';
        }
        return null;
      },
      // style: TextStyle(),
      onChanged: (value) {
        setState(() {
          currentTitle = value.toString();
        });
        palmProvider.setCurrentConversationTitle(value.toString());
      },
      onSaved: (value) {
        currentTitle = value.toString();
        palmProvider.setCurrentConversationTitle(value.toString());
        log("conversation.title: $currentTitle");
      },
    );
  }
}

class ConversationPromptFormWidget extends StatefulWidget {
  const ConversationPromptFormWidget({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<ConversationPromptFormWidget> createState() =>
      _ConversationPromptFormWidget();
}

class _ConversationPromptFormWidget
    extends State<ConversationPromptFormWidget> {
  late final ColorScheme colorScheme = Theme.of(context).colorScheme;
  @override
  Widget build(BuildContext context) {
    final palmProvider =
        Provider.of<PalmSettingProvider>(context, listen: false);
    var currentPrompt = palmProvider.getCurrentConversationPrompt;
    return TextFormField(
      maxLines: 2,
      controller: widget.controller,
      decoration: const InputDecoration(
        labelText: "Prompt",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.tips_and_updates_outlined),
      ),
      style: TextStyle(
          color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
      onChanged: (value) {
        setState(() {
          currentPrompt = value.toString();
        });
        palmProvider.setCurrentConversationPrompt(value.toString());
      },
      onSaved: (value) {
        currentPrompt = value.toString();
        palmProvider.setCurrentConversationPrompt(value.toString());
        log("conversation.prompt: $currentPrompt");
      },
    );
  }
}

class ConversationDescFormWidget extends StatefulWidget {
  const ConversationDescFormWidget({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<ConversationDescFormWidget> createState() =>
      _ConversationDescFormWidget();
}

class _ConversationDescFormWidget extends State<ConversationDescFormWidget> {
  @override
  Widget build(BuildContext context) {
    late final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final palmProvider =
        Provider.of<PalmSettingProvider>(context, listen: false);
    var currentConversation = palmProvider.getCurrentConversationInfo;
    var currentDesc = currentConversation.desc;
    return TextFormField(
      controller: widget.controller,
      decoration: const InputDecoration(
        labelText: "Description",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description_outlined),
      ),
      style: TextStyle(
          color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
      onChanged: (value) {
        setState(() {
          currentDesc = value.toString();
        });
        currentConversation.desc = currentDesc;
        palmProvider.setCurrentConversationInfo(currentConversation);
      },
      onSaved: (value) {
        currentDesc = value.toString();
        currentConversation.desc = currentDesc;
        palmProvider.setCurrentConversationInfo(currentConversation);
        log("conversation.desc: $currentDesc");
      },
    );
  }
}