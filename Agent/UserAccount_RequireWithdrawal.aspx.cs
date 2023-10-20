using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class UserAccount_RequireWithdrawal : System.Web.UI.Page
{

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.RequireWithdrawalResult GetRequireWithdrawal(string AID, string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.RequireWithdrawalResult RetValue = new EWin.BmAgent.RequireWithdrawalResult();

        RetValue = api.GetRequireWithdrawal(AID, LoginAccount);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.RequireWithdrawalResult RequireWithdrawalSuccess(string AID, string RequireID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.RequireWithdrawalResult RetValue = new EWin.BmAgent.RequireWithdrawalResult();

        RetValue = api.RequireWithdrawalSuccess(AID, RequireID);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.RequireWithdrawalResult RequireWithdrawalCancel(string AID, string RequireID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.RequireWithdrawalResult RetValue = new EWin.BmAgent.RequireWithdrawalResult();

        RetValue = api.RequireWithdrawalCancel(AID, RequireID);

        return RetValue;
    }
}