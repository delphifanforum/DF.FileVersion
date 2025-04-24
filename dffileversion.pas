unit DF.FileVersion;

interface

uses
  Winapi.Windows,
  Winapi.ImageHlp,
  System.SysUtils,
  System.DateUtils;

type
  /// <summary>
  /// Efficient representation of file and product version information
  /// Requires only 24 bytes of memory (Int64 + Int64 + TDateTime)
  /// </summary>
  TDFFileVersion = record
  private
    /// <summary>
    /// File version storage (64-bit integer)
    /// Bit layout:
    /// - 63..48 = Major
    /// - 47..32 = Minor
    /// - 31..16 = Release
    /// - 15..0  = Build
    /// </summary>
    FFileVersion64: Int64;
    
    /// <summary>
    /// Product version storage (64-bit integer)
    /// Same bit layout as FFileVersion64
    /// </summary>
    FProductVersion64: Int64;
    
    /// <summary>
    /// When the file was built
    /// </summary>
    FBuildDateTime: TDateTime;

    function GetFileVersion32: Integer; inline;
    function GetFileMajor: Integer; inline;
    procedure SetFileMajor(Major: Integer); inline;
    function GetFileMinor: Integer; inline;
    procedure SetFileMinor(Minor: Integer); inline;
    function GetFileRelease: Integer; inline;
    procedure SetFileRelease(Release: Integer); inline;
    function GetFileBuild: Integer; inline;
    procedure SetFileBuild(Build: Integer); inline;

    function GetProductVersion32: Integer; inline;
    function GetProductMajor: Integer; inline;
    procedure SetProductMajor(Major: Integer); inline;
    function GetProductMinor: Integer; inline;
    procedure SetProductMinor(Minor: Integer); inline;
    function GetProductRelease: Integer; inline;
    procedure SetProductRelease(Release: Integer); inline;
    function GetProductBuild: Integer; inline;
    procedure SetProductBuild(Build: Integer); inline;
  public
    /// <summary>
    /// Create a TDFFileVersion record from a file
    /// </summary>
    constructor Create(const FileName: TFileName); overload;
    
    /// <summary>
    /// Create a TDFFileVersion record with specific version information
    /// </summary>
    constructor Create(FileVersion64: Int64; ProductVersion64: Int64;
      BuildDateTime: TDateTime); overload;

    /// <summary>
    /// Returns the compact 32-bit version (Major.Minor.Release) from a 64-bit version
    /// </summary>
    class function GetVersion32(const Version64: Int64): Integer; static; inline;

    /// <summary>
    /// Extract major version from 64-bit version number
    /// </summary>
    class function GetMajor(const Version64: Int64): Integer; static; inline;
    
    /// <summary>
    /// Set major version in 64-bit version number
    /// </summary>
    class procedure SetMajor(var Version64: Int64; Major: Integer); static; inline;

    /// <summary>
    /// Extract minor version from 64-bit version number
    /// </summary>
    class function GetMinor(const Version64: Int64): Integer; static; inline;
    
    /// <summary>
    /// Set minor version in 64-bit version number
    /// </summary>
    class procedure SetMinor(var Version64: Int64; Minor: Integer); static; inline;

    /// <summary>
    /// Extract release version from 64-bit version number
    /// </summary>
    class function GetRelease(const Version64: Int64): Integer; static; inline;
    
    /// <summary>
    /// Set release version in 64-bit version number
    /// </summary>
    class procedure SetRelease(var Version64: Int64; Release: Integer); static; inline;

    /// <summary>
    /// Extract build number from 64-bit version number
    /// </summary>
    class function GetBuild(const Version64: Int64): Integer; static; inline;
    
    /// <summary>
    /// Set build number in 64-bit version number
    /// </summary>
    class procedure SetBuild(var Version64: Int64; Build: Integer); static; inline;

    /// <summary>
    /// Compare two 64-bit version numbers
    /// Returns > 0 if Left > Right, < 0 if Left < Right, 0 if equal
    /// </summary>
    class function Compare(const LeftVersion64, RightVersion64: Int64): Integer; static;
    
    /// <summary>
    /// Compare file versions of two TDFFileVersion records
    /// </summary>
    class function CompareFileVersion(
      const LeftVersion, RightVersion: TDFFileVersion): Integer; static;
      
    /// <summary>
    /// Compare product versions of two TDFFileVersion records
    /// </summary>
    class function CompareProductVersion(
      const LeftVersion, RightVersion: TDFFileVersion): Integer; static;

    /// <summary>
    /// Convert a 64-bit version number to string with desired level of detail
    /// </summary>
    class function ToString(const Version64: Int64; IncludeBuild: Boolean = False; 
      IncludeRelease: Boolean = True; IncludeMinor: Boolean = True): string; static;

    /// <summary>
    /// Convert file version to string with desired level of detail
    /// </summary>
    function FileVersionToString(IncludeBuild: Boolean = False; IncludeRelease: Boolean = True;
      IncludeMinor: Boolean = True): string;

    /// <summary>
    /// Convert product version to string with desired level of detail
    /// </summary>
    function ProductVersionToString(IncludeBuild: Boolean = False; IncludeRelease: Boolean = True;
      IncludeMinor: Boolean = True): string;

    /// <summary>
    /// File version as 32-bit integer (Major.Minor.Release)
    /// </summary>
    property FileVersion32: Integer read GetFileVersion32;
    
    /// <summary>
    /// Major version number of file
    /// </summary>
    property FileMajor: Integer read GetFileMajor write SetFileMajor;
    
    /// <summary>
    /// Minor version number of file
    /// </summary>
    property FileMinor: Integer read GetFileMinor write SetFileMinor;
    
    /// <summary>
    /// Release version number of file
    /// </summary>
    property FileRelease: Integer read GetFileRelease write SetFileRelease;
    
    /// <summary>
    /// Build number of file
    /// </summary>
    property FileBuild: Integer read GetFileBuild write SetFileBuild;

    /// <summary>
    /// Product version as 32-bit integer (Major.Minor.Release)
    /// </summary>
    property ProductVersion32: Integer read GetProductVersion32;
    
    /// <summary>
    /// Major version number of product
    /// </summary>
    property ProductMajor: Integer read GetProductMajor write SetProductMajor;
    
    /// <summary>
    /// Minor version number of product
    /// </summary>
    property ProductMinor: Integer read GetProductMinor write SetProductMinor;
    
    /// <summary>
    /// Release version number of product
    /// </summary>
    property ProductRelease: Integer read GetProductRelease write SetProductRelease;
    
    /// <summary>
    /// Build number of product
    /// </summary>
    property ProductBuild: Integer read GetProductBuild write SetProductBuild;

    /// <summary>
    /// Date and time when the file was built
    /// </summary>
    property BuildDateTime: TDateTime read FBuildDateTime;
    
    /// <summary>
    /// Direct access to the 64-bit file version value
    /// </summary>
    property FileVersion64: Int64 read FFileVersion64;
    
    /// <summary>
    /// Direct access to the 64-bit product version value
    /// </summary>
    property ProductVersion64: Int64 read FProductVersion64;
  end;

