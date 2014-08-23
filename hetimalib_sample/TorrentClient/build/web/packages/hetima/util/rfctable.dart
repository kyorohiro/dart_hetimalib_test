part of hetima;

class RfcTable {
  static String ALPHA_AS_STRING = 
       "abcdefghijklmnopqrstuvwxyz"
      +"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static String DIGIT_AS_STRING = 
      "0123456789";
  static String HEXDIG_AS_STRING = 
      DIGIT_AS_STRING+"ABCDEFabcdef";
  static String RFC3986_UNRESERVED_AS_STRING = 
      ALPHA_AS_STRING+DIGIT_AS_STRING+"-._~";
  static String RFC3986_RESERVED_AS_STRING = 
      GEM_DELIMS_AS_STRING+SUB_DELIMS_AS_STRING+"%";

  static String GEM_DELIMS_AS_STRING = """:/?#[]@""";
  static String SUB_DELIMS_AS_STRING = """!\$&'()*+,;=""";
  static String PCT_ENCODED_AS_STRING = "%"+HEXDIG_AS_STRING;
  static String RFC3986_SUB_DELIMS_AS_STRING = "!\$&'()*+,;=";
  static String RFC3986_PCHAR_AS_STRING = RFC3986_UNRESERVED_AS_STRING+":@"+RFC3986_SUB_DELIMS_AS_STRING+"%";
  static List<int> ALPHA = convert.UTF8.encode(ALPHA_AS_STRING);
  static List<int> DIGIT = convert.UTF8.encode(DIGIT_AS_STRING);
  static List<int> RFC3986_UNRESERVED = convert.UTF8.encode(RFC3986_UNRESERVED_AS_STRING);
  static List<int> RFC3986_RESERVED = convert.UTF8.encode(RFC3986_RESERVED_AS_STRING);
  static List<int> GEM_DELIMS = convert.UTF8.encode(GEM_DELIMS_AS_STRING);
  static List<int> SUB_DELIMS = convert.UTF8.encode(SUB_DELIMS_AS_STRING);
  static List<int> HEXDIG = convert.UTF8.encode(HEXDIG_AS_STRING);
  static List<int> PCT_ENCODED = convert.UTF8.encode(PCT_ENCODED_AS_STRING);
}

class ParseError implements Exception{
}
