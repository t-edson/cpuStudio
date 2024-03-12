program P65Pas;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, tachartlazaruspkg, FormPrincipal, Globales, FormConfig,
  FrameEditView, FrameMessagesWin,
  FrameCfgExtTool,
  FrameLateralPanel,
  {adapterKickc, FormAdapterKickc, }EditView, CibGrillas, FormAdapter6502,
  adapter6502, CodeTools6502, FormDebugger6502, FormElemProperty,
  FormRAMExplorer6502, FrameAsm6502, FrameCfgAfterChg6502, FrameCfgAsmOut6502,
  FrameCfgCompiler6502, FrameMIR6502, FrameRamExplorer6502, FrameRegisters6502,
  FrameRegWatcher6502, FrameStatist6502, FrameSynTree6502, GenCod_PIC16,
  GenCodBas_PIC16, LexPas, MirList, ParserASM_6502, ParserDirec, Analyzer,
  AstElemP65, AstTree, CompBase, CompContexts, CompGlobals, Compiler_PIC16;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TConfig, Config);
//  Application.CreateForm(TfraCfgGeneral, fraCfgGeneral);
  Application.Run;
end.

