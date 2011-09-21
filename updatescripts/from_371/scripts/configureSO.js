/*
 * This file is part of the xtpos package for xTuple ERP: PostBooks Edition, a free and
 * open source Enterprise Resource Planning software suite,
 * Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including xTuple-specific Exhibits)
 * is available at www.xtuple.com/CPAL.  By using this software, you agree
 * to be bound by its terms.
*/

//  Insert Retail Tab
var _tab 	= mywindow.findChild("_tab");
var idx	= toolbox.tabCount(_tab) + 1;
var page	= toolbox.loadUi("configureRetail", mywindow);
toolbox.tabInsertTab(_tab,idx,page, "Retail");

//  Define variables
var _retailCust	= page.findChild("_retailCust");
var _retailCustGroup	= page.findChild("_retailCustGroup");
var _retailSaleNumber	= page.findChild("_retailSaleNumber");
var _retailOnlyDefaultCust = page.findChild("_retailOnlyDefaultCust");
var _custTax  	= page.findChild("_custTax");
var _siteTax	= page.findChild("_siteTax");

//  Define connections
_retailCustGroup["toggled(bool)"].connect(custGroupToggled);
_retailCust["valid(bool)"].connect(sHandleRetailOnlyDefaultCust);
mywindow.saving.connect(save);

//  Misc. Defaults
_retailSaleNumber.setValidator(toolbox.qtyVal());
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
    _retaiCustGroup.checked = false;

  params = new Object();
  params.sale_number = _retailSaleNumber.text;
  toolbox.executeDbQuery("configureretail","setsalenumber",params);
  metrics.set("RetailUseInternalCust",     _retailCustGroup.checked);
  metrics.set("RetailCustId",              _retailCust.id());
  metrics.set("RetailOnlyUseInternalCust", _retailOnlyDefaultCust.checked &&
                                           (_retailCust.id() > -1));
  metrics.set("RetailUseCustTaxZone",     _custTax.checked);
}
