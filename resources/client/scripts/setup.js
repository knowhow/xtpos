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

