/*
 * This file is part of the xtpos package for xTuple ERP: PostBooks Edition, a free and
 * open source Enterprise Resource Planning software suite,
 * Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including xTuple-specific Exhibits)
 * is available at www.xtuple.com/CPAL.  By using this software, you agree
 * to be bound by its terms.
*/

var modeVal;

var name;
var uiName;

if (metrics.value("MultiWhs") == "t")
{
  name = qsTr("Retail Sites");
  uiName = "retailSites";
}
else
{
  name = qsTr("Retail Site");
  uiName = "retailSite";
}

modeVal = mywindow.mode("MaintainRetailSites");
mywindow.insert( name, uiName, setup.AccountMapping, Xt.SalesModule, modeVal, modeVal, "save");

