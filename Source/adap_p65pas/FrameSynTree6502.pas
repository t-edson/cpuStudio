unit FrameSynTree6502;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, TreeFilterEdit, Forms, Controls,
  ComCtrls, Menus, ActnList, ExtCtrls, LCLProc, Graphics,
  Globales, FormElemProperty, Parser,
  {AstElemP65, AstTree, }ASTunit, alexiaLex, MisUtils;
type
  { TfraSynxTree6502 }
  TfraSynxTree6502 = class(TFrame)
  published
    acGenRefres: TAction;
    acGenGoTo: TAction;
    acGenProp: TAction;
    acGenExpAll: TAction;
    acGenDoAnalys: TAction;
    acGenDoOptim: TAction;
    acGenDoSinth: TAction;
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
    mnRefresh: TMenuItem;
    mnProper: TMenuItem;
    mnRefresh1: TMenuItem;
    mnRefresh2: TMenuItem;
    Panel1: TPanel;
    PopupElem: TPopupMenu;
    PopupFrame: TPopupMenu;
    TreeFilterEdit1: TTreeFilterEdit;
    TreeView1: TTreeView;
    procedure acGenDoAnalysExecute(Sender: TObject);
    procedure acGenDoOptimExecute(Sender: TObject);
    procedure acGenDoSinthExecute(Sender: TObject);
    procedure acGenExpAllExecute(Sender: TObject);
    procedure acGenGoToExecute(Sender: TObject);
    procedure acGenRefresExecute(Sender: TObject);
    procedure acGenPropExecute(Sender: TObject);
    procedure TreeView1DblClick(Sender: TObject);
    procedure TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TreeView1SelectionChanged(Sender: TObject);
  private
    FBackColor: TColor;
    FTextColor: TColor;
    cpx       : TParser;   //Reference to lexer
    syntaxTree: TProgram; //Reference to SyntaxTree
    frmElemProp: TfrmElemProperty;  //Formulario de propiedades
    function AddNodeTo(nodParent: TTreeNode; elem: TASTNode; nodName: string = ''
      ): TTreeNode;
    procedure frmElemPropertyExplore(elem: TASTNode);
    procedure AddChildNodes(curNode: TTreeNode; curEle: TASTNode);
    function SelectedIsMain: boolean;
    function SelectedIsElement: boolean;
    procedure TreeView1AdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
  public
    OnLocateElemen: procedure(fileSrc: string; row, col: integer) of object;
    OnReqAnalysis  : procedure of object;
    OnReqOptimizat : procedure of object;
    OnReqSynthesis : procedure of object;
    procedure SetBackColor(AValue: TColor);
    procedure SetTextColor(AValue: TColor);
    function HasFocus: boolean;
    property BackColor: TColor read FBackColor write SetBackColor;
    property TextColor: TColor read FTextColor write SetTextColor;
  public    //Initialization
    procedure Refresh;
    procedure Init(Compiler: TParser);
    constructor Create(AOwner: TComponent) ; override;
  end;

implementation
{$R *.lfm}
var
  //Cadenas con los títulos de los nodos a mostrar en el árbol
  TIT_MAIN, TIT_UNIT : string;
  TIT_CONS: String;
  TIT_VARS: String;
  TIT_FUNC: String;
  TIT_TYPE: String;
  TIT_OTHER: String;

{ TfraSynxTree6502 }
function TfraSynxTree6502.AddNodeTo(nodParent: TTreeNode; elem: TASTNode;
  nodName: string = ''): TTreeNode;
{Agrega un nodo nuevo, al elemento "nodParent", que representa al elemento de sintaxis
"elem", configurando el ícono apropiado.}
var
  nod: TTreeNode;
  eleExp: TExpression;
  procDecl: TProcDecl;
  functDecl: TFunctionDecl;
  varRef: TVariableRef;
  numberLit: TNumberLiteral;
  binaryOp: TBinaryOp;
  procedCall: TProcedureCall;
  typeDecl: TTypeDecl;
  arrIndex: TArrayIndex;
