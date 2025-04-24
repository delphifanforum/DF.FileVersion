# DF.FileVersion

A modern Delphi unit for efficient file and product version information handling.

## Overview

`DF.FileVersion` provides a memory-efficient way to extract, manipulate, and compare version information from executable files. The unit uses only 24 bytes of memory per version record, making it highly efficient for applications that need to process version information for multiple files.

## Features

- Memory-efficient representation of version information (24 bytes per record)
- Extract file and product version information from PE files
- Extract build date/time from version resources or PE headers
- Compare version numbers with proper semantic versioning rules
- Format version numbers as strings with configurable detail levels
- Manipulate individual components of version numbers (Major, Minor, Release, Build)
- Full XML documentation for modern Delphi IDE integration

## Usage Examples

### Basic Version Information

```pascal
// Get version information from an executable
var
  FileVersion: TDFFileVersion;
begin
  FileVersion := TDFFileVersion.Create('C:\Path\To\YourApp.exe');
  
  // Display version information
  Memo1.Lines.Add('File Version: ' + FileVersion.FileVersionToString(True)); // Include build number
  Memo1.Lines.Add('Product Version: ' + FileVersion.ProductVersionToString());
  Memo1.Lines.Add('Build Date: ' + DateTimeToStr(FileVersion.BuildDateTime));
end;
```

### Version Comparison

```pascal
// Compare two version numbers
var
  FileVersion1, FileVersion2: TDFFileVersion;
  CompareResult: Integer;
begin
  FileVersion1 := TDFFileVersion.Create('C:\Path\To\YourApp1.exe');
  FileVersion2 := TDFFileVersion.Create('C:\Path\To\YourApp2.exe');
  
  CompareResult := TDFFileVersion.CompareFileVersion(FileVersion1, FileVersion2);
  
  case Sign(CompareResult) of
    -1: ShowMessage('Version 1 is older than Version 2');
     0: ShowMessage('Versions are identical');
     1: ShowMessage('Version 1 is newer than Version 2');
  end;
end;
```

### Creating and Manipulating Versions

```pascal
// Create a version manually
var
  Version: TDFFileVersion;
begin
  // Create with specific values (Major=1, Minor=2, Release=3, Build=4)
  Version := TDFFileVersion.Create(
    (Int64(1) shl 48) or (Int64(2) shl 32) or (Int64(3) shl 16) or 4,
    (Int64(1) shl 48) or (Int64(2) shl 32) or (Int64(3) shl 16) or 4,
    Now
  );
  
  // Update version components
  Version.FileMajor := 2;
  Version.FileMinor := 0;
  
  ShowMessage('New version: ' + Version.FileVersionToString(True));
end;
```

## Requirements

- Delphi XE7 or later
- Windows platform (uses Windows API calls)

## License

This code is provided under the MIT License.

---

Copyright (c) 2025
