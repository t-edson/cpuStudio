{Formulario para mostrar las propiedades de un elemento.}
unit FormElemProperty;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, ExtCtrls, MisUtils, AstElemP65, CompContexts, StrUtils;
type

  { TfrmElemProperty }

  TfrmElemProperty = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    butDetails: TButton;
    Image1: TImage;
    ImageList1: TImageList;
    lblElemName: TLabel;
    lblElemName1: TLabel;
    lblElemName2: TLabel;
    lblElemName3: TLabel;
    lblElemName4: TLabel;
    lblElemName5: TLabel;
    lblUsed: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Memo1: TMemo;
    txtEleLocaPath: TEdit;
    txtEleLocFile: TEdit;
    txtEleName: TEdit;
    txtEleType: TEdit;
    procedure BitBtn2Click(Sender: TObject);
    procedure butDetailsClick(Sender: TObject);
  private
    elem: TAstElement;
    procedure SetCalledInfo(elem0: TAstElement);
  public
    OnExplore: procedure(elem0: TAstElement) of object;
    procedure Clear;
    procedure Exec(cIn: TContexts; elem0: TAstElement);
  end;

var
  frmElemProperty: TfrmElemProperty;

implementation
{$R *.lfm}
{ TfrmElemProperty }
procedure TfrmElemProperty.BitBtn2Click(Sender: TObject);
begin
  if OnExplore<>nil then OnExplore(elem);
end;
procedure TfrmElemProperty.Clear;
begin
  txtEleName.Caption := 'Unknown';
  txtEleType.Caption := 'Unknown';
  txtEleLocaPath.Caption := '';
  txtEleLocFile.Caption := '';
  lblUsed.Font.Color := clGray;
  lblUsed.Caption := 'Unused';
  ImageList1.GetBitmap(13, Image1.Picture.Bitmap);
  Memo1.Text := '';
  BitBtn2.Enabled := false;
end;
procedure TfrmElemProperty.butDetailsClick(Sender: TObject);
var
  call: TAstEleCaller;
  tmp, callerStr: String;
begin
  //Detalla las llamadas hechas al elemento
  tmp := '';
  for call in elem.lstCallers do begin
    if call.caller.Parent<>nil then begin
      callerStr := call.caller.Parent.name + '-' + call.caller.name;
    end else begin
      callerStr := call.caller.name;
    end;
    tmp := tmp + 'Called by: ' + callerStr + ' ' +
           ' Pos:' + call.curPos.RowColString + LineEnding;
  end;
  MsgBox(tmp);
end;

procedure TfrmElemProperty.SetCalledInfo(elem0: TAstElement);
{Agrega información, sobre las llamadas que se hacen a un elemento }
var
  nCalled: Integer;
begin
  nCalled := elem0.nCalled;
  if nCalled = 0 then begin
    lblElemName3.Caption := 'Status';
    lblUsed.Font.Color := clGray;
    lblUsed.Caption := 'Unused';
    butDetails.Enabled := false;
  end else begin
    lblElemName3.Caption := 'Status';
    lblUsed.Font.Color := clGreen;
    lblUsed.Caption := 'Used ' + IntToStr(nCalled) + ' times.';
    butDetails.Enabled := true;
  end;
end;
procedure TfrmElemProperty.Exec(cIn: TContexts; elem0: TAstElement);
var
  adicInformation, dirSolic, tmp, hasImplem: String;
  xcon: TAstConsDec;
  funimp: TAstFunImp;
  fundec: TAstFunDec;
  xbod: TAstBody;
  xvar: TAstVarDec;
  //ecall : TxpExitCall;
  xexp: TAstExpress;
  sen: TAstSentence;
  xtyp: TAstTypeDec;
  asmInst: TAstAsmInstr;
  asmBlock: TAstAsmBlock;
