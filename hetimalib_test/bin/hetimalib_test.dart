import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'arraybuilder_test.dart' as arraybuilder_test;
import 'bencode_test.dart' as bencode_test;

void main() {
  unit.test("uuid", (){ 
     String id = hetima.Uuid.createUUID();
     print(id);
     unit.expect("","");
  });
  arraybuilder_test.test_arraybuilder();
  bencode_test.test_bencode();
}

