using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Agent_UserAccount_Edit_Casino : System.Web.UI.Page {
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserInfoResult QueryCurrentUserInfo(string AID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserInfoResult RetValue = new EWin.BmAgent.UserInfoResult();

        RetValue = api.QueryCurrentUserInfo(AID);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserInfoResult2 QueryUserInfoByUserAccountID(string AID, int UserAccountID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserInfoResult2 RetValue = new EWin.BmAgent.UserInfoResult2();

        RetValue = api.QueryUserInfoByUserAccountID(AID, UserAccountID);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult UpdateUserInfo(string AID, int UserAccountID, EWin.BmAgent.PropertySet[] UserField) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.APIResult RetValue = new EWin.BmAgent.APIResult();

        RetValue = api.UpdateUserInfo(AID, UserAccountID, UserField);

        return RetValue;
    }
}