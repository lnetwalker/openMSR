{ dynamic version: pascal to html syntax highlighter that accepts incoming
  URL variable for file name

  Lars (L505)
  http://z505.com
  
}

program PasToHtm;
{$ifndef fpc} {$APPTYPE CONSOLE} {$endif}

{$ifdef fpc}
 {$mode objfpc} {$h+}
{$endif}

uses
  dynpwu,
  PasHiliter,
  fileshare,
  htmw;
const
  POST_SELF = ''; // empty ACTION posts to self

var
  MainBody: THtmBody;
 { html panels }
  HeadBox1: THtmBox; // header box (panel)
  MainBox1: THtmBox; // main content box (panel)
  MainBox2: THtmBox; // main content box (panel)

  
procedure InitWidgets;
begin
  MainBody.font.family:= 'Verdana, Helvetica, sans-serif, serif';
  MainBody.font.color:= '#CCCCCC';
  MainBody.bgcolor:= '#252525';


  HeadBox1.pad:= 5;
  HeadBox1.padunit:= cuPixels;
  HeadBox1.text:= 'Pascal Unit Hiliter';
  HeadBox1.font.color:= '#CCCCCC';
  HeadBox1.font.size:= '2em';
  HeadBox1.hAlign:= chaCenter;
  //HeadBox1.bgcolor:= '#252525'; // already inherited

  MainBox1.pad:= 18;
  MainBox1.padunit:= cuPixels;
  MainBox1.font.color:= '#CCCCCC';
  MainBox1.font.size:= '1em';
  //MainBox1.bgcolor:= '#252525'; // already inherited


 { clone a box - this power not available to you in dreamweaver/frontpage nor
   is it easily done using templates or javascript hacks! Only one line of code}
  MainBox2:= MainBox1;
  MainBox2.pad:= 14;
end;

{ check file for proper extension }
function CheckPasFile(filename: string): boolean;
var
  last3: string[3];
  last4: string[4];
begin
  result:= false;
  setlength(last3, 3);
  last3[1]:= filename[length(filename)-2];
  last3[2]:= filename[length(filename)-1];
  last3[3]:= filename[length(filename)];
  //webwriteln('<br>debug last3: ' + last3);
  setlength(last4, 4);
  last4[1]:= filename[length(filename)-3];
  last4[2]:= filename[length(filename)-2];
  last4[3]:= filename[length(filename)-1];
  last4[4]:= filename[length(filename)];
  //webwriteln('<br>debug last4: ' + last4);

  if (last3 = '.pp') then
    result:= true;
    
  if (last4 = '.inc') then
    result:= true;
  if (last4 = '.lpr') then
    result:= true;
  if (last4 = '.pas') then
    result:= true;
  if (last4 = '.dpr') then
    result:= true;
end;

procedure OnLoad;
var
  GotString: string;
begin
  GotString:= GetCgiVar_S('unit', 0);
  GotString:= TrimBadChars_file(GotString); // only allow local directory
  //webwriteln('debug: ' + GotString);
  if CheckPasFile(GotString) = false then
  begin
    HParaBreak;
    webwrite('Err: file must be .pas, .pp, .dpr, .lpr, or .inc');
    exit;
  end;
  if fileshare.FileExists_plain(GotString) = false then
  begin
    HParaBreak;
    webwrite('Err: file does not exist');
    exit;
  end;

  MainBox1.text:= 'Here is the highlighted code:';
  BoxBegin(MainBox1);
    MainBox2.bgcolor:= '#1D2225';
    MainBox2.margin:= 2;
    MainBox2.text:= PreFormat(PasFileToHtmStr(GotString));
    HParaBreak;
    BoxOut(MainBox2);
  BoxEnd;
end;

procedure OnNoFile;
begin
  MainBox1.text:= 'Unit to highlight was not specified';
  BoxOut(MainBox1);
end;

begin


  // Initialize design time html widget code
  InitWidgets;

  // Code logic directs our organized custom OnEvent system
  HtmBegin('Demo', MainBody, '/cgi-htm/PasHiliteDemo/style.css');
    BoxOut(HeadBox1);
    if IsCGIVar('unit') = false then
      OnNoFile
    else
    if (IsCGIVar('unit')) and (GetCgiVar('unit') <> '') then
      OnLoad;
  HtmEnd; // indenting is used for clarity between htmbegin and htmend
end.

{
   You can keep design separate from code. Above is all the initial design
   positions. However, sometimes you need to output design based on logic.

   Initial widget designtime code is placed in an init procedure, but
   you could also place it into a hidden include file or an initialization
   section in a unit, to keep it hidden from your code logic. It could also
   be hooked up to a designer widget system like how Delphi handles forms at
   design time using the form designer. You can still modify your design time
   forms before you finally output them, and while you are doing posts/gets
   you can change the position of your components on the page - unlike fixed
   html templates which do not have that power (unless you use cheesy tactics
   such as macro variable templates, outputting snippets of html at a time,
   or other messy hacks - but they are much messier than clean run time html
   widgets).

   With DreamWeaver/TurboPHP/Frontpage style development you cannot design
   your forms and then do processing to change positions of your forms
   because those tools have no ability to process and change your widgets,
   they are purely design time tools where all design time html is fixed.
}

