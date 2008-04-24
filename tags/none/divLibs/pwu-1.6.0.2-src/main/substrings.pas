{*******************************************************************************

                           PSP/PWU Substrings

********************************************************************************

--------------------------------------------------------------------------------
  Some advanced code for working with AnsiStrings
--------------------------------------------------------------------------------

  Copyright (c) 2003-2005 by Pascal Server Pages development team.
  See the Pascal Server Pages License for more information.

--------------------------------------------------------------------------------
  Authors/Credits:
--------------------------------------------------------------------------------
  Trustmaster (Vladimir Sibirov), L505 (Lars Olson)

--------------------------------------------------------------------------------
  Developer Notes
--------------------------------------------------------------------------------

  [PSP 1.6.X - 29.MAR.2006 - L505]:
  - made delphi5 compatible

  [PSP 1.4.0 - 19.06.05 - Trustmaster]:
  - memory optimization (exact types);
  - string comparison functions: str_comp, str_icomp, str_ncomp, str_incomp,
    str_is_float, str_is_int, str_conv_float, str_conv_int.

  [PSP 1.4.0 - 27.05.05 - Trustmaster]:
  - PSP2-comliant function names with str_ and substr_ prefixes;
  - fixed bugs in substr_count and str_reverse;
  - added case insensitive variants of several functions (substr_iexists,
    substr_icount, substr_ireplace, substr_istrip, substr_isplit);
  - added new functions (substr_pos, substr_ipos, substr_rpos, substr_irpos).



********************************************************************************}

unit substrings;


{$IFDEF FPC}{$MODE OBJFPC}{$H+}
   {$IFDEF EXTRA_SECURE}
    {$R+}{$Q+}{$CHECKPOINTER ON}
   {$ENDIF}
{$ENDIF}

interface

uses
 pwuTypes;


function substrexists(const str, sub: string): boolean;
function substriexists(const str, sub: string): boolean;
function substrpos(const str, sub: string): longint;
function substripos(const str, sub: string): longint;
function substrrpos(const str, sub: string): longint;
function substrirpos(const str, sub: string): longint;
function substrcount(const str, sub: string): longint;
function substricount(const str, sub: string): longint;
function substrreplace(const str, sub, repl: string): string;
function substrireplace(const str, sub, repl: string): string;
function substrstrip(const str, sub: string): string;
function substristrip(const str, sub: string): string;
function substrsplit(const str, delimiter: string): TStrArray;
function substrisplit(const str, delimiter: string): TStrArray;
function strcomp(const str1, str2: string): shortint;
function stricomp(const str1, str2: string): shortint;
function strncomp(const str1, str2: string): shortint;
function strincomp(const str1, str2: string): shortint;
function strconvint(const str: string): longint;
function strconvfloat(const str: string): double;
function strisint(const str: string): boolean;
function strisfloat(const str: string): boolean;
function strreverse(const str: string): string;
function strtrimleft(const str: string): string;
function strtrimright(const str: string): string;
function strtrim(const str: string): string;


implementation

{$ifndef fpc}
uses
  sysutils;


// some missing functions in Delphi 5 equivilent to FPC
{function val(): boolean; overload;
begin

end;}

{$endif}

const
  STR_CONST_DIGITS = '1234567890';
  STR_CONST_INT = '-1234567890';


// Finds if sub exists in str
function substrexists(const str, sub: string): boolean;
begin
  if substrpos(str, sub) > 0 then result:= true
  else result:= false;
end;

// Case insensitive substr_exists
function substriexists(const str, sub: string): boolean;
begin
  if substrpos(lowercase(str), lowercase(sub)) > 0 then result:= true
  else result:= false;
end;

// Returns position of first occurance of sub in str
// I know, pos() exists, but this is done to see the logic
function substrpos(const str, sub: string): longint;
var
  spos, len, sublen: longint;
begin
  result:= 0;
  spos:= 1;
  len:= length(str);
  sublen:= length(sub);
  while (spos + sublen - 1) <= len do
    if copy(str, spos, sublen) = sub then
    begin
      result:= spos;
      break;
    end
    else inc(spos);
end;

// Case insensitive substrpos
function substripos(const str, sub: string): longint;
begin
  result:= substrpos(lowercase(str), lowercase(sub));
end;

// Returns position of last occurance of sub in str
// Ha-ha, you won't find it in system unit :)
function substrrpos(const str, sub: string): longint;
var
  spos, len, sublen: longint;
begin
  result:= 0;
  len:= length(str);
  sublen:= length(sub);
  spos:= len - sublen + 1;
  while spos > 0 do
    if copy(str, spos, sublen) = sub then
    begin
      result:= spos;
      break;
    end
    else dec(spos);
end;

// Case insensitive substrrpos
function substrirpos(const str, sub: string): longint;
begin
  result:= substrrpos(lowercase(str), lowercase(sub));
end;

// Returns number of occurances of sub in str
function substrcount(const str, sub: string): longint;
var
  temp: string;
  sublen: longint;
