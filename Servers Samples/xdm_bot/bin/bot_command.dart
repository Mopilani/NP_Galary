import 'dart:async';
import 'dart:convert';

import 'author.dart';
import 'classes.dart';

class BotCommand {
  final String command, descripton, usage;
  final FutureOr<String> Function(String arg, String arg2, dynamic body)
      function;
  final UserChatState? neededState;

  BotCommand(
    this.command,
    this.descripton,
    this.usage,
    this.function,
    this.neededState,
  );

  String show() => '''!$command
  $descripton
  $usage
  ${neededState?.name}''';

  static String showAll() {
    var commands = <BotCommand>[];
    commands.addAll(Lesson.commands);
    commands.addAll(Author.commands);
    var commandsMsg = '';
    for (var command in commands) {
      commandsMsg = '$commandsMsg${command.show()}\n';
    }
    return commandsMsg;
  }

  static final Map<String, BotCommand> commandsMap = {};

  static void loadCommands() {
    for (var command in Lesson.commands) {
      commandsMap.addAll({command.command: command});
    }
    for (var command in Author.commands) {
      commandsMap.addAll({command.command: command});
    }
  }

  static Future<String> excuteCommand(
    String authroId,
    String command,
    dynamic body,
  ) async {
    print('Body: $body');
    try {
      body = json.decode(body);
    } catch (e) {
      //
    }
    BotCommand? botCommand;
    try {
      // if (command.contains(':')) {
      //   botCommand = BotCommand.commandsMap[command.split(':').first];
      //   botCommand ??= BotCommand.commandsMap[command];
      // } else {
      botCommand = BotCommand.commandsMap[command];
      // }
      // return '';
    } catch (e) {
      return 'Command $command Not Found $e';
    }
    if (botCommand == null) {
      return 'Command $command Not Found';
    } else {
      if (userChatStates[authroId] == null) {
        userChatStates[authroId] = {
          'state': UserChatState.normalMode,
          'lsId': null,
        };
      }
      if (userChatStates[authroId]!['state'] == botCommand.neededState ||
          botCommand.neededState == UserChatState.all ||
          botCommand.neededState == null) {
        return await botCommand.function(authroId, command, body);
      } else {
        return 'userChatStates: $userChatStates\n'
            '\n'
            'Your Current State is ${userChatStates[authroId]!['state']}, You need to enter the ${botCommand.neededState?.name}';
      }
    }
  }
}
