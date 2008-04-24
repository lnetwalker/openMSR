unit KOLChrStm;

interface

uses
Windows,
Kol;
type
  PByteArray=^TByteArray;
  TByteArray = array[0..maxint -1] of byte;

  PInCharStream = ^TInCharStream;
  TInCharStream = object(TObj)
    private
      FBufEnd : integer;
      FBuffer : PByteArray;
      FBufPos : integer;
      FStream : PStream;
      FPutBackBuf : array [0..1] of char;
      FPutBackInx : integer;
    function Write(const Buffer; Count: Integer): longint;
    protected
      procedure GetBuffer;
    public
      destructor Destroy; virtual;
      function Read(var Buffer; Count : longint) : longint;
      function Seek(Offset : longint; Origin : word) : longint;
      function GetChar : char;
      procedure PutBackChar(aCh : char);
  end;

  TEndOfLine = (eolCRLF, eolLF);

  POutcharStream = ^TOutcharSTream;
  TOutCharStream = object(Tobj)
    private
      FBuffer : PByteArray;
      FBufPos : integer;
      FEOL    : TEndOfLine;
      FStream : PStream;
    protected
      procedure ocsFlush;
    public
      destructor Destroy; virtual;
      function Write(const Buffer; Count : longint) : longint;
      procedure PutChar(aCh : char);
      property EndOfLine : TEndOfLine read FEOL write FEOL;
  end;

 Function NewInCharStream(aStream : PStream):PIncharStream;overload;
 Function NewInCharStream(aStream : PStream;aBufSize:Integer):PIncharStream;overload;
 Function NewOutcharStream(aStream : PStream):POutCharStream;overload;
 Function NewOutCharStream(aStream : PStream;aBufSize:integer):POutcharStream;overload;
implementation

const
  BufSize = 32768;
  CR      = #13;
  LF      = #10;

{===TInCharStream==================================================}
function NewInCharStream(aStream : PStream):PIncharStream;overload;
begin
  {create the ancestor}
  New(Result,Create);
  with result^ do
  begin
  {save the stream}
  FStream := aStream;
  {create the buffer}
  GetMem(FBuffer, BufSize);
  //FBuffer:=ALlocMem(BufSize);
  end;
 {FBufPos := 0;}
 {FBufEnd := 0;}
end;

Function NewInCharStream(aStream : PStream;aBufSize:Integer):PIncharStream;overload;
begin
  {create the ancestor}
  New(Result,Create);
  with result^ do
  begin
  {save the stream}
  FStream := aStream;
  {create the buffer}
  GetMem(FBuffer, BufSize);
  //FBuffer:=ALlocMem(aBufSize);
  end;
 {FBufPos := 0;}
 {FBufEnd := 0;}
end;

{--------}
destructor TInCharStream.Destroy;
begin
  if (FBuffer <> nil) then
    FreeMem(FBuffer, BufSize);
