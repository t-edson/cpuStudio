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
    TabSheet1: TTabSheet;
    procedure PageControl1Change(Sender: TObject);
  private
    FBackColor: TColor;
    FPanelColor: TColor;
    FTextColor: TColor;
    procedure frmArcExplor1DoubleClickFile(nod: TExplorNode);
    procedure SetPanelColor(AValue: TColor);
    procedure SetTextColor(AValue: TColor);
  public
    fraFileExplor1: TfraFileExplor;
    //Eventos del explorador de archivo
    OnOpenFile: procedure(filname: string) of object;
    OnSelecFileExplorer: procedure of object;
    //Se requiere información del archivo actual
//    OnReqCurFile: procedure(var filname: string) of object;
    function HasFocus: boolean;
    property TextColor: TColor read FTextColor write SetTextColor;
    property PanelColor: TColor read FPanelColor write SetPanelColor;
  public //Inicialización
    procedure OpenFolder(folderPath: string);
    procedure CloseFolder();
    constructor Create(AOwner: TComponent) ; override;
  end;

implementation
{$R *.lfm}
{ TfraLateralPanel }
procedure TfraLateralPanel.frmArcExplor1DoubleClickFile(nod: TExplorNode);
begin
  if OnOpenFile<>nil then OnOpenFile(nod.GetPath);
end;
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
function TfraLateralPanel.HasFocus: boolean;
{Indica si el frame tiene el enfoque.}
begin
//  if fraFileExplor1.Visible then begin
//    //Modo de explorador de archivo
//    Result := fraFileExplor1.TreeView1.Focused;
//  end else begin
//    //Modo normal
//    Result := TreeView1.Focused;
//  end;
end;
//////////////////////// Acciones /////////////////////
procedure TfraLateralPanel.PageControl1Change(Sender: TObject);
//Se ha seleccionado una página diferente
begin
  if PageControl1.ActivePage = TabSheet1 then begin
    //Es el explrador de archivos.
    if OnSelecFileExplorer<>nil then OnSelecFileExplorer();
  end;
  label1.Caption := PageControl1.ActivePage.Caption;
end;
//Inicialización
procedure TfraLateralPanel.OpenFolder(folderPath: string);
{Abre la carpeta "folderPath" en el explorador de archivo.}
begin
  //Configura filtros del explorador de archivos
  {Por ahora esto es estático, pero más adelante se puede leer las opciones de
  configuración de un archivo o carpeta oculta, que resida en el mismo folder. }
  fraFileExplor1.Filter.Items.Clear;
  fraFileExplor1.Filter.Items.Add('*.pas,*.pp,*.inc');  //los filtros se separan por comas
  fraFileExplor1.Filter.Items.Add('*');  //para seleccionar todos
  fraFileExplor1.Filter.ItemIndex:=0;    //selecciona la primera opción por defecto
  fraFileExplor1.Filter.Visible := false;  //No se usa por ahora
  //Configura ruta de trabajo
  fraFileExplor1.OpenFolder(folderPath);
end;
procedure TfraLateralPanel.CloseFolder;
begin
  fraFileExplor1.CloseFolder();
end;
constructor TfraLateralPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //Crea Explorador de archivos por defecto
  fraFileExplor1:= TfraFileExplor.Create(self);
  fraFileExplor1.Parent := TabSheet1;
  fraFileExplor1.Align := alClient;
  //COnfigura Explorador de archivos
  fraFileExplor1.InternalPopupFile := true;
  fraFileExplor1.InternalPopupFolder := true;
  fraFileExplor1.OnDoubleClickFile:= @frmArcExplor1DoubleClickFile;
  fraFileExplor1.OnKeyEnterOnFile := @frmArcExplor1DoubleClickFile;
  fraFileExplor1.OnMenuOpenFile   := @frmArcExplor1DoubleClickFile;
end;

end.
//427
