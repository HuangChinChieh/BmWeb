using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class GetAgentTotalSummary_Casino : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.OrderSummaryResult GetAgentTotalOrderSummary(string AID, int TargetUserAccountID, DateTime QueryBeginDate, DateTime QueryEndDate, string CurrencyType) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.OrderSummaryResult RetValue = new EWin.BmAgent.OrderSummaryResult();

        RetValue = api.GetAgentTotalOrderSummary(AID, TargetUserAccountID, QueryBeginDate, QueryEndDate, CurrencyType);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.OrderSummaryResult GetAgentTotalOrderSummaryBySearch(string AID, string TargetLoginAccount, DateTime QueryBeginDate, DateTime QueryEndDate, string CurrencyType)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.OrderSummaryResult RetValue = new EWin.BmAgent.OrderSummaryResult();

        RetValue = api.GetSearchAgentTotalOrderSummary(AID, TargetLoginAccount, QueryBeginDate, QueryEndDate, CurrencyType);

        return RetValue;
    }
}