//  sen: TAstSentence;
//  asmInst: TAstAsmInstr;
begin
  if elem = nil then begin
    nod := TreeView1.Items.AddChild(nodParent, nodName);
    nod.ImageIndex := 0;
    nod.SelectedIndex := 0;
    nod.Data := elem;
    Result := nod;
    exit;
  end;
  {if elem.idClass = eleConsDec then begin
    nod.ImageIndex := 23;
    nod.SelectedIndex := 23;
  end else }if elem.NodeType = ntVarDecl then begin
    nod := TreeView1.Items.AddChild(nodParent, TVarDecl(elem).Name);
    nod.ImageIndex := 24;
    nod.SelectedIndex := 24;
  end else if elem.nodeType = ntTypeDecl then begin
    typeDecl := TTypeDecl(elem);
    nod := TreeView1.Items.AddChild(nodParent, typeDecl.Name);
    nod.ImageIndex := 15;
    nod.SelectedIndex := 15;
  end else if elem.nodeType = ntProcDecl then begin
    procDecl := TProcDecl(elem);
    nod := TreeView1.Items.AddChild(nodParent, procDecl.Name);
    nod.ImageIndex := 26;
    nod.SelectedIndex := 26;
  end else if elem.NodeType = ntFunction then begin
    functDecl := TFunctionDecl(elem);
    nod := TreeView1.Items.AddChild(nodParent, functDecl.Name);
    nod.ImageIndex := 16;
    nod.SelectedIndex := 16;
//  end else if elem.idClass = eleUnit then begin
//nod := TreeView1.Items.AddChild(nodParent, '?');
//    nod.ImageIndex := 6;
//    nod.SelectedIndex := 6;
  end else if elem.NodeType = ntBlock then begin
    nod := TreeView1.Items.AddChild(nodParent, '?');
    nod.ImageIndex := 5;
    nod.SelectedIndex := 5;
  end else if elem.NodeType = ntBinaryOp then begin
    binaryOp := TBinaryOp(elem);
    nod := TreeView1.Items.AddChild(nodParent, binaryOp.Op);
    nod.ImageIndex := 3;
    nod.SelectedIndex := 3;
//  end else if elem.idClass = eleSenten then begin
//    sen := TAstSentence(elem);
//    nod.Text :=   '<sentnc: ' + sen.sntTypeAsStr + '>';
//    //nod.Text := '<sentence>';
//    nod.ImageIndex := 12;
//    nod.SelectedIndex := 12;
//  end else if elem.idClass = eleAsmInstr then begin
//    asmInst := TAstAsmInstr(elem);
//    if asmInst.iType = itLabel then begin  //Etiquetas
//      nod.ImageIndex := 22;
//      nod.SelectedIndex := 22;
//    end else begin
//      nod.ImageIndex := 19;
//      nod.SelectedIndex := 19;
//    end;
  end else if elem.NodeType = ntAssignment then begin
    nod := TreeView1.Items.AddChild(nodParent, 'assign');
    nod.ImageIndex := 3;
    nod.SelectedIndex := 3;
  end else if elem.nodeType = ntFunctionCall then begin
    nod := TreeView1.Items.AddChild(nodParent, '?');
    nod.ImageIndex := 3;
    nod.SelectedIndex := 3;
  end else if elem.nodeType = ntProcedureCall then begin
    procedCall := TProcedureCall(elem);
    nod := TreeView1.Items.AddChild(nodParent, procedCall.Name);
    nod.ImageIndex := 3;
    nod.SelectedIndex := 3;
  end else if elem.nodeType = ntVariableRef then begin
    varRef := TVariableRef(elem);
    nod := TreeView1.Items.AddChild(nodParent, varRef.Name);
    nod.ImageIndex := 2;
    nod.SelectedIndex := 2;
  end else if elem.nodeType = ntArrayIndex then begin
    arrIndex := TArrayIndex(elem);
    nod := TreeView1.Items.AddChild(nodParent, arrIndex.ArrayVar.Name);
    nod.ImageIndex := 27;
    nod.SelectedIndex := 27;
//    Index := arrIndex.Indices;
  end else if elem.nodeType = ntNumberLiteral then begin
    numberLit := TNumberLiteral(elem);
    nod := TreeView1.Items.AddChild(nodParent, IntToStr(numberLit.Value));
    nod.ImageIndex := 4;
    nod.SelectedIndex := 4;
  end else begin
    nod := TreeView1.Items.AddChild(nodParent, '?');
    nod.ImageIndex := 0;
    nod.SelectedIndex := 0;
  end;
  nod.Data := elem;
  Result := nod;
end;
procedure TfraSynxTree6502.frmElemPropertyExplore(elem: TASTNode);
begin
  acGenGoToExecute(self);
end;
procedure TfraSynxTree6502.AddChildNodes(curNode: TTreeNode; curEle: TASTNode);
{Crea los subnodos del nodo "nodMain", de forma recursiva.}
var
  elem: TASTNode;
  varDecl: TVarDecl;
  procDecl: TProcDecl;
  nodElem, nodList: TTreeNode;
  prog: TProgram;
  assig: TAssignment;
  binaryOp: TBinaryOp;
  procedCall: TProcedureCall;
  arrIndex: TArrayIndex;