begin
  if elem0 = nil then exit;
  elem := elem0;
  Image1.Stretch := true;
  Image1.Proportional := true;  // to keep width/height ratio
  adicInformation := '';
  txtEleName.Caption := elem.name;
  txtEleLocaPath.Caption := cIn.ctxFileDir(elem.srcDec);
  txtEleLocFile.Caption := cIn.ctxFileName(elem.srcDec) + elem.srcDec.RowColString;
  BitBtn2.Enabled := true;
  //Configura etiqueta y botón de número de llamadas al elemento
  SetCalledInfo(elem);
  //Ícono e información adicional
  if          elem.idClass = eleConsDec then begin
    xcon := TAstConsDec(elem);
    txtEleType.Caption := 'Constant ('+elem.ClassName+')';
    ImageList1.GetBitmap(23, Image1.Picture.Bitmap);
    adicInformation :=
           'Constan Type: ' + IfThen(xcon.typ=nil, 'Unknown', xcon.typ.name) + LineEnding +
           'Evaluated: ???';
  end else if elem.idClass = eleVarDec then begin
    xvar := TAstVarDec(elem);
    txtEleType.Caption := 'Variable ('+elem.ClassName+')';
    ImageList1.GetBitmap(24, Image1.Picture.Bitmap);
    dirSolic := '0'; //IntToStr(xvar.adicPar.absAddr);
    adicInformation :=
           'Variable Type: ' + xvar.typ.name + LineEnding +
           'Allocated: '  + ifthen(xvar.allocated, 'true', 'false') + LineEnding +
           'Required address: ' + dirSolic + LineEnding;
  end else if elem.idClass = eleFuncDec then begin
    fundec := TAstFunDec(elem);
    txtEleType.Caption := 'Function Dec.('+elem.ClassName+')';;

    ImageList1.GetBitmap(16, Image1.Picture.Bitmap);
    //Genera reporte de ExitCalls
    //tmp := '';
    //for ecall in fundec.lstExitCalls do begin
    //  tmp := tmp + 'exit() in : ' + ecall.srcPos.RowColString + ' ' +
    //         LineEnding;
    //end;
    if fundec.firstObligExit=nil then begin
      tmp := 'No obligatory exit().' + LineEnding;
    end else begin
      tmp := 'Obligatory exit() in: ' + fundec.firstObligExit.srcDec.RowColString + LineEnding;
    end;
    //Información adicional
    if fundec.HasImplem then hasImplem := 'Yes' else hasImplem := 'Not';
    adicInformation :=
           'Return type: ' + ifthen(fundec.retType=nil,'Unknown', fundec.retType.name) + LineEnding +
           //'Address: $' + IntToHex(fundec.adrr, 3) + LineEnding +
           'Size: ' + IntToStr(fundec.srcSize) + LineEnding +
           'Has Implem.: ' + hasImplem + LineEnding +
           'Nº params: ' + IntToStr(length(fundec.pars)) + LineEnding +
           tmp;
  end else if elem.idClass = eleFuncImp then begin
    funimp := TAstFunImp(elem);
    txtEleType.Caption := 'Function ('+elem.ClassName+')';;

    ImageList1.GetBitmap(3, Image1.Picture.Bitmap);
    //Genera reporte de ExitCalls
    //tmp := '';  *** Esta información se puede sacar del AST.
    //for ecall in funimp.lstExitCalls do begin
    //  tmp := tmp + 'exit() in : ' + ecall.srcPos.RowColString + ' ' +
    //         LineEnding;
    //end;
    if funimp.firstObligExit=nil then begin
      tmp := 'No obligatory exit().' + LineEnding;
    end else begin
      tmp := 'Obligatory exit() in: ' + funimp.firstObligExit.srcDec.RowColString + LineEnding;
    end;
    //Información adicional
    adicInformation :=
           'Return type: ' + ifthen(funimp.retType=nil,'Unknown', funimp.retType.name) + LineEnding +
