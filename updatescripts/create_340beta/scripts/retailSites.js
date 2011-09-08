debugger
// Define Variables
var _close		= mywindow.findChild("_close");
var _delete		= mywindow.findChild("_delete");
var _edit		= mywindow.findChild("_edit");
var _new		= mywindow.findChild("_new");
var _print		= mywindow.findChild("_print");
var _sites		= mywindow.findChild("_sites");
var _view 		= mywindow.findChild("_view");

var _siteCol = 0;
var _sites = mywindow.findChild("_sites");
var _model = new XSqlTableModel();
var _currIdx = 0-0;

var cNew = 0 - 0;
var cEdit = 1 - 0;
var cView = 2 - 0;

// Set Columns
with (_sites)
{
  setColumn(qsTr("Site"), 60, 0, true, "site");
  setColumn(qsTr("Tax Zone"), -1, 0, true, "tax_zone");
  setColumn(qsTr("Quote Days"), 40, 0, true, "quote_days");
  setColumn(qsTr("Asset Acct."), 100, 0, true,"asset");
  setColumn(qsTr("Adjust Acct."), 100, 0, true, "adjustment");
  setColumn(qsTr("Clearing Acct."), 100, 0, true, "check_clearing");
}

// Retail Site list  connections
_close.clicked.connect(mywindow, "close");
_delete.clicked.connect(siteDelete);
_edit.clicked.connect(siteEdit);
_new.clicked.connect(siteNew);
_print.clicked.connect(sPrint);
_view.clicked.connect(siteView);
_sites["newModel(XSqlTableModel*)"].connect(setModel);
_sites["rowSelected(int)"].connect(setIndex);

// Populate the list
_sites.select();

// Define local functions
function siteDelete()
{
  try
  {
    var msg = qsTr("Are you sure you want to delete this retail site?")
    if (toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg, 
	QMessageBox.Yes | QMessageBox.Escape, 
	QMessageBox.No | QMessageBox.Default) == QMessageBox.Yes)
    {
      _sites.removeSelected();
      _sites.save();
    }
  }
  catch (e)
  {
    _sites.select();
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
}

function setIndex(idx)
{
  _currIdx = idx;
}

function setModel(model)
{
  _model = model;
}

function siteEdit()
{
  siteOpen(cEdit);
}

function siteNew()
{
  siteOpen(cNew);
}

function siteView()
{
  siteOpen(cView);
}

function siteOpen(mode)
{
  var childwnd = toolbox.openWindow("retailSite");
  var params   = new Object();

  params.mode   = mode;
  if (mode)
    params.index = _currIdx;

  childwnd.findChild("_retailSite").setModel(_model);
  childwnd.set(params);
}

function sPrint()
{
  toolbox.printReport("RetailSitesReport", new Object());
}