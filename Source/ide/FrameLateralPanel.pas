{Frame que se ubica en el panel lateral en la parte izquierda.}
unit FrameLateralPanel;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ComCtrls, ExtCtrls, LCLProc,
  Graphics, MisUtils;
type
  { TfraLateralPanel }
  TfraLateralPanel = class(TFrame)
    Label1: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    procedure FrameResize(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    FBackColor: TColor;
    FPanelColor: TColor;
    FTextColor: TColor;
  public  //Eventos del panel
    OnSelectedPage: procedure(pagName: string) of object;
    OnNewOrDeletePage: procedure(latPanel: TfraLateralPanel) of object;
  public  //Información
    //function HasFocus: boolean;
    function ActivePageName: string;
  public  //Acciones
    procedure SetPanelColor(HeaderCol, HeaderTextCol, HeaderBackCol: TColor);
    procedure HideHeader;
    procedure ShowHeader;
  public  //Inicialización
    function AddPage(frm: TCustomControl; pagName, tabCaption, compName: String
      ): TTabSheet;
    procedure DeletePage(pagName: string);
    procedure DeleteAllPages;
    constructor Create(AOwner: TComponent) ; override;
  end;

implementation
{$R *.lfm}
{ TfraLateralPanel }
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
function TfraLateralPanel.ActivePageName: string;
{Devuelve el nombre de la página activa. Si no hay ninguna página, devuelve una cadena
vacía.}
begin
  if PageControl1.PageCount=0 then exit('');
  exit (PageControl1.ActivePage.Name);
end;
procedure TfraLateralPanel.SetPanelColor(HeaderCol,
          HeaderTextCol, HeaderBackCol: TColor);
begin
  Label1.Color := HeaderCol;
  Panel1.Color := HeaderCol;
  FPanelColor := HeaderCol;

  Label1.Font.Color := HeaderTextCol;
  FTextColor := HeaderTextCol;

  //HeaderBackCol
  { #todo : Sería recomendable mandar un mensaje a todas las páginas para
  pedirles que configuren sus colores, con estos colores generales. Ya luego,
  si alguno de estos controles (que se han agregado como pestañas), tienen un
  formulario especial de configuración, se les personalziará sus colores. }
end;
procedure TfraLateralPanel.HideHeader;
begin
  Panel1.Visible := false;
end;
procedure TfraLateralPanel.ShowHeader;
begin
  Panel1.Visible := true;
end;
procedure TfraLateralPanel.PageControl1Change(Sender: TObject);
//Se ha seleccionado una página diferente
begin
  //Dispara evento
  if OnSelectedPage<>nil then OnSelectedPage(PageControl1.ActivePage.Name);
  //Actualiza el título del encabezado
  label1.Caption := PageControl1.ActivePage.Caption;
end;
procedure TfraLateralPanel.FrameResize(Sender: TObject);
var
  headerHeight: Integer;
begin
  if Panel1.Visible then headerHeight := Panel1.Height else headerHeight := 0;
  {Ubica el control "PageControl1" con sus bordes no visibles porque no hay forma de
  ocultarlos fácilmente}
  PageControl1.Left := -4;
  PageControl1.Top := headerHeight - 4;
  PageControl1.Width := self.Width + 8;
  if PageControl1.PageCount <= 1 then begin
    PageControl1.Height := self.Height - headerHeight+8;
  end else begin
    PageControl1.Height := self.Height - headerHeight+4;
  end;
end;
//Inicialización
function TfraLateralPanel.AddPage(frm: TCustomControl; pagName, tabCaption, compName: String
  ): TTabSheet;
{Agrega una nueva pestaña en el panel lateral y coloca el control "frm" dentro de la
página creada.
Devuelve la referencia.}
var
  tab: TTabSheet;
begin
  //Crea nueva página
  tab := PageControl1.AddTabSheet;
  tab.Name := pagName;      //El nombre debe ser único.
  tab.Caption := tabCaption;
  tab.Hint := compName;     //Lo marca aquí para saber que es de este compilador.
  //Agrega el Frame
  frm.Parent := tab;
  frm.Visible := true;
  frm.Align := alClient;
  //Verifica si hay una sola pestaña para ocultarse
  if PageControl1.PageCount = 1 then PageControl1.ShowTabs := false
  else PageControl1.ShowTabs := true;
  //Actualiza el título del encabezado
  label1.Caption := PageControl1.ActivePage.Caption;
  //Dispara evento
  if OnNewOrDeletePage<>Nil then OnNewOrDeletePage(self);
  exit(tab);
end;
procedure TfraLateralPanel.DeletePage(pagName: string);
{Elimina una página del panel, identificándola por su nombre.}
var
  tab: TTabSheet;
  i: Integer;
begin
  for i:=0 to PageControl1.PageCount-1 do begin
    tab := PageControl1.Pages[i];
    if tab.Name = pagName then begin
      tab.Free;
      Exit;
    end;
  end;
end;
procedure TfraLateralPanel.DeleteAllPages;
{Elimina todas las página del panel.}
begin
  while PageControl1.PageCount>0 do begin
    PageControl1.Pages[0].Free;
  end;

end;

constructor TfraLateralPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

end.
//427
