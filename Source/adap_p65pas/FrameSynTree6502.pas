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
    cpx       : TParser;  //Reference to lexer
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
  procDecl: TProcDecl;
  functDecl: TFunctDecl;
  varRef: TVariableRef;
  numberLit: TNumberLiteral;
  binaryOp: TBinaryOp;
  functCall: TFunctionCall;
  varDecl: TVarDecl;
  constDecl: TConstDecl;
  txtNumber: String;
  unaryOp: TUnaryOp;
  fieldAccess: TFieldAccess;
  typeDef: TTypeDef;
  strLiteral: TStringLiteral;
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
  {if elem.idClass = eleUnit then begin
     nod := TreeView1.Items.AddChild(nodParent, '?');
     nod.ImageIndex := 6;
     nod.SelectedIndex := 6;
  end else }if elem.NodeType = ntConstDecl then begin
    constDecl := TConstDecl(elem);
    nod := TreeView1.Items.AddChild(nodParent, constDecl.Name);
    nod.ImageIndex := 23;
    nod.SelectedIndex := 23;
  end else if elem.NodeType = ntVarDecl then begin
    varDecl:= TVarDecl(elem);
    nod := TreeView1.Items.AddChild(nodParent, varDecl.Name);
    nod.ImageIndex := 24;
    nod.SelectedIndex := 24;
  end else if elem.nodeType in [ntSubrangeType, ntEnumType, ntArrayType,
                                ntRecordType, ntPointerType, ntAliasType] then begin
    typeDef := TTypeDef(elem);
    nod := TreeView1.Items.AddChild(nodParent, typeDef.TypeName);
    nod.ImageIndex := 15;
    nod.SelectedIndex := 15;
  end else if elem.nodeType = ntProcDecl then begin
    procDecl := TProcDecl(elem);
    nod := TreeView1.Items.AddChild(nodParent, procDecl.Name);
    nod.ImageIndex := 26;
    nod.SelectedIndex := 26;
  end else if elem.NodeType = ntFunctDecl then begin
    functDecl := TFunctDecl(elem);
    nod := TreeView1.Items.AddChild(nodParent, functDecl.Name);
    nod.ImageIndex := 16;
    nod.SelectedIndex := 16;
  end else if elem.NodeType = ntDeclarations then begin
    nod := TreeView1.Items.AddChild(nodParent, 'Declarations');
    nod.ImageIndex := 0;
    nod.SelectedIndex := 0;
  end else if elem.NodeType = ntBlock then begin
    nod := TreeView1.Items.AddChild(nodParent, 'Block');
    nod.ImageIndex := 0;
    nod.SelectedIndex := 0;
  end else if elem.NodeType = ntBinaryOp then begin
    binaryOp := TBinaryOp(elem);
    nod := TreeView1.Items.AddChild(nodParent, binaryOp.Op);
    nod.ImageIndex := 3;
    nod.SelectedIndex := 3;
  end else if elem.NodeType = ntUnaryOp then begin
    unaryOp := TUnaryOp(elem);
    nod := TreeView1.Items.AddChild(nodParent, unaryOp.Op);
    nod.ImageIndex := 18;
    nod.SelectedIndex := 18;
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
    functCall := TFunctionCall(elem);
    nod := TreeView1.Items.AddChild(nodParent, functCall.Name);
    nod.ImageIndex := 3;
    nod.SelectedIndex := 3;
  end else if elem.nodeType = ntVariableRef then begin
    varRef := TVariableRef(elem);
    nod := TreeView1.Items.AddChild(nodParent, varRef.Name);
    nod.ImageIndex := 2;
    nod.SelectedIndex := 2;
  end else if elem.nodeType = ntPointerDeref then begin
    nod := TreeView1.Items.AddChild(nodParent, '_ptr');
    nod.ImageIndex := 29;
    nod.SelectedIndex := 29;
  end else if elem.nodeType = ntArrayIndex then begin
    nod := TreeView1.Items.AddChild(nodParent, '_item');
    nod.ImageIndex := 27;
    nod.SelectedIndex := 27;
  end else if elem.nodeType = ntFieldAccess then begin
    fieldAccess := TFieldAccess(elem);
    nod := TreeView1.Items.AddChild(nodParent, fieldAccess.FieldName);
    nod.ImageIndex := 28;
    nod.SelectedIndex := 28;
  end else if elem.nodeType = ntNumberLiteral then begin
    numberLit := TNumberLiteral(elem);
    if numberLit.IsInteger then begin
      txtNumber := IntToStr(numberLit.IntValue);
    end else begin
      txtNumber := FloatToStr(numberLit.FloatValue);
    end;
    nod := TreeView1.Items.AddChild(nodParent, txtNumber);
    nod.ImageIndex := 4;
    nod.SelectedIndex := 4;
  end else if elem.nodeType = ntStringLiteral then begin
    strLiteral := TStringLiteral(elem);
    nod := TreeView1.Items.AddChild(nodParent, strLiteral.Value);
    nod.ImageIndex := 30;
    nod.SelectedIndex := 30;
  end else if elem.nodeType = ntIfStatement then begin
    nod := TreeView1.Items.AddChild(nodParent, 'IF');
    nod.ImageIndex := 12;
    nod.SelectedIndex := 12;
  end else if elem.nodeType = ntWhileLoop then begin
    nod := TreeView1.Items.AddChild(nodParent, 'WHILE');
    nod.ImageIndex := 12;
    nod.SelectedIndex := 12;
  end else if elem.nodeType = ntRepeatUntil then begin
    nod := TreeView1.Items.AddChild(nodParent, 'REPEAT');
    nod.ImageIndex := 12;
    nod.SelectedIndex := 12;
  end else if elem.nodeType = ntForLoop then begin
    nod := TreeView1.Items.AddChild(nodParent, 'FOR');
    nod.ImageIndex := 12;
    nod.SelectedIndex := 12;
  end else if elem.nodeType = ntCaseStatement then begin
    nod := TreeView1.Items.AddChild(nodParent, 'CASE');
    nod.ImageIndex := 12;
    nod.SelectedIndex := 12;
  end else begin
    nod := TreeView1.Items.AddChild(nodParent, '?');
    nod.ImageIndex := 0;
    nod.SelectedIndex := 0;
  end;
  //Guarda referencia al elemento
  nod.Data := elem;
  //LLamada recursiva para agregar nodos hijos
  AddChildNodes(nod, elem);  //Llamada recursiva
  //Devuelve referencia al nodo
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
  procDecl: TProcDecl;
  assig: TAssignment;
  binaryOp: TBinaryOp;
  arrIndex: TArrayIndex;
  functCall: TFunctionCall;
  constDecl: TConstDecl;
  unaryOp: TUnaryOp;
  fieldAccess: TFieldAccess;
  ptrDeref: TPointerDeref;
  ifStatem: TIfStatement;
  nodDeclars: TDeclarations;
  block: TBlock;
  whileLoop: TWhileLoop;
  repUntil: TRepeatUntil;
  forLoop: TForLoop;
