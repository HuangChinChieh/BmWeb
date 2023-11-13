using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserAccountAgentMulti_Add : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserAgentInfoResult AddUserAccountSubUserList(string AID, string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserAgentInfoResult RetValue = new EWin.BmAgent.UserAgentInfoResult();

        RetValue = api.AddUserAccountSubUser(AID, LoginAccount);

        return RetValue;
    }
}