begin
  if curEle.NodeType = ntAssignment then begin
    assig := TAssignment(curEle);
    //Parte izquierda de la asignación
    nodElem := AddNodeTo(curNode, assig.Target);
    //Parte derecha de la asignación
    nodElem := AddNodeTo(curNode, assig.Value);
    AddChildNodes(nodElem, assig.Value);  //Llamada recursiva
    //Expande la asignación
    curNode.Expanded := true;
  end else if curEle.NodeType = ntBinaryOp then begin
    binaryOp := TBinaryOp(curEle);
    //Parte izquierda de la operación binaria
    nodElem := AddNodeTo(curNode, binaryOp.Left);
    AddChildNodes(nodElem, binaryOp.Left);  //Llamada recursiva
    //Parte derecha de la operación binaria
    nodElem := AddNodeTo(curNode, binaryOp.Right);
    AddChildNodes(nodElem, binaryOp.Right);  //Llamada recursiva
  end else if curEle.NodeType = ntProcedureCall then begin
    procedCall := TProcedureCall(curEle);
    //Agrega elementos
    for elem in procedCall.Arguments do begin
      nodElem := AddNodeTo(curNode, elem);
      AddChildNodes(nodElem, elem);  //Llamada recursiva
      ////Expande los Body
      //if elem.nodeType = ntBlock then nodElem.Expanded := true;
      //if elem.nodeType = ntAssignment then nodElem.Expanded := true;
      ////if elem.Parent.nodeType = ntAssignment then nodElem.Expanded := true; //Expande instrucciones
    end;
  end else if curEle.NodeType = ntArrayIndex then begin
    arrIndex := TArrayIndex(curEle);
    //Agrega índices
    for elem in arrIndex.Indices do begin
      nodElem := AddNodeTo(curNode, elem);
      AddChildNodes(nodElem, elem);  //Llamada recursiva
    end;
  end;


//  //Agrega elementos
//  for elem in curEle.elements do begin
//      nodElem := AddNodeTo(curNode, elem);
//      AddChildNodes(nodElem, elem);  //Llamada recursiva
//      //Expande los Body
//      if elem.nodeType = ntBlock then nodElem.Expanded := true;
//      if elem.nodeType = ntAssignment then nodElem.Expanded := true;
//      //if elem.Parent.nodeType = ntAssignment then nodElem.Expanded := true; //Expande instrucciones
//  end;
end;
function TfraSynxTree6502.SelectedIsMain: boolean;
//Indica si el nodo seleccionado es el nodo raiz
begin
  if TreeView1.Selected = nil then exit(false);
  if TreeView1.Selected.Level = 0 then exit(true);
  exit(false);
end;
function TfraSynxTree6502.SelectedIsElement: boolean;
//Indica si el nodo seleccionado es un nodo que representa a un elemeno.
var
  nod: TTreeNode;
begin
  if TreeView1.Selected = nil then exit(false);
  nod := TreeView1.Selected;
  //Todos son elementos.
  if nod.Level >= 1 then exit(true);
  exit(false);
end;
procedure TfraSynxTree6502.SetBackColor(AValue: TColor);
{Configura el color de fondo}
begin
//  if FBackColor = AValue then Exit;
  FBackColor := AValue;
  TreeView1.BackgroundColor := AValue;
end;
procedure TfraSynxTree6502.SetTextColor(AValue: TColor);
begin
//  if FTextColor = AValue then Exit;
  FTextColor := AValue;
end;
procedure TfraSynxTree6502.TreeView1AdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
begin
  with TreeView1.Canvas do begin
     if Node.Level = 0 then  begin
       Font.Style := [fsBold, fsItalic];
     end else begin
       Font.Style := [];
     end;
     font.Color:= FTextColor;
     DefaultDraw := true;   //Para que siga ejecutando la rutina de dibujo
  end;
end;
function TfraSynxTree6502.HasFocus: boolean;
{Indica si el frame tiene el enfoque.}
begin
  Result := TreeView1.Focused;
end;
procedure TfraSynxTree6502.TreeView1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  nod: TTreeNode;
begin
  //Quita la selección, si se pulsa en una zona vacía
  nod := TreeView1.GetNodeAt(X,Y);
  if nod=nil then begin
    TreeView1.Selected := nil;
  end;
  //Abre el menú que corresponda
  if button = mbRight then begin
    if SelectedIsElement then begin
      PopupElem.PopUp;
    end else begin
      PopupFrame.PopUp;
    end;
  end;
end;
procedure TfraSynxTree6502.TreeView1SelectionChanged(Sender: TObject);
var
  elem: TASTNode;
