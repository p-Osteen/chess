#define AppName "Chess"
#define AppVersion "1.0.0"
#define ReleaseFolder "build\windows\x64\runner\Release"

[Setup]
AppName={#AppName}
AppVersion=1.0.1+3
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
OutputBaseFilename={#AppName}_Setup
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes

[Files]
Source: "{#ReleaseFolder}\chess_game.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ReleaseFolder}\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ReleaseFolder}\data\*"; DestDir: "{app}\data"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "windows\runner\resources\app_icon.ico"; DestDir: "{app}\resources"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{commondesktop}\{#AppName}"; Filename: "{app}\chess_game.exe"; IconFilename: "{app}\resources\app_icon.ico"
Name: "{group}\{#AppName}"; Filename: "{app}\chess_game.exe"; IconFilename: "{app}\resources\app_icon.ico"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\chess_game.exe"; Description: "Run {#AppName}"; Flags: nowait postinstall skipifsilent
