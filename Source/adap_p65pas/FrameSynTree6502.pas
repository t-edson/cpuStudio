unit FrameSynTree6502;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, TreeFilterEdit, Forms, Controls,
  ComCtrls, Menus, ActnList, ExtCtrls, LCLProc, Graphics,
  Globales, FormElemProperty, AstPascal, Analyzer, alexiaLex, MisUtils;
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
    cpx       : TAnalyzer;  //Referencia al Compilador
    lexer     : TAleLexer;  //Referencia al lexer
    frmElemProp: TfrmElemProperty;  //Formulario de propiedades
    function AddNode(nodParent: TTreeNode; imgIndex: integer; nodName: string
      ): TTreeNode;
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
    procedure Init(cpx0: TAnalyzer);
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
procedure TfraSynxTree6502.frmElemPropertyExplore(elem: TASTNode);
begin
  acGenGoToExecute(self);
end;
function TfraSynxTree6502.AddNode(nodParent: TTreeNode; imgIndex: integer; nodName: string): TTreeNode;
{Agrega un nodo con un ícono y un nombre específico}
var
  nod: TTreeNode;
begin
  nod := TreeView1.Items.AddChild(nodParent, nodName);
  nod.ImageIndex := imgIndex;
  nod.SelectedIndex := imgIndex;
  //Devuelve referencia al nodo
  Result := nod;
end;
function TfraSynxTree6502.AddNodeTo(nodParent: TTreeNode; elem: TASTNode;
  nodName: string = ''): TTreeNode;
{Agrega un nodo nuevo, al elemento "nodParent", que representa al elemento de sintaxis
"elem", configurando el ícono apropiado.}
var
  nod: TTreeNode;
  numberLit: TNumberLiteral;
  txtNumber, rango, nodLabel: String;
  arrayRange: TArrayRange;
begin
  if elem = nil then begin
    nod := AddNode(nodParent, 17, nodName);
    nod.Data := elem;
    Exit(nod);
  end;
  case elem.NodeType of
  ntConstDecl:
    nod := AddNode(nodParent, 23, TConstDecl(elem).Name);
  ntVarDecl:
    nod := AddNode(nodParent, 24, TVarDecl(elem).Name);
  ntProcFunctDecl:
    nod := AddNode(nodParent, 26, TProcFunctDecl(elem).Name);
  ntTypeDecl:
    nod := AddNode(nodParent, 15, TTypeDecl(elem).Name);
  ntSubranTypeDef, ntEnumTypeDef, ntRecordTypeDef, ntPointerTypeDef, ntAliasTypeDef:
    nod := AddNode(nodParent, 31, TTypeDef(elem).TypeName);
  ntArrayTypeDef: begin
    nodLabel := TArrayTypeDef(elem).TypeName;
    if nodLabel = '' then nodLabel := '<Array>';   //Declaración INLINE
    nod := AddNode(nodParent, 31, nodLabel);
  end;
