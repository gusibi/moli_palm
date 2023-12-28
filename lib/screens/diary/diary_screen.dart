import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moli_ai/constants/api_constants.dart';
import 'package:moli_ai/dto/ai_service_dto.dart';
import 'package:moli_ai/services/services.dart';
import 'package:sprintf/sprintf.dart';

import 'package:moli_ai/constants/constants.dart';
import 'package:moli_ai/providers/diary_privider.dart';
import 'package:provider/provider.dart';

import '../../models/config_model.dart';
import '../../models/conversation_model.dart';
import '../../providers/palm_priovider.dart';
import '../../repositories/configretion/config_repo.dart';
import '../../repositories/conversation/conversation.dart';
import '../../repositories/conversation/conversation_message.dart';
import '../../utils/color.dart';
import '../../widgets/conversation_widget.dart';
import '../../widgets/form/form_widget.dart';

class DiaryScreen extends StatefulWidget {
  final ConversationModel diaryData;

  const DiaryScreen({
    super.key,
    required this.diaryData,
  });

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late final _colorScheme = Theme.of(context).colorScheme;
  late final _backgroundColor = _colorScheme.background;

  late TextEditingController textEditingController;
  final _scrollController = ScrollController();
  late ConversationModel currentDiary;
  late String currentDay = '${DateTime.now().day}';
  List<ConversationMessageModel> _messageList = [];
  bool _isTyping = false;

  void _queryConversationMessages() async {
    _messageList =
        await ConversationMessageRepo().getMessages(currentDiary.id, 0);
    setState(() {
      _messageList = _messageList;
    });
  }

  void _initDefaultConfig() async {
    final palmProvider = Provider.of<AISettingProvider>(context, listen: false);
    var configMap = await ConfigReop().getAllConfigsMap();
    ConfigModel? conf = configMap[palmConfigname];

    if (conf != null) {
      final palmConfig = conf.toPalmConfig();
      palmProvider.setBasePalmURL(palmConfig.basicUrl);
      palmProvider.setPalmApiKey(palmConfig.apiKey);
      palmProvider.setCurrentPalmModel(palmConfig.modelName);
    }
    conf = configMap[azureConfigname];
    if (conf != null) {
      final azureConfig = conf.toAzureConfig();
      palmProvider.setAzureOpenAIConfig(azureConfig);
    }

    ConfigModel? defaultAIConf = configMap[defaultAIConfigname];
    if (defaultAIConf != null) {
      final defaultAI = defaultAIConf.toDefaultAIConfig();
      palmProvider.setDiaryAI(defaultAI.diaryAI);
    }
  }

