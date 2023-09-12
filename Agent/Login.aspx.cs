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
public partial class Login : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult SetUserPasswordByValidateCode(string CompanyCode, string GUID, EWin.BmAgent.enumValidateType ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, string ValidateCode, string NewPassword, string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.APIResult RetValue = new EWin.BmAgent.APIResult();

        RetValue = api.SetUserPasswordByValidateCode(CompanyCode, GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, ValidateCode, NewPassword, LoginAccount);

        return RetValue;
    }
}