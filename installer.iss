
#define MyAppName "V_SHERE"
#define MyAppVersion "1.0.0"
#define MyAppExeName "v_shere.exe"

[Setup]
AppId={{A7F8C21D-9B32-4E65-AB81-123456789ABC}
SetupIconFile=v_shere.ico
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={autopf}\V_SHERE
DefaultGroupName={#MyAppName}
OutputDir=installer
OutputBaseFilename=V_SHERE-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\V_SHERE"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\V_SHERE"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch V_SHERE"; Flags: postinstall nowait skipifsilent
