{ see notes/pwu_lib.note.txt for header comments, legal terms, and license }

library pwu_lib;

{$IFDEF FPC}{$MODE OBJFPC}{$H+}
  {$IFDEF EXTRA_SECURE}
   {$R+}{$Q+}{$CHECKPOINTER ON}
  {$ENDIF}
{$ENDIF}

uses
  base64enc    ,
  mimetypes    ,
  fileshare    ,
  fileutil     ,
  hostname     ,
  http         ,
  md5crypt     ,
  regexp       ,
//  sdsMain      , // TODO: make separate dynamic sds library
  smtp         ,
  substrings   ,
  urlenc       ,
  pwumain      ;      
               

exports
{BEGIN}

{ -- base 64 exports -- }                                                        
  Base64Decode            ,
  Base64Encode            ,

{ -- mimetypes -- }
  GetMimeType             ,

{ -- file share exports -- }                                                     
  FileExists_plain        ,
  FileError               ,
  FileMarkRead            ,
  FileMarkWrite           ,
  FileUnmarkRead          ,
  FileUnmarkWrite         ,

{ -- http exports -- }                                                           
  HttpClose               ,
  HttpConnect1             , // todo: overloaded wrapper called httpconnect() wrapping httpconnec1()
  HttpCopy                ,
  HttpEof                 ,
  HttpGet1                 , // todo: overloaded wrapper called httpget() wrapping httpget1()
  HttpGetHeader           ,
  HttpRead                ,
  HttpReadLn              ,
  HttpSendRequest         ,
  HttpResponseInfo        ,
  HttpSetHeader           ,
  HttpSetPostData         ,
  HttpPutHeader           ,

{ -- host name exports -- }
  InetAddrAliases        ,
  InetNameAliases        ,
  InetResolve            ,
  InetSelfAddr           ,
  InetSelfName           ,

{ -- md5 exports -- }
  MD5String              ,
  MD5File                ,

{ -- regular expression exports -- }
  RegExpCheck            ,
  RegExpCount            ,
  RegExpCountAll         ,
  RegExpEntry            ,
  RegExpEntryCount       ,
  RegExpEntryItem        ,
  RegExpEntryLength      ,
  RegExpEntryPos         ,
  RegExpError            ,
  RegExpErrorAll         ,
  RegExpFree             ,
  RegExpFreeAll          ,
  RegExpMatch            ,
  RegExpMatchAll         ,
  RegExpReplace          ,
  RegExpSplit            ,

{ -- SDS exports -- }                                                            // still waiting, dot notation exports work in which fpc version??
  {sdsmain.ColumnFree          ,
  sdsmain.ColumnIndex         ,
  sdsmain.ColumnInfo          ,
  sdsmain.columnname          ,
  sdsmain.columntype          ,
  sdsmain.escape              ,
  sdsmain.exportcsv           ,
  sdsmain.exportsds           ,
  sdsmain.exportsql           ,
  sdsmain.exportxml           ,
  sdsmain.fetchcolumn         ,
  sdsmain.fetchcolumn_float   ,
  sdsmain.fetchcolumn_int     ,
  sdsmain.fetchfield          ,
  sdsmain.fetchfield_float    ,
  sdsmain.fetchfield_int      ,
  sdsmain.fetchrow            ,
  sdsmain.freeresult          ,
  sdsmain.freerow             ,
  sdsmain.importsql           ,
  sdsmain.lastid              ,
  sdsmain.numfields           ,
  sdsmain.numrows             ,
  sdsmain.resultcmd           ,
  sdsmain.resulteof           ,
  sdsmain.resulterror         ,
  sdsmain.resultfields        ,
  sdsmain.resultpointer       ,
  sdsmain.resultrewind        ,
  sdsmain.resultrows          ,
  sdsmain.resultseek          ,
  sdsmain.resulttime          ,
  sdsmain.totalfields         ,
  sdsmain.query               ,    }

{ -- SMTP exports -- }
  SmtpAttach              ,
  SmtpClose               ,
  SmtpConnect             ,
  SmtpFree                ,
  SmtpGetHeader           ,
  SmtpSetMessage          ,
  SmtpSend                ,
  SmtpSetHeader           ,
  SmtpSetTextType         ,
  SmtpPutHeader           ,

{ -- Substring exports -- }
  substrexists            ,
  substriexists           ,
  substrpos               ,
  substripos              ,
  substrrpos              ,
  substrirpos             ,
  substrcount             ,
  substricount            ,
  substrreplace           ,
  substrireplace          ,
  substrstrip             ,
  substristrip            ,
  substrsplit             ,
  substrisplit            ,
  strcomp                 ,
  stricomp                ,
  strncomp                ,
  strincomp               ,
  strconvint             ,
  strconvfloat           ,
  strisint               ,
  strisfloat             ,
  strreverse              ,
  strtrimleft            ,
  strtrimright           ,
  strtrim                 ,

