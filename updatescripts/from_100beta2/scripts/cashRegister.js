// Define Variables
var _viewMode     	= 2;

var _action 	= mywindow.findChild("_action");
var _active		= mywindow.findChild("_active");
var _adjustAmt   	= mywindow.findChild("_adjustAmt");
var _adjustDirection   = mywindow.findChild("_adjustDirection");
var _adjustGroup	= mywindow.findChild("_adjustGroup");
var _bankaccount	= mywindow.findChild("_bankaccount");
var _cashRegister	= mywindow.findChild("_cashRegister");
var _currentBalance	= mywindow.findChild("_currentBalance");
var _close		= mywindow.findChild("_close");
var _delete		= mywindow.findChild("_delete");
var _depositChecks 	= mywindow.findChild("_depositChecks");
var _edit		= mywindow.findChild("_edit");
var _maintainTab	= mywindow.findChild("_maintainTab");
var _new		= mywindow.findChild("_new");
var _newbalance	= mywindow.findChild("_newbalance");
var _notes		= mywindow.findChild("_notes");
var _opened		= mywindow.findChild("_opened");
var _post		= mywindow.findChild("_post");
var _print		= mywindow.findChild("_print");
var _printReceipt	= mywindow.findChild("_printReceipt");
var _sales		= mywindow.findChild("_sales");
var _search		= mywindow.findChild("_search");
var _site		= mywindow.findChild("_site");
var _siteLit	= mywindow.findChild("_siteLit");
var _tab		= mywindow.findChild("_tab");
var _terminal	= mywindow.findChild("_terminal");
var _transferAmt	= mywindow.findChild("_transferAmt");
var _transferDirection = mywindow.findChild("_transferDirection");
var _transferGroup	= mywindow.findChild("_transferGroup");
var _view		= mywindow.findChild("_view");

// Fill comboboxes
// When translation capability is available, tranlate second value, 
// but not third which is code.
_adjustDirection.append(0,"In","In");
_adjustDirection.append(1,"Out","Out");
_transferDirection.append(0,"In","In");
_transferDirection.append(1,"Out","Out");

// Set Columns
with (_sales)
{
  addColumn("Number" 		,100 , 1, true, "salehead_number");
  addColumn("Type"		,100 , 4, true, "type");
  addColumn("Cust#"           	,100 , 1, true, "cust_number");
  addColumn("Contact Name"    	,-1  , 1, true, "contact_name");
  addColumn("Time"		,100 , 1, true, "salehead_time");
}

// Terminal connections
_action["newID(int)"].connect(actionChanged);
_action["newID(int)"].connect(setDepositFlag);
_adjustAmt.valueChanged.connect(calcBalance);
_adjustDirection["newID(int)"].connect(calcBalance);
_adjustDirection["newID(int)"].connect(setDepositFlag);
_close.clicked.connect(mydialog, "accept");
_post.clicked.connect(post);
_print.clicked.connect(printSaleReceipt);
_search.clicked.connect(search);
_transferAmt.valueChanged.connect(calcBalance);
_transferDirection["newID(int)"].connect(calcBalance);
_transferDirection["newID(int)"].connect(setDepositFlag);

// Pending sales list connections
_new.clicked.connect(saleNew);
_edit.clicked.connect(saleEdit);
_view.clicked.connect(saleView);
_delete.clicked.connect(saleDelete);

// Check Metrics
if (metrics.value("MultiWhs") != "t")
{
  _site.hide();
  _siteLit.hide();
}

// Check Privileges
toolbox.tabSetTabEnabled(_tab, toolbox.tabTabIndex(_tab,_maintainTab)
 			,privileges.value("MaintainCashRegisters"))
if (privileges.value("MaintainRetailSales"))
{
  _active["toggled(bool)"].connect(_new["setEnabled(bool)"]);
  _sales["doubleClicked(QModelIndex)"].connect(_edit["animateClick()"]);
  _sales["valid(bool)"].connect(_edit["setEnabled(bool)"]);
  _sales["valid(bool)"].connect(_print["setEnabled(bool)"]);
  _sales["valid(bool)"].connect(_delete["setEnabled(bool)"]);
}
if (privileges.value("MaintainRetailSales") || privileges.value("ViewRetailSales"))
{

  _active["toggled(bool)"].connect(_sales["setEnabled(bool)"]);
  _active["toggled(bool)"].connect(_search["setEnabled(bool)"]);
  _sales["valid(bool)"].connect(_view["setEnabled(bool)"]);
  if (!privileges.value("MaintainRetailSales"))
    _sales["doubleClicked(QModelIndex)"].connect(_view["animateClick()"]);
}

// Initialize
calcBalance();

toolbox.executeDbQuery("retail", "setpath");

// Define local functions
function actionChanged()
{
  if (_action.code == "Open")
  {
    _adjustDirection.code = "In";
    _transferDirection.code = "In";
  }
  else
  {
    _adjustDirection.code = "Out";
    _transferDirection.code = "Out";
  }
}

function calcBalance()
{
  var transfer = _transferAmt.localValue;
  var adjust   = _adjustAmt.localValue;
 
  if (_transferDirection.code == "Out")
    transfer = transfer * -1;

  if (_adjustDirection.code == "Out")
    adjust = adjust * -1;
    
  _newbalance.localValue = 
    _currentBalance.localValue + transfer + adjust;
}

