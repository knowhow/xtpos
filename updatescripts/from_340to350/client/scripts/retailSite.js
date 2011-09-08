debugger
// Variables
var _adjust		= mywindow.findChild("_adjust");
var _asset		= mywindow.findChild("_asset");
var _bnkacct	= mywindow.findChild("_bnkacct");
var _bnkacctGroup	= mywindow.findChild("_bnkacctGroup");
var _bnkacctName	= mywindow.findChild("_bnkacctName");
var _bnkaccts	= mywindow.findChild("_bnkaccts");
var _cancel		= mywindow.findChild("_cancel");
var _checkClearing	= mywindow.findChild("_checkClearing");
var _expire		= mywindow.findChild("_expire");
var _insertBankAcct	= mywindow.findChild("_insertBankAcct");
var _removeBankAcct	= mywindow.findChild("_removeBankAcct");
var _insertTerminal	= mywindow.findChild("_insertTerminal");
var _removeTerminal	= mywindow.findChild("_removeTerminal");
var _retailSite	= mywindow.findChild("_retailSite");
var _save		= mywindow.findChild("_save");
var _site 		= mywindow.findChild("_site");
var _siteLit	= mywindow.findChild("_siteLit");
var _terminals	= mywindow.findChild("_terminals");

// Retail Site Connections
_cancel.clicked.connect(cancel);
_removeBankAcct.clicked.connect(removeBankAcct);
_save.clicked.connect(save);
_site["newID(int)"].connect(check);

// Set schema search path
toolbox.executeDbQuery("retail", "setpath");

// Hide site and populate if not multi warehouse
if (metrics.value("MultiWhs") != "t")
{
  _site.setVisible(false);
  _siteLit.setVisible(false);
  _site.allowNull = false;
  populate();
}

// Define local functions
function cancel()
{
  _retailSite.select();
  mywindow.close();
}

function check()
{
  if (_retailSite.mode) // Not New
    return;

  _site.updateMapperData(); // Issue 9563 - can remove after 3.3.1
  params = new Object();
  params.site = _site.code;

  var data = toolbox.executeDbQuery("retailsite","getapi_retailsite",params);
  if (data.first())
  {
    _retailSite.mode = 1;
    _retailSite.filter = "site = '" + _site.code + "'";
    populate();
  }
  else
    populateItems();
}

function checkBankAccts()
{
  var params = new Object();

  for (row = 0 - 0; row < _bnkaccts.rowCount(); row++)
  {
    if (!_bnkaccts.isRowHidden(row))
    {
      params.name = _bnkaccts.value(row,1);
      var data = toolbox.executeDbQuery("retailsite","getbankaccnt",params);
      if (!data.first())
      { 
        var msg = qsTr("Bank Account ") + params.name + qsTr(" is invalid.");
        throw msg;
      }
    }
  }
}

function checkTerminals()
{
  var params = new Object();
  params.site = _site.code;

  for (row = 0 - 0; row < _terminals.rowCount(); row++)
  {
    if (!_terminals.isRowHidden(row))
    {
      params.terminal = _terminals.value(row,1);
      var data = toolbox.executeDbQuery("retailsite","getapi_retailsiteterminal",params);
      if (data.first())
      { 
        var msg = qsTr("Terminal ") + params.terminal + qsTr(" already exists on site ")
                + data.value("site") + "."
        throw msg;
      }
    }
  }
}

function populate()
{
  _retailSite.select();
  if (_retailSite.currentIndex() < 0)
    _retailSite.mode = 0; // New
  populateItems();
  _site.enabled = false;
}

function populateItems()
{
  var idx = _retailSite.currentIndex();

  _bnkaccts.populate(idx);
  _terminals.populate(idx);
}

function removeBankAcct()
{
  _bnkacctGroup.enabled = false;
  _bnkacctName.setId(-1);
  // The rest is handled by slot connections on the UI
}

function save()
{
  var params = new Object;
  _expire.setFocus();

  try
  {
    _site["newID(int)"].disconnect(check);
    toolbox.executeBegin();

    if (_site.id() == -1)
      throw  qsTr("You must select a site.");

    if (!_asset.isValid())
      throw  qsTr("You must select a valid Asset account.");

    if (!_adjust.isValid()) 
      throw  qsTr("You must select a valid Adjustment account.");

    if (!_checkClearing.isValid())
      throw qsTr("You must select a valid Check Clearing account.");

    if(!_bnkaccts.rowCountVisible())
      throw qsTr("You must add at least one bank account.");

    if(!_terminals.rowCountVisible())
      throw qsTr("You must add at least one terminal.");

    checkBankAccts();
    checkTerminals();

    var model = new XSqlTableModel();
    model = _retailSite.model();
    _retailSite.submit();
    _bnkaccts.save();
    _terminals.save();
    toolbox.executeCommit();
    mywindow.close();
  }
  catch (e)
  {
    _site["newID(int)"].connect(check);
    toolbox.executeRollback();
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
}

function set(input)
{
  if ("mode" in input)
  { 
    _retailSite.setMode(input.mode);

    if (input.mode > 0) // Edit or View
      _site.enabled=false;
    if (input.mode == 2) // View
    {
      _save.hide();
      _cancel.text = "Close";
      _bnkaccts.setEnabled(0);
      _insertBankAcct.hide();
      _removeBankAcct.hide();
      _terminals.setEnabled(0);
      _insertTerminal.hide();
      _removeTerminal.hide();
      _bnkacctGroup.hide();
    }
  }
  if ("index" in input)
  {
    _retailSite.setCurrentIndex(input.index);
    _bnkaccts.populate(input.index);
    _terminals.populate(input.index);
  }

  return 0;
}