begin
  if not frmElemProp.Visible then exit;
  if TreeView1.Selected = nil then exit;
  if TreeView1.Selected.Data = nil then begin
    frmElemProp.Clear;
    exit;
  end;
  elem := TASTNode(TreeView1.Selected.Data);
  frmElemProp.Exec(cpx.lex, elem);
end;
procedure TfraSynxTree6502.TreeView1DblClick(Sender: TObject);
begin
  acGenGoToExecute(self);
end;
//////////////////////// Acciones /////////////////////
procedure TfraSynxTree6502.acGenRefresExecute(Sender: TObject);
begin
  Refresh;
end;
procedure TfraSynxTree6502.acGenGoToExecute(Sender: TObject);
var
  elem: TASTNode;
  fileName: String;
begin
  if SelectedIsElement then begin
    elem := TASTNode(TreeView1.Selected.Data);
    if elem = nil then exit;
    fileName := cpx.lex.ctxFile(elem.SrcPos);
    if OnLocateElemen <> nil then OnLocateElemen(fileName, elem.SrcPos.row, elem.SrcPos.col);
  end;
end;
procedure TfraSynxTree6502.acGenExpAllExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to TreeView1.Items.Count - 1 do begin
    TreeView1.Items[i].Expanded := true;
  end;
end;
procedure TfraSynxTree6502.acGenPropExecute(Sender: TObject);
var
  elem: TASTNode;
begin
  if TreeView1.Selected = nil then exit;
  if TreeView1.Selected.Data = nil then exit;
  elem := TASTNode(TreeView1.Selected.Data);
  frmElemProp.Exec(cpx.lex, elem);
  frmElemProp.Show;
end;
procedure TfraSynxTree6502.acGenDoAnalysExecute(Sender: TObject);
{Require the compiler to do Only Analysis.}
begin
  if OnReqAnalysis<>nil then OnReqAnalysis();
end;
procedure TfraSynxTree6502.acGenDoOptimExecute(Sender: TObject);
{Require the compiler to do Analysis and Optimization.}
begin
  if OnReqOptimizat<>nil then OnReqOptimizat();
end;
procedure TfraSynxTree6502.acGenDoSinthExecute(Sender: TObject);
{Require the compiler to do Analysis, Optimization and Synthesis.}
begin
  if OnReqSynthesis<>nil then OnReqSynthesis();
end;
//Initialization
procedure TfraSynxTree6502.Refresh;
{Actualiza el árbol de sintaxis con el AST del compilador}
var
  nodMain, nodDecl, nodElem, nodBody: TTreeNode;
  prog: TProgram;
  elem: TASTNode;
begin
  TreeView1.Visible := true;

  TreeView1.Items.BeginUpdate;
  TreeView1.Items.Clear;
  nodMain := TreeView1.Items.AddChild(nil, TIT_MAIN);
  nodMain.ImageIndex := 1;
  nodMain.SelectedIndex := 1;
  nodMain.Data := syntaxTree;  //Elemento raiz
  //AddChildNodes(nodMain, syntaxTree);

  prog := TProgram(syntaxTree);

  //Agrega nodo para las declaraciones globales
  nodDecl := AddNodeTo(nodMain, nil, 'Declarations');
  for elem in prog.Declarations.Items do begin
    nodElem := AddNodeTo(nodDecl, elem);  //Agrega el nodo
    AddChildNodes(nodElem, elem);  //Llamada recursiva
  end;
  //Agrega nodo para el programa principal
  nodBody := AddNodeTo(nodMain, nil, 'Body');
  for elem in prog.MainBody.Statements do begin
    nodElem := AddNodeTo(nodBody, elem);  //Agrega el nodo
    AddChildNodes(nodElem, elem);  //Llamada recursiva
  end;
  //Termina configuración
  nodMain.Expanded := true;    //Expande nodo raiz
  nodDecl.Expanded := true;
  nodBody.Expanded := true;
  TreeView1.Items.EndUpdate;
end;
procedure TfraSynxTree6502.Init(Compiler    : TParser);
begin
  cpx        := Compiler;
  syntaxTree := Compiler.ast;
  TreeView1.ReadOnly := true;
  TreeView1.OnAdvancedCustomDrawItem := @TreeView1AdvancedCustomDrawItem;
  TreeView1.Options := TreeView1.Options - [tvoThemedDraw];
  frmElemProp.OnExplore := @frmElemPropertyExplore;
end;
constructor TfraSynxTree6502.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //Creamos el formulario de propiedades como hijo, así que no necesitaremos destruirlo manualmente.
  frmElemProp := TfrmElemProperty.Create(self);
end;
end.
//435