{ -- urlencode exports -- }
  UrlDecode               ,
  UrlEncode               ,

{ -- web exports -- }
                                                                                 
  { CGI Variable Functions }
    CountCGIVars                          ,
    GetCGIVar                             ,
    GetCGIVar_S                           ,
    GetCGIVarAsFloat                      ,
    GetCGIVarAsInt                        ,
    GetCGIVar_SafeHTML                    ,
    FetchCGIVarName                       ,
    FetchCGIVarValue                      ,
    IsCgiVar                              ,
    GetCGIVar_SF                          ,

  { Cookie Functions }
    CountCookies                          ,
    FetchCookieName                       ,
    FetchCookieValue                      ,
    GetCookie                             ,
    GetCookieAsFloat                      ,
    GetCookieAsInt                        ,
    IsCookie                              ,
    SetCookie                             ,
    SetCookieAsFloat                      ,
    SetCookieAsInt                        ,
    SetCookieEx                           ,
    SetCookieAsFloatEx                    ,
    SetCookieAsIntEx                      ,
    UnsetCookie                           ,
    UnsetCookieEx                         ,

  { Config Functions }
    CountWebConfigVars                    ,
    FetchWebConfigVarName                 ,
    FetchWebConfigVarValue                ,
    GetWebConfigVar                       ,
    IsWebConfigVar                        ,
    SetWebConfigVar                       ,

  { Environment Variable Functions }
//    GetEnvVar                             , //MOVED TO PWUENVVAR.PAS
    IsEnvVar                              ,

  { Filtering Functions }
    FilterHTML                            ,
    FilterHTML_S                          ,
    TrimBadChars                          ,
    TrimBadChars_file                     ,
    TrimBadChars_dir                      ,
    TrimBadChars_S                        ,

  { Header Functions }
    CountWebheaders                       ,
    FetchWebHeaderName                    ,
    FetchWebHeaderValue                   ,
    GetWebHeader                          ,
    IsWebHeader                           ,
    SetWebHeader                          ,
    UnsetWebHeader                        ,
    PutWebHeader                          ,

  { Output/Write Out Functions/Procedures }
    WebWrite                              ,
    WebWriteA                             ,
    WebWriteF                             ,
    WebWriteFF                            ,
    WebWriteF_Fi                          ,
    WebWriteLn                            ,
    WebWriteLnF                           ,
    WebWriteLnFF                          ,
    WebWriteLnF_Fi                        ,
    WebBufferOut                          ,
    WebFileOut                            ,
    WebResourceOut                        ,
    WebTemplateOut                        ,
    WebTemplateRaw                        ,
    WebFormat                             ,
    WebFormatAndFilter                    ,
    WebFormat_SF                          ,

  { RTI Functions }
    CountRTIVars                          ,
    FetchRTIName                          ,
    FetchRTIValue                         ,
    GetRTI                                ,
    GetRTIAsFloat                         ,
    GetRTIAsInt                           ,
    IsRTI                                 ,

  { Session Functions }
    CountSessVars                         ,
    FetchSessName                         ,
    FetchSessValue                        ,
    GetSess                               ,
    GetSessAsFloat                        ,
    GetSessAsInt                          ,
    IsSess                                ,
    SessDestroy                           ,
    SetSess                               ,
    SetSessAsFloat                        ,
    SetSessAsInt                          ,
    UnsetSess                             ,

  { Upload File Functions }
    FetchUpfileName                       ,
    GetUpFileName                         ,
    GetUpFileSize                         ,
    GetUpFileType                         ,
    CountUpFiles                          ,
    IsUpFile                              ,
    SaveUpFile                            ,

  { Web Variable Functions/Procedures }
    CountWebVars                          ,
    FetchWebVarName                       ,
    FetchWebVarValue                      ,
    GetWebVar                             ,
    GetWebVar_S                           ,
    GetWebVarAsFloat                      ,
    GetWebVarAsInt                        ,
    SetWebVar                             ,
    SetWebVarAsFloat                      ,
    SetWebVarAsInt                        ,
    IsWebVar                              ,
    UnsetWebVar                           ,

  { Utility/Tools Functions }
    LineEndToBR                           ,
    RandomStr                             ,
    XORCrypt                              ,

  { Error Functions }
    ThrowWebError

{END};


// export memory manager from library for CGI program to use
procedure GetMemMan(out MemMan: TMemoryManager); stdcall;
begin
  GetMemoryManager(MemMan);
end;

exports
  GetMemMan name 'GetSharedMemMan';

begin

end.
