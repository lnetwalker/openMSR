program cook2;
{$mode objfpc} {$H+}

uses
  dynpwu;

var
  s: string;

begin
  UnsetCookie('foo');
  webwrite('Does the cookie still exist: ');
  s := GetCookie('foo');
  if s = '' then webwrite('no') else webwrite('yes');
end.