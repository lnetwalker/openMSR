{ Demo program showing how to parse Pascal Code and then do something with it..
  IMO this is a cleanly designed parser (IMO much cleaner/simpler than FPDOC and
  Pasdoc parsers or the FP compiler parser, and the Synedit parser.)

  Lars (L505)
  http://z505.com
}

program Project1;
{$APPTYPE CONSOLE}
uses
  pastokenize, ChrStream;


procedure RedirectStdOut(Outputfile: string);
begin
  AssignFile(output, OutputFile);
  rewrite(output);
end;

procedure RestoreStdOut;
begin
  CloseFile(output);
  Assign(output,'');
  rewrite(output);
end;

var
  InChrStrm: TInChrStrm;
  PasParser: TPasParser;
  InChrStrmData: TInChrStrmData;
  PasParserData: TPasParserData;

{ usage: InputFile: the file you want to parse, which contains pascal code
         OutputFile: an output report file }
procedure ParseFile(InputFile: string; OutputFile: string);
var
  s: string;
  token: TPasToken;
begin
  NewInChrStrm(inputfile, InChrStrmData, {result}InChrStrm);
  NewPasParser(InChrStrm, PasParserData, {result} PasParser);

  writeln('debug: redirect1');
  repeat
    writeln('debug: repeat loop1');
    PasParser.Test;
    InChrStrm.test;
    PasParser.GetToken(token, s, PasParserdata, InChrStrmdata);
    writeln('debug: repeat loop2');
    if token = ptKeyword then
      writeln('Keyword: ', s);

    if token =   ptInvalidToken  then
      writeln('Invalid token: ', s);

    if token =   ptIdentifier    then
      writeln('Identifier: ', s);

    if token =   ptString        then
      writeln('String: ', s);

    if token =   ptHexNumber     then
      writeln('Hex Number: ', s);

    if token =   ptNumber        then
      writeln('Number: ', s);

    if token =   ptComment       then
      writeln('Comment: ', s);

    if token =   ptDirective     then
      writeln('Directive: ', s);

    if token =   ptComma         then
      writeln('Comma');

    if token =   ptSemicolon     then
      writeln('Semicolon');

    if token =   ptColon         then
      writeln('Colon');

    if token =   ptPeriod        then
      writeln('Period');

    if token =   ptRange         then
      writeln('Range: ', s);

    if token =   ptEquals        then
      writeln('Equals');

    if token =   ptNotEquals     then
      writeln('Not Equals');

    if token =   ptLess          then
      writeln('Less Than');

    if token =   ptLessEqual     then
      writeln('Less Than Or Equal');

    if token =   ptGreater       then
      writeln('Greater Than');

    if token =   ptGreaterEqual  then
      writeln('Greater Than Or Equal');

    if token =   ptAssign        then
      writeln('Assigning');

    if token =   ptOpenParen     then
      writeln('Parenthesis Opened');

    if token =   ptCloseParen    then
      writeln('Parenthesis Closed');

    if token =   ptOpenBracket   then
      writeln('Bracket Opened');

    if token =   ptCloseBracket  then
      writeln('Bracket Closed');

    if token =   ptCaret         then
      writeln('Caret');

    if token =   ptHash          then
      writeln('Hash: ', s);

    if token =   ptAddress       then
      writeln('Address: ', s);

    if token =   ptPlus          then
      writeln('PLUS');

    if token =   ptMinus         then
      writeln('MINUS');

    if token =   ptMultiply      then
      writeln('MULTIPLIED BY');

    if token =   ptWhitespace    then
      writeln('WHITESPACE');

    if token =   ptDivide        then
      writeln('DIVIDE BY');

    if token =   ptEndOfFile     then
    begin
      writeln('------------------------------------------------------');
      writeln('  End of File');
      writeln('------------------------------------------------------');
    end;

  until token = ptEndOfFile; // done



  FreePasParser(PasParser, PasParserdata);
  FreeInChrStrm(InChrStrm, InChrStrmData);

end;


begin
  // redirect STDOUT to text file
  //  RedirectStdOut(OutputFile);

  ParseFile('test.txt', 'output.txt');

  writeln(output, 'done parsing, <enter> to exit');
//  RestoreStdOut;
  readln;
end.