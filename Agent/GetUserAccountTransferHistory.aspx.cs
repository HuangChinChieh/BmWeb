using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Agent_GetUserAccountTransferHistory : System.Web.UI.Page
{
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserAccountTransferHistoryResult GetOrderSummary(string AID, string QueryBeginDate, string QueryEndDate, int SearchState,string CurrencyType) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserAccountTransferHistoryResult RetValue = new EWin.BmAgent.UserAccountTransferHistoryResult();

        RetValue = api.GetUserAccountTransferHistory(AID, QueryBeginDate, QueryEndDate, SearchState, CurrencyType);

        return RetValue;
    }
}