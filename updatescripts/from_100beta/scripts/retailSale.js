// Define local variables
var _linenumCol = 1;
var _itemCol    = 2;
var _upcCol     = 3;
var _descripCol = 4;
var _qtyCol     = 5;
var _priceCol   = 6;
var _extendCol  = 7;
var _taxCol     = 8;

var _linenumber = 1;
var _populating = false;
var _returnReceipt = false;
var _siteCache;
var _salesrepCache;
var _submitted = false;

var _newMode    = 0;
var _editMode   = 1;
var _viewMode   = 2;

var _add		= mywindow.findChild("_add");
var _cancel		= mywindow.findChild("_cancel");
var _contact	= mywindow.findChild("_contact");
var _cust      	= mywindow.findChild("_cust");
var _custTab	= mywindow.findChild("_custTab");
var _edit		= mywindow.findChild("_edit");
var _extendedPrice	= mywindow.findChild("_extendedPrice");
var _item      	= mywindow.findChild("_item");
var _itemGroup    	= mywindow.findChild("_itemGroup");
var _itemsTab          = mywindow.findChild("_itemsTab");
var _new		= mywindow.findChild("_new");
var _number		= mywindow.findChild("_number");
var _payment	= mywindow.findChild("_payment");
var _qty       	= mywindow.findChild("_qty");
var _receiptNumberLit	= mywindow.findChild("_receiptNumberLit");
var _receiptNumber	= mywindow.findChild("_receiptNumber");
var _receiptSearch	= mywindow.findChild("_receiptSearch");
var _remove		= mywindow.findChild("_remove");
var _sale		= mywindow.findChild("_sale");
var _saleitem 	= mywindow.findChild("_saleitem");
var _saleitems 	= mywindow.findChild("_saleitems");
var _salesrep	= mywindow.findChild("_salesrep");
var _save		= mywindow.findChild("_save");
var _site		= mywindow.findChild("_site");
var _siteLit	= mywindow.findChild("_siteLit");
var _closed		= mywindow.findChild("_closed");
var _subtotal   	= mywindow.findChild("_subtotal");
var _tab		= mywindow.findChild("_tab");
var _tax		= mywindow.findChild("_tax");
var _terminal	= mywindow.findChild("_terminal")
var _total		= mywindow.findChild("_total");
var _type		= mywindow.findChild("_type");	
var _unitPrice  	= mywindow.findChild("_unitPrice");

// Set Columns
with (_saleitems)
{
  setColumn("Line#"  		, 40,  0, true, "line_number");
  setColumn("Item"   		, 100, 0, true, "item_number");
  setColumn("UPC"    		, 100, 0, true, "upc");
  setColumn("Description"	, -1 , 0, true, "description");
  setColumn("Quantity"		, 80 , 0, true, "qty");
  setColumn("Price" 		, 60 , 0, true, "price");
  setColumn("Extended"		, 100, 0, true, "extension");
  setColumn("Tax"      	, 60 , 0, false,"tax");
}

_terminal.populate("SELECT terminal_id, terminal_number, terminal_number"
                 + " FROM xtpos.terminal;");

// Define connections
_add.clicked.connect(add);
_cancel.clicked.connect(cancel);
_cust["newId(int)"].connect(handleButtons);
_cust["newId(int)"].connect(populateContact);
_edit.clicked.connect(customerEdit);
_item["descrip1Changed(QString)"].connect(itemDescripChanged);
_item["newId(int)"].connect(handleButtons);
_item["newId(int)"].connect(itemPrice);
_item["upcChanged(QString)"].connect(itemUpcChanged);
_item["valid(bool)"].connect(_add["setEnabled(bool)"]);
_new.clicked.connect(customerNew);
_payment.clicked.connect(payment);
_qty["textChanged(const QString&)"].connect(itemPrice);
_qty["textChanged(const QString&)"].connect(extension);
_receiptSearch.clicked.connect(receiptSearch);
_remove.clicked.connect(remove);
_saleitems["rowSelected(int)"].connect(rowSelected);
_saleitems["valid(bool)"].connect(_remove["setEnabled(bool)"]);
_salesrep["newID(int)"].connect(handleButtons);
_save.clicked.connect(save);
_terminal["newID(int)"].connect(handleItem);
_type["newID(int)"].connect(typeChanged);
_unitPrice.valueChanged.connect(extension);


// Check Metrics
if (metrics.value("MultiWhs") != "t")
{
  _site.hide();
  _siteLit.hide();
}
if (metrics.value("RetailOnlyUseInternalCust") == "t")
  toolbox.tabRemoveTab(_tab, _custTab);


