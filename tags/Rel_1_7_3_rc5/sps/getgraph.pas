unit getgraph;

{ unit zur ermittlung der grafikkarte     }
{ ergebnis steht nach einbinden der unit  }
{ in variable graph_mode zur verfueg.     }
{ (c) by HuSoft 23/09/93                  }

interface

type grafikkarte=(none,cga,mda,ega,dumm1,dumm2,dumm3,hga,dumm4,vga);
var graph_mode : Grafikkarte;

implementation

uses dos,crt;

var regs:registers;
    testbit7,x : BYTE;

function test_6845(adr :word):boolean;  { testet ob an der uebergebenen  }
var altwert,testwert:byte;              { adresse ein crt 6845 inst. ist }
begin
{     port[adr]:=$0A;					}
{     altwert:=port[adr+1];				}
{     port[adr+1]:=$4f;					}
{     delay(5);						}
{     testwert:=port[adr+1];				}
{     port[adr+1]:=altwert;				}
{     if testwert=$4f then test_6845:=true		}
{     else test_6845:=false;				}
end;

function check_grafik_karte(dummy:byte):grafikkarte;
var graphmode:grafikkarte;
begin
{     regs.ax:=$1a00;  { test vga tischer S. 677 }	}
{     intr($10,regs);					}
{     if regs.al=$1a then graphmode:=vga		}
{     else begin       { test ega }			}	
{          regs.ah:=$12;				}
{          regs.bl:=$10;				}
{          intr($10,regs);				}
{          if regs.bl=$10 then graphmode:=ega		}
{          else        { test cga }			}
{             if test_6845($3d4)=true then graphmode:=cga}
{             else     { test mda / hga }		}
{                if test_6845($3b4)=true then begin	}
{                   graphmode:=mda;			}
{                   testbit7:=port[$3ba];		}
{                   x:=0;				}
{                   repeat				}
{                      inc(x)				}
{                   until ((port[$3ba] and 128)<>testbit7) or (x>100);}
{                   if x<100 then graphmode:=hga;	}
{                end					}
{                else graphmode:=none;			}
{     end;						}
{     check_grafik_karte:=graphmode;			}
end;

begin
     Graph_mode:=check_grafik_karte(0);
end.