//  ntDeclarations:
//    nod := AddNode(nodParent, 0, 'Declarations');
  ntBlock:
    nod := AddNode(nodParent, 0, 'Block');
  ntBinaryOp:
    nod := AddNode(nodParent, 3, TBinaryOp(elem).Op);
  ntUnaryOp:
    nod := AddNode(nodParent, 18, TUnaryOp(elem).Op);
  ntAssignment:
    nod := AddNode(nodParent, 3, 'assign');
  ntProcFunctCall:
    nod := AddNode(nodParent, 3, TFunctionCall(elem).Name);
  ntVariableRef:
    nod := AddNode(nodParent, 2, TVariableRef(elem).Name);
  ntPointerDeref:
    nod := AddNode(nodParent, 29, '_ptr');
  ntArrayRef:
    nod := AddNode(nodParent, 27, '_item');
  ntArrayRange: begin
    arrayRange := TArrayRange(elem);
    if arrayRange.HighExpr = Nil then begin
      rango := arrayRange.LowExpr.ValueStr + '..';
    end else begin
      rango := arrayRange.LowExpr.ValueStr + '..' + arrayRange.HighExpr.ValueStr;
    end;
    nod := AddNode(nodParent, 27, rango);
  end;
  ntFieldAccess:
    nod := AddNode(nodParent, 28, TFieldAccess(elem).FieldName);
  ntNumberLiteral: begin
    numberLit := TNumberLiteral(elem);
    if numberLit.IsInteger then begin
      txtNumber := IntToStr(numberLit.IntValue);
    end else begin
      txtNumber := FloatToStr(numberLit.FloatValue);
    end;
    nod := AddNode(nodParent, 4, txtNumber);
  end;
  ntStringLiteral:
    nod := AddNode(nodParent, 30, TStringLiteral(elem).Value);
  ntBooleanLiteral:
    nod := AddNode(nodParent, 19, TBooleanLiteral(elem).ValueStr);
  ntArrayLiteral:
    nod := AddNode(nodParent, 27, TArrayLiteral(elem).ValueStr);
  ntRecordLiteral:
    nod := AddNode(nodParent, 28, TRecordLiteral(elem).ValueStr);
  ntIfStatement:
    nod := AddNode(nodParent, 12, 'IF');
  ntWhileLoop:
    nod := AddNode(nodParent, 12, 'WHILE');
  ntRepeatUntil:
    nod := AddNode(nodParent, 12, 'REPEAT');
  ntForLoop:
    nod := AddNode(nodParent, 12, 'FOR');
  ntCaseStatement:
    nod := AddNode(nodParent, 10, 'CASE');
  ntAsmBlock:
    nod := AddNode(nodParent, 12, 'Asm');
  ntAsmInstruction:
    nod := AddNode(nodParent, 19, 'Instruction');
  ntProgram:
    nod := AddNode(nodParent, 1, TProgram(elem).Name);
  ntUnit:
    nod := AddNode(nodParent, 1, TUnit(elem).Name);
  else
    nod := AddNode(nodParent, 0, '?');
  end;
  //Guarda referencia al elemento
  nod.Data := elem;
  //LLamada recursiva para agregar nodos hijos
  AddChildNodes(nod, elem);  //Llamada recursiva
  //Devuelve referencia al nodo
  Result := nod;
end;
procedure TfraSynxTree6502.AddChildNodes(curNode: TTreeNode; curEle: TASTNode);
{Crea los subnodos del nodo "nodMain", de forma recursiva.}
var
  elem: TASTNode;
  procDecl: TProcFunctDecl;
  assig: TAssignment;
  binaryOp: TBinaryOp;
  arrIndex: TArrayRef;
  functCall: TFunctionCall;
  constDecl: TConstDecl;
  unaryOp: TUnaryOp;
  fieldAccess: TFieldAccess;
  ptrDeref: TPointerDeref;
  ifStatem: TIfStatement;
  block: TBlock;
  whileLoop: TWhileLoop;
  repUntil: TRepeatUntil;
  forLoop: TForLoop;
  recordType: TRecordTypeDef;
  varDecl: TVarDecl;
  arrayType: TArrayTypeDef;
  asmBlock: TAsmBlock;
  Prog: TProgram;
  unt: TUnit;
  nodInterf, nodImplem, nodDecls: TTreeNode;
  TypeDecl: TTypeDecl;
