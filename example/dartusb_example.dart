import 'package:dartusb/src/libcator.dart';

void main() async {
  var lib = await Libcator().initialize();
  var path = await lib.locate(['libusb-1.0.so']);
  print(path);
}
