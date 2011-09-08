//  Insert Retail Tab
var _tab 	= mywindow.findChild("_tab");
var idx	= toolbox.tabCount(_tab) + 1;
var page	= toolbox.loadUi("configureRetail", mywindow); 
toolbox.tabInsertTab(_tab,idx,page, "Retail");

//  Define variables
var _save 		= mywindow.findChild("_save");
var _retailCust	= page.findChild("_retailCust");
var _retailCustGroup	= page.findChild("_retailCustGroup");
var _retailSaleNumber	= page.findChild("_retailSaleNumber");
var _retailOnlyDefaultCust = page.findChild("_retailOnlyDefaultCust");
var _custTax  	= page.findChild("_custTax");
var _siteTax	= page.findChild("_siteTax");

//  Define connections
toolbox.coreDisconnect(_save, "clicked()", mywindow, "sSave()");
_retailCustGroup["toggled(bool)"].connect(custGroupToggled);
_retailCust["valid(bool)"].connect(sHandleRetailOnlyDefaultCust);
_save.clicked.connect(save);

//  Misc. Defaults
_retailSaleNumber.setValidator(toolbox.qtyVal());
toolbox.executeDbQuery("retail", "setpath");
populate();

function custGroupToggled(checked)
{
  if (!checked)
    _retailCust.setId(-1);
  sHandleRetailOnlyDefaultCust();
}

function sHandleRetailOnlyDefaultCust()
{
  _retailOnlyDefaultCust.enabled = (_retailCustGroup.checked &&
                                    _retailCust.id() > -1);
  if (! _retailCustGroup.checked || _retailCust.id() <= -1)
    _retailOnlyDefaultCust.checked = false;
}

function populate()
{
  // Sale Number
  var data = toolbox.executeDbQuery("configureretail","nextsalenumber");
  if (data.first())
    _retailSaleNumber.text = data.value("sale_number");

  // Customer Group
  if (metrics.value("RetailUseInternalCust") == "t")
    _retailCustGroup.checked = true;
  _retailCust.setId(metrics.value("RetailCustId"));

  _retailOnlyDefaultCust.checked = (metrics.value("RetailOnlyUseInternalCust") == "t");
  
  _custTax.checked = (metrics.value("RetailUseCustTaxZone") == "t");
}

function save()
{
  if (_retailCustGroup.checked && _retailCust.id() == -1)
  {
    _retailCust.setFocus();
    msg = "You must select a customer."
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg);
    return;
  }
    
  params = new Object();
  params.sale_number = _retailSaleNumber.text;
  toolbox.executeDbQuery("configureretail","setsalenumber",params);
  metrics.set("RetailUseInternalCust",     _retailCustGroup.checked);
  metrics.set("RetailCustId",              _retailCust.id());
  metrics.set("RetailOnlyUseInternalCust", _retailOnlyDefaultCust.checked &&
                                           (_retailCust.id() > -1));
  metrics.set("RetailUseCustTaxZone",     _custTax.checked);
  mywindow.sSave();
}