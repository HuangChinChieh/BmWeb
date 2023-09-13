using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class SetPassword : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.PhoneResult GetUserSMSNumber(string AID)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.PhoneResult RetValue = new EWin.BmAgent.PhoneResult();

        RetValue = api.GetUserSMSNumber(AID);

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.Lobby.APIResult GetLoginAccount(string PhonePrefix, string PhoneNumber)
    {
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult()
        {
            Result = EWin.Lobby.enumResult.ERR
        };

        TelPhoneNormalize telPhoneNormalize = new TelPhoneNormalize(PhonePrefix, PhoneNumber);

        if (telPhoneNormalize.PhoneIsValid)
        {
            R.Result = EWin.Lobby.enumResult.OK;
            R.Message = telPhoneNormalize.PhonePrefix + telPhoneNormalize.PhoneNumber;

        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "NormalizeError";
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult SetUserPasswordByValidateCode(string LoginAccount, int ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, string ValidateCode, string NewPassword)
    {

        EWin.BmAgent.APIResult R;

        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        string GUID = Guid.NewGuid().ToString();
        R = api.SetUserPasswordByValidateCode(EWinWeb.CompanyCode, GUID, (EWin.BmAgent.enumValidateType)ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, ValidateCode, NewPassword, LoginAccount);

        return R;
    }

}