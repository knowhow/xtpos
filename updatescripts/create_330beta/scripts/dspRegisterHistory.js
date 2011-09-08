// Define Variables
var _close 		= mywindow.findChild("_close");
var _dates 		= mywindow.findChild("_dates");
var _detail		= mywindow.findChild("_detail");
var _printList	= mywindow.findChild("_printList");
var _printReceipt	= mywindow.findChild("_printReceipt");
var _query 		= mywindow.findChild("_query");
var _sites 		= mywindow.findChild("_sites");

// Define list columns
with (_detail)
{
  addColumn("Site" 		,75,  1, true, "warehous_code");
  addColumn("Terminal"		,60,  1, true, "terminal_number");
  addColumn("Type"		,60,  1, true, "f_type");
  addColumn("Time"		,-1,  1, true, "regdetail_time");
  addColumn("Start Balance"	,100, 3, true, "regdetail_startbal");
  addColumn("Cash Sales"	,100, 3, true, "regdetail_cashslsamt");
  addColumn("Transfer"		,100, 3, true, "regdetail_transferamt");
  addColumn("Bank Account"	,100, 1, false,"bankaccnt_name");
  addColumn("Adjustment"	,80 , 3, true, "regdetail_adjustamt");
  addColumn("End Balance"	,80 , 3, true, "regdetail_endbal");
  addColumn("Deposit Checks"	,50 , 1, false,"regdetail_depchks");
  addColumn("Notes"		,100, 1, false,"regdetail_notes");
  addColumn("Username"		,75,  1, true ,"regdetail_username");
  addColumn("Journal #"	,80 , 1, true ,"f_journalnumber");	
}

// Define Connections
_printList.clicked.connect(printList);
_printReceipt.clicked.connect(printReceipt);
_query.clicked.connect(fillList);
_close.clicked.connect(mywindow, "close");

function fillList()
{
  var params = new Object();
  if (!setParams(params))
    return;
  
  var data = toolbox.executeDbQuery("registerhistory","detail",params);
  _detail.populate(data);
}

function printList()
{
  var params = new Object();
  if (!setParams(params))
    return;

  toolbox.printReport("RetailRegisterHistory",params);
}

function printReceipt()
{
print(_detail.id());
  var params = new Object();
  params.regdetail_id  = _detail.id();
  params.mastercard 	= "Master Card";
  params.visa	= "Visa";
  params.amex	= "American Express";
  params.discover	= "Discover";

  toolbox.printReport("RetailRegisterReceipt",params);
}

function setParams(params)
{
  if (_dates.startDate == "" || _dates.endDate == "")
  {
    var msg = "You must specify a valid date range."
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg);
    return false;
  }

  if (_sites.isSelected())
    params.warehous_id = _sites.id();

  params.start_date 	= _dates.startDate;
  params.end_date   	= _dates.endDate;

  return true;
}