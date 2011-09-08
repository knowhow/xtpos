// Define local variables
var terminalCol = 1;

var editMode    = 1;
var viewMode    = 2;

var _model = new XSqlTableModel();
var _currIdx = 0 - 0;

var _close		= mywindow.findChild("_close");
var _terminals 	= mywindow.findChild("_terminals");
var _use		= mywindow.findChild("_use");
var _view		= mywindow.findChild("_view");

// Terminal list  connections
_close.clicked.connect(mywindow, "close");
_use.clicked.connect(useTerminal);
_view.clicked.connect(viewTerminal);
_terminals["newModel(XSqlTableModel*)"].connect(setModel);
_terminals["rowSelected(int)"].connect(setIndex);

// Populate the list
populate();

// Column settings	
with (_terminals)
{
  setColumn("Site"		, 100	, 0, true	,"site");
  setColumn("Terminal"		, 60	, 0, true	,"terminal");
  setColumn("Active"		, 60	, 0, true	,"active");
  setColumn("Opened"		, -1	, 0, true	,"opened");
  setColumn("Opening Balance"	, 100	, 0, false	,"opening_balance");
  setColumn("Current Balance"	, 100	, 0, true	,"current_balance");
  setColumn("Total Sales"		, 100	, 0, false	,"total_sales");
  setColumn("Cash Sales"		, 100	, 0, false	,"cash_sales");
  setColumn("Credit Sales"	, 100	, 0, false	,"credit_card_sales");
  setColumn("Check Sales"		, 100	, 0, false	,"check_sales");
}

function setIndex(idx)
{
  _currIdx = idx;
}

function setModel(model)
{
  _model = model;
}

function useTerminal()
{
  openTerminal(editMode)
}

function viewTerminal()
{
  openTerminal(viewMode)
}

function openTerminal(mode)
{
  var childwnd = toolbox.openWindow("cashRegister", mywindow, Qt.NonModal, Qt.Sheet);
  var params   = new Object;

  params.mode   = mode;
  params.index  = _currIdx;

  childwnd.findChild("_cashRegister").setModel(_model);
  childwnd.set(params);
}

function populate()
{
  _terminals.select();
}