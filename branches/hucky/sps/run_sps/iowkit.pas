//
// IO-Warrior kit library V1.4 include file
//

unit iowkit;

interface

uses
  oldlinux;

const
  // IoWarrior vendor & product IDs
  IOWKIT_VENDOR_ID        = $07c0;
  IOWKIT_VID              = IOWKIT_VENDOR_ID;

  // IO-Warrior 40
  IOWKIT_PRODUCT_ID_IOW40 = $1500;
  IOWKIT_PID_IOW40        = IOWKIT_PRODUCT_ID_IOW40;

  // IO-Warrior 24
  IOWKIT_PRODUCT_ID_IOW24 = $1501;
  IOWKIT_PID_IOW24        = IOWKIT_PRODUCT_ID_IOW24;

  // Max number of pipes per IOW device
  IOWKIT_MAX_PIPES   = 2;

  // pipe names
  IOW_PIPE_IO_PINS      = 0;
  IOW_PIPE_SPECIAL_MODE = 1;

  // Max number of IOW devices in system
  IOWKIT_MAX_DEVICES = 16;

  // IOW Legacy devices open modes
  IOW_OPEN_SIMPLE    = 1;
  IOW_OPEN_COMPLEX   = 2;

  // first IO-Warrior revision with serial numbers
  IOW_NON_LEGACY_REVISION = $1010;

type
  PIOWKIT_REPORT = ^IOWKIT_REPORT;
  IOWKIT_REPORT = packed record
    ReportID: Byte;
  case Boolean of
    False: (Value: DWORD;);
    True: (Bytes: array [0..3] of Byte;);
  end;

  PIOWKIT40_IO_REPORT = ^IOWKIT40_IO_REPORT;
  IOWKIT40_IO_REPORT = packed record
    ReportID: Byte;
  case Boolean of
    False: (Value: DWORD;);
    True: (Bytes: array [0..3] of Byte;);
  end;

  PIOWKIT24_IO_REPORT = ^IOWKIT24_IO_REPORT;
  IOWKIT24_IO_REPORT = packed record
    ReportID: Byte;
  case Boolean of
    False: (Value: WORD;);
    True: (Bytes: array [0..1] of Byte;);
  end;

  PIOWKIT_SPECIAL_REPORT = ^IOWKIT_SPECIAL_REPORT;
  IOWKIT_SPECIAL_REPORT = packed record
    ReportID: Byte;
    Bytes: array [0..6] of Byte;
  end;

const
  IOWKIT_REPORT_SIZE = SizeOf(IOWKIT_REPORT);
  IOWKIT40_IO_REPORT_SIZE = SizeOf(IOWKIT40_IO_REPORT);
  IOWKIT24_IO_REPORT_SIZE = SizeOf(IOWKIT24_IO_REPORT);
  IOWKIT_SPECIAL_REPORT_SIZE = SizeOf(IOWKIT_SPECIAL_REPORT);

type
  // Opaque IO-Warrior handle
  IOWKIT_HANDLE = Pointer;

function IowKitOpenDevice: IOWKIT_HANDLE; stdcall;
procedure IowKitCloseDevice(devHandle: IOWKIT_HANDLE); stdcall;
function IowKitWrite(devHandle: IOWKIT_HANDLE; numPipe: Cardinal;
  buffer: PChar; length: Cardinal): Cardinal; stdcall;
function IowKitRead(devHandle: IOWKIT_HANDLE; numPipe: Cardinal;
  buffer: PChar; length: Cardinal): Cardinal; stdcall;
function IowKitReadImmediate(devHandle: IOWKIT_HANDLE; var value: DWORD): LongBool; stdcall;
function IowKitGetNumDevs: Cardinal; stdcall;
function IowKitGetDeviceHandle(numDevice: Cardinal): IOWKIT_HANDLE; stdcall;
function IowKitSetLegacyOpenMode(legacyOpenMode: Cardinal): LongBool; stdcall;
function IowKitGetProductId(devHandle: IOWKIT_HANDLE): Cardinal; stdcall;
function IowKitGetRevision(devHandle: IOWKIT_HANDLE): Cardinal; stdcall;
function IowKitGetThreadHandle(devHandle: IOWKIT_HANDLE): THandle; stdcall;
function IowKitGetSerialNumber(devHandle: IOWKIT_HANDLE; serialNumber: PWideChar): LongBool; stdcall;
function IowKitSetTimeout(devHandle: IOWKIT_HANDLE; timeout: Cardinal): LongBool; stdcall;
function IowKitSetWriteTimeout(devHandle: IOWKIT_HANDLE; timeout: Cardinal): LongBool; stdcall;
function IowKitCancelIo(devHandle: IOWKIT_HANDLE; numPipe: Cardinal): LongBool; stdcall;
function IowKitVersion: PChar; stdcall;

implementation

const
  IOWKITDllName = 'iowkit';

function IowKitOpenDevice: IOWKIT_HANDLE; stdcall; external IOWKITDllName name 'IowKitOpenDevice';
procedure IowKitCloseDevice(devHandle: IOWKIT_HANDLE); stdcall; external IOWKITDllName name 'IowKitCloseDevice';
function IowKitWrite(devHandle: IOWKIT_HANDLE; numPipe: Cardinal; buffer: PChar; length: Cardinal): Cardinal; stdcall; external IOWKITDllName name 'IowKitWrite';
function IowKitRead(devHandle: IOWKIT_HANDLE; numPipe: Cardinal;buffer: PChar; length: Cardinal): Cardinal; stdcall; external IOWKITDllName name 'IowKitRead';
function IowKitReadImmediate(devHandle: IOWKIT_HANDLE; var value: DWORD): LongBool; stdcall; external IOWKITDllName name 'IowKitReadImmediate';
function IowKitGetNumDevs: Cardinal; stdcall; external IOWKITDllName name 'IowKitGetNumDevs';
function IowKitGetDeviceHandle(numDevice: Cardinal): IOWKIT_HANDLE; stdcall; external IOWKITDllName name 'IowKitGetDeviceHandle';
function IowKitSetLegacyOpenMode(legacyOpenMode: Cardinal): LongBool; stdcall; external IOWKITDllName name 'IowKitSetLegacyOpenMode';
function IowKitGetProductId(devHandle: IOWKIT_HANDLE): Cardinal; stdcall; external IOWKITDllName name 'IowKitGetProductId';
function IowKitGetRevision(devHandle: IOWKIT_HANDLE): Cardinal; stdcall; external IOWKITDllName name 'IowKitGetRevision';
function IowKitGetThreadHandle(devHandle: IOWKIT_HANDLE): THandle; stdcall; external IOWKITDllName name 'IowKitGetThreadHandle';
function IowKitGetSerialNumber(devHandle: IOWKIT_HANDLE; serialNumber: PWideChar): LongBool; stdcall; external IOWKITDllName name 'IowKitGetSerialNumber';
function IowKitSetTimeout(devHandle: IOWKIT_HANDLE; timeout: Cardinal): LongBool; stdcall; external IOWKITDllName name 'IowKitSetTimeout';
function IowKitSetWriteTimeout(devHandle: IOWKIT_HANDLE; timeout: Cardinal): LongBool; stdcall; external IOWKITDllName name 'IowKitSetWriteTimeout';
function IowKitCancelIo(devHandle: IOWKIT_HANDLE; numPipe: Cardinal): LongBool; stdcall; external IOWKITDllName name 'IowKitCancelIo';
function IowKitVersion: PChar; stdcall; external IOWKITDllName name 'IowKitVersion';

end.
