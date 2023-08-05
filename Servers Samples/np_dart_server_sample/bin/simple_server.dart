import 'dart:io';
import 'dart:math';

Future<void> main(List<String> args) async {
  // getStartIndex() {
  // }
  // var fileSize = 16000000;
  // var expectedChunkes = fileSize / 262144;
  // print(
  //     'Expected Chunkes: $expectedChunkes ~ ${expectedChunkes.ceilToDouble()}');
  // var start = 1230500;
  // var end = 2230500;
  // var chunkSize = 262144;
  // start = chunkSize * 0 + 1;
  // end = chunkSize * 4 + chunkSize - 1;

  // var rest = start % chunkSize;
  // var skipCount = (start - rest) / chunkSize;
  // // print('The rest: $rest -- Chunkes Count: $chunkesCount');
  // // var skipCount = chunkesCount;
  // print('Skip Count: $skipCount Chunkes @ $rest');
  // var endRest = end % chunkSize;
  // var limitCount = (end - endRest) / chunkSize;
  // limitCount = limitCount - skipCount;
  // // print('The rest: $rest -- Chunkes Count: $chunkesCount');
  // print(
  //     'Limit Count: $limitCount + $endRest ${endRest > 0 ? 'At Next Chunk' : ''}');

  // exit(0);

  var server = await HttpServer.bind('0.0.0.0', 80);

  List getRangeValue(String str) {
    var _str = str.substring('bytes='.length);
    var range = _str.split('-');
    if (range[1].isNotEmpty) {
      return [int.parse(range[0]), int.parse(range[1])];
    }
    // var _str = str.substring('bytes='.length, str.length - 1);
    return [int.parse(range[0])];
  }

  // print(getRangeValue('bytes=43253760-'));
  // return null;

  server.listen((req) async {
    print(req.headers);
    req.response.statusCode = HttpStatus.partialContent;

    // var file =
    //     File(r'G:\MoVideos\Raider464 vs Subscribers (FFA)(1080P_60FPS).mp4');
    // var file =
    //     File(r'C:\Users\Mopilani\Videos\Animated Backgrounds\Blue - 27239.wmv');
    var file = File(
        r'C:\Users\Mopilani\Downloads\Compressed\pycharm-community-2023.1.2.tar.gz');
    // var file = File(r'F:\Videos\Saigon Vietnam at Night - Short Clip - Free HD Stock Footage (No Copyright) Travel City Lights(720P_HD).mp4');
    // var file = File(r'js_server\Kimetsu.mp4');
    var fileSize = (await file.stat()).size;
    print('FileSize: $fileSize');

    var chunkSize = 1000000;
    var start = 0;
    var end = 0;

    if (req.headers.value(HttpHeaders.rangeHeader) != null) {
      var range = getRangeValue(req.headers.value(HttpHeaders.rangeHeader)!);
      if (range.length == 2) {
        start = range[0];
        end = range[1];
      } else {
        start = range[0];
      }
    }
    // end = min(start + chunkSize, fileSize);
    end = fileSize;

    var stream = file.openRead(start, end);

    // req.response.headers.add(HttpHeaders.contentTypeHeader, 'video/mp4');
    // req.response.headers
    //     .add(HttpHeaders.contentTypeHeader, 'multipart/form-data');
    req.response.headers
        .add(HttpHeaders.contentTypeHeader, ContentType.binary.mimeType);
    req.response.headers.add(HttpHeaders.acceptRangesHeader, 'bytes');
    req.response.headers.add(HttpHeaders.contentLengthHeader, end - start);
    req.response.headers
        .add(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$fileSize');
    print('Response: ========> Status Code: ');
    print(req.response.statusCode);
    print('Response: ========> Headers: ');
    print(req.response.headers);
    await req.response.addStream(stream);
    // Stream.fromIterable(List.generate(
    //   10,
    //   (index) => List.generate(1000 * 100, (index) => 128),
    // )),

    await req.response.close();
  });

  print('Serving...');
}
