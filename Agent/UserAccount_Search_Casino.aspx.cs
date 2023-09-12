using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class Agent_UserAccount_Search_Casino : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.ChildUserInfoResult QueryChildUserInfo(string AID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.ChildUserInfoResult RetValue = new EWin.BmAgent.ChildUserInfoResult();

        RetValue = api.QueryChildUserInfo(AID);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.ChildUserInfoResult QueryCurrentUserInfo(string AID, string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.ChildUserInfoResult RetValue = new EWin.BmAgent.ChildUserInfoResult();

        RetValue = api.QueryCurrentUserInfoForSearchPage(AID, LoginAccount);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult UpdateUserAccountNote(string AID, int UserAccountID, string UserAccountNote) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.APIResult RetValue = new EWin.BmAgent.APIResult();

        RetValue = api.UpdateUserAccountNote(AID, UserAccountID, UserAccountNote);

        return RetValue;
    }
}