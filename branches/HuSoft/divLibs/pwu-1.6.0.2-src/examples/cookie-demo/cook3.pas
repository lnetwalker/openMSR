program cook2;
{$mode objfpc} {$H+}

uses
  dynpwu;

var
  s: string;

begin
  webwrite('Does the cookie exist: ');
  s := GetCookie('foo');
  if s = '' then 
    webwrite('no') 
  else 
  begin
    webwrite('yes');
    webwrite('<p>');
    webwrite('Cookie value: ');
    webwrite(s);
  end;
end.