end;
{--------}
function TInCharStream.GetChar : char;
begin
  repeat
    {use putback chars if available}
    if (FPutBackInx <> 0) then begin
      dec(FPutBackInx);
      Result := FPutBackBuf[FPutBackInx];
    end
    {otherwise use the buffer}
    else begin
      {make sure the buffer has data}
      if (FBufPos = FBufEnd) then
        GetBuffer;
      {if there is no more data, return #0 to signal end of stream}
      if (FBufEnd = 0) then
        Result := #0
      {otherwise return the current character}
      else begin
        Result := char(FBuffer^[FBufPos]);
        Assert(Result <> #0,
               'TInCharStream.GetChar: input stream is not text, read null');
        inc(FBufPos);
      end;
    end;
  until (Result <> CR);
end;
{--------}
procedure TInCharStream.GetBuffer;
begin
  FBufPos := 0;
  FBufEnd := FStream.Read(FBuffer^, BufSize);
end;
{--------}
procedure TInCharStream.PutBackChar(aCh : char);
begin
  Assert(FPutBackInx < 2,
         'TInCharStream.PutBackChar: put back buffer is full');
  FPutBackBuf[FPutBackInx] := aCh;
  inc(FPutBackInx);
end;
{--------}
function TInCharStream.Read(var Buffer; Count : longint) : longint;
var
  BytesToRead : longint;
  OutBuf       : PByteArray;
  OutBufPos    : integer;
begin
  {make sure the buffer has data}
  if (FBufPos = FBufEnd) then
    GetBuffer;
  {assume we read nothing}
  Result := 0;
  if (FBufEnd = 0) then
    Exit;
  {calculate the number of bytes to copy the first time}
  BytesToRead := FBufEnd - FBufPos;
  if (Count < BytesToRead) then
    BytesToRead := Count;
  {copy the calculated number of bytes}
  Move(FBuffer^[FBufPos], Buffer, BytesToRead);
  inc(FBufPos, BytesToRead);
  dec(Count, BytesToRead);
  inc(Result, BytesToRead);
  {if there are still bytes to copy, do so}
  if (Count <> 0) then begin
    {create indexable pointer to output buffer}
    OutBuf := PByteArray(@Buffer);
    OutBufPos := BytesToRead;
    {while there are bytes to copy...}
    while (Count <> 0) do begin
      {read from the underlying stream}
      GetBuffer;
      if (FBufEnd = 0) then
        Exit;
      {calculate the number of bytes to copy this time}
      BytesToRead := FBufEnd;
      if (Count < BytesToRead) then
        BytesToRead := Count;
      {copy the calculated number of bytes}
      Move(FBuffer^[FBufPos], OutBuf^[OutBufPos], BytesToRead);
      inc(FBufPos, BytesToRead);
      inc(OutBufPos, BytesToRead);
      dec(Count, BytesToRead);
      inc(Result, BytesToRead);
    end;
  end;
end;
{--------}
function TInCharStream.Seek(Offset : longint; Origin : word) : longint;
begin
  Assert(false,
         'TOutCharStream.Seek: this class is write only, it cannot seek');
  Result := 0; {to satify the compiler}
end;
{--------}
function TInCharStream.Write(const Buffer; Count : longint) : longint;
begin
  Assert(false,
         'TInCharStream.Write: this class is read only, it cannot write');
  Result := 0; {to satisfy the compiler}
end;
{====================================================================}


{===TOutCharStream=================================================}
function NewOutCharStream(aStream : PStream):pOutCharStream;overload;
begin
  {create the ancestor}
  New(Result, Create);
  with Result^ do
  begin
  {save the stream}
  FStream := aStream;
  {create the buffer}
  GetMem(FBuffer, BufSize);
  //FBuffer:=AllocMem(BufSize);
  end;
 {FBufPos := 0;}
end;

function NewOutCharStream(aStream : PStream;aBufSize:Integer):pOutCharStream;overload;
begin
  {create the ancestor}
  New(Result, Create);
  with Result^ do
  begin
  {save the stream}
  FStream := aStream;
  {create the buffer}
  GetMem(FBuffer, BufSize);
  //FBuffer:=AllocMem(aBufSize);
  end;
 {FBufPos := 0;}
end;

{--------}
destructor TOutCharStream.Destroy;
begin
  {if there is a buffer and there is some data, flush it,
   then free the buffer}
  if (FBuffer <> nil) then begin
    ocsFlush;
    FreeMem(FBuffer, BufSize);
  end;
  {free the ancestor}
  inherited Destroy;
end;
{--------}
procedure TOutCharStream.ocsFlush;
begin
  {if there's data in the buffer, write it to the underlying stream}
  if (FBufPos <> 0) then begin
    FStream.Write(FBuffer^, FBufPos);
    FBufPos := 0;
  end;
end;
{--------}
procedure TOutCharStream.PutChar(aCh : char);
begin
  if (FEOL = eolCRLF) and (aCh = LF) then begin
    {add a CR to the buffer}
    FBuffer^[FBufPos] := byte(CR);
    inc(FBufPos);
    {if the buffer is full, flush it to the underlying stream}
    if (FBufPos = BufSize) then
      ocsFlush;
  end;
  {add the character to the buffer}
  FBuffer^[FBufPos] := byte(aCh);
  inc(FBufPos);
  {if the buffer is full, flush it to the underlying stream}
  if (FBufPos = BufSize) then
    ocsFlush;
end;
{--------}

{--------}
function TOutCharStream.Write(const Buffer; Count : longint) : longint;
var
  BytesToWrite : longint;
  InBuf        : PByteArray;
  InBufPos     : integer;
begin
  {assume we write the entire buffer}
  Result := Count;
  {calculate the number of bytes to copy the first time}
  BytesToWrite := BufSize - FBufPos;
  if (Count < BytesToWrite) then
    BytesToWrite := Count;
  {copy the calculated number of bytes}
  Move(Buffer, FBuffer^[FBufPos], BytesToWrite);
  inc(FBufPos, BytesToWrite);
  dec(Count, BytesToWrite);
  {if there are still bytes to copy, do so}
  if (Count <> 0) then begin
    {create indexable pointer to input buffer}
    InBuf := PByteArray(@Buffer);
    InBufPos := BytesToWrite;
    {while there are bytes to copy...}
    while (Count <> 0) do begin
      {flush the output buffer}
      ocsFlush;
     {calculate the number of bytes to copy this time}
      BytesToWrite := BufSize;
      if (Count < BytesToWrite) then
        BytesToWrite := Count;
      {copy the calculated number of bytes}
      Move(InBuf^[InBufPos], FBuffer^[FBufPos], BytesToWrite);
      inc(FBufPos, BytesToWrite);
      inc(InBufPos, BytesToWrite);
      dec(Count, BytesToWrite);
    end;
  end;
  {if the buffer is full, flush it to the underlying stream}
  if (FBufPos = BufSize) then
    ocsFlush;
end;
{====================================================================}


end.
