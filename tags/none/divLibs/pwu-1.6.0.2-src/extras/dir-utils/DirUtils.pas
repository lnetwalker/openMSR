(*******************************************************************************

                              Directory Utilities

********************************************************************************

  Functions for dealing with directories and their contents. Find files,
  wildcard matches, subdirectories.

  Authors/Credits: L505 (Lars),

*******************************************************************************)

unit dirutils;

{$mode objfpc}{$H+}

interface

uses
  sysutils; // future: compactsysutils

type
  TStrArray = array of string;

  TDirContents = record
    Dirs: TStrArray;
    DirCount: integer;
    Files: TStrArray;
    FileCount: integer;
  end;

  TDirNames = record
    Dirs: TStrArray;
    Count: integer;
  end;
                                
  TFileNames = record
    Files: TStrArray;
    Count: integer;
  end;

procedure ClearFileNames(var fn: TFileNames);
procedure GetDirContent(Dir: string; const wildcard: string; var result: TDirContents);
procedure GetDirContent(Dir: string; var result: TDirContents); // overloaded
procedure GetDirContent_nodots(Dir: string; const wildcard: string; var result: TDirContents);
procedure GetDirContent_nodots(Dir: string; var result: TDirContents);   // overloaded
procedure GetSubDirs(Dir: string; const wildcard: string; var result: TDirNames);
procedure GetSubDirs(Dir: string; var result: TDirNames); // overloaded
procedure GetFiles(Dir: string; const wildcard: string; var result: TFileNames);
procedure GetFiles(Dir: string; var result: TFileNames); // overloaded

implementation

procedure ClearFileNames(var fn: TFileNames);
begin
  setlength(fn.files, 0);
  fn.count:= 0;
end;

{ find all files in a given directory, with wildcard match
   READ-ONLY FILES are skipped }
procedure GetFiles(Dir: string; const wildcard: string; var result: TFileNames);
var
  Info : TSearchRec;
begin
  // must have trailing slash
  if dir[length(dir)] <> DirectorySeparator then dir:= dir + DirectorySeparator;
  //initialize count, appends if result has existing array contents
  if length(result.files) < 1 then 
    result.Count:= 0 
  else 
     result.Count:= length(result.files); 
  if FindFirst(dir + wildcard, faAnyFile and faDirectory, Info) = 0 then
  begin
    repeat
      // keep track of file names
      if (info.Attr and faDirectory) <> faDirectory then
      begin
        Inc(result.Count);
        SetLength(result.files, result.Count);
        result.files[result.Count - 1]:= info.Name;
      end;
    until FindNext(info) <> 0;
  end;
  FindClose(Info);
end;

{ find all files in a given directory
   READ-ONLY FILES are skipped }
procedure GetFiles(Dir: string; var result: TFileNames);
begin
  GetFiles(dir, '*', result);
end;


{ find all subdirectory names in a given directory, with wildcard
   READ-ONLY DIRECTORIES are skipped, dotted directories skipped }
procedure GetSubDirs(Dir: string; const wildcard: string; var result: TDirNames);
var
  Info : TSearchRec;
begin
  // must have trailing slash
  if dir[length(dir)] <> DirectorySeparator then dir:= dir + DirectorySeparator;
  //initialize count, appends if result has existing array contents
  if length(result.dirs) < 1 then 
    result.Count:= 0 
  else 
    result.Count:= length(result.dirs); 

  if FindFirst(dir + wildcard, faAnyFile and faDirectory, Info) = 0 then
  begin
    repeat
      // keep track of directory names
      if (info.Attr and faDirectory) = faDirectory then
      begin
        // we want only subdirectories, not dots like ../ and ./
        if (info.name = '.') or (info.name = '..') then continue;
        Inc(result.Count);
        SetLength(result.dirs, result.Count);
        result.dirs[result.Count - 1]:= info.name;
      end;
    until FindNext(info) <> 0;
  end;
  FindClose(Info);
end;

{ find all subdirectory names in a given directory
   READ-ONLY DIRECTORIES are skipped }
procedure GetSubDirs(Dir: string; var result: TDirNames);
begin
  GetSubDirs(Dir, '*', result);
end;

{ find contents of any directory with wildcard, but skip dots ../ ./
   READ-ONLY FILES are skipped }
procedure GetDirContent_nodots(Dir: string; const wildcard: string; var result: TDirContents);
var
  Info : TSearchRec;
begin
  // must have trailing slash
  if dir[length(dir)] <> DirectorySeparator then dir:= dir + DirectorySeparator;
  // initialize counts, appends if there are existing contents
  if length(result.dirs) < 1 then 
    result.dirCount:= 0 
  else 
    result.dirCount:= length(result.dirs); 
  if length(result.files) < 1 then 
    result.fileCount:= 0 
  else 
    result.fileCount:= length(result.files);       
  
  if FindFirst(dir + wildcard, faAnyFile and faDirectory, Info) = 0 then
  begin
    repeat
      // keep track of directory names
      if (info.Attr and faDirectory) = faDirectory then
      begin
        // we want only true directories, not dots like ../ and ./
        if (info.name = '.') or (info.name = '..') then continue;
        Inc(result.DirCount);
        SetLength(result.dirs, result.DirCount);
        result.dirs[result.DirCount - 1]:= info.name;
      end else
      begin
        Inc(result.FileCount);
        SetLength(result.files, result.FileCount);
        result.files[result.FileCount - 1]:= info.Name;
      end;
    until FindNext(info) <> 0;
  end;
  FindClose(Info);
end;

{ find contents of any directory but skip dots like ../ ./
  READ ONLY FILES are skipped }
procedure GetDirContent_nodots(Dir: string; var result: TDirContents);
begin
  GetDirContent_nodots(dir, '*', result);
end;

{ find contents of any directory with a wildcard filter
  READ ONLY FILES are skipped }
procedure GetDirContent(Dir: string; const wildcard: string; var result: TDirContents);
var
  Info : TSearchRec;
begin
  // must have trailing slash
  if dir[length(dir)] <> DirectorySeparator then dir:= dir + DirectorySeparator;
  // initialize counts, appends if there are existing contents
  if length(result.dirs) < 1 then 
    result.dirCount:= 0 
  else 
    result.dirCount:= length(result.dirs); 
  if length(result.files) < 1 then 
    result.fileCount:= 0 
  else 
    result.fileCount:= length(result.files);         
  if FindFirst(dir + wildcard, faAnyFile and faDirectory, Info) = 0 then
  begin
    repeat
      // keep track of directory names
      if (info.Attr and faDirectory) = faDirectory then
      begin
        Inc(result.DirCount);
        SetLength(result.dirs, result.DirCount);
        result.dirs[result.DirCount - 1]:= info.name;
      end else
      begin
        Inc(result.FileCount);
        SetLength(result.files, result.FileCount);
        result.files[result.FileCount - 1]:= info.Name;
      end;
    until FindNext(info) <> 0;
  end;
  FindClose(Info);
end;

{ find contents of any directory
  READ ONLY FILES are skipped }
procedure GetDirContent(Dir: string; var result: TDirContents);
begin
  GetDirContent(Dir, '*.*', result);
end;



end.

