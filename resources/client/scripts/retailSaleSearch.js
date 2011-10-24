/*
 * This file is part of the xtpos package for xTuple ERP: PostBooks Edition, a free and
 * open source Enterprise Resource Planning software suite,
 * Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including xTuple-specific Exhibits)
 * is available at www.xtuple.com/CPAL.  By using this software, you agree
 * to be bound by its terms.
*/

// Define variables
var _close              = mywindow.findChild("_close");
var _dates              = mywindow.findChild("_dates");
var _print              = mywindow.findChild("_print");
var _query              = mywindow.findChild("_query");
var _sale               = mywindow.findChild("_sale");
var _sales              = mywindow.findChild("_sales");
var _search             = mywindow.findChild("_search");
var _select     = mywindow.findChild("_select");
var _showQuotes = mywindow.findChild("_showQuotes");
var _showReturns        = mywindow.findChild("_showReturns");
var _showSales  = mywindow.findChild("_showSales");
var _view               = mywindow.findChild("_view");

// Define Columns
with (_sales)
{
  addColumn("Number"            ,80  , 1, true, "salehead_number");
  addColumn("Type"              ,80  , 4, true, "type");
  addColumn("Closed"            ,50  , 1, true, "salehead_closed");
  addColumn("Cust#"             ,80  , 1, true, "cust_number");
  addColumn("Contact Name"      ,-1  , 1, true, "contact_name");
  addColumn("Phone"     ,100 , 1, true, "cntct_phone");
  addColumn("Time"              ,100 , 1, true, "salehead_time");
}

// Define connections
_close.clicked.connect(close);
_print.clicked.connect(printReceipt);
_query.clicked.connect(fillList);
_sales["itemSelected(int)"].connect(itemSelected);
_select.clicked.connect(select);
_view.clicked.connect(viewSale);

if (mywindow.windowModality)
{
  _view.hide();
  _close.text = "Cancel";
}
else
  _select.hide();


var data = toolbox.executeDbQuery("salesearch","defaultdates");
if (data.first())
{
  _dates.startDate = data.value("start_date");
  _dates.endDate = data.value("end_date");
}

_search.setFocus();

// Define functions
function close()
{
  if (mywindow.windowModality)
    mydialog.reject();
  else
    mywindow.close();
}

function fillList()
{
  if (_dates.startDate == "" || _dates.endDate == "")
  {
    var msg = "You must enter a start and end date."
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg);
    return;
  }

  var params = new Object();
  params.start_date     = _dates.startDate;
  params.end_date       = _dates.endDate;
  params.search = _search.text;
  if (!_showSales.checked)
    params.noSales      = true;
  if (!_showQuotes.checked)
     params.noQuotes    = true;
  if (!_showReturns.checked)
     params.noReturns   = true;
  params.Sale = "Sale";
  params.Quote = "Quote";
  params.Return = "Return";

  var data = toolbox.executeDbQuery("cashregister","sales",params);
  _sales.populate(data);
}

function itemSelected()
{
  if (mywindow.windowModality)
    _select.click();
  else
    _view.click();
}

function printReceipt()
{
  params = new Object();
  params.sale_number = _sales.id();
  params.sale_receipt = "Racun";
  params.return_receipt = "Reklamirani racun";
  params.quote_receipt = "Quote receipt";
  params.sale_proposal = "Ponuda";
  params.return_proposal = "Reklamirana ponuda";
  toolbox.printReport("RetailSaleReceipt",params);
}

function select()
{
  mydialog.done(_sales.id())
}

function set(input)
{
  if ("noQuotes" in input)
  {
    _showQuotes.checked = false;
    _showQuotes.enabled = false;
  }

  if ("noReturns" in input)
  {
    _showReturns.checked = false;
    _showReturns.enabled = false;
  }
}

function viewSale()
{
  var childwnd = toolbox.openWindow("retailSale");
  var params   = new Object;

  params.mode   = 2;
  params.filter = "sale_number='" + _sales.id() + "'";

  childwnd.set(params);
}



