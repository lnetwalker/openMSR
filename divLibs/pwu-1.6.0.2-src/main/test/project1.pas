{

 Program to test to see if GENERALLY the shared memory manager is working:

 So far the tests have proved as follows:

 ON LINUX

  - cmem caused a seg fault! this is an FPC bug, reported in FPC bug repository

  - using no shared memory manager at all did not cause a seg fault, but when
    testing PasForum codenamed "Bubble" there were random access violations.
    This was expected!
   
  - Trustmaster's suggestion, using an excellent memory manager trick, causes no
    seg fault. (see source code marked Jan 24-2006)
    Any problem with Trustmaster's trick? To be announced after testing
    PasForum codenamed Bubble2 .
  
  
 ON WIN32

  - cmem caused no seg fault on simple testing
    
  - using no shared memory manager did not cause seg fault on basic testing.
    This does not mean it is okay to not use one!
    
    
  Regards,
   Lars (L505)
}
    

program project1;


{$IFDEF FPC}{$MODE OBJFPC}{$H+}
  {$IFDEF EXTRA_SECURE}
   {$R+}{$Q+}{$CHECKPOINTER ON}
  {$ENDIF}
{$ENDIF}

uses
{  cmem,}
 dynpwu; // loads the pwu library and has all imported functions declared.


begin

  webwriteln('testing');
  webwriteln('testing');
  webwriteln('yo man');
  webwriteln('yo man');
  webwriteln('yo man');
  webwriteln('a general test');
  webwriteln('a general test');
  webwriteln('a general test');
  webwriteln('shared memory test');
  webwriteln('shared memory test');
  webwriteln('repetitive memory test');
  webwriteln('repetitive memory test');
  webwriteln('repetitive memory test');
  webwriteln('memory test');
  webwriteln('memory test');
  webwriteln('memory test');

  //readln; //DEBUG
end.

