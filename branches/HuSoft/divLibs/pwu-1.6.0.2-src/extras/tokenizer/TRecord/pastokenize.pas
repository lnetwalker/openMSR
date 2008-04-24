{
 Pascal tokenizer for general purpose parsing of Pascal code. Derived from the
 ideas of Julian Bucknall's Pascal tokenizer and Thaddy de Koning's kolpastok.

 Authors: Lars(L505)
          http://z505.com

 Version: 1.0a
}
unit PasTokenize;

interface

uses
  compactutils,
  ChrStream;

type
  TPasToken = (
    ptInvalidToken,  {..invalid syntax, token, or an error occured }
    ptEndOfFile,     {..end of file}
    ptKeyword,       {..keyword, i.e. if, while, do, ... }
    ptIdentifier,    {..identifier, i.e. words that aren't language keywords }
    ptString,        {..string or character constant }
    ptHexNumber,     {..number in hex, starts with $ }
    ptNumber,        {..sequence of digits, maybe with radix point }
    ptComment,       {..comment, any type }
    ptDirective,     {..Compiler directive or conditional }
    ptComma,         {..comma: , }
    ptSemicolon,     {..semicolon: ; }
    ptColon,         {..colon: : }
    ptPeriod,        {..period: . }
    ptRange,         {..range: .. }
    ptEquals,        {..equals char: = }
    ptNotEquals,     {..not equals: <> }
    ptLess,          {..less than: < }
    ptLessEqual,     {..less than or equal: <= }
    ptGreater,       {..greater than: > }
    ptGreaterEqual,  {..greater than or equal: >= }
    ptAssign,        {..assignment: := }
    ptOpenParen,     {..open parenthesis: ( }
    ptCloseParen,    {..close parenthesis: ) }
    ptOpenBracket,   {..open bracket: [ }
    ptCloseBracket,  {..close bracket: ] }
    ptCaret,         {..caret: ^ }
    ptHash,          {..hash: # }
    ptAddress,       {..ampersand: @ }
    ptPlus,          {..addition: + }
    ptMinus,         {..subtraction: - }
    ptMultiply,      {..multiplication: * }
    ptWhitespace,    { #1..#32 }
    ptDivide);       {..division: /}

{-- private Parser data -------------------------------------------------------}
{
type
  PPasParserData = ^TPasParserData;
  TPasParserData = record
     FInStrm: PInChrStrm;
     FKeywords: PStrlist;
  end;
}
{------------------------------------------------------------------------------}


{-- public parser -------------------------------------------------------------}
type
  TPasParserData = record
     FInStrm: TInChrStrm;
     FKeywords: PStrlist;
  end;

//  PPasParser = ^TPasParser;
  TPasParser = record
//    data: TPasParserData;
    GetToken: procedure(var ATokenType: TPasToken; var AToken: string;
      var ParserSelf: TPasParserData; var self: TInChrStrmData);
    Test: procedure;
  end;
{------------------------------------------------------------------------------}


procedure GetaToken(var aInStm: TInChrStrm; var aTokenType: TPasToken;
  var aToken: string; var self: TInChrStrmData);

procedure NewPasParser(var aInStm: TInChrStrm; var self: TPasParserData;
  var Result: TPasParser);
procedure FreePasParser(var PasParser: TPasParser; var self: TPasParserData);

implementation

{-- private unit data ---------------------------------------------------------}
const
  KeywordCount = 106;
  KeywordList : array [0..pred(KeywordCount)] of string = (
    {reserved words}
    'AND', 'ARRAY', 'AS', 'ASM', 'BEGIN', 'CASE', 'CLASS', 'CONST',
    'CONSTRUCTOR', 'DESTRUCTOR', 'DISPINTERFACE', 'DIV', 'DO',
    'DOWNTO', 'ELSE', 'END', 'EXCEPT', 'EXPORTS', 'FILE',
    'FINALIZATION', 'FINALLY', 'FOR', 'FUNCTION', 'GOTO', 'IF',
    'IMPLEMENTATION', 'IN', 'INHERITED', 'INITIALIZATION', 'INLINE',
    'INTERFACE', 'IS', 'LABEL', 'LIBRARY', 'MOD', 'NIL', 'NOT',
    'OBJECT', 'OF', 'OR', 'OUT', 'PACKED', 'PROCEDURE', 'PROGRAM',
    'PROPERTY', 'RAISE', 'RECORD', 'REPEAT', 'RESOURCESTRING', 'SET',
    'SHL', 'SHR', 'STRING', 'THEN', 'THREADVAR', 'TO', 'TRY', 'TYPE',
    'UNIT', 'UNTIL', 'USES', 'VAR', 'WHILE', 'WITH', 'XOR',
    {directives}
    'ABSOLUTE', 'ABSTRACT', 'ASSEMBLER', 'AUTOMATED', 'CDECL',
    'CONTAINS', 'DEFAULT', 'DISPID', 'DYNAMIC', 'EXPORT', 'EXTERNAL',
    'FAR', 'FORWARD', 'IMPLEMENTS', 'INDEX', 'MESSAGE', 'NAME',
    'NEAR', 'NODEFAULT', 'OVERLOAD', 'OVERRIDE', 'PACKAGE', 'PASCAL',
    'PRIVATE', 'PROTECTED', 'PUBLIC', 'PUBLISHED', 'READ', 'READONLY',
    'REGISTER', 'REINTRODUCE', 'REQUIRES', 'RESIDENT', 'SAFECALL',
    'STDCALL', 'STORED', 'VIRTUAL', 'WRITE', 'WRITEONLY',
    {others}
    'AT', 'ON'
    );
{------------------------------------------------------------------------------}

{--- TESTS --------------------------------------------------------------------}
procedure Test;
begin
  writeln('PASPARSER TEST SUCCESSFUL');
end;
{------------------------------------------------------------------------------}

{--- protected methods --------------------------------------------------------}

procedure ppInitKeywords(var self: TPasParserData);
var
  i : integer;
begin
  Assert(self.FKeywords <> nil, 'ppInitKeywords can''t be called with nil Stringlist');
  for i := 0 to pred(KeywordCount) do
    self.FKeywords.Add(KeyWordList[i]);
   self.FKeywords.sort(True);
end;

{------------------------------------------------------------------------------}


{-- public methods ------------------------------------------------------------}

procedure GetToken(var ATokenType: TPasToken; var AToken: string;
  var ParserSelf: TPasParserData; var self: TInChrStrmData);
var
  DummyObj: Integer;
begin
  GetaToken(parserself.FInStrm, aTokenType, aToken, self);
  if (aTokenType = ptIdentifier) then
    if parserself.FKeywords.Find(UpperCase(aToken), DummyObj) then
      aTokenType:= ptKeyword;
end;

procedure NewPasParser(var aInStm: TInChrStrm; var self: TPasParserData;
  var Result: TPasParser);
begin
  { create }
//  new(Result);
  result.GetToken:= GetToken;
  result.Test:= Test;

  { save the stream }
  self.FInStrm := aInstm;
  { create the keywords list }
  self.FKeywords := NewstrList;
  ppInitKeywords(self);
end;

procedure FreePasParser(var PasParser: TPasParser; var self: TPasParserData);
begin
  { destroy the keywords list }
  self.FKeywords.Free;
  self.FKeywords:= nil;
  { destroy PasParser }

//  dispose(PasParser);
end;

{------------------------------------------------------------------------------}


{--- private unit methods -----------------------------------------------------}

procedure ReadNumber(var aInStm : TInChrStrm; var aToken : string;
  var self: TInChrStrmData);
var
  Ch : char;
  State : (BeforeDecPt, GotDecPt, AfterDecPt, Finished);
begin
  State:= BeforeDecPt;
  while (State <> Finished) do begin
     ch:= aInStm.GetChar(self);
    if (Ch = #0) then begin
      State := Finished;
      aInStm.PutBackChar(Ch, self);
    end
    else begin
      case State of
        BeforeDecPt :
          begin
            if (Ch = '.') then begin
              State := GotDecPt;
            end
            else if (Ch < '0') or (Ch > '9') then begin
              State := Finished;
            aInStm.PutBackChar(Ch, self);
            end
            else
              aToken := aToken + Ch;
          end;
        GotDecPt :
          begin
            if (Ch = '.') then begin
              aInStm.PutBackChar(Ch, self);
              aInStm.PutBackChar(Ch, self);
              State := Finished;
            end
            else begin
              aToken := aToken + '.';
              aToken := aToken + Ch;
              State := AfterDecPt;
            end;
          end;
        AfterDecPt :
          begin
            if (Ch < '0') or (Ch > '9') then begin
              State := Finished;
            aInStm.PutBackChar(Ch, self);
            end
            else
              aToken := aToken + Ch;
          end;
      end;
    end;
  end;
end;

procedure ReadHexNumber(var aInStm: TInChrStrm; var aToken : string;
  var self: TInChrStrmData);
var
  Ch : char;
  State : (NormalScan, Finished);
begin
  State := NormalScan;
  while (State <> Finished) do begin
     ch:= aInStm.GetChar(self);
    if (Ch = #0) then
      State := Finished
    else begin
      case State of
        NormalScan :
          begin
            if not (Ch in ['A'..'F', 'a'..'f', '0'..'9']) then begin
              State := Finished;
            aInStm.PutBackChar(Ch, self);
            end
            else
              aToken:= aToken + Ch;
          end;
      end;
    end;
  end;
end;

procedure ReadIdentifier(var aInStm: TInChrStrm; var aToken : string;
  var self: TInChrStrmData);
var
  Ch : char;
begin
  ch:=aInStm.GetChar(self);
  while Ch in ['A'..'Z', 'a'..'z', '0'..'9', '_'] do begin
    aToken := aToken + Ch;
    ch:=aInStm.GetChar(self);
  end;
  aInStm.PutBackChar(Ch, self);
end;

procedure ReadString(var aInStm: TInChrStrm; var aToken : string;
  var self: TInChrStrmData);
var
  Ch : char;
begin
  ch:=aInStm.GetChar(self);
  while (Ch <> '''') and (Ch <> #0) do begin
    aToken := aToken + Ch;
    ch:=aInStm.GetChar(self);
  end;
  if (Ch = '''') then
    aToken := aToken + Ch
  else
    aInStm.PutBackChar(Ch, self);
end;

procedure ReadBraceComment(var aInStm: TInChrStrm; var aToken : string;
  var self: TInChrStrmData);
var
  Ch : char;
begin
  ch:=aInStm.GetChar(self);
  while (Ch <> '}') and (Ch <> #0) do begin
    aToken := aToken + Ch;
    ch:=aInStm.GetChar(self);
  end;
  if (Ch = '}') then
    aToken := aToken + Ch
  else
    aInStm.PutBackChar(Ch, self);
end;

procedure ReadSlashComment(var aInStm: TInChrStrm; var aToken: string;
  var self: TInChrStrmData);
var
  Ch : char;
begin
  ch:= aInStm.GetChar(self);
  while (Ch <> #10) and (Ch <> #0) do begin
    aToken := aToken + Ch;
    ch:= aInStm.GetChar(self);
  end;
  aInStm.PutBackChar(Ch, self);
end;

procedure ReadWhitespace(var aInStm: TInChrStrm; var aToken: string;
  var self: TInChrStrmData);
var
  Ch: char;
begin
  aToken:= '';
  ch:= aInStm.GetChar(self);
  while Ch in [#1..#32] do begin
    aToken:= aToken + Ch;
    ch:= aInStm.GetChar(self);
  end;
  aInStm.PutBackChar(Ch, self);
end;

procedure ReadParenComment(var aInStm: TInChrStrm; var aToken: string;
  var self: TInChrStrmData);
var
  Ch: char;
  State: (NormalScan, GotStar, Finished);
begin
  State:= NormalScan;
  while (State <> Finished) do begin
     ch:=aInStm.GetChar(self);
    if (Ch = #0) then begin
      State:= Finished;
      aInStm.PutBackChar(Ch, self);
    end
    else begin
      aToken := aToken + Ch;
      case State of
        NormalScan :
          if (Ch = '*') then
            State:= GotStar;
        GotStar :
          if (Ch = ')') then
            State:= Finished
          else
            State:= NormalScan;
      end;
    end;
  end;
end;
{------------------------------------------------------------------------------}


{ Parses one token at a time per procedure call, sends back information
  in the var parameters.

  Usage: Input: PInChrStrm
         ATokenType: reports type of token found
         AToken: reports token text or contents     }
procedure GetAToken(var aInStm: TInChrStrm; var ATokenType: TPasToken;
  var AToken: string; var self: TInChrStrmData);
var
  Ch : char;
begin
  { assume invalid token }
  aTokenType:= ptInvalidToken;
  aToken:= '';

  ch:= aInStm.GetChar(self);
  aToken:= ch;
  { parse the token character by character }
  case Ch of
    '#' : aTokenType:= ptHash;
    '$' : begin
            aTokenType:= ptHexNumber; // L505: fixed to hex
            ReadHexNumber(aInStm, aToken, self);
          end;
    '''': begin
            aTokenType:= ptString;
            aToken:= '''';
            ReadString(aInStm, aToken, self);
          end;
    '(' : begin
            ch:=aInStm.GetChar(self);
            if (Ch <> '*') then begin
              aInStm.PutBackChar(Ch, self);
              aTokenType:= ptOpenParen;
            end
            else begin
              aTokenType:= ptComment;
              aToken:= '(*';
              ReadParenComment(aInStm, aToken, self);
            end;
          end;
    ')' : aTokenType:= ptCloseParen;
    '*' : aTokenType:= ptMultiply;
    '+' : aTokenType:= ptPlus;
    ',' : aTokenType:= ptComma;
    '-' : aTokenType:= ptMinus;
    '.' : begin
            ch:=aInStm.GetChar(self);
            if (Ch = '.') then
            begin
              aToken:= '..';
              aTokenType:= ptRange;
            end
            else begin
              aInStm.PutBackChar(Ch, self);
              aTokenType:= ptPeriod;
            end;
          end;
    '/' : begin
            ch:=aInStm.GetChar(self);
            if (Ch <> '/') then begin
              aInStm.PutBackChar(Ch, self);
              aTokenType:= ptDivide;
            end
            else begin
              aTokenType:= ptComment;
              aToken:= '//';
              ReadSlashComment(aInStm, aToken, self);
            end;
          end;
    '0'..'9' :
          begin
            aTokenType:= ptNumber;
            ReadNumber(aInStm, aToken, self);
          end;
    ':' : begin
            ch:=aInStm.GetChar(self);
            if (Ch = '=') then
            begin
              aTokenType:= ptAssign;
              aToken:= ':=';
            end
            else begin
              aInStm.PutBackChar(Ch, self);
              aTokenType:= ptColon;
            end;
          end;
    ';' :aTokenType:= ptSemicolon;
    '<' : begin
            ch:=aInStm.GetChar(self);
            if (Ch = '=') then
            begin
              aToken:= '<=';
              aTokenType:= ptLessEqual;
            end
            else if (Ch = '>') then
            begin
              aToken:= '<>';
              aTokenType:= ptNotEquals;
            end
            else begin
              aInStm.PutBackChar(Ch, self);
              aTokenType:= ptLess;
              aToken:= '<';
            end;
          end;
    '=' : aTokenType:= ptEquals;
    '>' : begin
             ch:= aInStm.GetChar(self);
            if (Ch = '=') then
            begin
              aToken:='>=';
              aTokenType:= ptGreaterEqual;
            end
            else begin
              aInStm.PutBackChar(Ch, self);
              aTokenType:= ptLess;
              aToken:='>';
            end;
          end;
    '@' : aTokenType:= ptAddress;
    'A'..'Z', 'a'..'z', '_' :
          begin
            aTokenType:= ptIdentifier;
            ReadIdentifier(aInStm, aToken, self);
          end;
    '[' : aTokenType:= ptOpenBracket;
    ']' : aTokenType:= ptCloseBracket;
    '^' : aTokenType:= ptCaret;
    '{' : begin
             ch:= aInStm.GetChar(self);
            if ch<>'$' then
            begin
              aInStm.PutBackChar(Ch, self);
              aTokenType:= ptComment;
              aToken:= '{';
              ReadBraceComment(aInStm, aToken, self);
            end else
            begin
              aTokenType:= ptDirective;
              aToken:= '{$';
              ReadBraceComment(aInstm, aToken, self);
            end;
          end;
    #1..#32:
          begin
            aInStm.PutBackChar(Ch, self);//
            ReadWhitespace(aInStm,aToken, self);
            aTokenType:= ptWhitespace;
          end;
    #$0 : begin
            aTokenType:= ptEndOfFile;
            exit;
          end;
    else
      begin

       // aToken = ch at this point,

      end;
  end;

  Assert(aTokenType <> ptInvalidToken,
         'Managed to find an invalid token.');

end;


end.
