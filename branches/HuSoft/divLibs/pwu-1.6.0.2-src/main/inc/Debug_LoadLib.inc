  if MainLibHandle = NilHandle then
  begin
    ThrowLibError('1: failed to load or not found: ' + LibPath);
    // ERROR #1 (ERR1): Cannot load PSP library, or cannot find PSP library       // LUFDOC
    // PATH to PSP/PWU library may be incorrect in PWU CONFIG file. Check
    // the first line of the config file for the path to the library.
  end;

