library lexer;

final RegExp expressionRegExp = new RegExp(r'^{{\s+[\s\S]+?\s+}}');
final RegExp ifStartRegExp = new RegExp(r'^{%\s+if\s+[\s\S]+?\s+%}');
final RegExp ifEndRegExp = new RegExp(r'^{%\s+endif\s+%}');
final RegExp forStartRegExp = new RegExp(r'^{%\s+for\s+\w+?\s+in[\s\S]+?\s+%}');
final RegExp forEndRegExp = new RegExp(r'^{%\s+endfor\s+%}');

final Map<String,RegExp> rules = {                       
  'expression' : expressionRegExp,
  'ifStart'    : ifStartRegExp,
  'ifEnd'      : ifEndRegExp,
  'forStart'   : forStartRegExp,
  'forEnd'     : forEndRegExp
};

num ifCount = 0;
num forCount = 0;

// TODO: need line numbers.

void adjustKeysCount(key) {
  if (key == 'ifStart') {
    ifCount += 1;
  } else if (key == 'ifEnd') {  
    ifCount -= 1;
  } else if (key == 'forStart') {
    forCount += 1;
  } else if (key == 'forEnd') {
    forCount -= 1;
  }
}

List<String> tokenize(String string) {
  List<String> tokens = [];
  
  while(!string.isEmpty) {

    bool tokenized = false;
    for (String key in rules.keys) {
      Match match = rules[key].firstMatch(string);
      if (match != null) {
        tokens.add({'value': match.group(0), 'type': key});
        adjustKeysCount(key);
        string = string.substring(match.group(0).length);
        tokenized = true;
        break;
      }
    }
    if (!tokenized) {
      tokens.add({'value': string[0], 'type': 'default'});
      string = string.substring(1);
    }
  }
  
  // TODO: more granular exception messages.
  if (ifCount != 0) throw "missing {{ endif }}";
  if (forCount != 0) throw "missing {{ endfor }}";
  
  return tokens;
}