implementation

{ TDFFileVersion }

constructor TDFFileVersion.Create(const FileName: TFileName);
var
  Size, Size2: DWord;
  VersionInfo: Pointer;
  FileInfo: PVSFixedFileInfo;
  FileTime: TFILETIME;
  SystemTime: TSYSTEMTIME;

  function GetBuildDateFromPE: TDateTime;
  var
    LoadedImage: TLoadedImage;
    FileNameAnsi: AnsiString;
  begin
    Result := 0;
    FileNameAnsi := AnsiString(FileName);
    
    if MapAndLoad(PAnsiChar(FileNameAnsi), nil, @LoadedImage, False, True) then
    try
      Result := LoadedImage.FileHeader.FileHeader.TimeDateStamp / SecsPerDay + UnixDateDelta;
      Result := TTimeZone.Local.ToLocalTime(Result);
    finally
      UnMapAndLoad(@LoadedImage);
    end;
  end;

begin
  FFileVersion64 := 0;
  FProductVersion64 := 0;
  FBuildDateTime := 0;
  
  if (FileName = '') or not FileExists(FileName) then
    Exit;
    
  Size := GetFileVersionInfoSize(PChar(FileName), Size2);
  if Size > 0 then
  begin
    GetMem(VersionInfo, Size);
    try
      if GetFileVersionInfo(PChar(FileName), 0, Size, VersionInfo) then
      begin
        if VerQueryValue(VersionInfo, '\', Pointer(FileInfo), Size2) then
        begin
          with FileInfo^ do
          begin
            FFileVersion64 := (Int64(dwFileVersionMS) shl 32) or dwFileVersionLS;
            FProductVersion64 := (Int64(dwProductVersionMS) shl 32) or dwProductVersionLS;

            // Try to get build date from version info
            if (dwFileDateLS <> 0) or (dwFileDateMS <> 0) then
            begin
              FileTime.dwLowDateTime := dwFileDateLS;
              FileTime.dwHighDateTime := dwFileDateMS;
              if FileTimeToSystemTime(FileTime, SystemTime) then
                FBuildDateTime := EncodeDate(SystemTime.wYear, SystemTime.wMonth, SystemTime.wDay) +
                  EncodeTime(SystemTime.wHour, SystemTime.wMinute, SystemTime.wSecond, SystemTime.wMilliseconds);
            end;
          end;
        end;
      end;
    finally
      FreeMem(VersionInfo);
    end;
  end;

  // If we couldn't get build date from version info, try PE header
  if FBuildDateTime = 0 then
    FBuildDateTime := GetBuildDateFromPE;
    
  // If that still failed, use file modification time as fallback
  if FBuildDateTime = 0 then
  begin
    var FileData: TWin32FileAttributeData;
    if GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @FileData) then
    begin
      FileTimeToSystemTime(FileData.ftLastWriteTime, SystemTime);
      FBuildDateTime := EncodeDate(SystemTime.wYear, SystemTime.wMonth, SystemTime.wDay) +
        EncodeTime(SystemTime.wHour, SystemTime.wMinute, SystemTime.wSecond, SystemTime.wMilliseconds);
    end;
  end;
