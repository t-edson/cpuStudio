{Frame que se ubica en el panel lateral en la parte izquierda.}
unit FrameLateralPanel;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls,
  ComCtrls, Menus, ActnList, ExtCtrls, LCLProc, Graphics,
  FrameFileExplor, MisUtils;
type
  { TfraLateralPanel }
  TfraLateralPanel = class(TFrame)
    Label1: TLabel;
    PageControl1: TPageControl;
    procedure PageControl1Change(Sender: TObject);
  private
    FBackColor: TColor;
    FPanelColor: TColor;
    FTextColor: TColor;
    procedure SetPanelColor(AValue: TColor);
    procedure SetTextColor(AValue: TColor);
  public
    //Eventos del explorador de archivo
    OnSelectedPage: procedure(pagName: string) of object;
    //Se requiere información del archivo actual
//    OnReqCurFile: procedure(var filname: string) of object;
    //function HasFocus: boolean;
    property TextColor: TColor read FTextColor write SetTextColor;
    property PanelColor: TColor read FPanelColor write SetPanelColor;
  public //Inicialización
    function AddPage(frm: TFrame; tabName, tabCaption, compName: String
      ): TTabSheet;
    constructor Create(AOwner: TComponent) ; override;
  end;

implementation
{$R *.lfm}
{ TfraLateralPanel }
procedure TfraLateralPanel.SetTextColor(AValue: TColor);
begin
//  if FTextColor = AValue then Exit;
  Label1.Font.Color := AValue;
  FTextColor := AValue;
end;
procedure TfraLateralPanel.SetPanelColor(AValue: TColor);
begin
//  if FPanelColor = AValue then Exit;
  Label1.Color := AValue;
  FPanelColor := AValue;
end;
//function TfraLateralPanel.HasFocus: boolean;
//{Indica si este panel tiene el enfoque.}
//begin
//  if fraFileExplor1.Visible then begin
//    //Modo de explorador de archivo
//    Result := fraFileExplor1.TreeView1.Focused;
//  end else begin
//    //Modo normal
//    Result := TreeView1.Focused;
//  end;
//end;
//////////////////////// Acciones /////////////////////
procedure TfraLateralPanel.PageControl1Change(Sender: TObject);
//Se ha seleccionado una página diferente
begin
  //Dispara evento
  if OnSelectedPage<>nil then OnSelectedPage(PageControl1.ActivePage.Name);
  //Actualiza el título del encabezado
  label1.Caption := PageControl1.ActivePage.Caption;
end;
//Inicialización
function TfraLateralPanel.AddPage(frm: TFrame; tabName, tabCaption, compName: String
  ): TTabSheet;
{Agrega un nuevo frame y lo coloca como una nueva pestaña del panel lateral.
Devuelve la referencia.}
var
  tab: TTabSheet;
begin
  //Crea nueva página
  tab := PageControl1.AddTabSheet;
  tab.Name := tabName;      //El nombre debe ser único.
  tab.Caption := tabCaption;
  tab.Hint := compName;     //Lo marca aquí para saber que es de este compilador.
  //Agrega el Frame
  frm.Parent := tab;
  frm.Visible := true;
  frm.Align := alClient;
  exit(tab);
end;
constructor TfraLateralPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

end.
//427
