using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserAccountAgentMulti_Maint : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserAgentInfoResult QueryUserAccountSubUserList(string AID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserAgentInfoResult RetValue = new EWin.BmAgent.UserAgentInfoResult();

        RetValue = api.QueryUserAccountSubUserList(AID);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserAgentInfoResult DeleteUserAccountSubUserList(string AID,string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserAgentInfoResult RetValue = new EWin.BmAgent.UserAgentInfoResult();

        RetValue = api.DeleteUserAccountSubUser(AID, LoginAccount);

        return RetValue;
    }
}