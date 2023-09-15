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
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CheckAccountExist(string GUID, string LoginAccount)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.CheckAccountExist(GetToken(), GUID, LoginAccount);
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

    private EWin.Lobby.APIResult setUserAccountProperty(string LoginAccount, string GUID, string PropertyName, string PropertyValue)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult();

        R = lobbyAPI.SetUserAccountProperty(GetToken(), GUID, EWin.Lobby.enumUserTypeParam.ByLoginAccount, LoginAccount, PropertyName, PropertyValue);

        return R;
    }

    private static Newtonsoft.Json.Linq.JObject GetActivityDetail(string Path)
    {
        Newtonsoft.Json.Linq.JObject o = null;
        string Filename;

        Filename = HttpContext.Current.Server.MapPath(Path);

        if (System.IO.File.Exists(Filename))
        {
            string SettingContent;

            SettingContent = System.IO.File.ReadAllText(Filename);

            if (string.IsNullOrEmpty(SettingContent) == false)
            {
                try { o = Newtonsoft.Json.Linq.JObject.Parse(SettingContent); } catch (Exception ex) { }
            }
        }

        return o;
    }

    public class UserTwoMonthSummaryResult : EWin.Lobby.APIResult
    {
        public List<Payment> PaymentResult { get; set; }
        public List<Game> GameResult { get; set; }

        public class Payment
        {
            public int SortIndex { get; set; }
            public decimal DepositAmount { get; set; }
            public decimal WithdrawalAmount { get; set; }
        }

        public class Game
        {
            public int SortIndex { get; set; }
            public decimal OrderValue { get; set; }
            public decimal ValidBetValue { get; set; }
            public decimal RewardValue { get; set; }
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

    public class OcwBulletinBoardResult : EWin.Lobby.APIResult
    {
        public List<OcwBulletinBoard> Datas { get; set; }
    }

    public class OcwBulletinBoard
    {
        public int BulletinBoardID { get; set; }
        public string BulletinTitle { get; set; }
        public string BulletinContent { get; set; }
        public DateTime CreateDate { get; set; }
        public int State { get; set; }
    }

    public class OcwCompanyGameCodeResult : EWin.Lobby.APIResult
    {
        public int MaxGameID { get; set; }
        public long TimeStamp { get; set; }
        public List<OcwCompanyCategory> CompanyCategoryDatas { get; set; }
    }

    public class OcwCompanyCategoryGameCodeResult : EWin.Lobby.APIResult
    {
        public List<GroupOcwCompanyCategoryGameCode> LobbyGameList { get; set; }
    }

    public class GroupOcwCompanyCategoryGameCode
    {
        public List<OcwCompanyCategorysGameCode> Categories { get; set; }
        public string Location { get; set; }
    }

    public class OcwAllCompanyGameCodeResult : EWin.Lobby.APIResult
    {
        public List<OcwCompanyGameCode> Datas { get; set; }
        public int MaxGameID { get; set; }
        public long TimeStamp { get; set; }
    }

    public class OcwCompanyCategorysGameCode
    {
        public int CompanyCategoryID { get; set; }
        public int State { get; set; }
        public int SortIndex { get; set; }
        public string CategoryName { get; set; }
        public string Location { get; set; }
        public int ShowType { get; set; }
        public List<OcwCompanyCategoryGameCode> Datas { get; set; }
    }

    public class OcwCompanyCategoryGameCode
    {
        public int forCompanyCategoryID { get; set; }
        public string GameCode { get; set; }
        public int SortIndex { get; set; }
    }

    public class OcwCompanyCategory
    {
        public int CompanyCategoryID { get; set; }
        public int State { get; set; }
        public int SortIndex { get; set; }
        public string CategoryName { get; set; }
        public string Location { get; set; }
        public int ShowType { get; set; }
        public List<OcwCompanyGameCode> Datas { get; set; }
    }

    public class OcwCompanyGameCode
    {
        public int forCompanyCategoryID { get; set; }
        public int GameID { get; set; }
        public string GameCode { get; set; }
        public string GameBrand { get; set; }
        public string GameName { get; set; }
        public string GameCategoryCode { get; set; }
        public string GameCategorySubCode { get; set; }
        public int AllowDemoPlay { get; set; }
        public string RTPInfo { get; set; }
        public string Info { get; set; }
        public int IsHot { get; set; }
        public int IsNew { get; set; }
        public int SortIndex { get; set; }
        public string Tag { get; set; }
    }

    public class OcwLoginMessageResult : EWin.Lobby.APIResult
    {
        public string Title { get; set; }
        public string Version { get; set; }
    }

    public class OcwPromotionCollectHistoryResult : EWin.Lobby.APIResult
    {
        public string QueryBeginDate { get; set; }
        public string QueryEndDate { get; set; }
        public OcwPromotionCollect[] CollectList { get; set; }
    }

    public class OcwPromotionCollectResult : EWin.Lobby.APIResult
    {
        public OcwPromotionCollect[] CollectList { get; set; }
    }

    public class OcwPromotionCollect
    {
        //0=尚未領取/1=已領取/2=已過期
        public enum OcwEnumStatus
        {
            None = 0,
            Taked = 1,
            Expire = 2
        }

        public int CollectID { get; set; }
        public string CurrencyType { get; set; }
        public int PromotionID { get; set; }
        public int PromotionDetailID { get; set; }
        public int CollectAreaType { get; set; }
        public OcwEnumStatus Status { get; set; }
        public string Description { get; set; }
        public string ActionContent { get; set; }
        public string ExpireDate { get; set; }
        public string CollectDate { get; set; }
        public string CreateDate { get; set; }
        public decimal PointValue { get; set; }
        public string PromotionTitle { get; set; }
    }

    public class CompanyGameCodeResult1 : EWin.Lobby.APIResult
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

    public class OcwPropertySet
    {
        public string Name { get; set; }
        public string Value { get; set; }
    }

    public class OcwActionContentSet
    {
        public string Field { get; set; }
        public string Value { get; set; }
    }

    public class UserAccountEventSummaryResult : EWin.Lobby.APIResult
    {
        public List<UserAccountEventSummary> Datas { get; set; }
    }

    public class UserAccountEventSummary
    {
        public string LoginAccount { get; set; }
        public string ActivityName { get; set; }
        public int CollectCount { get; set; }
        public int JoinCount { get; set; }
        public decimal ThresholdValue { get; set; }
        public decimal BonusValue { get; set; }
    }

    public class UserAccountThisWeekTotalValidBetValueResult : EWin.Lobby.APIResult
    {
        public List<UserAccountThisWeekTotalValidBetValue> Datas { get; set; }
    }

    public class UserAccountThisWeekTotalValidBetValue
    {
        public string Date { get; set; }
        public decimal TotalValidBetValue { get; set; }
        public int Status { get; set; }
    }

    public class UserAccountTotalSummaryResult : EWin.Lobby.APIResult
    {
        public List<UserAccountTotalSummary> Datas { get; set; }
    }

    public class UserAccountTotalSummary
    {
        public string LoginAccount { get; set; }
        public int DepositCount { get; set; }
        public decimal DepositRealAmount { get; set; }
        public decimal DepositAmount { get; set; }
        public int WithdrawalCount { get; set; }
        public decimal WithdrawalRealAmount { get; set; }
        public decimal WithdrawalAmount { get; set; }
        public DateTime LastDepositDate { get; set; }
        public DateTime LastWithdrawalDate { get; set; }
        public string FingerPrints { get; set; }
    }

    public class UserVIPResult : EWin.Lobby.APIResult
    {
        public UserVIPInfo Data { get; set; }

        public class UserVIPInfo
        {
            public int UserLevelIndex { get; set; }
            public string VIPDescription { get; set; }
            public string NextVIPDescription { get; set; }
            public int ElapsedDays { get; set; } //保級流水計算時間 (10/30天) => 10
            public int KeepLevelDays { get; set; } //保級流水計算時間 (10/30天) => 30
            public decimal DepositValue { get; set; }
            public decimal DepositMaxValue { get; set; }
            public decimal ValidBetValue { get; set; }
            public decimal ValidBetMaxValue { get; set; }
            public decimal KeepValidBetValue { get; set; }
        }
    }

    public class UserLevelUpgradeTempData
    {
        public int NewLevelIndex { get; set; }
        public decimal DepositMinValue { get; set; }
        public decimal ValidBetMinValue { get; set; }
    }
}