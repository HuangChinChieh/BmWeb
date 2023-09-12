using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class SetWalletPassword : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult TransToGameAccount(string AID, string CurrencyType, decimal TransOutValue) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.APIResult RetValue = new EWin.BmAgent.APIResult();

        RetValue = api.TransToGameAccount(AID, CurrencyType, TransOutValue);

        return RetValue;
    }

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
    public static EWin.Lobby.APIResult SetWalletPasswordByValidateCode(string LoginAccount, int ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, string ValidateCode, string NewPassword)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.FANTA.FANTA fantaAPI = new EWin.FANTA.FANTA();
        EWin.Lobby.APIResult R;
        EWin.FANTA.APIResult R2;
        string Token = GetToken();
        string GUID = Guid.NewGuid().ToString();
        R2 = fantaAPI.SetWalletPasswordByValidateCode(Token, LoginAccount, (EWin.FANTA.enumValidateType)ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, ValidateCode, NewPassword);

            if (R2.ResultState == EWin.FANTA.enumResultState.OK)
            {
                R = lobbyAPI.SetUserAccountProperty(GetToken(), GUID, EWin.Lobby.enumUserTypeParam.ByLoginAccount, LoginAccount, "IsSetWalletPassword", "true");
            }
            else
            {
                R = new EWin.Lobby.APIResult()
                {
                    Result = EWin.Lobby.enumResult.ERR,
                    Message = R2.Message,
                    GUID = GUID
                };
            }

        return R;
    }

    private static string GetToken()
    {
        string Token;
        int RValue;
        Random R = new Random();
        RValue = R.Next(100000, 9999999);
        Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());

        return Token;
    }
}