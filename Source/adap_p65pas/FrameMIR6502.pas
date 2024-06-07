unit FrameMIR6502;
{$mode ObjFPC}{$H+}
interface
uses
  Classes, SysUtils, TreeFilterEdit, Forms, Controls,
  ComCtrls, Menus, ActnList, ExtCtrls, LCLProc, Graphics,
  Globales, CompBase, MirList;

type
  { TfraMIR6502 }
  TfraMIR6502 = class(TFrame)
    acGenDoAnalys: TAction;
    acGenDoOptim: TAction;
    acGenDoSinth: TAction;
    acGenExpAll: TAction;
    acGenGoTo: TAction;
    acGenProp: TAction;
    acGenRefres: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    mnGoTo: TMenuItem;
    mnProper: TMenuItem;
    mnRefresh: TMenuItem;
    mnRefresh2: TMenuItem;
    Panel1: TPanel;
    PopupElem: TPopupMenu;
    PopupFrame: TPopupMenu;
    TreeFilterEdit1: TTreeFilterEdit;
    TreeView1: TTreeView;
  private
    FBackColor: TColor;
    FTextColor: TColor;
    cpx       : TCompilerBase;   //Reference to lexer
    mirCont: TMirList;
    function AddNodeTo(nodParent: TTreeNode; elem: TMirElement; nodLabel: String =
      ''): TTreeNode;
    procedure RefreshByDeclar(nodMain: TTreeNode; elems: TMirElements);
    procedure SetBackColor(AValue: TColor);
    procedure SetTextColor(AValue: TColor);
    procedure TreeView1AdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);

  public
    property BackColor: TColor read FBackColor write SetBackColor;
    property TextColor: TColor read FTextColor write SetTextColor;
  public    //Initialization
    procedure Refresh;
    procedure Init(Compiler: TCompilerBase);
    constructor Create(AOwner: TComponent) ; override;
  end;

implementation
{$R *.lfm}

{ TfraMIR6502 }
function TfraMIR6502.AddNodeTo(nodParent: TTreeNode; elem: TMirElement;
         nodLabel: String = ''): TTreeNode;
{Agrega un elemento a un nodo.}
var
  nod: TTreeNode;
begin
  if elem = nil then begin
    //Agrega un elemento con nombre "nodLabel" y con el ícono por defecto.
    nod := TreeView1.Items.AddChild(nodParent, nodLabel);
    nod.ImageIndex := 0;
    nod.SelectedIndex := 0;
    nod.Data := elem;
    Result := nod;
    exit;
  end;
  if nodLabel='' then nodLabel := elem.text;
  nod := TreeView1.Items.AddChild(nodParent, nodLabel);
  if elem.mirType = mtyVarDec then begin
    //    nod.Text :=   '<Assign>';
    nod.ImageIndex := 2;
    nod.SelectedIndex := 2;
  end else if elem.mirType = mtyConDec then begin
    nod.ImageIndex := 23;
    nod.SelectedIndex := 23;
  end else if elem.mirType = mtyAssign then begin
    nod.ImageIndex := 12;
    nod.SelectedIndex := 12;
  end else if elem.mirType = mtyIfJump then begin
    nod.ImageIndex := 12;
    nod.SelectedIndex := 12;
  end else if elem.mirType= mtyFunCall then begin
    nod.ImageIndex := 3;
    nod.SelectedIndex := 3;
  end else if elem.mirType = mtyLabel then begin
    nod.ImageIndex := 9;
    nod.SelectedIndex := 9;
  end else begin
    nod.ImageIndex := 0;
    nod.SelectedIndex := 0;
  end;
  nod.Data := elem;
  Result := nod;
end;
procedure TfraMIR6502.TreeView1AdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
begin
  with TreeView1.Canvas do begin
     //if Node.Level = 0 then  begin
     //  Font.Style := [fsBold, fsItalic];
     //end else begin
     //  Font.Style := [];
     //end;
     font.Color:= FTextColor;
     DefaultDraw := true;   //Para que siga ejecutando la rutina de dibujo
  end;
end;
procedure TfraMIR6502.SetBackColor(AValue: TColor);
begin
  //  if FBackColor = AValue then Exit;
    FBackColor := AValue;
//    TreeView1.BackgroundColor := AValue;
end;
procedure TfraMIR6502.SetTextColor(AValue: TColor);
begin
  //  if FTextColor = AValue then Exit;
    FTextColor := AValue;
end;
procedure TfraMIR6502.RefreshByDeclar(nodMain: TTreeNode; elems: TMirElements);
var
  elem: TMirElement;
  nodElem: TTreeNode;
  mirFunct: TMirFunDec;
  nodFunDec: TTreeNode;
  nodFunIns: TTreeNode;
  mirDecs: TMirDeclars;
  mirCode: TMirContainer;
begin
  //Agrega elementos
  if elems = nil then exit;
  for elem in elems do begin
      nodElem := AddNodeTo(nodMain, elem);
      if elem.mirType = mtyFunDec then begin  //Tiene nodos hijos
         mirFunct:= TMirFunDec(elem);
         //Functions have declaration and instructions
         nodFunDec := AddNodeTo(nodElem, nil, 'Declarations');
         nodFunIns := AddNodeTo(nodElem, nil, 'Instructions');
         RefreshByDeclar(nodFunDec, mirFunct.declars.items);  //Llamada recursiva
         RefreshByDeclar(nodFunIns, mirFunct.instrucs.items);  //Llamada recursiva
      //   nodElem.Expanded := true;
      end else if elem.mirType = mtyDeclars then begin  //Tiene nodos hijos
         mirDecs:= TMirDeclars(elem);
         RefreshByDeclar(nodElem, mirDecs.items);  //Llamada recursiva
         nodElem.Expanded := true;
      end else if elem.mirType = mtyCode then begin  //Tiene nodos hijos
         mirCode:= TMirContainer(elem);
         RefreshByDeclar(nodElem, mirCode.items);  //Llamada recursiva
         nodElem.Expanded := true;
      end;
      //Expande los Body
//      if elem.idClass = eleSenten then nodElem.Expanded := true;
  end;
end;
procedure TfraMIR6502.Refresh;
{Actualiza el árbol de sintaxis con el AST del compilador}
var
  nodMain, nodFunDec, nodFunIns: TTreeNode;
begin
  TreeView1.Visible := true;

  TreeView1.Items.BeginUpdate;
  TreeView1.Items.Clear;
  //nodMain := TreeView1.Items.AddChild(nil, '');
  //nodMain.ImageIndex := 1;
  //nodMain.SelectedIndex := 1;
  ////nodMain.Data := syntaxTree.main;  //Elemento raiz
  nodFunDec := AddNodeTo(nil, nil, 'Declarations');
  nodFunIns := AddNodeTo(nil, nil, 'Instructions');
  RefreshByDeclar(nodFunDec, mirCont.root.declars.items);
  RefreshByDeclar(nodFunIns, mirCont.root.instrucs.items);
  nodFunDec.Expand(false);
  nodFunIns.Expand(false);
  //nodMain.Expanded := true;    //Expande nodo raiz
  TreeView1.Items.EndUpdate;
end;
procedure TfraMIR6502.Init(Compiler: TCompilerBase);
begin
  cpx      := Compiler;
  mirCont  := Compiler.mirRep;
  TreeView1.ReadOnly := true;
  TreeView1.OnAdvancedCustomDrawItem := @TreeView1AdvancedCustomDrawItem;
  TreeView1.Options := TreeView1.Options - [tvoThemedDraw];

end;
constructor TfraMIR6502.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;
end.