function populate()
{
  try
  {
    _cashRegister.select();
    populateAction();
    populateAccount();
    populateSales();
    _transferAmt.clear();
    _adjustAmt.clear();
    _notes.clear();
  }
  catch (e)
  {
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
}

function populateAccount()
{   
  var sql =  "SELECT bankaccnt_id,  bankaccnt_name, bankaccnt_name "
              + "FROM bankaccnt "
              + "  JOIN xtpos.rtlsitebnkacct ON (bankaccnt_id=rtlsitebnkacct_bankaccnt_id) "
              + "  JOIN xtpos.rtlsite ON (rtlsitebnkacct_rtlsite_id=rtlsite_id) "
              + "WHERE (rtlsite_warehous_id=" + _site.id() +"); "

  _bankaccount.populate(sql, -1);
}

function populateAction()
{
  _action.clear();

  if (_active.checked)
  {
    _action.append(0,"Close","Close");
    _action.append(1,"Adjust","Adjust");
  }
  else
  {
    _action.append(0,"Open","Open");
    _action.append(1,"Adjust","Adjust");
  }

  actionChanged();
}

function populateSales()
{
  var params = new Object();
  params.terminal = _terminal.text;
  params.open = true;
  params.Sale = "Sale";
  params.Quote = "Quote";
  params.Return = "Return";

  var data = toolbox.executeDbQuery("cashregister","sales", params);
  _sales.populate(data); 
}

function post()
{
  var params = new Object();

  try
  {
    if (_newbalance.localValue < 0)
      throw "The new balance must be positive.";

    params.action  		= _action.code;
    params.terminal		= _terminal.text;
    params.bankaccount		= _bankaccount.code;
    params.transfer_amount	= _transferAmt.localValue;
    params.transfer_direction	= _transferDirection.code;
    params.adjustment_amount	= _adjustAmt.localValue;
    params.adjustment_direction	= _adjustDirection.code;
    params.notes		= _notes.plainText;
    var data = toolbox.executeDbQuery("cashregister","post",params);
    if (data.first())
    {
      if (_printReceipt.checked)
        printReceipt(data.value("regdetail_id"));
    }
    else
      throw "Action was not successfully posted.  Check database log for details."
    populate();
  }
  catch(e)
  {
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
}

function printReceipt(detailId)
{
  params = new Object();
  params.regdetail_id  = detailId;
  params.mastercard 	= "Master Card";
  params.visa	= "Visa";
  params.amex	= "American Express";
  params.discover	= "Discover";
  toolbox.printReport("RetailRegisterReceipt",params);
}

function printSaleReceipt()
{
  params = new Object();
  params.sale_number = _sales.id();
  params.sale_receipt = "Sale Receipt";
  params.return_receipt = "Return Receipt";
  params.quote_receipt = "Quotation";
  params.sale_proposal = "Sale Proposal";
  params.return_proposal = "Return Proposal";
  toolbox.printReport("RetailSaleReceipt",params);
}

function saleDelete()
{
  params = new Object();
  params.sale_number = _sales.id();
  toolbox.executeDbQuery("cashregister","deletesale",params);
  populateSales();
}

function saleEdit()
{
  saleOpen(1,_sales.id());
}

function saleNew()
{
  saleOpen(0,0);
}

function saleOpen(mode, number)
{try{
  var childwnd = toolbox.openWindow("retailSale", mywindow, 0, 1);
  var params   = new Object;

  params.mode   = mode;
  params.site = _site.code;
  params.terminal = _terminal.text;
  if (mode) // Edit or View
    params.filter = "sale_number='" + number + "'";

  var tmp = toolbox.lastWindow().set(params);
  var execval = childwnd.exec();
  if (execval)
    populate();
}catch(e){print(e)};
}

function saleView()
{
  saleOpen(2,_sales.id());
}

function search()
{
  var childwnd = toolbox.openWindow("retailSaleSearch", mywindow, 0, 1);
  var execval = childwnd.exec();
  if (execval)
    saleOpen(_cashRegister.mode, execval);
}

function setDepositFlag()
{
  var state = (_action.code == "Adjust" && _transferDirection.code == "Out");

  _depositChecks.enabled = state;

  if (_action.code == "Close")
    _depositChecks.checked = true;
  if (_transferDirection.code == "In")
    _depositChecks.checked = false;
}

function set(input)
{
try {
  if ("mode" in input)
  {
    _cashRegister.setMode(input.mode);

    // Edit mode will enable these, but we don't ever want them enabled
    _site.enabled = false;
    _terminal.enabled = false;
    _active.enabled = false;
    _opened.enabled = false;

    if (input.mode == _viewMode)
    {
       _close.text = "Close";
       _sales.enabled 	= false;
       _new.hide();
       _edit.hide();
       _delete.hide();
       _post.hide();
       _action.enabled = false;
       _transferGroup.enabled = false;
       mywindow.findChild("_adjGroup").enabled = false;
    }
  }
  if ("filter" in input)
  {
    _cashRegister.setFilter(input.filter);
    populate();
  }

  return 0;
}
catch (e) {
  print("cashRegister::set() at " + e.lineNumber + ": " + e);
}
}