begin
  if curEle.NodeType = ntConstDecl then begin
    constDecl := TConstDecl(curEle);
    //Añade valor de la constante
    AddNodeTo(curNode, constDecl.Value);
  end else if curEle.NodeType = ntProcDecl then begin
    procDecl := TProcDecl(curEle);
    //Agrega nodo para los parámetros
    //AddNodeTo(curNode, procDecl.Parameters);
    //Agrega nodo para las declaraciones
    AddNodeTo(curNode, procDecl.Declarations);
    //Agrega nodo para el cuerpo
    AddNodeTo(curNode, procDecl.Body);
  end else if curEle.NodeType = ntDeclarations then begin
    nodDeclars := TDeclarations(curEle);
    for elem in nodDeclars.Items do begin
      AddNodeTo(curNode, elem);  //Agrega el nodo
    end;
  end else if curEle.NodeType = ntAssignment then begin
    assig := TAssignment(curEle);
    //Parte izquierda de la asignación
    AddNodeTo(curNode, assig.Target);
    //Parte derecha de la asignación
    AddNodeTo(curNode, assig.Value);
    //Expande la asignación
    curNode.Expanded := true;
  end else if curEle.NodeType = ntBinaryOp then begin
    binaryOp := TBinaryOp(curEle);
    //Parte izquierda de la operación binaria
    AddNodeTo(curNode, binaryOp.Left);
    //Parte derecha de la operación binaria
    AddNodeTo(curNode, binaryOp.Right);
  end else if curEle.NodeType = ntUnaryOp then begin
    unaryOp := TUnaryOp(curEle);
    //Argumento
    AddNodeTo(curNode, unaryOp.Operand);
  end else if curEle.NodeType = ntFunctionCall then begin
    functCall := TFunctionCall(curEle);
    //Agrega elementos
    for elem in functCall.Arguments do begin
      AddNodeTo(curNode, elem);
      ////Expande los Body
      //if elem.nodeType = ntBlock then nodElem.Expanded := true;
      //if elem.nodeType = ntAssignment then nodElem.Expanded := true;
      ////if elem.Parent.nodeType = ntAssignment then nodElem.Expanded := true; //Expande instrucciones
    end;
  end else if curEle.nodeType = ntPointerDeref then begin
    ptrDeref := TPointerDeref(curEle);
    //Agrega variable base
    AddNodeTo(curNode, ptrDeref.Pointer);
  end else if curEle.NodeType = ntArrayIndex then begin
    arrIndex := TArrayIndex(curEle);
    //Agrega variable base
    AddNodeTo(curNode, arrIndex.ArrayVar);
    //Agrega índices
    for elem in arrIndex.Indices do begin
      AddNodeTo(curNode, elem);
    end;
  end else if curEle.nodeType = ntFieldAccess then begin
    fieldAccess := TFieldAccess(curEle);
    //Añade la variable base de registro
    AddNodeTo(curNode, fieldAccess.RecordVar);
  end else if curEle.nodeType = ntIfStatement then begin
    ifStatem := TIfStatement(curEle);
    AddNodeTo(curNode, ifStatem.Condition);
    AddNodeTo(curNode, ifStatem.ThenBranch);
    AddNodeTo(curNode, ifStatem.ElseBranch);
    curNode.Expanded := true;
  end else if curEle.nodeType = ntWhileLoop then begin
    whileLoop := TWhileLoop(curEle);
    AddNodeTo(curNode, whileLoop.Condition);
    AddNodeTo(curNode, whileLoop.Body);
    curNode.Expanded := true;
  end else if curEle.nodeType = ntRepeatUntil then begin
    repUntil := TRepeatUntil(curEle);
    AddNodeTo(curNode, repUntil.Body);
    AddNodeTo(curNode, repUntil.Condition);
    curNode.Expanded := true;
  end else if curEle.nodeType = ntForLoop then begin
    forLoop := TForLoop(curEle);
    AddNodeTo(curNode, forLoop.ControlVar);
    AddNodeTo(curNode, forLoop.StartExpr);
    AddNodeTo(curNode, forLoop.EndExpr);
    AddNodeTo(curNode, forLoop.Body);
    curNode.Expanded := true;
  end else if curEle.NodeType = ntBlock then begin
    block := TBlock(curEle);
    for elem in block.Statements do begin
      AddNodeTo(curNode, elem);  //Agrega el nodo
    end;
  end;
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
  nodMain, nodDecl, nodBody: TTreeNode;
  prog: TProgram;
begin
  TreeView1.Visible := true;

  TreeView1.Items.BeginUpdate;
  TreeView1.Items.Clear;
  nodMain := TreeView1.Items.AddChild(nil, TIT_MAIN);
  nodMain.ImageIndex := 1;
  nodMain.SelectedIndex := 1;
  nodMain.Data := syntaxTree;  //Elemento raiz
  //AddChildNodes(nodMain, syntaxTree);
  prog := syntaxTree;
  //Agrega nodo para las declaraciones globales
  nodDecl := AddNodeTo(nodMain, prog.Declarations, 'Declarations');
  //Agrega nodo para el programa principal
  nodBody := AddNodeTo(nodMain, prog.Body, 'Body');
  //Termina configuración
  nodMain.Expanded := true;    //Expande nodo raiz
  nodDecl.Expanded := true;
  nodBody.Expanded := true;
  TreeView1.Items.EndUpdate;
end;
procedure TfraSynxTree6502.Init(Compiler    : TParser);
begin
  cpx        := Compiler;
  syntaxTree := Compiler.astProg;
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
