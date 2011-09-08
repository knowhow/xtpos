debugger
// Define Variables
var _viewMode     	= 2;
var _saleCurrIdx = 0-0; //TO DO: Get rid of me in 3.3.1

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
var _sale		= mywindow.findChild("_sale"); //TO DO: Get rid of me in 3.3.1
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
var _selectedSale       = mywindow.findChild("_selectedSale");
var _number             = mywindow.findChild("_number");
var _options           = mywindow.findChild("_options");

_selectedSale.visible = false;

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
  setColumn(qsTr("Number"), 80, 0, true, "sale_number");
  setColumn(qsTr("Type"), 80, 0, true, "type");
  setColumn(qsTr("Closed"), 60, 0, false, "closed");
  setColumn(qsTr("Cust#"), -1, 0, true, "customer_number");
  setColumn(qsTr("Contact#"), 60, 0, false, "contact_number");
  setColumn(qsTr("Hnfc."), 60, 0, false, "honorific");
  setColumn(qsTr("First"), 60, 0, true, "first");
  setColumn(qsTr("Middle"), 60, 0, false, "middle");
  setColumn(qsTr("Last"), 100, 0, true, "last");
  setColumn(qsTr("Suffix"), 60, 0, false, "suffix");
  setColumn(qsTr("Title"), 60, 0, false, "job_title");
  setColumn(qsTr("Voice"), 60, 0, false, "voice");
  setColumn(qsTr("Alternate"), 60, 0, false, "alternate");
  setColumn(qsTr("Fax"), 60, 0, false, "fax");
  setColumn(qsTr("Email"), 60, 0, false, "email");
  setColumn(qsTr("Web"), 60, 0, false, "web");
  setColumn(qsTr("Cont. Change"), 60, 0, false, "contact_change");
  setColumn(qsTr("Address#"), 60, 0, false, "address_number");
  setColumn(qsTr("Address1"), 60, 0, false, "address1");
  setColumn(qsTr("Address2"), 60, 0, false, "address2");
  setColumn(qsTr("Address3"), 60, 0, false, "address3");
  setColumn(qsTr("City"), 60, 0, false, "city");
  setColumn(qsTr("State"), 60, 0, false, "state");
  setColumn(qsTr("Postal"), 60, 0, false, "postalcode");
  setColumn(qsTr("Country"), 60, 0, false, "country");
  setColumn(qsTr("Addr. Change"), 60, 0, false, "address_change");
  setColumn(qsTr("Date"), 60, 0, true, "date");
  setColumn(qsTr("Sales Rep."), 60, 0, false, "sales_rep");
  setColumn(qsTr("Notes"), 60, 0, false, "notes");
  setColumn(qsTr("Site"), 60, 0, false, "site");
  setColumn(qsTr("Terminal"), 60, 0, false, "terminal");
  setColumn(qsTr("Tax Zone"), 60, 0, false, "tax_zone");
  setColumn(qsTr("Subtotal"), 60, 0, false, "subtotal");
  setColumn(qsTr("Tax"), 60, 0, false, "tax");
  setColumn(qsTr("Total"), 60, 0, false, "total");
}

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

function handleTab(index)
{
  if (index = 1)
  {
     var scrIdx = _cashRegister.currentIndex();
     _cashRegister.select();
     _cashRegister.setCurrentIndex(scrIdx);
  }
}

function refresh()
{
  var idx = _cashRegister.currentIndex();
  _cashRegister.select();
  _cashRegister.setCurrentIndex(idx);
  populate();
}

function options()
{
  var params = new Object;
  params.parentName = "cashRegister";

  var newdlg = toolbox.openWindow("printOptions");
  newdlg.set(params);
  newdlg.exec();
  printSettings();
}

