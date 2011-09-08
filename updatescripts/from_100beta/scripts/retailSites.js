// Define Variables
var _siteCol = 0;
var _sites = mywindow.findChild("_sites");

// Retail Site list  connections
mywindow.findChild("_close").clicked.connect(mywindow, "close");
mywindow.findChild("_delete").clicked.connect(siteDelete);
mywindow.findChild("_edit").clicked.connect(siteEdit);
mywindow.findChild("_new").clicked.connect(siteNew);
mywindow.findChild("_print").clicked.connect(sPrint);
mywindow.findChild("_view").clicked.connect(siteView);

// Populate the list
_sites.select();

// Define local functions
function siteDelete()
{
  var msgBox     = new Object();
  msgBox.Yes     = 0x00004000;
  msgBox.No      = 0x00010000;
  msgBox.Default = 0x00000100;
  msgBox.Escape  = 0x00000200;

  try
  {
    var msg = "Are you sure you want to delete this retail site?"
    if (toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg, 
          msgBox.Yes | msgBox.Escape, msgBox.No | msgBox.Default) == msgBox.Yes)
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

function siteEdit()
{
  siteOpen(1);
}

function siteNew()
{
  siteOpen(0);
}

function siteView()
{
  siteOpen(2);
}

function siteOpen(mode)
{
  var childwnd = toolbox.openWindow("retailSite", mywindow, 0, 1);
  var params   = new Object();

  params.mode   = mode;
  if (mode)
    params.filter = "site='" + _sites.selectedValue(0) + "'";

  var tmp = toolbox.lastWindow().set(params);
  var execval = childwnd.exec(); 

  if (execval)
    _sites.select();
}

function sPrint()
{
  toolbox.printReport("RetailSitesReport", new Object());
}