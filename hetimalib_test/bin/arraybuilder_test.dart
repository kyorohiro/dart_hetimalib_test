import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;

void test_arraybuilder() {
  unit.test("arraybuilder: init", (){
   hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
   unit.expect(0, builder.size());
   unit.expect(0, builder.toList().length);
   unit.expect("", builder.toText());
  });

  unit.test("arraybuilder: senario", (){
   hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
   builder.appendString("abc");
   unit.expect("abc", builder.toText());
   unit.expect(3, builder.toList().length);
   builder.appendString("abc");
   unit.expect("abcabc", builder.toText());
   unit.expect(6, builder.toList().length);
  });
}
