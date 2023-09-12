using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserAccount_Add_Casino : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult CreateUserInfo(string AID, string LoginAccount, EWin.BmAgent.PropertySet[] UserField) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.APIResult RetValue = new EWin.BmAgent.APIResult();
        
        RetValue = api.CreateUserInfo(AID, LoginAccount, UserField);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult CheckAccountExist(string AID, string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.APIResult RetValue = new EWin.BmAgent.APIResult();

        RetValue = api.CheckAccountExist(AID, LoginAccount);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserInfoResult QueryCurrentUserInfo(string AID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserInfoResult RetValue = new EWin.BmAgent.UserInfoResult();

        RetValue = api.QueryCurrentUserInfo(AID);

        return RetValue;
    }
}