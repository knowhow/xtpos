// Define variables
var _customer = mywindow.findChild("_customer");
var _number   = mywindow.findChild("_number");
var _numCache = "";
var _numFetch = 0 - 0;

// Define connections
_number.lostFocus.connect(check);
mywindow.findChild("_ok").clicked.connect(save);
mywindow.findChild("_cancel").clicked.connect(cancel);

// Define local functions
function cancel()
{
  releaseNumber();
  mydialog.reject();
}

function check()
{
  if (_numCache == _number.text)
    return true;

  var msgBox     = new Object();
  msgBox.Yes     = 0x00004000;
  msgBox.No      = 0x00010000;
  msgBox.Default = 0x00000100;
  msgBox.Escape  = 0x00000200;
  var msg;

  _number.text = _number.text.toUpperCase();

  if (getCustId(_number.text) > 0)
  {
    msg = "A customer with this number already exists.  "
        + "Would you like to load that customer?";
    if (toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg, 
        msgBox.Yes | msgBox.Default, msgBox.No | msgBox.Escape) == msgBox.Yes)
    {
      _customer.mode = 1; // Edit
      _customer.setFilter("customer_number = '" + _number.text + "'");
      _customer.select();
      _numCache = _number.text;
    }
    else
    {
      _number.text = _numCache;
      _number.setFocus();
      return false;
    }
  }
  else
  {
    var crmacct = getCrmAcct(_number.text);
    if ("id" in crmacct)
    {
      msg = "A CRM Account with this number already exists.  "
          + "Would you like to associate this customer that CRM Account?";
      if (toolbox.messageBox("critical", mywindow, mywindow.windowTitle, msg, 
          msgBox.Yes | msgBox.Default, msgBox.No | msgBox.Escape) == msgBox.Yes)
      {
        mywindow.findChild("_name").text = crmacct.name;
        mywindow.findChild("_billingContact").setSearchAcct(crmacct.id);
        _numCache = _number.text;
      }
      else
      {
        _number.text = _numCache;
        _number.setFocus();
        return false;
      }
    }
  }

  return true;
}

function getCrmAcct(number)
{
  var results = new Object();
  var params = new Object();
  params.number = number;

  var data = toolbox.executeDbQuery("retailcustomer","getcrmacct",params);
  if (data.first())
  {
    results.id = data.value("crmacct_id");
    results.name = data.value("crmacct_name"); 
  }

  return results;
}

function getCustId(number)
{
  var params = new Object();
  params.number = number;

  var data = toolbox.executeDbQuery("retailcustomer","getcustid",params);
  if (data.first())
    return data.value("cust_id");

  return -1;
}

function releaseNumber()
{
  if (_numFetch)
  {
     params = new Object();
     params.number = _numFetch;

     toolbox.executeDbQuery("retailcustomer","releasecrmnumber",params);
  }
}

function save()
{
  if (!check())
    return;

  var number = _number.text;

  try
  {
    mywindow.findChild("_billingContact").check();
    _customer.save();
    if (_numFetch)
      if (_numFetch != number)
        releaseNumber();
    mydialog.done(getCustId(number));
  }
  catch (e)
  {
    print(e);
    toolbox.messageBox("critical", mywindow, mywindow.windowTitle, e);
  }
}

function set(input)
{
  if ("mode" in input)
  {
    _customer.setMode(input.mode);

    if (_customer.mode == 0) // New mode
    {
      if((metrics.value("CRMAccountNumberGeneration") == "A") ||
         (metrics.value("CRMAccountNumberGeneration") == "O"))
      {
        var data = toolbox.executeDbQuery("retailcustomer","fetchcustnumber");
        if (data.first())
        {
          mywindow.findChild("_number").text = data.value("number");
          _numFetch = data.value("number");
          if (metrics.value("CRMAccountNumberGeneration") == "A")
            mywindow.findChild("_number").enabled = false;
        }
      }
    }
  }

  if ("filter" in input)
  {
    _customer.setFilter(input.filter);
    _customer.select();
    _numCache = _number.text;
  }

  return 0;
}