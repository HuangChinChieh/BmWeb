<%@ WebService Language="C#" Class="LobbyAPI" %>

using System;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Collections;
using System.Collections.Generic;
using System.Web.Script.Services;
using System.Web.Script.Serialization;
using System.Linq;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允許使用 ASP.NET AJAX 從指令碼呼叫此 Web 服務，請取消註解下列一行。
// [System.Web.Script.Services.ScriptService]
[System.ComponentModel.ToolboxItem(false)]
[System.Web.Script.Services.ScriptService]
public class LobbyAPI : System.Web.Services.WebService
{
    [WebMethod]
    public void GetGcSyncSetting()
    {
        //string Ret="";
        //if (EWinWeb.IsTestSite)
        //    Ret = "{\"Url\":\"https://gcfdev.ewin888.com/" + EWinWeb.CompanyID + EWinWeb.CompanyCode + "\",\"Domain\":\"gcfdev.ewin888.com\"}";
        //else
        //    Ret = "{\"Url\":\"https://gcfprod.ewin888.com/" + EWinWeb.CompanyID + EWinWeb.CompanyCode + "\",\"Domain\":\"gcfprod.ewin888.com\"}";


        //Context.Response.Write(Ret);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult HeartBeat(string GUID, string Echo)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        //TEST
        return lobbyAPI.HeartBeat(GUID, Echo);
    }

  


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult UserAccountTransfer(string WebSID, string GUID, string DstLoginAccount, string DstCurrencyType, string SrcCurrencyType, decimal TransOutValue, string WalletPassword, string Description)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.UserAccountTransfer(GetToken(), SI.EWinSID, GUID, DstLoginAccount, DstCurrencyType, SrcCurrencyType, TransOutValue, WalletPassword, Description);
        }
        else
        {
            var R = new EWin.Lobby.APIResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult ConfirmUserAccountTransfer(string WebSID, string GUID, string TransferGUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.ConfirmUserAccountTransfer(GetToken(), SI.EWinSID, GUID, TransferGUID);
        }
        else
        {
            var R = new EWin.Lobby.APIResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.TransferHistoryResult GetTransferHistory(string WebSID, string GUID, string BeginDate, string EndDate)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.GetTransferHistory(GetToken(), SI.EWinSID, GUID, BeginDate, EndDate);
        }
        else
        {
            var R = new EWin.Lobby.TransferHistoryResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.UserAccountPropertyResult GetUserAccountProperty(string WebSID, string GUID, string PropertyName)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.GetUserAccountProperty(GetToken(), GUID, EWin.Lobby.enumUserTypeParam.BySID, SI.EWinSID, PropertyName);
        }
        else
        {
            var R = new EWin.Lobby.UserAccountPropertyResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetUserAccountProperty(string WebSID, string GUID, string PropertyName, string PropertyValue)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.SetUserAccountProperty(GetToken(), GUID, EWin.Lobby.enumUserTypeParam.BySID, SI.EWinSID, PropertyName, PropertyValue);
        }
        else
        {
            var R = new EWin.Lobby.APIResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }



    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult GetSIDParam(string WebSID, string GUID, string ParamName)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.GetSIDParam(GetToken(), SI.EWinSID, GUID, ParamName);
        }
        else
        {
            var R = new EWin.Lobby.APIResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetSIDParam(string WebSID, string GUID, string ParamName, string ParamValue)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.SetSIDParam(GetToken(), SI.EWinSID, GUID, ParamName, ParamValue);
        }
        else
        {
            var R = new EWin.Lobby.APIResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult KeepSID(string WebSID, string GUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.APIResult lobbyAPI_ret = new EWin.Lobby.APIResult();
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            lobbyAPI_ret = lobbyAPI.KeepSID(GetToken(), SI.EWinSID, GUID);

            if (lobbyAPI_ret.Result == EWin.Lobby.enumResult.OK)
            {
                if (RedisCache.SessionContext.RefreshSID(WebSID) == true)
                {
                    R.Result = EWin.Lobby.enumResult.OK;
                }
                else
                {
                    R.Result = EWin.Lobby.enumResult.ERR;
                    R.Message = "InvalidWebSID";
                    R.GUID = GUID;
                }
            }
            else
            {
                RedisCache.SessionContext.ExpireSID(WebSID);

                R.Result = EWin.Lobby.enumResult.ERR;
                R.Message = "InvalidWebSID";
                R.GUID = GUID;
            }
        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "InvalidWebSID";
            R.GUID = GUID;
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CheckAccountExist(string GUID, string LoginAccount)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        if (LoginAccount.ToUpper().StartsWith("BMH"))
        {
            return new EWin.Lobby.APIResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "HasLimitChar",
                GUID = GUID
            };
        }
        else
        {
            return lobbyAPI.CheckAccountExist(GetToken(), GUID, LoginAccount);
        }

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CheckAccountExistEx(string GUID, string LoginAccount, string PhonePrefix, string PhoneNumber, string EMail)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        var a = GetToken();
        return lobbyAPI.CheckAccountExistEx(GetToken(), GUID, LoginAccount, PhonePrefix, PhoneNumber, EMail);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CheckAccountExistByContactPhoneNumber(string GUID, string PhonePrefix, string PhoneNumber)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.CheckAccountExistByContactPhoneNumber(GetToken(), GUID, PhonePrefix, PhoneNumber);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult RequireRegister(string GUID, string ParentPersonCode, EWin.Lobby.PropertySet[] PS, EWin.Lobby.UserBankCard[] UBC)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.RequireRegister(GetToken(), GUID, ParentPersonCode, PS, UBC);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.ValidateCodeResult SetValidateCodeOnlyNumber(string GUID, string PhonePrefix, string PhoneNumber)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.SetValidateCodeOnlyNumber(GetToken(), GUID, EWin.Lobby.enumValidateType.PhoneNumber, string.Empty, PhonePrefix, PhoneNumber);
    }

            [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CheckValidateCodeOnlyNumber(string GUID, string PhonePrefix, string PhoneNumber, string ValidateCode)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.CheckValidateCode(GetToken(), GUID,  EWin.Lobby.enumValidateType.PhoneNumber, string.Empty, PhonePrefix, PhoneNumber, ValidateCode);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CreateAccount(string GUID, string LoginAccount, string LoginPassword, string ParentPersonCode, EWin.Lobby.PropertySet[] PS)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();     
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult();        
        System.Data.DataTable DT = null;        
        string ParentLoginAccount = string.Empty;        
        string Birthday = DateTime.Now.ToString("yyyy/MM/dd");
        
        R = lobbyAPI.CreateAccount(GetToken(), GUID, LoginAccount, LoginPassword, ParentPersonCode, EWinWeb.MainCurrencyType, PS);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult GetLoginAccount(string GUID, string PhonePrefix, string PhoneNumber)
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
    public EWin.Lobby.CompanySiteResult GetCompanySite(string GUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.GetCompanySite(GetToken(), GUID);
    }



    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.CompanyGameCodeExchangeResult GetCompanyGameCodeExchange(string GUID, string CurrencyType, string GameBrand, string GameCode)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        var aa = GetToken();
        return lobbyAPI.GetCompanyGameCodeExchange(GetToken(), GUID, CurrencyType, GameBrand, GameCode);
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.UserInfoResult GetUserInfo(string WebSID, string GUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.GetUserInfo(GetToken(), SI.EWinSID, GUID);
        }
        else
        {
            var R = new EWin.Lobby.UserInfoResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.UserBalanceResult GetUserBalance(string WebSID, string GUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.GetUserBalance(GetToken(), SI.EWinSID, GUID);
        }
        else
        {
            var R = new EWin.Lobby.UserBalanceResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    private string GetToken()
    {
        string Token;
        int RValue;
        Random R = new Random();
        RValue = R.Next(100000, 9999999);
        Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());

        return Token;
    }


}