begin
  if          curEle.NodeType = ntConstDecl then begin
    constDecl := TConstDecl(curEle);
    //Añade valor de la constante
    AddNodeTo(curNode, constDecl.Value);
  end else if curEle.NodeType = ntVarDecl then begin
    varDecl := TVarDecl(curEle);
    //Añade tipo de la variable
    AddNodeTo(curNode, varDecl.TypeDef);
  end else if curEle.NodeType = ntProcFunctDecl then begin
    procDecl := TProcFunctDecl(curEle);
    if procDecl.IsFunction then begin  //Tipo de retorno
      AddNodeTo(curNode, procDecl.ReturnTypeDef);
    end;
    if not procDecl.IsForward then begin
      //Agrega nodo para los parámetros
      //AddNodeTo(curNode, procDecl.Parameters);
      //Agrega nodo para las declaraciones y sus ítems
      nodDecls := AddNode(curNode, 0, 'Declarations');
      for elem in procDecl.Declarations do begin
        AddNodeTo(nodDecls, elem);  //Agrega el nodo
      end;
      //Agrega nodo para el cuerpo
      AddNodeTo(curNode, procDecl.Body);
    end;
  end else if curEle.NodeType = ntTypeDecl then begin
    TypeDecl := TTypeDecl(curEle);
    //Añade de definici¨´on
    AddNodeTo(curNode, TypeDecl.Definition);
  end else if curEle.NodeType = ntRecordTypeDef then begin
    recordType := TRecordTypeDef(curEle);
    for elem in recordType.Fields do begin
      AddNodeTo(curNode, elem);  //Agrega el nodo
    end;
  end else if curEle.NodeType = ntArrayTypeDef then begin
    arrayType := TArrayTypeDef(curEle);
    //Agrega los índices del arreglo
    for elem in arrayType.IndexRanges do begin
      AddNodeTo(curNode, elem);  //Agrega el nodo
    end;
    //Agrega el tipo de elemento
    AddNodeTo(curNode, arrayType.ElemTypeDef);
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
  end else if curEle.NodeType = ntProcFunctCall then begin
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
  end else if curEle.NodeType = ntArrayRef then begin
    arrIndex := TArrayRef(curEle);
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
  end else if curEle.nodeType = ntAsmBlock then begin
    asmBlock := TAsmBlock(curEle);
    for elem in asmBlock.Instructions do begin
      AddNodeTo(curNode, elem);  //Agrega el nodo
    end;
  end else if curEle.NodeType = ntBlock then begin
    block := TBlock(curEle);
    for elem in block.Statements do begin
      AddNodeTo(curNode, elem);  //Agrega el nodo
    end;
  end else if curEle.NodeType = ntProgram then begin
    prog := TProgram(curEle);
    //Agrega nodo para las declaraciones globales
    nodDecls := AddNode(curNode, 0, 'Declarations');
    nodDecls.Expanded := true;
    for elem in prog.Declarations do begin
      AddNodeTo(nodDecls, elem);  //Agrega el nodo
    end;
    //Agrega nodo para el programa principal
    AddNodeTo(curNode, prog.Body, 'Body')
    .Expanded := true;
  end else if curEle.NodeType = ntUnit then begin
    unt := TUnit(curEle);
    //Agrega las declaraciones globales
    nodInterf := AddNode(curNode, 0, 'Interface');   //Contenedor
    for elem in unt.InterfaceDecls do begin
      AddNodeTo(nodInterf, elem);  //Agrega el nodo
    end;
    nodInterf.Expanded := true;
    //Agrega nodo para el programa principal
    nodImplem := AddNode(curNode, 0, 'Implementation');
    for elem in unt.ImplementationDecls do begin
      AddNodeTo(nodImplem, elem);  //Agrega el nodo
    end;
    nodImplem.Expanded := true;
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
begin
  if not frmElemProp.Visible then exit;
  if TreeView1.Selected = nil then exit;
  if TreeView1.Selected.Data = nil then begin
    frmElemProp.Clear;
    exit;
  end;
  //Muestra propiedades
  frmElemProp.Exec(lexer, TreeView1.Selected);
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
    fileName := lexer.ctxFile(elem.SrcPos);
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
begin
  if TreeView1.Selected = nil then exit;
  if TreeView1.Selected.Data = nil then exit;
  frmElemProp.Exec(lexer, TreeView1.Selected);
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
  nodMain: TTreeNode;
begin
  TreeView1.Visible := true;
  TreeView1.Items.BeginUpdate;
  TreeView1.Items.Clear;
  //Agrega nodo principal
  if cpx.CompiledUnit then begin
    nodMain := AddNodeTo(Nil, cpx.astUnit);   //Agrega nodo de unidad
  end else begin
    nodMain := AddNodeTo(Nil, cpx.astProg);   //Agrega nodo de programa
  end;
  //Termina configuración
  nodMain.Expanded := true;    //Expande nodo raiz
  TreeView1.Items.EndUpdate;
end;
procedure TfraSynxTree6502.Init(cpx0: TAnalyzer);
begin
  lexer := cpx0.lexer;
  cpx   := cpx0;
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
