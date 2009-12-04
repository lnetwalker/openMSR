program iowarriortest;

uses crt,iowkit_io_access;

var i : byte;

begin
  iow_hwinit('',255);
  while true do begin
    i:=iow_read_ports(10);
    iow_write_ports(11,i);
    //delay(200);
    i:=iow_read_ports(12);
    iow_write_ports(13,i);
    //delay(200);
    //writeln (iow_read_ports(10));
  end;
end.