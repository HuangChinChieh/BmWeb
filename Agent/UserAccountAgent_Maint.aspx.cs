using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserAccountAgent_Maint : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserAgentInfoResult QueryUserAccountAgentList(string AID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserAgentInfoResult RetValue = new EWin.BmAgent.UserAgentInfoResult();

        RetValue = api.QueryUserAccountAgentList(AID);

        return RetValue;
    }
}