// Sale menu references
var saleMenu 	= mainwindow.findChild("menu.sales");
var lookupMenu	= mainwindow.findChild("menu.sales.lookup");

// Retail menu
var retailMenu 	= toolbox.menuInsertMenu(saleMenu, lookupMenu, "Retail"); 

// Separator
toolbox.menuInsertSeparator(saleMenu, lookupMenu);

// Cash Register action
var cshRegAction	= toolbox.menuAddAction(retailMenu, "Cash Registers...", 
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
var reportMenu 	= mainwindow.findChild("menu.sales.reports");
var earnedCommAction 	= mainwindow.findChild("so.dspEarnedCommissions");
var regHistAction	= toolbox.menuInsertAction(reportMenu, earnedCommAction,
			"Register History", privileges.value("MaintainCashRegisters"));
var detailedRegHistAction = toolbox.menuInsertAction(reportMenu, earnedCommAction,
                        "Detailed Register History", privileges.value("ViewRetailSales"));

toolbox.menuInsertSeparator(reportMenu, earnedCommAction);

// Master Information menu references
var masterInfoMenu 	= mainwindow.findChild("menu.sales.masterinfo");
var termsAction 	= mainwindow.findChild("so.terms");

// Retail Sites action
var name;
if (metrics.value("MultiWhs") == "t")
  name = "Retail Sites...";
else
  name = "Retail Site...";
var rtlSiteAction 	= toolbox.menuInsertAction(masterInfoMenu, termsAction, name,
			privileges.value("MaintainRetailSites"));

// Separator
toolbox.menuInsertSeparator(masterInfoMenu, termsAction);

// Connect new menus to existing custom command actions
var cshRegTrig	= mainwindow.findChild("custom.cashRegisters");
cshRegAction.triggered.connect(cshRegTrig, "trigger");

var rtlSaleSearchTrig	= mainwindow.findChild("custom.retailSaleSearch");
rtlSaleSearchAction.triggered.connect(rtlSaleSearchTrig, "trigger");

var regHistTrig	= mainwindow.findChild("custom.dspRegisterHistory");
regHistAction.triggered.connect(regHistTrig, "trigger");

var detailedRegHistTrig	= mainwindow.findChild("custom.dspDetailedRegisterHistory");
detailedRegHistAction.triggered.connect(detailedRegHistTrig, "trigger");

var rtlSiteTrig 	= mainwindow.findChild("custom.retailSite");
var rtlSitesTrig 	= mainwindow.findChild("custom.retailSites");

if (metrics.value("MultiWhs") == "t")
  rtlSiteAction.triggered.connect(rtlSitesTrig, "trigger");
else
  rtlSiteAction.triggered.connect(rtlSiteTrig, "trigger");


// Remove custom command actions
var customSalesMenu	= mainwindow.findChild("menu.sales.custom");
toolbox.menuRemove(customSalesMenu,cshRegTrig);
toolbox.menuRemove(customSalesMenu,rtlSaleSearchTrig);
toolbox.menuRemove(customSalesMenu,regHistTrig);
toolbox.menuRemove(customSalesMenu,detailedRegHistTrig);
toolbox.menuRemove(customSalesMenu,rtlSitesTrig);
toolbox.menuRemove(customSalesMenu,rtlSiteTrig);

// Remove custom menu if no custom commands left
if (!toolbox.menuActionCount(customSalesMenu))
  toolbox.menuRemove(saleMenu,customSalesMenu);
