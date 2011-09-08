// Define variables
var _custId;
var _ccOn;
var _ccp         	= toolbox.getCreditCardProcessor();
var _ccPayId;
var _number;
var _receiptNumber = "";
var _type;

var _address	= mywindow.findChild("_address");
var _balance	= mywindow.findChild("_balance");
var _cancel		= mywindow.findChild("_cancel");
var _cashAmount	= mywindow.findChild("_cashAmount");
var _cashGroup	= mywindow.findChild("_cashGroup");
var _change		= mywindow.findChild("_change");
var _checkAmount	= mywindow.findChild("_checkAmount");
var _creditAmount	= mywindow.findChild("_creditAmount");
var _creditCardNumber	= mywindow.findChild("_creditCardNumber");
var _creditGroup 	= mywindow.findChild("_creditGroup");
var _checkGroup  	= mywindow.findChild("_checkGroup");
var _checkNumber	= mywindow.findChild("_checkNumber");
var _cvv		= mywindow.findChild("_cvv");
var _expireMonth	= mywindow.findChild("_expireMonth");
var _expireYear	= mywindow.findChild("_expireYear");
var _fundsType	= mywindow.findChild("_fundsType");
var _name		= mywindow.findChild("_name");
var _ok		= mywindow.findChild("_ok");
var _paid		= mywindow.findChild("_paid");
var _paidLit	= mywindow.findChild("_paidLit");
var _print		= mywindow.findChild("_print");
var _subtotal	= mywindow.findChild("_subtotal");
var _tax		= mywindow.findChild("_tax");
var _total		= mywindow.findChild("_total");

_ccOn = (_ccp != null && _ccp.testConfiguration() >= 0);
if (! _ccOn)
{
  try {
    if (_ccp)
      print(_ccp.errorMsg());
  }
  catch (e) {
    print(e);
  }
}

// Define local connections
_checkGroup["toggled(bool)"].connect(checkToggled);
_creditGroup["toggled(bool)"].connect(creditToggled);
_cashAmount.valueChanged.connect(calc);
_checkAmount.valueChanged.connect(calc);
_creditAmount.valueChanged.connect(calc);
_ok.clicked.connect(closeSale);
_cancel.clicked.connect(mydialog, "reject");

  // Set Defaults
_creditGroup.enabled = _ccOn;
_creditAmount.localValue = 0;
_checkAmount.localValue = 0;
_paid.localValue = 0;
_balance.localValue = 0;
_change.localValue = 0;

function calc()
{
  _paid.localValue =  _cashAmount.localValue +_creditAmount.localValue + _checkAmount.localValue;

  if (_paid.localValue - 0 >= _total.localValue)
  {
    _balance.localValue = 0;
    _change.localValue =  _paid.localValue - _total.localValue;
  }
  else
  {
    _balance.localValue = _total.localValue - _paid.localValue;
    _change.localValue = 0;
  }
  
  if (_cashAmount.localValue >= _total.localValue)
  {
    _checkAmount.valueChanged.disconnect(calc);
    _creditAmount.valueChanged.disconnect(calc);

    _creditGroup.setChecked(false);
    _creditGroup.setEnabled(false);
    _creditAmount.localValue = 0;
    _checkGroup.setChecked(false);
    _checkGroup.setEnabled(false); 
    _checkAmount.localValue = 0;

    _checkAmount.valueChanged.connect(calc);
    _creditAmount.valueChanged.connect(calc);
  }
  else
  {
    _creditGroup.setEnabled(_ccOn);
    if (_type != "Return")
      _checkGroup.setEnabled(true); 
  }
}

function charge()
{
  // First save the card info
  var ccardId = toolbox.saveCreditCard(mywindow,
                                    _custId,
			  _name.text,
			  _address.line1(),
			  _address.line2(),
			  _address.city(),
			  _address.state(),
			  _address.postalCode(),
			  _address.country(),
			  _creditCardNumber.text,
			  _fundsType.text.charAt(0),
			  _expireMonth.text,
			  _expireYear.text,
			  0);

  switch (ccardId)
  {
    case -1:
      _creditCardNumber.setFocus();
      break;
    case -2:
      break;
    case -3:
      _name.setFocus();
      break;
    case -4:
      _address.setFocus();
      break;
    case -5:
      _expireMonth.setFocus();
      break;
    case -6:
      _expireYear.setFocus();
      break;
    default:
      break;
  }
  if (ccardId < 0)
    return ccardId;

  // Charge the card
  var params = new Object;
  params.ccard_id = ccardId;
  params.cvv      = _cvv.text - 0;
  params.amount   = _creditAmount.localValue;
  params.curr_id  = _creditAmount.id();
  params.neworder = _number;

  var results = new Object;
  if (_type == "Return")
  {
    results = _ccp.credit(params);
    if (results.returnVal < 0)
    {
      print(_ccp.errorMsg());
      toolbox.messageBox("critical", mywindow, "Credit Card Charge Error", _ccp.errorMsg());
      return results.returnVal - 0;
    }
  }
  else // assume SALE as normal case
  {
    results = _ccp.charge(params);
    if (results.returnVal < 0)
    {
      print(_ccp.errorMsg());
      toolbox.messageBox("critical", mywindow, "Credit Card Charge Error", _ccp.errorMsg());
      return results.returnVal - 0;
    }
  }

  return results.ccpayid - 0;
}

