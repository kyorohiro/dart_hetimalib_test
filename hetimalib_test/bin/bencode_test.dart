import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;

void test_bencode() {

  unit.test("bencode: string", () {
    type.Uint8List out = hetima.Bencode.encode("test");
    unit.expect("4:test", convert.UTF8.decode(out.toList()));
    type.Uint8List text = hetima.Bencode.decode(out);
    unit.expect("test", convert.UTF8.decode(text.toList()));
  });

  unit.test("bencode: number", () {
    {
      type.Uint8List out = hetima.Bencode.encode(1024);
      unit.expect("i1024e", convert.UTF8.decode(out.toList()));
      num ret = hetima.Bencode.decode(out);
      unit.expect(1024, ret);
    }
    {
      type.Uint8List out = hetima.Bencode.encode(-10.24);
      unit.expect("i-10.24e", convert.UTF8.decode(out.toList()));
      num ret = hetima.Bencode.decode(out);
      unit.expect(-10.24, ret);
    }
  });

  unit.test("bencode: list", () {
    {
      List l = new List();
      l.add("test");
      l.add(1024);
      type.Uint8List out = hetima.Bencode.encode(l);
      unit.expect("l4:testi1024ee", convert.UTF8.decode(out.toList()));

      List list = hetima.Bencode.decode(out);
      unit.expect("test", convert.UTF8.decode(list[0].toList()));
      unit.expect(1024, list[1]);
    }
  });

  unit.test("bencode: dictionary", () {
    {
      Map<String, Object> m = new Map();
      m["test"] = "test";
      m["value"] = 1024;
      type.Uint8List out = hetima.Bencode.encode(m);
      unit.expect("d4:test4:test5:valuei1024ee", convert.UTF8.decode(out.toList()));

      Map me = hetima.Bencode.decode(out);
      unit.expect("test", convert.UTF8.decode(me["test"].toList()));
      unit.expect(1024, me["value"]);

    }
  });

}