// Check Privileges
if (privileges.value("MaintainCustomerMasters"))
{
  _new.enabled = true;
  _cust["valid(bool)"].connect(_edit["setEnabled(bool)"]);
}
else
{
  _new.enabled  = false;
  _new.visible  = false;
  _edit.visible = false;
}

// Fill combobox
// When translation capability is available, tranlate second value only.
with (_type)
{
  append(0,"Sale","Sale");
  append(1,"Quote","Quote");
  append(2,"Return","Return");
}

// Disable until we have a line item to work with
_itemGroup.enabled = false;

// Set precision
_qty.setValidator(toolbox.qtyVal());

// Misc Defaults
handleItem();

_salesrepCache = fetchSalesRep();

_receiptNumber.hide();
_receiptNumberLit.hide();
_receiptSearch.hide();

toolbox.executeDbQuery("retail", "setpath");

// Define local functions
function add()
{
  _saleitems.insert();
  _saleitem.clear();
  _saleitems.setValue(_saleitem.currentIndex(),_linenumCol,_linenumber);
  _saleitems.setValue(_saleitem.currentIndex(),_taxCol,0);
  _itemGroup.enabled = true;
  _linenumber = _linenumber + 1;
  _item.setFocus();
}

function cancel()
{
  if (_sale.mode == _newMode)
  {
    if (_submitted)
    // Delete sale
    {
      dparams = new Object();
      dparams.sale_number = _number.text;
      toolbox.executeDbQuery("cashregister","deletesale",dparams);
    }

    // Release number
    params = new Object;
    params.sale_number = _number.text;
    toolbox.executeDbQuery("sale","releasesalenumber",params);
    mydialog.accept();
  }
  else
    mydialog.reject();
}

function customerEdit()
{
  customerOpen(_editMode);
}

function customerNew()
{
  try
  {
    if (metrics.value("DefaultShipFormId") == "")
      throw "A default Ship Form";
    if (metrics.value("DefaultCustType") == "")
      throw "A default Customer Type";
    if (metrics.value("DefaultSalesRep") == "")
      throw "A default Sales Rep";
    if (metrics.value("DefaultTerms") == "")
      throw "Default Terms";
  }
  catch(e)
  {
    var msg = e + " must be set in Sales configuration to create customers "
            + "from here.  Please see your administrator."
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg);
    return;
  }

  customerOpen(_newMode);
}

function customerOpen(mode)
{
  var childwnd = toolbox.openWindow("retailCustomer", mywindow, 0, 1);
  var params   = new Object();
  params.mode  = mode;
  if (mode)
    params.filter = "customer_number='" + _cust.number + "'";

  var tmp = toolbox.lastWindow().set(params);
  var execval = childwnd.exec(); 

  if (execval)
  {
    if (_cust.id() == execval)
      populateContact();
    else
      _cust.setId(execval);
  }
}

function extension()
{
  if (_populating)  // No need to keep recalculating now
    return;

  var extCache = _extendedPrice.localValue;
  var tax;
  var taxCache = _saleitems.selectedValue(_taxCol);
  var row  = 0;
  var hsub = 0;
  var htax = 0;

  try
  {
    // Update item extension
    var ext = _qty.text * _unitPrice.localValue;
    _extendedPrice.setLocalValue(ext);

    // Recalculate Tax
    var params = new Object;
    params.item_id    = _item.id();
    params.qty        = _qty.text;
    params.terminal   = _terminal.code;
    params.unit_price = _unitPrice.localValue;
  
    var data = toolbox.executeDbQuery("sale","saleitemtax",params);
    if (data.first())
    { 
      tax = data.value("item_tax") - 0;
      _saleitems.setValue(_saleitem.currentIndex(),_taxCol,tax);
    }

    // Update header info
    while (row < _saleitems.rowCount())
    {
      if (!_saleitems.isRowHidden(row))
      {
        hsub += _saleitems.value(row, _qtyCol) * 		
		_saleitems.value(row, _priceCol);
        htax += _saleitems.value(row, _taxCol) - 0;
      }
      row++;
    }

    _subtotal.localValue = hsub;
    _tax.localValue = htax;
    _total.localValue = hsub + htax;
  }
  catch (e)
  {
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  } 
}

function fetchSalesRep()
{
  // Get current salesrep
  var data = toolbox.executeDbQuery("sale", "fetchsalesrep");
  if (data.first())
    return data.value("salesrep_number");

  return "";
}

