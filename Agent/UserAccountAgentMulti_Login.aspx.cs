using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class UserAccountAgentMulti_Login : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult AgentMultoLogin(string AID, string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.APIResult RetValue = new EWin.BmAgent.APIResult();

        RetValue = api.AgentMultoLogin(AID, LoginAccount);

        return RetValue;
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserAgentInfoResult QueryUserAccountSubUserList(string AID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserAgentInfoResult RetValue = new EWin.BmAgent.UserAgentInfoResult();

        RetValue = api.QueryUserAccountSubUserList(AID);

        return RetValue;
    }
}