//           'Size: ' + IntToStr(funimp.srcSize) + LineEnding +
//           'Has Implem.: ' + hasImplem + LineEnding +
           'Nº params: ' + IntToStr(length(funimp.pars)) + LineEnding +
           tmp;
  end else if elem.idClass = eleUnit then begin
    txtEleType.Caption := 'Unit ('+elem.ClassName+')';
    ImageList1.GetBitmap(6, Image1.Picture.Bitmap);
    adicInformation := '';
  end else if elem.idClass = eleBody then begin
    xbod:= TAstBody(elem);
    txtEleType.Caption := 'Body ('+elem.ClassName+')';
    ImageList1.GetBitmap(5, Image1.Picture.Bitmap);
    adicInformation := 'Address: $' + IntToHex(xbod.adrr, 3) + LineEnding +
           'Begin: ' + xbod.srcDec.RowColString  + LineEnding +
           'End: ' + elem.srcEnd.RowColString;
  end else if elem.idClass = eleProg then begin
    txtEleType.Caption := 'Main ('+elem.ClassName+')';
    ImageList1.GetBitmap(1, Image1.Picture.Bitmap);
    adicInformation := '';
  end else if elem.idClass = eleSenten then begin
    sen := TAstSentence(elem);
    txtEleType.Caption := 'Sentence ('+elem.ClassName+')';
    ImageList1.GetBitmap(12, Image1.Picture.Bitmap);
    adicInformation := 'Sentence type: ' + sen.sntTypeAsStr;
  end else if elem.idClass = eleExpress then begin
    xexp := TAstExpress(elem);
    txtEleType.Caption := 'Expression ('+elem.ClassName+')';
    ImageList1.GetBitmap(3, Image1.Picture.Bitmap);
    adicInformation :=
           'Expression type: ' + xexp.opTypeAsStr +
           ' --> ' + xexp.Typ.name + LineEnding {+
           'Storage: ' + xexp.StoAsStr + LineEnding};
    case xexp.opType of
    otConst: begin
      adicInformation +=
            'Evaluated: ' + ifthen(xexp.evaluated, 'true', 'false') + LineEnding +
            'Value: ' + xexp.value.valuesAsString;
    end;
    otVariab: begin
      adicInformation +=
            'Type: ' + xexp.opTypeAsStr;
    end;
    otFunct: begin
      adicInformation +=
            '';
    end;
    end;
  end else if elem.idClass = eleTypeDec then begin
    xtyp := TAstTypeDec(elem);
    txtEleType.Caption := 'Type ('+elem.ClassName+')';
    ImageList1.GetBitmap(14, Image1.Picture.Bitmap);
    adicInformation :=
           'Group: ' + xtyp.groupStr + LineEnding +
           'Cat. Type: '  + xtyp.catTypeStr + LineEnding +
           'Size: ' + IntToStr(xtyp.size) + LineEnding +
           '' ;
  end else if elem.idClass = eleBlock then begin
    //sen := TAstSentence(elem);
    txtEleType.Caption := 'Block ('+elem.ClassName+')';
    ImageList1.GetBitmap(0, Image1.Picture.Bitmap);
    adicInformation := '';
  end else if elem.idClass = eleAsmBlock then begin
    asmBlock := TAstAsmBlock(elem);
    txtEleType.Caption := 'ASM Block ('+elem.ClassName+')';
    ImageList1.GetBitmap(0, Image1.Picture.Bitmap);
    adicInformation := 'Instructions: ' + IntToStr(asmBlock.elements.Count) + LineEnding +
                    'Incomplete instructions: ' + IntToStr(asmBlock.undefInstrucs.Count);
  end else if elem.idClass = eleAsmInstr then begin
    asmInst := TAstAsmInstr(elem);
    txtEleType.Caption := 'ASM instruction ('+elem.ClassName+')';
    ImageList1.GetBitmap(19, Image1.Picture.Bitmap);
    if asmInst.iType = itOpcode then begin
      adicInformation := 'Opcode instruction';
    end else if asmInst.iType = itLabel then begin
      adicInformation := 'ASM label';
    end else begin
      adicInformation := '';
    end;
  end else begin
    txtEleType.Caption := 'Unknown ('+elem.ClassName+')';
    ImageList1.GetBitmap(13, Image1.Picture.Bitmap);
    adicInformation := '';
  end;
  Memo1.Text := adicInformation;
end;

end.


