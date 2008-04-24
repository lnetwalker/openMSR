{ PWU/PSP Example Project

  Author:  Lars (L505)

  Website: http://z505.com

Questions:

1. Why use something like CGIEnvVars.DocRoot when you could just use
   GetEnvVar('DOCUMENT_ROOT'); ?

  Answer:

   There is just a bit more code clarity and ease of use when using
   CgiEnvVar.DocRoot 

   Also, in editors that have CodeCompletion, you get to see your available
   variables.  With string constants like 'DOCUMENT_ROOT', you don't.

   In other words, it is purely for making programming more enjoyable and
   possibly neater (you may prefer either method).

2. What is the difference between
   CGIEnvVar.DocRoot versus CGIEnvVars.DocRoot    ???

  Answer:
                 
   Both have different advantages. One trigers a function call, the other 
   gets all the variables at once (Taking more time, but loading them 
   all at once)
}

program EnvVar;

{$mode delphi}{$H+}

uses
 {$ifdef STATIC}
  pwumain,
 {$else}   
  dynpwu,       // main web functions
 {$endif} 
  pwuEnvVar, // convenient CGI environment variable access
  HTMw;      // HTML wrapper unit to make source code cleaner


begin

{  Records are powerful enough that we do not need classes for simple 
   environment variable access. If you feel the need to build a class 
   using properties instead of record functions, you can}

  webwrite('Content length: ' +  CgiEnvVar.ContentLength); //if in delphi mode we don't have to type double brackets ()
  RuleOut; // ...
  webwrite('Content type: ' + CgiEnvVar.ContentType);
  RuleOut; // ...
  webwrite('Document root: ' +CgiEnvVar.DocRoot);
  RuleOut; // ...
  webwrite('Document name (definitely not implemented on all servers): ' +CgiEnvVar.DocName);
  RuleOut;
  webwrite('HTTP Accept: ' +CgiEnvVar.Accept);
  RuleOut;
  webwrite('Path info: ' +CgiEnvVar.PathInfo);
  RuleOut;
  webwrite('Path translated: ' +CgiEnvVar.PathTranslated);
  RuleOut;
  webwrite('Query string: ' +CgiEnvVar.QueryString);
  RuleOut;
  webwrite('Http referer: ' +CgiEnvVar.Referer);
  RuleOut;
  webwrite('Remote address: ' +CgiEnvVar.RemoteAddr);
  RuleOut;
  webwrite('Remote host: ' +CgiEnvVar.RemoteHost);
  RuleOut;
  webwrite('Remote identity: ' +CgiEnvVar.RemoteIdent);
  RuleOut;
  webwrite('Request method: ' +CgiEnvVar.RequestMethod);
  RuleOut;
  webwrite('Remote user: ' +CgiEnvVar.RemoteUser);
  RuleOut;
  webwrite('Script name: ' +CgiEnvVar.ScriptName);
  RuleOut;
  webwrite('Server port: ' +CgiEnvVar.ServerPort);
  RuleOut;
  webwrite('Server protocol: ' +CgiEnvVar.ServerProtocol);
  RuleOut;
  webwrite('User agent: ' +CgiEnvVar.UserAgent);
  RuleOut;
  webwrite('Gateway interface: ' +CgiEnvVar.GateIntf);
  RuleOut;
  webwrite('Accept encoding: ' +CgiEnvVar.AcceptEncod);
  RuleOut;
  webwrite('Accept languages: ' +CgiEnvVar.AcceptLang);
  RuleOut;
  webwrite('Cookie: ' +CgiEnvVar.Cookie);
  RuleOut;
  webwrite('Forwarded: ' +CgiEnvVar.Forwarded);
  RuleOut;
  webwrite('Request  URI: ' +CgiEnvVar.RequestURI);
  RuleOut;
  webwrite('Host: ' +CgiEnvVar.Host);
  RuleOut;
  webwrite('Pragma: ' +CgiEnvVar.Pragma);
  RuleOut;
  webwrite('Script File Name (definitely not implemented on all servers): ' +CgiEnvVar.ScriptFileName);
  RuleOut;
  webwrite('Server admin: ' +CgiEnvVar.ServerAdmin);
  RuleOut;
  webwrite('Server name: ' +CgiEnvVar.ServerName);
  RuleOut;
  webwrite('Server signature: ' +CgiEnvVar.ServerSig);
  RuleOut;
  webwrite('Remote port: ' +CgiEnvVar.RemotePort);
  RuleOut;
  webwrite('Server software: ' +CgiEnvVar.ServerSoft);
  RuleOut;
  webwrite('If modified since: ' +CgiEnvVar.IfModSince);
  RuleOut;

  webwrite('<i>NOTE: NOT ALL SERVERS IMPLEMENT ALL THE ABOVE VARIABLES! Also, only certain variables are triggered at certain times, for example pragma and cookie.</i>');
  
  {    RuleOut = <hr>, see HTMw.pas  }

end.





























