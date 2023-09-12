<%@ WebService Language="C#" Class="LobbyAPI2" %>

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
public class LobbyAPI2 : System.Web.Services.WebService
{
    [WebMethod]
    public void GetGcSyncSetting()
    {
        string Ret = "";
        if (EWinWeb.IsTestSite)
            Ret = "{\"Url\":\"https://gcfdev.ewin888.com/" + EWinWeb.CompanyID + EWinWeb.CompanyCode + "\",\"Domain\":\"gcfdev.ewin888.com\"}";
        else
            Ret = "{\"Url\":\"https://gcfprod.ewin888.com/" + EWinWeb.CompanyID + EWinWeb.CompanyCode + "\",\"Domain\":\"gcfprod.ewin888.com\"}";


        Context.Response.Write(Ret);
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby2.APIResult HeartBeat(string GUID, string Echo)
    {
        EWin.Lobby2.LobbyAPI lobbyAPI = new EWin.Lobby2.LobbyAPI();
        //TEST
        return lobbyAPI.HeartBeat(GUID, Echo);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby2.CompanyGameCodeResult GetCompanyGameCodeByUpdateTimestamp(string GUID, long UpdateTimestamp, int GameID)
    {
        EWin.Lobby2.LobbyAPI lobbyAPI = new EWin.Lobby2.LobbyAPI();

        return lobbyAPI.GetCompanyGameCodeByUpdateTimestamp(GetToken(), GUID, UpdateTimestamp, GameID);

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public CompanyGameCodeResult1 GetCompanyGameCode(string GUID, string GameCode)
    {
        CompanyGameCodeResult1 R = new CompanyGameCodeResult1() { Result = EWin.Lobby2.enumResult.ERR };
        System.Data.DataTable DT;

        DT = RedisCache.CompanyGameCode.GetCompanyGameCode(GameCode.Split('.').First(), GameCode);
        if (DT != null && DT.Rows.Count > 0)
        {
            R.Result = EWin.Lobby2.enumResult.OK;
            R.Data = DT.ToList<CompanyGameCode>().First();
        }

        return R;
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

    public class CompanyGameCodeResult1 : EWin.Lobby2.APIResult
    {
        public CompanyGameCode Data { get; set; }
    }

    public class CompanyGameCode
    {
        public string GameCode { get; set; }
        public int SortIndex { get; set; }
        public int GameID { get; set; }
        public string GameBrand { get; set; }
        public string GameName { get; set; }
        public string GameCategoryCode { get; set; }
        public string GameCategorySubCode { get; set; }
        public int AllowDemoPlay { get; set; }
        public string RTPInfo { get; set; }
        public int IsNew { get; set; }
        public int IsHot { get; set; }
        public string Tags { get; set; }
        public string Language { get; set; }
        public string GameAccountingCode { get; set; }
        public int GameStatus { get; set; }

    }
}