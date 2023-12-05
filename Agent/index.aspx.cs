using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web;

/// <summary>
/// index 的摘要描述
/// </summary>
public partial class index : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserAccountBetLimit GetBetLimitInfo(string AID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        return api.GetUserAccountBetLimit(AID);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.CompanyGameBrandResult GetCompanyGameBrand(string AID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        return api.GetCompanyGameBrand(AID);
    }
}