  Future<void> _initDiary() async {
    setState(() {
      currentDiary = widget.diaryData.copy();
    });
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
    if (currentDiary.id == 0) {
      final title =
          '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
      // get diary by title
      ConversationModel? cnv =
          await ConversationReop().getConversationById(currentDiary.id);
      if (cnv == null) {
        // create new
        ConversationModel cnv = newDiaryConversation;
        log("cnv $cnv");
        cnv.title = title;
        int id = await ConversationReop().createConversation(cnv);
        cnv.id = id;
        currentDiary = cnv;
      } else {
        currentDiary = cnv;
      }
      diaryProvider.setCurrentDiaryInfo(currentDiary);
    } else {
      ConversationModel? cnv =
          await ConversationReop().getConversationById(currentDiary.id);
      if (cnv != null) {
        currentDiary = cnv;
      }
    }
    setState(() {
      currentDiary = currentDiary;
      List<String> dateList = currentDiary.title.split('-');
      currentDay = dateList[2];
    });
  }

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
    _initDiary();
    _queryConversationMessages();
    _initDefaultConfig();
  }

  void _hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /*这段代码的作用是将滚动条滚动到 ScrollController 的最底部位置。
  具体来说，它使用 animateTo() 方法来滚动到指定位置。
  _scrollController.position.maxScrollExtent 表示滚动条的最大位置，即最底部位置。
  duration 属性表示滚动的持续时间，这里设置为 const Duration(milliseconds: 1)，表示在 1 毫秒内完成滚动。
  curve 属性表示滚动的动画曲线，这里使用 Curves.easeOut，表示使用缓出的动画效果。
  */
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 1),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    late final backgroundColor = Color.alphaBlend(
        _colorScheme.primary.withOpacity(0.14), colorScheme.surface);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        automaticallyImplyLeading: false,
        // backgroundColor: colorScheme.primary,
        shadowColor: getShadowColor(colorScheme),
        flexibleSpace: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  // color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              CircleAvatar(
                child: Text(currentDay),
              ),
              const SizedBox(
                width: 12,
              ),
              const Expanded(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Diary",
                        style: TextStyle(
                            // color: colorScheme.onPrimary,
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  summaryDaily(context);
                },
                icon: const Icon(Icons.directions_run),
                // color: colorScheme.onSecondary,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: GestureDetector(
          onTap: () => _hideKeyboard(context),
          child: Align(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messageList.length,
                    itemBuilder: (context, index) {
                      return ConversationMessageWidget(
                          conversation: _messageList[index]);
                    },
                  ),
                ),
                PromptMessageInputFormWidget(
                    textController: textEditingController,
                    leftOnPressed: () {
                      resetDiaryMessage(context);
                      _hideKeyboard(context);
                    },
                    sendOnPressed: () {
                      if (_isTyping) {
                        log("asking");
                      } else {
                        saveNoteMessage(context);
                        _hideKeyboard(context);
                      }
                    }),
              ],
            ),
          )),
    );
  }

  Future<List<String>> sendMessageByTextApi(
      String diaryMessage, ConversationModel currentConversation) async {
    final aiSettingProvider =
        Provider.of<AISettingProvider>(context, listen: false);
    String prompt = sprintf(diaryPrompt, [diaryMessage]);
    var aiService = PALM_SERVICE;
    var modelName = "";
    var basicUrl = "";
    var apiKey = "";
    var defaultAI = aiSettingProvider.getDiaryAI;
    if (defaultAI == defaultAIAzure) {
      aiService = AZURE_SERVICE;
      modelName = aiSettingProvider.getAuzreOpenAIConfig.modelName;
      basicUrl = aiSettingProvider.getAuzreOpenAIConfig.basicUrl;
      apiKey = aiSettingProvider.getAuzreOpenAIConfig.apiKey;
    } else if (defaultAI == defaultAIOpenAI) {
      aiService = OPENAI_SERVICE;
    } else {
      aiService = PALM_SERVICE;
      modelName = aiSettingProvider.getCurrentPalmModel;
      basicUrl = aiSettingProvider.getBasePalmURL;
      apiKey = aiSettingProvider.getPalmApiKey;
    }
    TextAIMessageReq req = TextAIMessageReq(
      aiService: aiService,
      prompt: prompt,
      messages: [
        ChatMessageData(content: diaryPrompt, role: roleSys),
        ChatMessageData(content: diaryMessage, role: roleUser)
      ],
      modelName: modelName,
      basicUrl: basicUrl,
      apiKey: apiKey,
      temperature: 0.7,
      apiVersion: aiSettingProvider.getAuzreOpenAIConfig.apiVersion,
      maxOutputTokens: 4096 - prompt.length,
    );
    final response = await AIApiService.getTextReponse(req);
    var chatRole = roleAI;
    var message = "";
    if (response.error != null && response.error!.code != 0) {
      chatRole = roleSys;
      message = response.error!.message;
    } else if (response.candidates!.isNotEmpty) {
      message = response.candidates![0].message!.content;
    }
    return [chatRole, message];
  }

  Future<void> summaryDaily(BuildContext context) async {
    // get diary message
    try {
      List<ConversationMessageModel> messageList =
          await ConversationMessageRepo().getMessages(currentDiary.id, 0);
      var message = '';
      for (var i = 0; i < messageList.length; i++) {
        if (messageList[i].role == roleAI) {
          continue;
        }
        if (messageList[i].role == roleSys) {
          if (messageList[i].message == "diary reset") {
            message = "";
          }
          continue;
        }
        message += "${messageList[i].message}\n";
      }
      List<String> result;
      var chatRole = roleAI;
      result = await sendMessageByTextApi(message, currentDiary);
      chatRole = result[0];
      message = result[1];
      ConversationMessageModel aiMessage = await ConversationMessageRepo()
          .createMessageWithRole(chatRole, message, currentDiary.id, 0);
      setState(() {
        messageList.add(aiMessage);
        _messageList = messageList;
        _isTyping = false;
      });
    } catch (error) {
      log("error $error");
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  Future<void> saveNoteMessage(BuildContext context) async {
    String text = textEditingController.text;
    String trimmedText = text.trimRight();
    ConversationMessageModel userMessage = await ConversationMessageRepo()
        .createUserMessage(trimmedText, currentDiary.id);
    setState(() {
      _messageList.add(userMessage);
      _isTyping = false;
      textEditingController.clear();
    });
  }

  Future<void> resetDiaryMessage(BuildContext context) async {
    ConversationMessageModel sysMessage = await ConversationMessageRepo()
        .createSysMessage("diary reset", currentDiary.id);
    setState(() {
      _messageList.add(sysMessage);
      _isTyping = false;
      textEditingController.clear();
    });
  }
}