function checkToggled(checked)
{
  if (checked)
  {
    _creditGroup.setChecked(false);
    _checkAmount.localValue = _total.localValue - _paid.localValue;
  }
  else
    _checkAmount.localValue = 0;
}

function closeSale()
{
  try
  {
    if (_paid.localValue - 0 < _total.localValue)
      throw "The amount paid is less than the total due.";

    if (_checkGroup.checked && _checkNumber.text.length == 0)
      throw "A check number is required.";

    var params = new Object;
    params.sale_number = _number;
    params.tendered = _cashAmount.localValue;

    if (_creditGroup.checked)
    {
      var ccpayId = charge() - 0;
      if (ccpayId < 0)
        return;

      params.credit = true; 
      params.ccpay_id = ccpayId;
    }
    else if (_checkGroup.checked)
    { 
      params.check = true;
      params.check_amount = _checkAmount.localValue;
      params.check_number = _checkNumber.text;
    }
    else
      params.cash = true;
    
    var data = toolbox.executeDbQuery("payment","closesale",params);
    if (data.first())
    {
      if (!data.value("result"))
        throw "Sale was not closed successfully.  Please see your administrator."
    }
    else
      throw "Sale was not closed successfully.  Please see your administrator."
  
    if (_print.checked)
      printReceipt(_number);

    mydialog.accept();
  }
  catch (e)
  {
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
}

function creditToggled(checked)
{
  if (checked)
  {
    _checkGroup.setChecked(0);
    _creditAmount.localValue = _total.localValue - _paid.localValue;
  }
  else
    _creditAmount.localValue = 0;
}

function printReceipt(number)
{
  var params = new Object();
  params.sale_number    = number;
  params.sale_receipt   = "Sale Receipt";
  params.return_receipt = "Return Receipt";
  params.type           = _type;
  if (_creditGroup.checked)
    params.cclast4      = _creditCardNumber.text.slice(-4);

  toolbox.printReport("RetailSaleReceipt",params);
}

function set(input)
{
  if ("cust_id" in input)
  {
    _custId = input.cust_id;

    var qparams = new Object;
    qparams.cust_id = _custId;
    var data = toolbox.executeDbQuery("sale","fetchcustcontact", qparams);
    if(data.first())
      _address.setNumber(data.value("addr_number"));
  }

  if ("name" in input)
    _name.text = input.name;

  if ("receipt_number" in input)
    _receiptNumber = input.receipt_number;

  if ("sale_number" in input)
    _number = input.sale_number; 

  if ("subtotal" in input)
    _subtotal.localValue = input.subtotal;

  if ("tax" in input)
    _tax.localValue = input.tax;

  if ("total" in input)
  {
    _total.localValue = input.total;
    calc();
  }

  if ("type" in input)
  {
    _type = input.type;

    if (_type == "Return")
    {
      if ("ccpay_id" in input)
      {
        var qparams = new Object;
        qparams.ccpayid         = input.ccpay_id;
        qparams.key             = mainwindow.key;
        qparams.masterCard      = "Master Card"; // ccard types must match .ui
        qparams.visa            = "Visa";
        qparams.americanExpress = "American Express";
        qparams.discover        = "Discover";
        qparams.other           = "Other";

        var data = toolbox.executeDbQuery("payment", "fetchccinfo", qparams);
        if (data.first())
        {
          _name.text             = data.value("ccard_name");
          _address.setLine1(data.value("ccard_address1"));
          if ((data.value("ccard_address2") + "").indexOf("QVariant") <= -1)
            _address.setLine2(data.value("ccard_address2"));
          _address.setCity(data.value("ccard_city"));
          _address.setState(data.value("ccard_state"));
          _address.setPostalCode(data.value("ccard_zip"));
          _address.setCountry(data.value("ccard_country"));
          _creditCardNumber.text = data.value("ccard_number");
          _fundsType.text        = data.value("cardtype");
          _expireMonth.text      = data.value("ccard_month_expired");
          _expireYear.text       = data.value("ccard_year_expired");
          _creditGroup.checked   = _ccOn;
          _creditAmount.localValue = data.value("ccpay_amount");
          _creditCardNumber.echoMode = 3;
        }
      }

      _cashGroup.enabled = true;
      _checkGroup.enabled = false;
      _creditGroup.enabled = _ccOn;
      mywindow.windowTitle = "Refund";
      _paidLit.text = "Refund:";
      _cashAmount.localValue = _total.localValue - _creditAmount.localValue;
    }
  }
}
