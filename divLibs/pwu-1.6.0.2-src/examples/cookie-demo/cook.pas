program cook;
{$mode objfpc} {$H+}

uses
  dynpwu;

var
  s: string;
begin

  SetCookie('foo', 'bar');
  s := GetCookie('foo');
  webwrite('What is the cookie value: ');
  webwrite(s);

end.