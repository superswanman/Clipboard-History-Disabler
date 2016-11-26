unit UClipboardHistoryDisabler;

interface

uses
  Winapi.Windows, System.Rtti;

procedure Register;

implementation

var
  FTargetAddr: PByte;
  FOriginalData: Byte;

procedure Register;
var
  ctx: TRttiContext;
  typ: TRttiType;
  oldProtect: DWORD;
begin
  typ := ctx.FindType('ClipboardHistoryDlg.TClipboardHistoryForm');
  if typ = nil then Exit;
  FTargetAddr := GetProcAddress(GetModuleHandle(PChar(typ.Package.Name)), '@Clipboardhistorydlg@TClipboardHistoryForm@WMClipboardUpdate$qqrr24Winapi@Messages@TMessage');
  if not Assigned(FTargetAddr) then Exit;

  VirtualProtect(FTargetAddr, 1, PAGE_READWRITE, oldProtect);
  FOriginalData := FTargetAddr^;
  FTargetAddr^ := $C3; // RET
  VirtualProtect(FTargetAddr, 1, oldProtect, nil);
  FlushInstructionCache(GetCurrentProcess, FTargetAddr, 1);
end;

procedure Unregister;
var
  oldProtect: DWORD;
begin
  if not Assigned(FTargetAddr) then Exit;

  VirtualProtect(FTargetAddr, 1, PAGE_READWRITE, oldProtect);
  FTargetAddr^ := FOriginalData;
  VirtualProtect(FTargetAddr, 1, oldProtect, nil);
  FlushInstructionCache(GetCurrentProcess, FTargetAddr, 1);
end;

initialization
finalization
  Unregister;
end.