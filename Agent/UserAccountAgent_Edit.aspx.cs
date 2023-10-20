using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserAccountAgent_Edit : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult UpdateUserInfo(string AID, string LoginAccount, EWin.BmAgent.PropertySet[] UserField) {

        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.APIResult RetValue = new EWin.BmAgent.APIResult();

        RetValue = api.UpdateUserAccountAgentLogin(AID, LoginAccount, UserField);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.AgentInfoResult QueryAgentInfo(string AID, string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.AgentInfoResult RetValue = new EWin.BmAgent.AgentInfoResult();

        RetValue = api.GeteUserAccountAgentInfoByLoginAccount(AID, LoginAccount);

        return RetValue;
    }
    
}