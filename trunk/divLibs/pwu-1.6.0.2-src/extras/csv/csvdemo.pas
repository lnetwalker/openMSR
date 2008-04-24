{ CsvUtils505 demo

  Mote: relies on strwrap1, it is available in freepascal contributed units section 

  Author,
  Lars (L505)
  http://z505.com
  }

program CsvDemo; {$ifdef fpc}{$mode objfpc} {$H+}{$endif}

uses
  csvutils505,
  strwrap1,
  capstr;

const
  LF = #10;

// CSV ansistring 
procedure Example1;
var
  newstr: string = '';
begin
  CsvAddCell('test', newstr, ',', '"');
  CsvAddCell('testing 123', newstr, ',', '"');
  CsvAddCell('testing "and" 456', newstr, ',', '"');
  CsvStartNewRow(newstr, ',');
  CsvAddCell('tester', newstr, ',', '"');
  CsvStartNewRow(newstr, ',');
  CsvAddCell('testing12345', newstr, ',', '"');
  CsvAddCell('testing345', newstr, ',', '"');
  CsvAddCell('multi line '#10'cell is here', newstr, ',', '"');
  CsvAddCell('multi and another multiline '#10'cell is here', newstr, ',', '"');
  CsvEnd(newstr, ',');
  writeln(newstr);

  strsavefile('testcsv.csv', newstr);
  writeln;
  writeln('Done example 1, hit enter');
  writeln;
  readln;
end;

// capstring is much more effecient than an ansistring
procedure Example2;
var
  newstr: TCapstr;
begin
  capstr.resetbuf(@newstr);
  CsvAddCell('test', newstr, ',', '"');
  CsvAddCell('testing 123', newstr, ',', '"');
  CsvAddCell('testing "and" 456', newstr, ',', '"');
  CsvStartNewRow(newstr, ',');
  CsvAddCell('tester', newstr, ',', '"');
  CsvStartNewRow(newstr, ',');
  CsvAddCell('testing12345', newstr, ',', '"');
  CsvAddCell('testing345', newstr, ',', '"');
  CsvAddCell('multi line '#10'cell is here', newstr, ',', '"');
  CsvAddCell('multi and another multiline '#10'cell is here', newstr, ',', '"');
  CsvEnd(newstr, ',');
  writeln(newstr.data);

  strsavefile('testcsv.csv', newstr.data);
  writeln;
  writeln('Done example 2');
  writeln;
end;


begin
  writeln('Demo');
  writeln;
  Example1;
  Example2;
  writeln('(Done program. hit enter)');
  readln;
end.