begin
  result:= 0;
  temp:= str;
  sublen:= length(sub);
  while pos(sub, temp) > 0 do
  begin
    inc(result);
    delete(temp, pos(sub, temp), sublen);
  end;
end;

// Case insensitive substr_count
function substricount(const str, sub: string): longint;
begin
  result:= substrcount(lowercase(str), lowercase(sub));
end;

// Replaces all the sub substrings in str with repl substrings
function SubStrReplace(const str, sub, repl: string): string;
var
  posn, sublen, len, replen: longint;
begin
  result:= str;
  posn:= 1;
  sublen:= length(sub);
  replen:= length(repl);
  repeat
    if copy(result, posn, sublen) = sub then
    begin
      delete(result, posn, sublen);
      insert(repl, result, posn);
      posn:= posn + replen;
    end
    else inc(posn);
    len:= length(result);
  until posn > len;
end;

// Case insensitive substrreplace
function substrireplace(const str, sub, repl: string): string;
var
  posn, sublen, len, replen: longint;
  lsub: string;
begin
  result:= str;
  posn:= 1;
  sublen:= length(sub);
  replen:= length(repl);
  lsub:= lowercase(sub);
  repeat
    if lowercase(copy(result, posn, sublen)) = lsub then
    begin
      delete(result, posn, sublen);
      insert(repl, result, posn);
      posn:= posn + replen;
    end
    else inc(posn);
    len:= length(result);
  until posn > len;
end;

// Removes all occurances of sub in the string
function substrstrip(const str, sub: string): string;
var
  len: longint;
begin
  result:= str;
  len:= length(sub);
  while pos(sub, result) > 0 do delete(result, pos(sub, result), len);
end;

// Case insensitive substrstrip
function substristrip(const str, sub: string): string;
var
  len, posn: longint;
begin
  result:= str;
  len:= length(sub);
  repeat
    posn:= pos(lowercase(sub), lowercase(result));
    if posn > 0 then delete(result, posn, len);
  until posn <= 0;
end;

// Splits str into array by string delimiter
function substrsplit(const str, delimiter: string): TStrArray;
var
  temp: string;
  i, len: longint;
begin
  SetLength(result, 0);
  temp:= str;
  len:= length(delimiter);
  i:= 1;
  // Splitting while delemiter presents in temp
  while pos(delimiter, temp) > 0 do
  begin
    i:= pos(delimiter, temp);
    SetLength(result, length(result) + 1);
    result[length(result) - 1]:= copy(temp, 1, i - 1);
    delete(temp, 1, (i - 1) + len);
  end;
  // Just copying the last part
  SetLength(result, length(result) + 1);
  result[length(result) - 1]:= temp;
end;

// Case insensitive strsplit
function substrisplit(const str, delimiter: string): TStrArray;
var
  temp: string;
  i, len: longint;
begin
  SetLength(result, 0);
  temp:= str;
  len:= length(delimiter);
  i:= 1;
  // Splitting while delemiter presents in temp
  while pos(lowercase(delimiter), lowercase(temp)) > 0 do
  begin
    i:= pos(lowercase(delimiter), lowercase(temp));
    SetLength(result, length(result) + 1);
    result[length(result) - 1]:= copy(temp, 1, i - 1);
    delete(temp, 1, (i - 1) + len);
  end;
  // Just copying the last part
  SetLength(result, length(result) + 1);
  result[length(result) - 1]:= temp;
end;

// String comparsion
function strcomp(const str1, str2: string): shortint;
var
  i, lim: longint;
begin
  result:= 0;
  if length(str1) > length(str2) then lim:= length(str1)
  else lim:= length(str2);
  for i:= 1 to lim do
  begin
    if ord(str1[i]) > ord(str2[i]) then
    begin
      result:= 1;
      break;
    end;
    if ord(str1[i]) < ord(str2[i]) then
    begin
      result:= -1;
      break;
    end;
  end;
  if (result = 0) and (length(str1) > length(str2)) then result:= 1;
  if (result = 0) and (length(str1) < length(str2)) then result:= -1;
end;

// String comparsion, case insensitive
function stricomp(const str1, str2: string): shortint;
begin
  result:= strcomp(lowercase(str1), lowercase(str2));
end;

// String comparsion, natural algoritm
function strncomp(const str1, str2: string): shortint;
var
  i, j, len1, len2, num1, num2: longint;
  lex1, lex2, lex3, lex4: string;
  sub: shortint;
  dummy: integer;
