; Zanit 1.2.1 installer
; Modified from the upstream chiaki-ng Inno Setup script.

#define MyAppName "Zanit"
#define MyAppPublisher "Zanit Contributors"
#define MyAppExeName "Zanit.exe"
#define MyAppPath "..\Zanit-Win"
#define MyAppVersion() \
  GetVersionComponents(MyAppPath + "\" + MyAppExeName, Local[0], Local[1], Local[2], Local[3]), \
  Str(Local[0]) + "." + Str(Local[1]) + "." + Str(Local[2])

[Setup]
AppId={{2F6B7D3E-42E6-4C88-9336-2EEDCC4E6F64}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
UsePreviousAppDir=no
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableDirPage=no
ChangesAssociations=yes
DefaultGroupName={#MyAppName}
UsePreviousGroup=no
AllowNoIcons=yes
LicenseFile=..\LICENSES\AGPL-3.0-only-OpenSSL.txt
PrivilegesRequiredOverridesAllowed=dialog
OutputBaseFilename=Zanit-1.2.1-Setup
OutputDir=..
SetupIconFile=..\gui\zanit.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#MyAppPath}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppPath}\*"; DestDir: "{app}"; Excludes: "*.log,*.log1,Zanit *.png,*.bak-*"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\ZANIT_MODIFICATIONS.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSES\AGPL-3.0-only-OpenSSL.txt"; DestDir: "{app}\licenses"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
