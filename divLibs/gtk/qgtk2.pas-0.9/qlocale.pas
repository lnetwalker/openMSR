unit qlocale;

{ Convert central European encoding for qgtk2.pas 
  ------------------------------------------------


  (c) 2002-2005 Jirka Bubenicek  -  hebrak@yahoo.com


  License: GNU GENERAL PUBLIC LICENSE

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

}


interface

const

e_ascii  =0;
e_utf_8  =1;
e_8859_2 =2;
e_1250   =3;
e_dos852 =4;

gtk_encoding : integer = e_utf_8;
pas_encoding : integer = e_utf_8;
{you can set  pas_encoding in your program

 gtk_encoding is in gtk2 utf8
 pas_encoding is encoding of the program source and of the input-output }



kodascii:string='A~LxLSS"SSTZ-ZZ''a,l''ls~,sstz"zzRAAAALCCCEEEEIIDDNNOOOOxRUUUUYTsraaaalccceeeeiiddnnoooo/ruuuuyt';
kod8859 :string='¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäåæçèéêëìíîïğñòóôõö÷øùúûüış';
kod1250 :string='¥¢£¤¼Œ§¨Šª­¯°¹²³´¾œ¡¸šºŸ½¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäåæçèéêëìíîïğñòóôõö÷øùúûüış';
kod852  :string='¤ôÏ•—õùæ¸›ğ¦½ø¥òˆï–˜ó÷ç­œ«ñ§¾èµ¶Æ‘€¬¨Ó·Ö×ÒÑãÕàâŠ™üŞéëšíİáê ƒÇ„’†‡Ÿ‚©‰Ø¡ŒÔĞäå¢“‹”öı…£ûìî';
kod2utf8:string='Ä„Ë˜ÅÂ¤Ä½ÅšÂ§Â¨Å ÅÅ¤Å¹Â­Å½Å»Â°Ä…Ë›Å‚Â´Ä¾Å›Ë‡Â¸Å¡ÅŸÅ¥ÅºËÅ¾Å¼Å”ÃÃ‚Ä‚Ã„Ä¹Ä†Ã‡ÄŒÃ‰Ä˜Ã‹ÄšÃÃÄÄÅƒÅ‡Ã“Ã”ÅÃ–Ã—Å˜Å®ÃšÅ°ÃœÃÅ¢ÃŸÅ•Ã¡Ã¢ÄƒÃ¤ÄºÄ‡Ã§ÄÃ©Ä™Ã«Ä›Ã­Ã®ÄÄ‘Å„ÅˆÃ³Ã´Å‘Ã¶Ã·Å™Å¯ÃºÅ±Ã¼Ã½Å£';


function e_conv(s : string; ie, oe : integer): string;
function encode(s: string):string;
function decode(s: string):string;



implementation


function e_conv(s : string; ie, oe : integer): string;
var ki1, ki2, ko1, ko2, so : string;
    i, j, k :integer;
begin
if (ie = oe) or (ie = e_ascii ) then begin e_conv:=s; exit; end;
case ie of e_ascii  : begin ki1:=kodascii; ki2:=''; end;
           e_8859_2 : begin ki1:=kod8859;  ki2:=''; end;
           e_1250   : begin ki1:=kod1250;  ki2:=''; end;
           e_dos852 : begin ki1:=kod852;   ki2:=''; end;
          else{utf-8} begin
                       ki1:=''; ki2:='';
		       k:=1;
		       while k<length(kod2utf8) do
		        begin
			 ki1:=ki1+kod2utf8[k];
			 ki2:=ki2+kod2utf8[k+1];
			 k:=k+2;
			end;
		      end;
end;
case oe of e_ascii  : begin ko1:=kodascii; ko2:=''; end;
           e_8859_2 : begin ko1:=kod8859;  ko2:=''; end;
           e_1250   : begin ko1:=kod1250;  ko2:=''; end;
           e_dos852 : begin ko1:=kod852;   ko2:=''; end;
          else{utf-8} begin
                       ko1:=''; ko2:='';
		       k:=1;
		       while k<length(kod2utf8) do
		        begin
			 ko1:=ko1+kod2utf8[k];
			 ko2:=ko2+kod2utf8[k+1];
			 k:=k+2;
			end;
		      end;
end;
so:='';

//for i:=1 to length(s) do
i:=0;
while i< length(s) do
  begin
   inc(i);
    so:=so+s[i];
    if ( i<length(s) ) or ( ki2='' ) then
     for j:=1 to length(ki1) do
       if (s[i]=ki1[j]) and ( (ki2='') or (s[i+1]=ki2[j]) ) then
          begin
           so[length(so)]:=ko1[j];
           if ko2<>'' then so:=so+ko2[j];
           if ki2<>'' then inc(i);
           break;
          end;
  end;
e_conv:=so;
end;




function encode(s: string):string;
begin
encode:=e_conv(s, pas_encoding, gtk_encoding );
end;


function decode(s: string):string;
begin
decode:=e_conv(s, gtk_encoding, pas_encoding );;
end;


begin
if    ( length(kodascii)<>length(kod8859) )
   or ( length(kodascii)<>length(kod1250) )
   or ( length(kodascii)<>length(kod852) )
   or ( 2*length(kodascii)<>length(kod2utf8) )
 then writeln('qlocale error - kod strings length');
end.
