var _allTerminals     = mywindow.findChild("_allTerminals");
var _close            = mywindow.findChild("_close");
var _dates            = mywindow.findChild("_dates");
var _print            = mywindow.findChild("_print");
var _query            = mywindow.findChild("_query");
var _results          = mywindow.findChild("_results");
var _site             = mywindow.findChild("_site");
var _specificTerminal = mywindow.findChild("_specificTerminal");
var _terminal         = mywindow.findChild("_terminal");

_results.addColumn("Trans. Type",     -1, 1, true, "type");
_results.addColumn("Transaction",     -1, 1, true, "transaction");
_results.addColumn("Time",            -1, 1, true, "timestamp");
_results.addColumn("Site",            -1, 1, true, "warehous_code");
_results.addColumn("Terminal",        -1, 1, true, "terminal_number");
_results.addColumn("User/Rep/Item",   -1, 1, true, "usrrepitem");
_results.addColumn("Cust./Descrip",   -1, 1, true, "descrip");
_results.addColumn("Tendered/Line Total", -1, 2, true, "tendered");
_results.addColumn("Check/Unit Price",-1, 2, true, "checkunit");
_results.addColumn("Credit Card/Qty", -1, 2, true, "qtyNcard");
_results.addColumn("Tax on Line",     -1, 2, true, "linetax");
_results.addColumn("Cash",            -1, 2, true, "regdetail_cashslsamt");
_results.addColumn("Transfer",        -1, 2, true, "regdetail_transferamt");
_results.addColumn("Adjustment",      -1, 2, true, "regdetail_adjustamt");

_dates.startDate = new Date(); // TODO: setStartNull("Today", new Date(), true);
_dates.endDate   = new Date(); // TODO: setEndNull("Today", new Date(), true);

_allTerminals.clicked.connect(sHandleButtons);
_close.clicked.connect(mywindow, "close");
_print.clicked.connect(sPrint);
_query.clicked.connect(sQuery);
_site.updated.connect(sPopulateTerminal);
_specificTerminal.clicked.connect(sHandleButtons);
_terminal["newID(int)"].connect(sHandleButtons);

sPopulateTerminal();

function getParams()
{
  var params = new Object();

  if (_specificTerminal.checked)
    params.terminal_id = _terminal.id();

  if (_site.isSelected())
    params.site_id = _site.id();

  params.startDate = _dates.startDate;
  params.endDate   = _dates.endDate;

  // translate these:
  params.adjust    = "Adjust";
  params.close     = "Close";
  params.linecount = "# of Lines";
  params.open      = "Open";
  params.ordertotal= "Order Total";
  params.register  = "Register"; // register open/close/adjust
  params.sale      = "Sale";
  params.saleitem  = "Line Item";
  params.mastercard= "MasterCard";
  params.visa      = "Visa";
  params.amex      = "American Express";
  params.discover  = "Discover";
  params.othercc   = "Other";
  return params;
}

function sHandleButtons()
{
  _print.enabled = (_allTerminals.checked || _terminal.id() > -1);
  _query.enabled = (_allTerminals.checked || _terminal.id() > -1);
}

function sPopulateTerminal()
{
  // TODO: use metasql here but xcombobox.populate() doesn't do metasql
  var queryStr = "SELECT terminal_id, terminal_number, terminal_number "
               + "FROM xtpos.terminal "
               + (_site.isSelected() ? (" JOIN xtpos.rtlsiteterm ON "
                                      + "    (terminal_id=rtlsiteterm_terminal_id) "
                                      + " JOIN xtpos.rtlsite ON "
                                      + "    (rtlsiteterm_rtlsite_id=rtlsite_id) "
                                      + "WHERE (rtlsite_warehous_id=" + _site.id() + ")")
                                     : "" )
              + " ORDER BY terminal_number;";
  _terminal.populate(queryStr);
}

function sPrint()
{
  toolbox.printReport("DetailedRegisterHistory", getParams());
}

function sQuery()
{
  var q = toolbox.executeDbQuery("display", "detailedRegisterHistory",
                               getParams());
  _results.populate(q, true);
}
