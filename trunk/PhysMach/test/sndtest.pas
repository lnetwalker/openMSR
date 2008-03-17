program sndtest;

{ dependecies: libesd0-dev,esound }
{ start /usr/bin/esd for propper function }

function esd_play_file(const name_prefix, filename: PChar; fallback:Integer): Integer; cdecl; external 'libesd';

begin
	esd_play_file('wav','/usr/share/apps/ktuberling/sounds/de/fliege.wav', 0);
end.

