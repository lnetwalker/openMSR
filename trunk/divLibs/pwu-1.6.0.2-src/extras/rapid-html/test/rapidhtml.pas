{ OBSOLETE OBSOLETE

  see /examples/rapidhtml/

  Program to test out HTML WRAPPER functions in HTMw.pas


  
  --
  L505
  
--------------------------------------------------------------------------------
  TO DO
--------------------------------------------------------------------------------

   - replace writeln with webwriteln

--------------------------------------------------------------------------------

}
program rapidhtml;

{$mode objfpc}{$H+}

uses
  HTMw; // html wrapper
  

var
  HeaderPan: THtmPanel;
    
   

{ Another way of wrapping HTML, but less elegant than a record structure like
  in wHTM.pas }
procedure TestDIVout(left, top, height, width, pad: integer; bgcolor: string;
  zindex: integer; text: string);
begin
  writeln('<div style="position: absolute;');
  writeln('   left: ', Left,'px;');
  writeln('   top: ', top ,'px;');
  writeln('   height: ', height , 'px;');
  writeln('   width: ', width , 'px;');
  writeln('   padding: ', pad , 'em;');
  writeln('   background-color: '+ bgcolor + ';');
  writeln('   z-index: ', zindex , ';');
  writeln('   ">');
  writeln(text);
  writeln('</div>');
end;



begin
  htmB;

  writeln('test');
  writeln;
  writeln;
  TestDIVout
        ({left}    2,
         {top}     2,
         {height}  50,
         {width}   60,
         {padding} 3,
         {bgcolor} 'black' ,
         {index}   1 ,
         {text}    'testing div area'
        );
        
  writeln;

  // clean source code with no HTML obfuscation ( no < < > > )
  HeaderPan.bgcolor:= 'blue';
  HeaderPan.height:= 100;
  HeaderPan.width:= 100;
  HeaderPan.left:= 0;
  headerpan.top:= 0;
  headerpan.pad:= 0;
  headerpan.text:= 'this is a test to see if it works';
  
  PixelBoxOut(HeaderPan);

  htmE;
  readln;
end.

