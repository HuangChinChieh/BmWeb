using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class Agent_GetUserAccountPointOPLog : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserAccountPointOPLogResult GetPointOPLog(string AID, string QueryBeginDate, string CurrencyType) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserAccountPointOPLogResult RetValue = new EWin.BmAgent.UserAccountPointOPLogResult();

        RetValue = api.GetUserAccountPointOPLog(AID, QueryBeginDate, CurrencyType);

        return RetValue;
    }

}