function handleItem() {
  _item.setQuery("SELECT DISTINCT item_id, item_number, item_descrip1,"
               + "                item_descrip2, uom_name, item_type,"
               + "                item_config, item_upccode,"
               + "                item_descrip1 || item_descrip2 AS itemdescrip,"
               + "                item_active "
               + "FROM    item "
               + "   JOIN uom      ON (item_inv_uom_id=uom_id)"
               + "   JOIN itemsite ON (item_id=itemsite_item_id) "
               + "   JOIN reghist  ON (itemsite_warehous_id=reghist_warehous_id)"
               + "WHERE ((reghist_terminal_id=" + _terminal.id() + ")"
               + "   AND reghist_open"
               + "   AND item_active"
               + "   AND item_sold"
               + "   AND (NOT itemsite_loccntrl)"                // 8436 vs. 8581
               + "   AND (itemsite_controlmethod IN ('N', 'R'))" // 8436 vs. 8581
               + ")");
}

function handleButtons()
{
  var state = (_cust.id() != -1 && 
               _salesrep.id() != -1 &&
              (_saleitems.rowCountVisible() > 1 ||
               _item.number.length))
  _payment.enabled = (state);
  _save.enabled = (state);
}

function itemPrice()
{
  if (_populating) // Don't overwrite data stored in the db being populated
    return;

  var params = new Object;
  params.item_id = _item.id();
  params.cust_id = _cust.id();
  params.qty     = _qty.text;

  try
  {
    if (_qty.text && _item.id() > 0)
    {
      var data = toolbox.executeDbQuery("sale","itemprice",params);
      if (data.first())
        _unitPrice.setLocalValue(data.value("itemprice"));
      else if (data.lastError())
        throw data.lastError().text;
      else
        throw "Price not found.  Please see your administrator.";
    }
  }
  catch (e)
  {
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
}

function itemDescripChanged(descrip)
{
  _saleitems.setValue(_saleitem.currentIndex(),_descripCol,descrip);
}

function itemUpcChanged(upc)
{
  _saleitems.setValue(_saleitem.currentIndex(),_upcCol,upc);
}

function payment()
{
  // Check
  var previous_ccpay_id;
  try
  {
    mywindow.findChild("_notes").updateMapperData(); // 8447

    if (_receiptNumber.text)
    {
      var params = new Object();
      params.sale_number = _receiptNumber.text;
  
      var data = toolbox.executeDbQuery("salereceipt","detail",params);
      if (data.first())
      {
        if ((data.value("salehead_cashamt") - 0)  +
            (data.value("salehead_checkamt") - 0) +
            (data.value("ccpay_amount") - 0)       < _total.localValue)
          throw "The refund amount can not exceed the original sale amount.";
        if (data.value("salehead_ccpay_id"))
          previous_ccpay_id = data.value("salehead_ccpay_id");
      }
      else
        throw "Receipt sale record not found.";
    }
  }
  catch (e)
  {
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
    return;
  }

  var idx = _saleitem.currentIndex();
  var filter = "sale_number = '" +  _number.text + "'";

  if (_item.id() == -1)
  {
    remove();
    idx--;
  }

  _populating = true;
  _contact.check();

  // This alternative to save() manually submits data to the database
  // without advancing to a new record or closing window.
  // In the future perhaps pass the entire model and save in payment window.
  try
  {
    toolbox.executeBegin();
    _sale.submit();
    _saleitem.submit();
    _sale.setFilter(filter);
    _sale.select(); 
    toolbox.executeCommit();
    _submitted = true;
  }
  catch (e)
  {
    toolbox.executeRollback();
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
  finally
  {
    _populating = false;
    _saleitems.selectRow(idx);
  }

  var childwnd = toolbox.openWindow("payment", mywindow, 0, 1);
  var params   = new Object;
  params.cust_id  	= _cust.id();
  params.name 	= _contact.name();
  params.sale_number   = _number.text;
  params.subtotal 	= _subtotal.localValue;
  params.tax      	= _tax.localValue;
  params.total   	= _total.localValue;
  params.type	= _type.code;
  if (_receiptNumber.text)
    params.receipt_number = _receiptNumber.text;
  if (previous_ccpay_id != null)
    params.ccpay_id = previous_ccpay_id;

  var tmp = toolbox.lastWindow().set(params);
  var execval = childwnd.exec();
  if (execval)
  {
   if (_sale.mode == _newMode)
   {
    // Adavance to next sale
    _sale.insert();
    prepare();
   }
   else
     mydialog.accept();
  }
}

function populate()
{
  var msgBox     = new Object();
  msgBox.Yes     = 0x00004000;
  msgBox.No      = 0x00010000;
  msgBox.Default = 0x00000100;
  msgBox.Escape  = 0x00000200;

  _populating     = true;
  _sale.select();

  if (_closed.checked && _sale.mode != _viewMode)
    setMode(_viewMode);

  populateItems();

  if (_saleitems.rowCount())
  {
    _saleitem.setCurrentIndex(0);
    _saleitems.selectRow(0);
  }

  if (_sale.mode == _editMode &&
      _salesrep.code != _salesrepCache &&
      _salesrepCache.length > 0)
  {
    var msg = "The Sales Rep number on this order is not your Sales Rep number.  "
            + "Do you want to change it to your number?"
    if (toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg, 
        msgBox.Yes | msgBox.Default, msgBox.No | msgBox.Escape) == msgBox.Yes)
      _salesrep.code = _salesrepCache;
  }

  if (_sale.mode == _editMode)
  {
    _terminal.code = _terminal.defaultCode;
    _site = _siteCache;
  }

  _populating = false;
  _submitted  = false;
  handleButtons();
}

function populateContact()
{
  _contact.clear();
  _contact.number="";

  var params = new Object;
  params.cust_id = _cust.id();

  var data = toolbox.executeDbQuery("sale","fetchcustcontact", params);
  if(data.first())
    _contact.number = data.value("cntct_number");
}

function populateItems()
{
  try
  {
    _saleitems.populate(_sale.currentIndex());
    _itemGroup.enabled = (_saleitems.rowCount());
    _linenumber = _saleitems.rowCount() + 1;
  }
  catch(e)
  {
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
}

function prepare()
{
  // Set header data
  _site.code     = _siteCache;
  _salesrep.code = _salesrepCache;
  _type.code     = "Sale";
  setReturnReceipt(false);

  var data = toolbox.executeDbQuery("sale", "fetchsalenumber");
  if(data.first())
    _number.text = data.value("sale_number");

  // Associate sale items to new header
  populateItems();
  add();
  _add.enabled = false;

  _submitted = false;

  if (metrics.value("RetailUseInternalCust") == "t")
  {
    _cust.setId(metrics.value("RetailCustId"));
    _tab.setCurrentIndex(toolbox.tabTabIndex(_tab, _itemsTab));
    _item.setFocus();
  }
  else
  {
    _tab.setCurrentIndex(0);
    _cust.setFocus();
  }
}

function receiptSearch()
{
  // Warn users if applicable
  if (_saleitems.rowCountVisible() > 1 || _item.id() != -1)
  {
    var msgBox     = new Object();
    msgBox.Yes     = 0x00004000;
    msgBox.No      = 0x00010000;
    msgBox.Default = 0x00000100;
    msgBox.Escape  = 0x00000200;

    var msg = "This action will delete all listed items.  Are you sure you want to do this?"
    if (toolbox.messageBox("warning", mywindow, mywindow.windowTitle, msg, 
          msgBox.Yes | msgBox.Escape, msgBox.No | msgBox.Default) == msgBox.No)
      return;
  }
  
  while(_saleitems.rowCountVisible())
    remove();

  // Look for a receipt
  var childwnd = toolbox.openWindow("retailSaleSearch", mywindow, 0, 1);
  var sparams = new Object();
  sparams.noQuotes = true;
  sparams.noReturns = true;
  var tmp = toolbox.lastWindow().set(sparams);
  var execval = childwnd.exec();

  if (execval)
  {
    // Popualte the line items with the original sale data
    _receiptNumber.text = execval;

    setReturnReceipt(true);
    populating = true;

    params = new Object();
    params.sale_number = _receiptNumber.text;
    var i = 0;
    var data = toolbox.executeDbQuery("sale","getapi_sale",params);
    if (data.first())
      _cust.number = data.value("customer_number");
    data = toolbox.executeDbQuery("sale","getapi_saleitem",params);
    while (data.next())
    {
      with (_saleitems)
      {
        insert();
        setValue(i,_linenumCol,data.value("line_number"));
        setValue(i,_itemCol,data.value("item_number"));
        setValue(i,_upcCol,data.value("upc"));
        setValue(i,_descripCol,data.value("description"));
        setValue(i,_qtyCol,0);
        setValue(i,_priceCol,data.value("price"));
        setValue(i,_extendCol,data.value("extension"));
        setValue(i,_taxCol,0);
      }
      i++;
    }
    handleButtons();
    populating = false;
    return;
  } 
  // Reset for normal sale activity
  else if (_returnReceipt)
    setReturnReceipt(false);
  _receiptNumber.clear();
}

function remove()
{
  var num = _saleitems.selectedValue(_linenumCol);
  var row = _saleitem.currentIndex();
  var idx = 0;

  _itemGroup.enabled = false;
  _saleitem.clear();
  _saleitems.removeSelected();

  // Renumber Rows
  for (row; row < _saleitems.rowCount(); row++)
  {
    if (!_saleitems.isRowHidden(row))
    {
      _saleitems.setValue(row,_linenumCol,num);
      num++;
    }
  }
  _linenumber = num;

  // Select a valid row, otherwise enable/disable appropriate controls
  if (!_saleitems.rowCountVisible())
  {
    _itemGroup.enabled = false;
    _add.enabled = true;
    _remove.enabled = false;
    handleButtons();
    return;
  }
  else
  {
    while (_saleitems.isRowHidden(idx))
      idx++;
    _populating = true;
    _saleitem.setCurrentIndex(idx);
    _saleitems.selectRow(idx);
    popualting = false;
  }
}

function rowSelected(row)
{
  var currentRow = _saleitem.currentIndex(row);
  if (row == currentRow)
    return;

  if (_itemGroup.enabled)
  {
    if (_item.id() == -1)
    {
      _saleitems.selectRow(currentRow);
      var msg = "You must select an item or remove the current line."
      toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg);
      return;
    }
    else if (_qty.text.length == 0)
    {
      _saleitems.selectRow(currentRow);
      var msg = "You must enter a valid quantity or remove the current line."
      toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg);
      return;
    }
  }
  else
    _itemGroup.enabled = true;

  _populating = true;
  _saleitem.setCurrentIndex(row);
  _populating = false;
}

