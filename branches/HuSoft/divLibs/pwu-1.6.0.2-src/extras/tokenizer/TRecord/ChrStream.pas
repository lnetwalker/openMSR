unit ChrStream;

interface

uses
  {$ifdef win32} Windows; {$endif}

const
  fmOpenRead = 0;
  fmReadWrite = 2;

type
  PByteArray = ^TByteArray;
  TByteArray = array[0..maxint -1] of byte;

{-- private declaration -------------------------------------------------------}
{
type
  PInChrStrmData = ^TInChrStrmData;
  TInChrStrmData = record
    FBufEnd: integer;
    FBuffer: PByteArray;
    FBufPos: integer;
    FPutBackBuf: array [0..1] of char;
    FPutBackInx: integer;
    Ffh: file; // handle to file
  end;
}
{------------------------------------------------------------------------------}

{-- public declaration --------------------------------------------------------}
type
  TInChrStrmData = record
    FBufEnd: integer;
    FBuffer: PByteArray;
    FBufPos: integer;
    FPutBackBuf: array [0..1] of char;
    FPutBackInx: integer;
    Ffh: file; // handle to file
  end;

//  PInChrStrm = ^TInChrStrm;
  TInChrStrm = record
//    data: TInChrStrmData;
    GetChar: function(var self: TInChrStrmData): char;
    PutBackChar: procedure(aCh: char; var self: TInChrStrmData);
    Test: procedure;
  end;

  TEndOfLine = (eolCRLF, eolLF);

procedure NewInChrStrm(const filename: string;
  var self: TInChrStrmData; var result: TInChrStrm); overload;

procedure NewInChrStrm(const filename: string; ABufSize: Integer;
  var self: TInChrStrmData; var result: TInChrStrm); overload;


procedure FreeInChrStrm(var InChrStrm: TInChrStrm; var self: TInChrStrmData);

implementation

{-- TESTS ---------------------------------------------------------------------}
procedure Test;
begin
  writeln('INCHRSTRM TEST SUCCESSFUL');
end;
{------------------------------------------------------------------------------}

{-- private unit variables ----------------------------------------------------}
const
  BufSize = 32768;
  CR = #13;
  LF = #10;
{------------------------------------------------------------------------------}

{-- protected methods ---------------------------------------------------------}
procedure GetBuffer(var self: TInChrStrmData);
begin
  self.FBufPos:= 0;
  // reads until bufsize, returns total read into Fbufend
  BlockRead(self.FFh, self.FBuffer^, BufSize, self.FBufEnd);
end;
{------------------------------------------------------------------------------}

{-- private methods -----------------------------------------------------------}
function Read(var Buffer; Count: longint; var self: TInChrStrmData): longint;
var
  BytesToRead : longint;
  OutBuf       : PByteArray;
  OutBufPos    : integer;
begin
  { make sure the buffer has data }
  if (self.FBufPos = self.FBufEnd) then
    GetBuffer(self);
  { assume we read nothing }
  Result := 0;
  if (self.FBufEnd = 0) then
    Exit;
  { calculate the number of bytes to copy the first time }
  BytesToRead:= self.FBufEnd - self.FBufPos;
  if (Count < BytesToRead) then
    BytesToRead := Count;
  { copy the calculated number of bytes }
  Move(self.FBuffer^[self.FBufPos], Buffer, BytesToRead);
  inc(self.FBufPos, BytesToRead);
  dec(Count, BytesToRead);
  inc(Result, BytesToRead);
  { if there are still bytes to copy, do so }
  if (Count <> 0) then
  begin
    { create indexable pointer to output buffer }
    OutBuf := PByteArray(@Buffer);
    OutBufPos := BytesToRead;
    { while there are bytes to copy... }
    while (Count <> 0) do
    begin
      { read from the underlying stream }
      GetBuffer(self);
      if (self.FBufEnd = 0) then
        Exit;
      { calculate the number of bytes to copy this time }
      BytesToRead := self.FBufEnd;
      if (Count < BytesToRead) then
        BytesToRead := Count;
      { copy the calculated number of bytes }
      Move(self.FBuffer^[self.FBufPos], OutBuf^[OutBufPos], BytesToRead);
      inc(self.FBufPos, BytesToRead);
      inc(OutBufPos, BytesToRead);
      dec(Count, BytesToRead);
      inc(Result, BytesToRead);
    end;
  end;
end;
{------------------------------------------------------------------------------}


{-- public methods ------------------------------------------------------------}

function GetChar(var self: TInChrStrmData): char;
begin
  repeat
    { use putback chars if available }
    if (self.FPutBackInx <> 0) then
    begin
      dec(self.FPutBackInx);
      writeln('DEBUG: ', self.FPutBackInx);
      Result := self.FPutBackBuf[self.FPutBackInx];
    end
    { otherwise use the buffer }
    else begin
      {make sure the buffer has data}
      if (self.FBufPos = self.FBufEnd) then
        GetBuffer(self);
      { if there is no more data, return #0 to signal end of stream }
      if (self.FBufEnd = 0) then
        Result := #0
      { otherwise return the current character }
      else begin
        Result := char(self.FBuffer^[self.FBufPos]);
        Assert(Result <> #0, 'GetChar: input stream is not text, read null');
        inc(self.FBufPos);
      end;
    end;
  until (Result <> CR);
end;

procedure PutBackChar(aCh: char; var self: TInChrStrmData);
begin
  Assert(self.FPutBackInx < 2,'PutBackChar: put back buffer is full');
  self.FPutBackBuf[self.FPutBackInx] := aCh;
  inc(self.FPutBackInx);
end;

procedure NewInChrStrm(const filename: string;
  var self: TInChrStrmData; var result: TInChrStrm); overload;
begin
  self.FBufPos:= 0;
  self.FBufEnd:= 0;
  self.FPutBackInx:= 0;
  { setup file }
  assign(self.Ffh, filename) ;
  //  FileMode:= fmReadOnly;
  reset(self.ffh, 1);

  { create the buffer }
  GetMem(self.FBuffer, BufSize);


  { create }
//  new(Result);
  result.GetChar:= getchar;
  result.Putbackchar:= putbackchar;
  result.Test:= test;

end;

procedure NewInChrStrm(const filename: string; ABufSize: Integer;
  var self: TInChrStrmData; var result: TInChrStrm); overload;
begin
  self.FBufPos:= 0;
  self.FBufEnd:= 0;
  self.FPutBackInx:= 0;
  { setup file }
  AssignFile(self.Ffh, filename) ;
  //FileMode:= fmReadOnly;
  reset(self.ffh, 1);

  { create the buffer }
  GetMem(self.FBuffer, ABufSize);

  { create PInCharStream }
//  new(Result);
  result.GetChar:= getchar;
  result.Putbackchar := putbackchar;
  result.Test:= Test;

end;

procedure FreeInChrStrm(var InChrStrm: TInChrStrm; var self: TInChrStrmData);
begin
  CloseFile(self.ffh);
  if (self.FBuffer <> nil) then
    FreeMem(self.FBuffer, BufSize);
//  Dispose(InChrStrm);
end;


{------------------------------------------------------------------------------}


end.