end;

constructor TDFFileVersion.Create(FileVersion64, ProductVersion64: Int64; BuildDateTime: TDateTime);
begin
  FFileVersion64 := FileVersion64;
  FProductVersion64 := ProductVersion64;
  FBuildDateTime := BuildDateTime;
end;

class function TDFFileVersion.GetVersion32(const Version64: Int64): Integer;
begin
  Result := (GetMajor(Version64) shl 16) + (GetMinor(Version64) shl 8) + GetRelease(Version64);
end;

class function TDFFileVersion.GetMajor(const Version64: Int64): Integer;
begin
  Result := Version64 shr 48;
end;

class procedure TDFFileVersion.SetMajor(var Version64: Int64; Major: Integer);
begin
  Version64 := (Version64 and $0000FFFFFFFFFFFF) or (Int64(Major and $FFFF) shl 48);
end;

class function TDFFileVersion.GetMinor(const Version64: Int64): Integer;
begin
  Result := (Version64 shr 32) and $FFFF;
end;

class procedure TDFFileVersion.SetMinor(var Version64: Int64; Minor: Integer);
begin
  Version64 := (Version64 and $FFFF0000FFFFFFFF) or (Int64(Minor and $FFFF) shl 32);
end;

class function TDFFileVersion.GetRelease(const Version64: Int64): Integer;
begin
  Result := (Version64 shr 16) and $FFFF;
end;

class procedure TDFFileVersion.SetRelease(var Version64: Int64; Release: Integer);
begin
  Version64 := (Version64 and $FFFFFFFF0000FFFF) or (Int64(Release and $FFFF) shl 16);
end;

class function TDFFileVersion.GetBuild(const Version64: Int64): Integer;
begin
  Result := Version64 and $FFFF;
end;

class procedure TDFFileVersion.SetBuild(var Version64: Int64; Build: Integer);
begin
  Version64 := (Version64 and $FFFFFFFFFFFF0000) or Int64(Build and $FFFF);
end;

class function TDFFileVersion.ToString(const Version64: Int64; IncludeBuild,
  IncludeRelease, IncludeMinor: Boolean): string;
begin
  if IncludeMinor and IncludeRelease and IncludeBuild then
    Result := Format('%d.%d.%d.%d', [GetMajor(Version64), GetMinor(Version64), 
                                     GetRelease(Version64), GetBuild(Version64)])
  else if IncludeMinor and IncludeRelease then
    Result := Format('%d.%d.%d', [GetMajor(Version64), GetMinor(Version64), 
                                  GetRelease(Version64)])
  else if IncludeMinor then
    Result := Format('%d.%d', [GetMajor(Version64), GetMinor(Version64)])
  else
    Result := IntToStr(GetMajor(Version64));
