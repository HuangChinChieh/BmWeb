using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class GetGameSetResult : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.GameSetResult GetGameSetData(string AID, string TargetLoginAccount, DateTime QueryBeginDate, DateTime QueryEndDate, string CurrencyType)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.GameSetResult RetValue = new EWin.BmAgent.GameSetResult();

        RetValue = api.GetGameSetResult(AID, QueryBeginDate, QueryEndDate, TargetLoginAccount, CurrencyType);

        return RetValue;
    }
}