function populate()
{
  try
  {
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
  // Sales screen only exists because no available setFilter property on 3.3.0 xtreeview
  // Eliminate and set filter on _sale in 3.3.1
  _sale.setFilter("closed=false AND terminal='" + _terminal.text + "'");
  _sale.select();
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
    refresh();
  }
  catch(e)
  {
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
}

function printReceipt(detailId)
{
  var printer = new QPrinter(QPrinter.HighResolution);
  var presetPrinter = settingsValue("cashRegister.defaultPrinter");
  var userCanceled = false;

  if (presetPrinter.length)
  { 
    printer.setPrinterName(presetPrinter);
    orReport.beginMultiPrint(printer);
  }
  else if (orReport.beginMultiPrint(printer, userCanceled) == false)
  {
    if (!userCanceled)
      QMessageBox.critical(mywindow, qsTr("Database Error"),
                           qsTr("Could not initialize printing system for "
                              + "multiple reports."));
    return;
  }

  var params = new Object();
  params.regdetail_id  = detailId;
  params.mastercard 	= "Master Card";
  params.visa	= "Visa";
  params.amex	= "American Express";
  params.discover	= "Discover";

  var report = new orReport("RetailRegisterReceipt", params);
  if (! report.isValid() || ! report.print(printer, true))
    report.reportError(mywindow);

  orReport.endMultiPrint(printer);
}

function printSettings()
{
  var autoPrint = settingsValue("cashRegister.autoPrint");
  if (autoPrint == "true")
  {
    _printReceipt.forgetful = true;
    _printReceipt.enabled = false;
    _printReceipt.checked = true;
  }
  else
  {
    _printReceipt.forgetful = false;
    _printReceipt.enabled = true;
  }
}

function printSaleReceipt()
{
  params = new Object();
  params.sale_number = _number.text;
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
  params.sale_number = _number.text;
  toolbox.executeDbQuery("cashregister","deletesale",params);
  populateSales();
}

function saleEdit()
{
  saleOpen(1,_number.text);
}

function saleNew()
{
  saleOpen(0,0);
}

function saleOpen(mode, number)
{
  var childwnd = toolbox.openWindow("retailSale", mywindow, Qt.ApplicationModal, Qt.Dialog);
  var params   = new Object();
  params.site = _site.code;
  params.terminal = _terminal.text;

  params.mode = mode;
  if (mode)
    params.index = _saleCurrIdx;

  childwnd.findChild("_sale").setModel(_sale.model());
  childwnd.set(params);
  return childwnd;
}

function saleView()
{
  saleOpen(2,_number.text);
}

function search()
{
  var childwnd = toolbox.openWindow("retailSaleSearch", mywindow, Qt.ApplicationModal);
  var execval = childwnd.exec();
  if (execval)
  {
    var childwnd = toolbox.openWindow("retailSale", mywindow, Qt.ApplicationModal);
    var params   = new Object;

    params.mode   = _viewMode;
    params.filter = "sale_number='" + execval + "'";

    childwnd.set(params);
  }
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
  if ("index" in input)
    _cashRegister.setCurrentIndex(input.index);

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

    populate();
  }

  return 0;
}

function setIndex(idx)
{
  _saleCurrIdx = idx;
  _selectedSale.setCurrentIndex(idx);
}

// Terminal connections
_action["newID(int)"].connect(actionChanged);
_action["newID(int)"].connect(setDepositFlag);
_adjustAmt.valueChanged.connect(calcBalance);
_adjustDirection["newID(int)"].connect(calcBalance);
_adjustDirection["newID(int)"].connect(setDepositFlag);
_close.clicked.connect(mywindow, "close");
_post.clicked.connect(post);
_print.clicked.connect(printSaleReceipt);
_search.clicked.connect(search);
_transferAmt.valueChanged.connect(calcBalance);
_transferDirection["newID(int)"].connect(calcBalance);
_transferDirection["newID(int)"].connect(setDepositFlag);
_options.clicked.connect(options);

// Pending sales list connections
_new.clicked.connect(saleNew);
_edit.clicked.connect(saleEdit);
_view.clicked.connect(saleView);
_delete.clicked.connect(saleDelete);
_sales["rowSelected(int)"].connect(setIndex);
_tab["currentChanged(int)"].connect(handleTab);

printSettings();
