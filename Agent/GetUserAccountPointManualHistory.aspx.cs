using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class Agent_GetUserAccountPointManualHistory : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserAccountPointManualHistoryResult GetOrderSummary(string AID, string QueryBeginDate, string QueryEndDate,string CurrencyType) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserAccountPointManualHistoryResult RetValue = new EWin.BmAgent.UserAccountPointManualHistoryResult();

        RetValue = api.GetPointManualHistory(AID, QueryBeginDate, QueryEndDate, CurrencyType);

        return RetValue;
    }

}