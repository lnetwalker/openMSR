{

 Purpose: Pascal tokenizer for KOL with visualisation specific extensions
  Author: © 2004, Thaddy de Koning
 Remarks: Translated to KOL, modified and extended form Julian Bucknall's
          Pascal tokenizer in the Delphi Magazine 68
          Modifications:
          - Added ptWhiteSpace token for easy visualisation/preservation,
            by design this also includes control characters #1..#31
          - Added ptDirective token for compiler directives and conditionals
          - Rewritten to preserve token in all cases during processing
          - Uses KOL pStrlist instead of  a hashtable
           (2K smaller size, almost just as fast)

 Updated: Lars(L505) Apr.27.2006
          Fixed hex typo

}
unit KolPastok;


interface
uses
  Kol,
  KolChrStm;


type
  TPascalToken = ( {types of Pascal tokens...}
    ptInvalidToken,  {..some kind of error}
    ptEndOfFile,     {..end of file}
    ptKeyword,       {..keyword, eg, if, while, do, ...}
    ptIdentifier,    {..identifier}
    ptString,        {..string or character constant}
    ptHexNumber,     {..number in hex, starts with $}
    ptNumber,        {..sequence of digits, maybe with radix point}
    ptComment,       {..comment, any type}
    ptDirective,     {..Compiler directive or conditional}
    ptComma,         {..comma: ,}
    ptSemicolon,     {..semicolon: ;}
    ptColon,         {..colon: :}
    ptPeriod,        {..period: .}
    ptRange,         {..range: ..}
    ptEquals,        {..equals char: =}
    ptNotEquals,     {..not equals: <>}
    ptLess,          {..less than: <}
    ptLessEqual,     {..less than or equal: <=}
    ptGreater,       {..greater than: >}
    ptGreaterEqual,  {..greater than or equal: >=}
    ptAssign,        {..assignment: :=}
    ptOpenParen,     {..open parenthesis: (}
    ptCloseParen,    {..close parenthesis: )}
    ptOpenBracket,   {..open bracket: [}
    ptCloseBracket,  {..close bracket: ]}
    ptCaret,         {..caret: ^}
    ptHash,          {..hash: #}
    ptAddress,       {..ampersand: @}
    ptPlus,          {..addition: +}
    ptMinus,         {..subtraction: -}
    ptMultiply,      {..multiplication: *}
    ptWhitespace,     {#1..#32}
    ptDivide);       {..division: /}

type
  PPascalParser = ^TPascalParser;
  TPascalParser = object(Tobj)
    private
      FInStrm   : PInCharStream;
      FKeywords : PStrlist;
    protected
      procedure ppInitKeywords;
    public
      destructor Destroy; virtual;
      procedure GetToken(var aTokenType : TPascalToken;
                         var aToken     : string);
  end;


procedure GetaToken(aInStm     : PInCharStream;
                 var aTokenType : TPascalToken;
                 var aToken     : string);

function NewPascalParser(aInStm : PInCharStream): PPascalParser;

implementation

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

{===TPascalParser==================================================}
function NewPascalParser(aInStm : PInCharStream):PPascalParser;
begin
  {create the ancestor}
  New(Result,Create);
  with Result^ do
  begin
    {save the stream}
    FInStrm := aInstm;
    {create the keywords list}
    FKeywords := NewstrList;
    ppInitKeywords;
  end;
end;
{--------}
destructor TPascalParser.Destroy;
begin
  {destroy the keywords list}
  FKeywords.Free;
  FKeywords:=nil;
  {destroy the ancestor}
  inherited Destroy;
end;
{--------}
procedure TPascalParser.GetToken(var aTokenType : TPascalToken;
  var aToken: string);
var
  DummyObj : Integer;
begin
  GetaToken(FInStrm, aTokenType, aToken);
  if (aTokenType = ptIdentifier) then
    if FKeywords.Find(UpperCase(aToken), DummyObj) then
      aTokenType := ptKeyword;
end;
{--------}


procedure TPascalParser.ppInitKeywords;
var
  i : integer;
begin
  Assert(FKeywords <> nil,
         'ppInitKeywords cannot be called with nil Stringlist');
  for i := 0 to pred(KeywordCount) do
    FKeywords.Add(KeyWordList[i]);
   FKeywords.sort(True);
end;
{====================================================================}


{===Helper routines==================================================}
procedure ReadNumber(aInStm : PInCharStream;
                 var aToken : string);
var
  Ch : char;
  State : (BeforeDecPt, GotDecPt, AfterDecPt, Finished);
begin
  State := BeforeDecPt;
  while (State <> Finished) do begin
     ch:=aInStm.GetChar;
    if (Ch = #0) then begin
      State := Finished;
      aInStm.PutBackChar(Ch);
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
            aInStm.PutBackChar(Ch);
            end
            else
              aToken := aToken + Ch;
          end;
        GotDecPt :
          begin
            if (Ch = '.') then begin
              aInStm.PutBackChar(Ch);
              aInStm.PutBackChar(Ch);
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
            aInStm.PutBackChar(Ch);
            end
            else
              aToken := aToken + Ch;
          end;
      end;
    end;
  end;
end;
{--------}
procedure ReadHexNumber(aInStm : PInCharStream;
                    var aToken : string);
var
  Ch : char;
  State : (NormalScan, Finished);
begin
  State := NormalScan;
  while (State <> Finished) do begin
     ch:= aInStm.GetChar;
    if (Ch = #0) then
      State := Finished
    else begin
      case State of
        NormalScan :
          begin
            if not (Ch in ['A'..'F', 'a'..'f', '0'..'9']) then begin
              State := Finished;
            aInStm.PutBackChar(Ch);
            end
            else
              aToken:= aToken + Ch;
          end;
      end;
    end;
  end;
end;
{--------}
procedure ReadIdentifier(aInStm : PInCharStream;
                     var aToken : string);
var
  Ch : char;
begin
  ch:=aInStm.GetChar;
  while Ch in ['A'..'Z', 'a'..'z', '0'..'9', '_'] do begin
    aToken := aToken + Ch;
    ch:=aInStm.GetChar
  end;
  aInStm.PutBackChar(Ch);
end;
{--------}
procedure ReadString(aInStm : PInCharStream;
                 var aToken : string);
var
  Ch : char;
begin
  ch:=aInStm.GetChar;
  while (Ch <> '''') and (Ch <> #0) do begin
    aToken := aToken + Ch;
    ch:=aInStm.GetChar
  end;
  if (Ch = '''') then
    aToken := aToken + Ch
  else
    aInStm.PutBackChar(Ch);
end;
{--------}
procedure ReadBraceComment(aInStm : PInCharStream; var aToken : string);
var
  Ch : char;
begin
  ch:=aInStm.GetChar;
  while (Ch <> '}') and (Ch <> #0) do begin
    aToken := aToken + Ch;
    ch:=aInStm.GetChar
  end;
  if (Ch = '}') then
    aToken := aToken + Ch
  else
    aInStm.PutBackChar(Ch);
end;
{--------}
procedure ReadSlashComment(aInStm : PInCharStream; var aToken : string);
var
  Ch : char;
begin
  ch:=aInStm.GetChar;
  while (Ch <> #10) and (Ch <> #0) do begin
    aToken := aToken + Ch;
    ch:=aInStm.GetChar
  end;
  aInStm.PutBackChar(Ch);
end;


{--------}
procedure ReadWhitespace(aInStm : PInCharStream; var aToken : string);
var
  Ch : char;
begin
  aToken:='';
  ch:=aInStm.GetChar;
  while Ch in [#1..#32] do begin
    aToken := aToken + Ch;
    ch:=aInStm.GetChar
  end;
  aInStm.PutBackChar(Ch);
end;

{--------}
procedure ReadParenComment(aInStm : PInCharStream; var aToken : string);
var
  Ch : char;
  State : (NormalScan, GotStar, Finished);
begin
  State := NormalScan;
  while (State <> Finished) do begin
     ch:=aInStm.GetChar;
    if (Ch = #0) then begin
      State := Finished;
      aInStm.PutBackChar(Ch);
    end
    else begin
      aToken := aToken + Ch;
      case State of
        NormalScan :
          if (Ch = '*') then
            State := GotStar;
        GotStar :
          if (Ch = ')') then
            State := Finished
          else
            State := NormalScan;
      end;
    end;
  end;
end;
{====================================================================}
(*
Changes made from original:
- Added ptWhitespace (#1..#32) token for easy visual parsing
- Added ptDirective token for compiler directives and conditionals
- Token persists throughout processing
Thaddy de Koning
*)
{===Interface routine================================================}
procedure GetaToken(aInStm: PInCharStream; var aTokenType: TPascalToken;
  var aToken: string);
var
  Ch : char;
begin
  {assume we have an invalid token}
  aTokenType := ptInvalidToken;
  aToken := '';
  ch:=aInStm.GetChar;
  aToken:=ch;
  {parse the token based on the current character}
  case Ch of
    '#' : aTokenType := ptHash;
    '$' : begin
            aTokenType := ptHexNumber; // L505: fixed to hex
            ReadHexNumber(aInStm, aToken);
          end;
    '''': begin
            aTokenType := ptString;
            aToken := '''';
            ReadString(aInStm, aToken);
          end;
    '(' : begin
            ch:=aInStm.GetChar;
            if (Ch <> '*') then begin
              aInStm.PutBackChar(Ch);
              aTokenType := ptOpenParen;
            end
            else begin
              aTokenType := ptComment;
              aToken := '(*';
              ReadParenComment(aInStm, aToken);
            end;
          end;
    ')' : aTokenType := ptCloseParen;
    '*' : aTokenType := ptMultiply;
    '+' : aTokenType := ptPlus;
    ',' : aTokenType := ptComma;
    '-' : aTokenType := ptMinus;
    '.' : begin
            ch:=aInStm.GetChar;
            if (Ch = '.') then
            begin
              aToken:='..';
              aTokenType := ptRange;
            end
            else begin
              aInStm.PutBackChar(Ch);
              aTokenType := ptPeriod;
            end;
          end;
    '/' : begin
            ch:=aInStm.GetChar;
            if (Ch <> '/') then begin
              aInStm.PutBackChar(Ch);
              aTokenType := ptDivide;
            end
            else begin
              aTokenType := ptComment;
              aToken := '//';
              ReadSlashComment(aInStm, aToken);
            end;
          end;
    '0'..'9' :
          begin
            aTokenType := ptNumber;
            ReadNumber(aInStm, aToken);
          end;
    ':' : begin
            ch:=aInStm.GetChar;
            if (Ch = '=') then
            begin
              aTokenType := ptAssign;
              aToken:=':=';
            end
            else begin
              aInStm.PutBackChar(Ch);
              aTokenType := ptColon;
            end;
          end;
    ';' :aTokenType := ptSemicolon;
    '<' : begin
            ch:=aInStm.GetChar;
            if (Ch = '=') then
            begin
              aToken:='<=';
              aTokenType := ptLessEqual;
            end
            else if (Ch = '>') then
            begin
              aToken:='<>';
              aTokenType := ptNotEquals;
            end
            else begin
              aInStm.PutBackChar(Ch);
              aTokenType := ptLess;
              aToken:='<';
            end;
          end;
    '=' : aTokenType := ptEquals;
    '>' : begin
             ch:=aInStm.GetChar;
            if (Ch = '=') then
            begin
              aToken:='>=';
              aTokenType := ptGreaterEqual;
            end
            else begin
              aInStm.PutBackChar(Ch);
              aTokenType := ptLess;
              aToken:='>';
            end;
          end;
    '@' : aTokenType := ptAddress;
    'A'..'Z', 'a'..'z', '_' :
          begin
            aTokenType := ptIdentifier;
            ReadIdentifier(aInStm, aToken);
          end;
    '[' : aTokenType := ptOpenBracket;
    ']' : aTokenType := ptCloseBracket;
    '^' : aTokenType := ptCaret;
    '{' : begin
             ch:=aInStm.GetChar;
            if ch<>'$' then
            begin
              aInStm.PutBackChar(Ch);
              aTokenType := ptComment;
              aToken := '{';
              ReadBraceComment(aInStm, aToken);
            end else
            begin
              aTokenType := ptDirective;
              aToken:='{$';
              ReadBraceComment(aInstm, aToken);
            end;
          end;
    #1..#32:
          begin
            aInStm.PutBackChar(Ch);//
            ReadWhitespace(aInStm,aToken);
            aTokenType:=ptWhitespace;
          end;
    #$0 : begin
            aTokenType :=ptEndOfFile;
            exit;
          end;
    else
      begin
       // Note: in this modified version
       // aToken = ch at this point,
       // Thaddy
      end;
  end;

  Assert(aTokenType <> ptInvalidToken,
         'Managed to find an invalid token.');
end;
{====================================================================}

end.
