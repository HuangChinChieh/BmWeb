using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class UserAccountWallet_Transfer : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult TransToGameAccount(string AID, string CurrencyType, decimal TransOutValue) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.APIResult RetValue = new EWin.BmAgent.APIResult();

        RetValue = api.TransToGameAccount(AID, CurrencyType, TransOutValue);

        return RetValue;
    }
}