end;

class function TDFFileVersion.Compare(const LeftVersion64, RightVersion64: Int64): Integer;
var
  LMajorDiff, LMinorDiff, LReleaseDiff, LBuildDiff: Integer;
begin
  LMajorDiff := GetMajor(LeftVersion64) - GetMajor(RightVersion64);
  
  if LMajorDiff <> 0 then
    Result := LMajorDiff
  else
  begin
    LMinorDiff := GetMinor(LeftVersion64) - GetMinor(RightVersion64);
    
    if LMinorDiff <> 0 then
      Result := LMinorDiff
    else
    begin
      LReleaseDiff := GetRelease(LeftVersion64) - GetRelease(RightVersion64);
      
      if LReleaseDiff <> 0 then
        Result := LReleaseDiff
      else
      begin
        LBuildDiff := GetBuild(LeftVersion64) - GetBuild(RightVersion64);
        Result := LBuildDiff;
      end;
    end;
  end;
end;

class function TDFFileVersion.CompareFileVersion(
  const LeftVersion, RightVersion: TDFFileVersion): Integer;
begin
  Result := Compare(LeftVersion.FFileVersion64, RightVersion.FFileVersion64);
end;

class function TDFFileVersion.CompareProductVersion(
  const LeftVersion, RightVersion: TDFFileVersion): Integer;
begin
  Result := Compare(LeftVersion.FProductVersion64, RightVersion.FProductVersion64);
end;

function TDFFileVersion.GetFileVersion32: Integer;
begin
  Result := GetVersion32(FFileVersion64);
end;

function TDFFileVersion.GetFileMajor: Integer;
begin
  Result := GetMajor(FFileVersion64);
end;

function TDFFileVersion.GetFileMinor: Integer;
begin
  Result := GetMinor(FFileVersion64);
end;

function TDFFileVersion.GetFileRelease: Integer;
begin
  Result := GetRelease(FFileVersion64);
end;

function TDFFileVersion.GetFileBuild: Integer;
begin
  Result := GetBuild(FFileVersion64);
end;

function TDFFileVersion.FileVersionToString(IncludeBuild, IncludeRelease, IncludeMinor: Boolean): string;
begin
  Result := ToString(FFileVersion64, IncludeBuild, IncludeRelease, IncludeMinor);
end;

function TDFFileVersion.GetProductVersion32: Integer;
begin
  Result := GetVersion32(FProductVersion64);
end;

function TDFFileVersion.GetProductMajor: Integer;
begin
  Result := GetMajor(FProductVersion64);
end;

function TDFFileVersion.GetProductMinor: Integer;
begin
  Result := GetMinor(FProductVersion64);
end;

function TDFFileVersion.GetProductRelease: Integer;
begin
  Result := GetRelease(FProductVersion64);
end;

function TDFFileVersion.GetProductBuild: Integer;
begin
  Result := GetBuild(FProductVersion64);
end;

function TDFFileVersion.ProductVersionToString(IncludeBuild, IncludeRelease,
  IncludeMinor: Boolean): string;
begin
  Result := ToString(FProductVersion64, IncludeBuild, IncludeRelease, IncludeMinor);
end;

procedure TDFFileVersion.SetFileBuild(Build: Integer);
begin
  SetBuild(FFileVersion64, Build);
end;

procedure TDFFileVersion.SetFileMajor(Major: Integer);
begin
  SetMajor(FFileVersion64, Major);
end;

procedure TDFFileVersion.SetFileMinor(Minor: Integer);
begin
  SetMinor(FFileVersion64, Minor);
end;

procedure TDFFileVersion.SetFileRelease(Release: Integer);
begin
  SetRelease(FFileVersion64, Release);
end;

procedure TDFFileVersion.SetProductBuild(Build: Integer);
begin
  SetBuild(FProductVersion64, Build);
end;

procedure TDFFileVersion.SetProductMajor(Major: Integer);
begin
  SetMajor(FProductVersion64, Major);
end;

procedure TDFFileVersion.SetProductMinor(Minor: Integer);
begin
  SetMinor(FProductVersion64, Minor);
end;

procedure TDFFileVersion.SetProductRelease(Release: Integer);
begin
  SetRelease(FProductVersion64, Release);
end;

end.
