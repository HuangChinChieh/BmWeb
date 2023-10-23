<%@ WebService Language="C#" Class="LoginAPI" %>

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
public class LoginAPI : System.Web.Services.WebService
{

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string HeartBeat(string GUID, string Echo)
    {
        EWin.Login.LoginAPI loginAPI = new EWin.Login.LoginAPI();
        //TEST
        return loginAPI.HeartBeat(Echo);
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

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Login.Result CheckUserIP(string GUID)
    {
        EWin.Login.Result Ret = new EWin.Login.Result() { ResultState = EWin.Login.enumResultState.ERR };
        EWin.Login.LoginAPI loginAPI = new EWin.Login.LoginAPI();
        EWin.Login.GeoClass GC;
        string UserIP = CodingControl.GetUserIP();
        string[] LimitAreas = new string[] { "PH" };
        string[] CIDRList = new string[] {
      "103.151.28.225/29",
      "111.90.176.25/29",
      "202.178.118.255",
      "103.151.28.224/29",
      "103.151.28.112/29",
      "103.151.28.160/29",
      "210.213.88.66",
      "103.176.207.80/29",
      "103.18.64.90",
      "103.18.64.91",
      "103.18.64.92",
      "103.18.64.93",
      "103.18.64.94"
        };

        bool IsCanEntry = true;

        if (!EWinWeb.IsTestSite)
        {
            GC = loginAPI.GetGeoCode(UserIP);

            foreach (var area in LimitAreas)
            {
                if (GC.GeoCountry == area)
                {
                    IsCanEntry = false;
                    break;


                }
            }

            if (IsCanEntry == false)
            {
                foreach (var cidr in CIDRList)
                {
                    if (CodingControl.CheckIPInCIDR(cidr, UserIP))
                    {
                        IsCanEntry = true;
                        break;
                    }
                }
            }



        }

        if (IsCanEntry)
            Ret.ResultState = EWin.Login.enumResultState.OK;
        return Ret;
    }



    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Login.LoginResult UserLogin(string GUID, string LoginGUID, string LoginAccount, string LoginPassword, string ImageCode, string GuestLogin, string Lang)
    {
        EWin.Login.LoginResult Ret = new EWin.Login.LoginResult() { ResultState = EWin.Login.enumResultState.ERR };
        EWin.Login.LoginAPI loginAPI = new EWin.Login.LoginAPI();
        EWin.Login.LoginResult loginRet;

        if (GuestLogin != "1")
        {
            loginRet = loginAPI.UserLogin(EWinWeb.GetToken(), LoginGUID, LoginAccount, LoginPassword, EWinWeb.CompanyCode, ImageCode, CodingControl.GetUserIP());

            if (loginRet.ResultState == EWin.Login.enumResultState.OK)
            {
                Ret.ResultState = EWin.Login.enumResultState.OK;
                Ret.LoginURL = EWinWeb.EWinUrl + "/Game/Login.aspx?CT=" + Server.UrlEncode(loginRet.CT) + "&Lang=" + Lang + "&Action=Game";
            }
            else
            {
                Ret.ResultState = EWin.Login.enumResultState.ERR;
                Ret.Message = loginRet.Message;
            }

        }
        else
        {
            if (!string.IsNullOrEmpty(ImageCode))
            {
                Ret.ResultState = EWin.Login.enumResultState.OK;
                Ret.LoginURL = EWinWeb.EWinUrl + "/Game/LoginGuest.aspx?Lang=" + Lang + "&LoginGUID=" + LoginGUID + "&ImageCode=" + ImageCode + "&Action=Game";
            }
            else
            {
                Ret.ResultState = EWin.Login.enumResultState.ERR;
                Ret.Message = "ImageCodeNotValied";
            }
        }

        return Ret;
    }

         [WebMethod]
 [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
 public EWin.Login.LoginResult UserLoginEntryGameSel(string GUID, string LoginGUID, string LoginAccount, string LoginPassword, string ImageCode, string GuestLogin, string Lang)
 {
     EWin.Login.LoginResult Ret = new EWin.Login.LoginResult() { ResultState = EWin.Login.enumResultState.ERR };
     EWin.Login.LoginAPI loginAPI = new EWin.Login.LoginAPI();
     EWin.Login.LoginResult loginRet;

     if (GuestLogin != "1")
     {
         loginRet = loginAPI.UserLogin(EWinWeb.GetToken(), LoginGUID, LoginAccount, LoginPassword, EWinWeb.CompanyCode, ImageCode, CodingControl.GetUserIP());

         if (loginRet.ResultState == EWin.Login.enumResultState.OK)
         {
             Ret.ResultState = EWin.Login.enumResultState.OK;
             //Ret.LoginURL = EWinWeb.EWinUrl + "/Game/Login.aspx?CT=" + Server.UrlEncode(loginRet.CT) + "&Lang=" + Lang + "&Action=Game";
             Ret.LoginURL ="GameSelect.html?CT=" + Server.UrlEncode(loginRet.CT) + "&Lang=" + Lang + "&Action=Game";
         }
         else
         {
             Ret.ResultState = EWin.Login.enumResultState.ERR;
             Ret.Message = loginRet.Message;
         }

     }
     else
     {
         if (!string.IsNullOrEmpty(ImageCode))
         {
             Ret.ResultState = EWin.Login.enumResultState.OK;
             Ret.LoginURL = EWinWeb.EWinUrl + "/Game/LoginGuest.aspx?Lang=" + Lang + "&LoginGUID=" + LoginGUID + "&ImageCode=" + ImageCode + "&Action=Game";
         }
         else
         {
             Ret.ResultState = EWin.Login.enumResultState.ERR;
             Ret.Message = "ImageCodeNotValied";
         }
     }

     return Ret;
 }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Login.Result GetLoginGUID(string GUID)
    {
        EWin.Login.Result Ret = new EWin.Login.Result() { ResultState = EWin.Login.enumResultState.ERR };
        EWin.Login.LoginAPI loginAPI = new EWin.Login.LoginAPI();
        string loginGUID;

        loginGUID = loginAPI.CreateLoginGUID(EWinWeb.GetToken());

        if (!string.IsNullOrEmpty(loginGUID))
        {
            Ret.ResultState = EWin.Login.enumResultState.OK;
            Ret.Message = loginGUID;
        }
        else
        {
            Ret.ResultState = EWin.Login.enumResultState.ERR;
        }

        return Ret;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Login.Result GetVerify(string GUID, string Url)
    {
        EWin.Login.Result Ret = new EWin.Login.Result() { ResultState = EWin.Login.enumResultState.ERR };
        string UnixTimeStamp = CodingControl.GetUnixTimestamp(DateTime.Now, CodingControl.enumUnixTimestampType.Seconds).ToString();
        string Verify = UnixTimeStamp + "-" + HttpUtility.UrlEncode(CodingControl.GetHMACSHA256(Url + UnixTimeStamp, "EWin"));
            
        Ret.ResultState = EWin.Login.enumResultState.OK;
        Ret.Message = Verify;

        return Ret;
    }
}