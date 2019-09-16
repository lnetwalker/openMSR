program pingchk;
{$mode objfpc}
uses SysUtils,pingsend;


var
  Ping: TPINGSend;
  Hosts: Array[1..10] of string;
  i: byte;

begin
  Hosts[1]:='firewall';
  Hosts[2]:='www.eilers.net';

  for i:=1 to 2 do begin
    Ping := TPINGSend.Create;
    try
      Ping.Timeout:=750;
      if Ping.Ping(hosts[i]) = True then
      begin
        writeln ('Reply from ' + Hosts[i] + ' in: ' + IntToStr(Ping.PingTime) + ' ms');
      end
      else
      begin
        writeln ('No response in: ' + IntToStr(Ping.Timeout) + ' ms');
      end;
    finally
     Ping.Free;
    end;
  end;
end.