begin
  result:= 0;
  i:= 1;
  j:= 1;
  len1:= length(str1);
  len2:= length(str2);
  while (i <= len1) and (j <= len2) do
  begin
    if (pos(str1[i], STR_CONST_DIGITS) > 0) and (pos(str2[j], STR_CONST_DIGITS) > 0) then
    begin
      // Natural number comparsion
      lex1:= '';
      while (i <= len1) and (pos(str1[i], STR_CONST_DIGITS) > 0) do
      begin
        SetLength(lex1, length(lex1) + 1);
        lex1[length(lex1)]:= str1[i];
        inc(i);
      end;
      val(lex1, num1, dummy);
      lex1:= '';
      while (j <= len2) and (pos(str2[j], STR_CONST_DIGITS) > 0) do
      begin
        SetLength(lex1, length(lex1) + 1);
        lex1[length(lex1)]:= str2[j];
        inc(j);
      end;
      val(lex1, num2, dummy);
      if num1 > num2 then
      begin
        result:= 1;
        break;
      end;
      if num1 < num2 then
      begin
        result:= -1;
        break;
      end;
    end else
    begin
      // Alpha order comparsion
      lex1:= '';
      // Getting numeric part if exists
      while (i <= len1) and (pos(str1[i], STR_CONST_DIGITS) > 0) do
      begin
        SetLength(lex1, length(lex1) + 1);
        lex1[length(lex1)]:= str1[i];
        inc(i);
      end;
      lex3:= '';
      // Then getting the string part
      while (i <= len1) and (pos(str1[i], STR_CONST_DIGITS) <= 0) do
      begin
        SetLength(lex3, length(lex3) + 1);
        lex3[length(lex3)]:= str1[i];
        inc(i);
      end;
      lex2:= '';
      // Getting numeric part if exists
      while (j <= len2) and (pos(str2[j], STR_CONST_DIGITS) > 0) do
      begin
        SetLength(lex2, length(lex2) + 1);
        lex2[length(lex2)]:= str2[j];
        inc(j);
      end;
      lex4:= '';
      // Then getting the string part
      while (j <= len2) and (pos(str2[j], STR_CONST_DIGITS) <= 0) do
      begin
        SetLength(lex4, length(lex4) + 1);
        lex4[length(lex4)]:= str2[j];
        inc(j);
      end;
      if lex3 = lex4 then
      begin
        // Natural hint
        val(lex1, num1, dummy);
        val(lex2, num2, dummy);
        if num1 > num2 then
        begin
          result:= 1;
          break;
        end;
        if num1 < num2 then
        begin
          result:= -1;
          break;
        end;
        if num1 = num2 then
        begin
          result:= 0;
          continue;
        end;
      end;
      sub:= strcomp(lex1, lex2);
      if sub > 0 then
      begin
        result:= 1;
        break;
      end;
      if sub < 0 then
      begin
        result:= -1;
        break;
      end;
    end;
  end;
end;

// String comparsion, natural algoritm, case insensitive
function strincomp(const str1, str2: string): shortint;
begin
  result:= strncomp(lowercase(str1), lowercase(str2));
end;

// Converts a string into int if it is a real int
function strconvint(const str: string): longint;
var
  dummy: integer;
begin
  result:= 0;
  if strisint(str) then val(str, result, dummy);
end;

// Converts a string into float it is a real float
function strconvfloat(const str: string): double;
var
  dummy: integer;
begin
  result:= 0.0;
  if strisfloat(str) then val(str, result, dummy);
end;

// Whether it is a string representation of integer type
function strisint(const str: string): boolean;
var
  i: longint;
begin
  result:= true;
  for i:= 1 to length(str) do
    if pos(str[i], STR_CONST_INT) = 0 then
    begin
      result:= false;
      break;
    end;
end;

// Whether it is a string representation of float type
function strisfloat(const str: string): boolean;
var
  i, p: longint;
  tmp: string;
begin
  p:= pos('.', str);
  if p <= 0 then
  begin
    result:= false;
    exit;
  end;
  result:= true;
  tmp:= copy(str, 1, p - 1);
  for i:= 1 to length(tmp) do
    if pos(tmp[i], STR_CONST_DIGITS) <= 0 then
    begin
      result:= false;
      break;
    end;
  tmp:= copy(str, p + 1, length(str) - p);
  for i:= 1 to length(tmp) do
    if pos(tmp[i], STR_CONST_DIGITS) <= 0 then
    begin
      result:= false;
      break;
    end;
end;

// Returns reversed string
function strreverse(const str: string): string;
var
  i, len: longint;
begin
  len:= length(str);
  SetLength(result, len);
  for i:= 1 to len do result[i]:= str[len - i + 1];
end;

// Removes whitespaces and tab chars from the beginning of the line
function strtrimleft(const str: string): string;
var
  i: longint;
begin
  i:= 0;
  while (str[i + 1] = #32) or (str[i + 1] = #9) do inc(i);
  result:= copy(str, i + 1, length(str) - i);
end;

// Removes whitespaces and tab chars from the end of the line
function strtrimright(const str: string): string;
var
  i, len: longint;
begin
  len:= length(str);
  i:= 0;
  while (str[len - i] = #32) or (str[len - i] = #9) do inc(i);
  result:= copy(str, 1, len - i);
end;

// Removes whitespaces and tab chars from beginning and end of the line
function strtrim(const str: string): string;
begin
  result:= strtrimright(strtrimleft(str));
end;



end.
