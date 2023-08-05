// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'author.dart';
import 'bot_command.dart';
import 'classes.dart';
import 'lessons.dart';

// Configure routes.
final _router = Router()
  ..get('/greating', _greating)
  ..get('/authors', _authors)
  ..get('/author/<phone>', _author)
  ..get('/commands', commands)
  ..post('/command/<phone>/<command>', _command)
  ..get('/all-lessons', allLessons)
  ..get('/month-lessons', monthLessons)
  ..get('/lesson/<lessonName>', _lesson);

// DONE
Response _greating(Request req) {
  return Response.ok(greatingMsg);
}

// DONE
Response _author(Request req) {
  final phone = req.params['phone'];
  var author = authors[phone];
  if (author != null) {
    return Response.ok(author.show());
  }
  return Response.notFound('لقيتو مافي والله');
}

// DONE
Future<Response> _command(Request req) async {
  final command = req.params['command'];
  final phone = req.params['phone'];
  var body = utf8.decode(await req.read().first);
  try {
    var r = await BotCommand.excuteCommand(phone!, command!, body);
    return Response.ok(r);
  } catch (e, s) {
    print(e);
    print(s);
    return Response.internalServerError(body: 'FATAL ERROR: $e');
  }
}

// DONE
Response _lesson(Request req) {
  final _lesson = req.params['lessonName'];
  var lesson = lessonsById[_lesson?.toLowerCase()];
  if (lesson != null) {
    return Response.ok(lesson.show());
  } else {
    lesson = lessonsByTitle[_lesson?.toLowerCase()];
    if (lesson != null) {
      return Response.ok(lesson.show());
    }
  }
  return Response.notFound('لقيتو مافي والله');
}

// DONE
Response _authors(Request req) {
  return Response.ok(Author.showAll());
}

// DONE
Response allLessons(Request req) {
  return Response.ok(Lesson.showAll(LessonsCount.all));
}

// DONE
Response monthLessons(Request req) {
  return Response.ok(Lesson.showAll(LessonsCount.thisMonth));
}

// DONE
Response commands(Request req) {
  return Response.ok(BotCommand.showAll());
}

void main(List<String> args) async {
  var _lessonsFile = File(lessonsFile);
  if (!_lessonsFile.existsSync()) _lessonsFile.createSync();
  var _authorsFile = File(authorsFile);
  if (!_authorsFile.existsSync()) _authorsFile.createSync();
  await loadAuthors();
  await loadLessons();
  BotCommand.loadCommands();

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8185');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}

