program testmime;

uses baseunix,
{$IFDEF STATIC}
 pwumain, mimetypes,
{$ELSE} 
 dynpwu, 
{$ENDIF} 
 HTMw;
 
 
var
 TestIt : AnsiString; 
 tmp : AnsiString;
 PStyle : PStyleSheet;
 MimeStat : Integer;
 
 
begin
  PStyle := New(PStyleSheet, Create);
  PStyle^.InsertProperty('body','background-color','#343434');
  PStyle^.InsertProperty('body','color','#FF8800');
  HTMBegin('PWU/PSP MIMETYPE TEST PROGRAM', PStyle);
  BR;
   FormOut('MIMEFORM',fpGetEnv('SCRIPT_NAME'), GET);
    WebWrite('ENTER FILE NAME TO TEST: ');
    Form_TextOut('TESTFILE', GetCGIVar_SF('TESTFILE',0));
    nbsp; nbsp; 
    Form_SubmitOut('TESTSUBMIT','SUBMIT FILE NAME','');
   FormEnd;

  If IsCGIVar('TESTFILE') then
     begin
       br; br;
       WebWrite('MIME TYPE IS: ');
       Span_Begin('STYLE="color : #FFFF00; font-size : 175%; font-weight : bolder;"');
         WebWrite(GetMimeType(GetCGIVar_SF('TESTFILE',0)));
       Span_End;
       MimeStat := MimeStatus;
       If MimeStat <> MIME_FOUND then
         begin
           RuleOut;
           Div_Begin('STYLE="color : #FFFFFF; background-color: #CC0000;  width : 65%;"');
             case MimeStat of
              MIME_CANTFIND_DATABASE : WebWrite('cannot find pwu_mime.types');
              MIME_ERR_FILEIO : WebWrite('error reading pwu_mime.types');
              MIME_NOT_FOUND : WebWrite('file type not found in database');
             end;
           Div_End;
           RuleOut;
         end;   
       BR; BR;
     end;
     

   HTMEnd;
end.   
   
