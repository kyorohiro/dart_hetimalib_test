import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'dart:typed_data' as type;
import  'dart:convert' as convert;

void test_bencode() {
  unit.test("bencode: string", (){
    type.Uint8List out = hetima.Bencode.encode("test");
    unit.expect("4:test", convert.UTF8.decode(out.toList()));
    type.Uint8List text = hetima.Bencode.decode(out);
    unit.expect("test", convert.UTF8.decode(text.toList()));
  });

}