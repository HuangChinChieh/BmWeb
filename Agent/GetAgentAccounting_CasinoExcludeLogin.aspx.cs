using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class GetAgentAccounting_CasinoExcludeLogin : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.AccountingResult GetAccountingItem(string StartDate,string EndDate,string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.AccountingResult RetValue = new EWin.BmAgent.AccountingResult();
        string CurrencyType = EWinWeb.MainCurrencyType;
        RetValue = api.GetAccountingItemExcludeLogin(EWinWeb.CompanyCode, LoginAccount, StartDate, EndDate, CurrencyType);

        return RetValue;
    }
}