import 'package:unittest/unittest.dart';
import 'package:panther/lexer.dart';

void main() {
  group('regexps', () {
    group('expressionRegExp', () {
      test('', () {
        String string = '{{ x }}';
        Match match = expressionRegExp.firstMatch(string);
        expect(match.group(0), equals(string));
      });
      
      test('with newline', () {
        String string = '{{ x\ny }}';
        Match match = expressionRegExp.firstMatch(string);
        expect(match.group(0), equals(string));
      });
      
      test('with non-alphaNum chars', () {
        String string = '{{ foo.bar().first }}';
        Match match = expressionRegExp.firstMatch(string);
        expect(match.group(0), equals(string));
      });
      
      test('with extra whitespace', () {
        String string = '{{ \t\nx\s }}';
        Match match = expressionRegExp.firstMatch(string);
        expect(match.group(0), equals(string));
      });
    });
    
    group('ifStartRegExp', () {
      test('', () {
        String string = '{% if foo.bar() != null %}';
        Match match = ifStartRegExp.firstMatch(string);
        expect(match.group(0), equals(string));
      });
      
      test('with newline', () {
        String string = '{% if x\n.y()\n.z() %}';
        Match match = ifStartRegExp.firstMatch(string);
        expect(match.group(0), equals(string));
      });
      
      test('with extra whitespace', () {
        String string = '{% \tif x\t %}';
        Match match = ifStartRegExp.firstMatch(string);
        expect(match.group(0), equals(string));
      });
      
      test('with endif block', () {
        String string = '{% if foo %}';
        Match match = ifStartRegExp.firstMatch(string + '{% endif %}');
        expect(match.group(0), equals(string));
      });
      
      group('ifEndRegExp', () {
        test('', () {
          String string = '{% endif %}';
          Match match = ifEndRegExp.firstMatch(string);
          expect(match.group(0), equals(string));
        });
        
        test('with extra whitespace', () {
          String string = '{%  \tendif \t%}';
          Match match = ifEndRegExp.firstMatch(string);
          expect(match.group(0), equals(string));
        });
      });
      
      group('forStartRegExp', () {
        test('', () {
          String string = '{%  for item in items %}';
          Match match = forStartRegExp.firstMatch(string);
          expect(match.group(0), equals(string));
        });
        
        test('with newlines', () {
          String string = '{%  for item in ite\nms %}';
          Match match = forStartRegExp.firstMatch(string);
          expect(match.group(0), equals(string));  
        });
        
        test('with extra whitespace', () {
          String string = '{%  for item in items %}';
          Match match = forStartRegExp.firstMatch(string);
          expect(match.group(0), equals(string));
        });
      });
      
      group('forEndRegExp', () {
        test('', () {
          String string = '{% endfor %}';
          Match match = forEndRegExp.firstMatch(string);
          expect(match.group(0), equals(string));
        });
        
        test('with extra whitespace', () {
          String string = '{%  \tendfor \t%}';
          Match match = forEndRegExp.firstMatch(string);
          expect(match.group(0), equals(string));
        });
      });
    });
  });
  
  group('tokenize', () {
    group('with default types', () {
      test('with a default type', () {
        var tokens = tokenize('p');
        expect(tokens.first['value'], equals('p'));
        expect(tokens.first['type'], equals('default'));
      });
    });
    
    group('with an expression', () {
      test('', () {
        var tokens = tokenize('{{ x }}');
        expect(tokens.first['value'], equals('{{ x }}'));
        expect(tokens.first['type'], equals('expression')); 
      });
      
      test('nested', () {
        var tokens = tokenize('a{{ x }}a');
        expect(tokens.length, equals(3));
        expect(tokens[1]['value'], equals('{{ x }}'));
        expect(tokens[1]['type'], equals('expression')); 
      });
      
      test('badly formed', () {
        var tokens = tokenize('{{ x }');
        expect(tokens.length, equals(6));
        List types = tokens.map((token) => token['type']).toList();
        expect(types, everyElement(equals('default')));
      });
    });
    
    group('with an if block', () {
      test('', () {
        ifCount = 0;
        forCount = 0;
        String conditional = '{% if x != null %}';
        var tokens = tokenize(conditional + '{% endif %}');
        
        expect(tokens.first['value'], equals(conditional));
        expect(tokens.first['type'], equals('ifStart')); 
      });
      
      test('with a missing endif', () {
        String conditional = '{% if x != null %}';
        expect(() => tokenize(conditional), throws);
      });
    });
    
    group('with a for block', () {
      test('', () {
        ifCount = 0;
        forCount = 0;       
        
        String loop = '{% for item in items %}';
        var tokens = tokenize(loop + '{% endfor %}');
        
        expect(tokens.first['value'], equals(loop));
        expect(tokens.first['type'], equals('forStart')); 
      });
      
      test('with a missing endfor', () {
        String loop = '{% for item in items %}';
        expect(() => tokenize(loop), throws);
      });
    });
  });
}