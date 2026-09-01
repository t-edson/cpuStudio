{Formulario para mostrar las propiedades de un elemento.}
unit FormElemProperty;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls, ExtCtrls,
  ComCtrls, ImgList, MisUtils, alexiaLex, AstPascal, Analyzer;
type

  { TfrmElemProperty }

  TfrmElemProperty = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    butDetails: TButton;
    Image1: TImage;
    ImageList1: TImageList;
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
    txtEleType: TEdit;
    procedure BitBtn2Click(Sender: TObject);
    procedure butDetailsClick(Sender: TObject);
  private
    elem: TASTNode;
    procedure SetCalledInfo(elem0: TASTNode);
  public
    OnExplore: procedure(elem0: TASTNode) of object;
    procedure Clear;
    procedure Exec(cpx: TAnalyzer; treeNod: TTreeNode);
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
//var
//  call: TAstEleCaller;
//  tmp, callerStr: String;
begin
//  //Detalla las llamadas hechas al elemento
//  tmp := '';
//  for call in elem.lstCallers do begin
//    if call.caller.Parent<>nil then begin
//      callerStr := call.caller.Parent.name + '-' + call.caller.name;
//    end else begin
//      callerStr := call.caller.name;
//    end;
//    tmp := tmp + 'Called by: ' + callerStr + ' ' +
//           ' Pos:' + call.curPos.RowColString + LineEnding;
//  end;
//  MsgBox(tmp);
end;

procedure TfrmElemProperty.SetCalledInfo(elem0: TASTNode);
{Agrega información, sobre las llamadas que se hacen a un elemento }
var
  nCalled: Integer;
begin
//  nCalled := elem0.nCalled;
//  if nCalled = 0 then begin
//    lblElemName3.Caption := 'Status';
//    lblUsed.Font.Color := clGray;
//    lblUsed.Caption := 'Unused';
//    butDetails.Enabled := false;
//  end else begin
//    lblElemName3.Caption := 'Status';
//    lblUsed.Font.Color := clGreen;
//    lblUsed.Caption := 'Used ' + IntToStr(nCalled) + ' times.';
//    butDetails.Enabled := true;
//  end;
end;
procedure TfrmElemProperty.Exec(cpx: TAnalyzer; treeNod: TTreeNode);
var
  adicInformation: String;
  imgIdx: TImageIndex;
  Express: TExpression;
begin
  elem := TASTNode(treeNod.Data);
  if elem = nil then exit;
  Image1.Stretch := true;
  Image1.Proportional := true;  //To keep width/height ratio
  adicInformation := '';

  txtEleLocaPath.Caption := cpx.lexer.ctxFileDir(elem.SrcPos);
  txtEleLocFile.Caption := cpx.lexer.ctxFileName(elem.SrcPos) + elem.SrcPos.RowColString;
  BitBtn2.Enabled := true;
  //Configura etiqueta y botón de número de llamadas al elemento
  SetCalledInfo(elem);
  //Ícono e información adicional
  imgIdx := treeNod.ImageIndex;
  ImageList1.GetBitmap(imgIdx, Image1.Picture.Bitmap);
  txtEleType.Caption := elem.ClassName;
  adicInformation := elem.ToString;
  if elem is TExpression then begin
    Express := TExpression(elem);
    adicInformation += LineEnding +
      'TypeDef using GetTypeOf():' + LineEnding + cpx.checker.GetTypeOf(Express).ToString;
  end;
  Memo1.Text := adicInformation;
end;

end.


