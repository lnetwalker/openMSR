unit pwuerrors; {$ifdef fpc}{$mode objfpc}{$h+}{$endif}

interface

type
  errcode = word; // incase we have more than 255 errors, word allows plenty

const
  GENERAL_ERR = 0;
  OK = 1;  
  FILE_READ_ERR = 2; // file not found or can't open
  
        
implementation  

end.
  
  
