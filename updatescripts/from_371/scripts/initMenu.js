/*
 * This file is part of the xtpos package for xTuple ERP: PostBooks Edition, a free and
 * open source Enterprise Resource Planning software suite,
 * Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including xTuple-specific Exhibits)
 * is available at www.xtuple.com/CPAL.  By using this software, you agree
 * to be bound by its terms.
*/

// change the search_path to ensure existing client code works with tables in xtpos schema
var qry = toolbox.executeQuery("SHOW search_path;", new Object);
if (! qry.first())
  toolbox.messageBox("critical", mainwindow, qsTr("Initialize xtpos failed"),
                     qsTr("Failed to initialize the xtpos package. "
                        + "This functionality may not work correctly. ")
                        .arg(qry.lastError().databaseText));
else
{
  // If the search path is empty set the base value to public
  var search_path = qry.value("search_path");
  if(search_path == "")
  {
    search_path = "public";
  }

  // Prepend xtpos to the existing search path.
  qry = toolbox.executeQuery("SET search_path TO " + search_path + ", xtpos;", new Object);
  if(!qry.isActive())
  {
    toolbox.messageBox("critical", mainwindow, qsTr("Initialize xtpos failed"),
                       qsTr("Failed to initialize the xtpos package. This "
                          + "functionality may not work correctly. %1")
                          .arg(qry.lastError().databaseText));
  }
}

// Sale menu references
var saleMenu    = mainwindow.findChild("menu.sales");
var lookupMenu  = mainwindow.findChild("menu.sales.lookup");

// Retail menu
var retailMenu  = toolbox.menuInsertMenu(saleMenu, lookupMenu, "Retail");

// Separator
toolbox.menuInsertSeparator(saleMenu, lookupMenu);

// Cash Register action
var cshRegAction        = toolbox.menuAddAction(retailMenu, "Cash Registers...",
                        (privileges.value("MaintainCashRegisters") ||
                         privileges.value("MaintainRetailSales") ||
                         privileges.value("ViewRetailSales")));

// Separator
toolbox.menuAddSeparator(retailMenu);

// Retail Sale Search action
var rtlSaleSearchAction= toolbox.menuAddAction(retailMenu, "Retail Sale Search...",
                        (privileges.value("MaintainRetailSales") ||
                         privileges.value("ViewRetailSales")));

// Report
var reportMenu  = mainwindow.findChild("menu.sales.reports");
var earnedCommAction    = mainwindow.findChild("so.dspEarnedCommissions");
var regHistAction       = toolbox.menuInsertAction(reportMenu, earnedCommAction,
                        "Register History", privileges.value("MaintainCashRegisters"));
var detailedRegHistAction = toolbox.menuInsertAction(reportMenu, earnedCommAction,
                        "Detailed Register History", privileges.value("ViewRetailSales"));

// Connect new menus to existing custom command actions
var cshRegTrig  = mainwindow.findChild("custom.cashRegisters");
cshRegAction.triggered.connect(cshRegTrig, "trigger");

var rtlSaleSearchTrig   = mainwindow.findChild("custom.retailSaleSearch");
rtlSaleSearchAction.triggered.connect(rtlSaleSearchTrig, "trigger");

var regHistTrig = mainwindow.findChild("custom.dspRegisterHistory");
regHistAction.triggered.connect(regHistTrig, "trigger");

var detailedRegHistTrig = mainwindow.findChild("custom.dspDetailedRegisterHistory");
detailedRegHistAction.triggered.connect(detailedRegHistTrig, "trigger");

// Remove custom command actions
var customSalesMenu     = mainwindow.findChild("menu.sales.custom");
toolbox.menuRemove(customSalesMenu,cshRegTrig);
toolbox.menuRemove(customSalesMenu,rtlSaleSearchTrig);
toolbox.menuRemove(customSalesMenu,regHistTrig);
toolbox.menuRemove(customSalesMenu,detailedRegHistTrig);

// Remove custom menu if no custom commands left
if (!toolbox.menuActionCount(customSalesMenu))
  toolbox.menuRemove(saleMenu,customSalesMenu);
