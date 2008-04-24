Notes:

 -the demo EXE and ELF files are CGI programs. Rename the extension to CGI if 
  you need to do this for them to run on the server. You can test them on the
  command line but they display HTML.. so not to much you can see there.
  
 -the main PASCAL TO HTML functions are in PasHiliter.pas 

 -although some included project files are DPR extension, I tested in FPC.

 -you don't have to use the pascal tokenizer dll. Just define STATIC_HILITER 
  in the demo or take out DYN prefixed units.

 -you don't have to use beautiful pascal widgets with the highlighter/tokenizer.
  they do not rely on each other. You can use plain HTML or HTML templates.
  The tokenizer is meant to be modular and doesn't rely on PWU or HTML.

 -included exe's (if any)  compiled in Windows 2000 i386 with FPC 2.0.4

 -included elf's (if any) compiled in Debian Linux i386 with FPC 2.0.4

 -the library uses ansistrings. Memory is shared using the pwu dynamic link 
  library. Normally one can't export functions that use ansistrings from a dll, 
  but we can when we use the pwu shared memory manager.

 -to use these functions without using any DLL's, define STATIC_HILITER or take 
  out all the DYN prefixed units in uses clause and replace them with units 
  without DYN.

 -The actual PASHILITER.PAS and tokenizer does not rely on PWU. This hilighter 
  can be used in command line programs or desktop software programs.

 -to use the HTML hilighter without using the PWU dll just takeout DYNPWU 
  and replace with PWUMAIN. Obtain PWUMAIN from pwu-1.6.0.0 on  sourceforge
  
 -to use the tokenizer without any HTML (desktop program, example TMemo or 
  TRichEdit) just don't use html related functions, such as the ones in 
  pashiliter.pas. Use the tokenizer itself and make your own PasToRTF or
  PasToText converters.
  