function save()
{
  mywindow.findChild("_notes").updateMapperData(); // 8447

  if (_item.id() == -1)
    remove();

  _populating = true;
  _contact.check();

  try
  {
    toolbox.executeBegin();
    _sale.save();
    _saleitem.save();
    toolbox.executeCommit();
    if (_sale.mode == _newMode)
      prepare();
    else
      mydialog.accept();
  }
  catch (e)
  {
    toolbox.executeRollback();
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
  finally
  {
    _populating = false;
  }
}

function set(input)
{
  if ("site" in input)
    _siteCache = input.site;

  if ("terminal" in input)
  {
    _terminal.code = input.terminal;
    _terminal.defaultCode = input.terminal;
  }

  if ("mode" in input)
  {
    setMode(input.mode);
    if (input.mode == _newMode)
      prepare();
  }

  if ("filter" in input) // Use to populate an existing record
  {
    _sale.setFilter(input.filter);
    populate();
  }

  return 0;
}

function setMode(mode)
{
  _sale.setMode(mode);

  if (mode == _viewMode)
  {
     _save.hide();
     _cancel.text = "Close";
     _new.hide();
     _edit.hide();
     _payment.hide();
     _add.hide();
     _remove.hide(); 
     _itemGroup.hide();
  }

  //These widgets are automatically enabled by new or edit mode, but we don't want them enabled
  _number.enabled 	= false;
  _closed.enabled 	= false;
  _site.enabled 	= false;  
  _terminal.enabled	= false;
}

function setReturnReceipt(hasReceipt)
{try{
  if (hasReceipt && !_returnReceipt)
  {
    _type.enabled = false;
    _item["valid(bool)"].disconnect(_add["setEnabled(bool)"]);
    _saleitems["valid(bool)"].disconnect(_remove["setEnabled(bool)"]);
    _qty["textChanged(const QString&)"].disconnect(itemPrice);
  }
  else if (!hasReceipt && _returnReceipt)
  {
    _type.code = "Sale";
    _type.enabled = true;
    _item["valid(bool)"].connect(_add["setEnabled(bool)"]);
    _saleitems["valid(bool)"].connect(_remove["setEnabled(bool)"]);
    _qty["textChanged(const QString&)"].connect(itemPrice);
    add();
  }

  _add.enabled = !hasReceipt;
  _type.enabled = !hasReceipt;
  _new.enabled = !hasReceipt;
  _cust.enabled = !hasReceipt;
  _unitPrice.enabled = !hasReceipt;
  _item.enabled = !hasReceipt;

  _returnReceipt = hasReceipt;
}catch(e){print(e)}
}

function typeChanged()
{
  _receiptNumber.setVisible(_type.code == "Return");
  _receiptNumberLit.setVisible(_type.code == "Return");
  _receiptSearch.setVisible(_type.code == "Return");
  if (_type.code == "Return")
    _payment.text = "Refund";
  else
    _payment.text = "Payment";
}
