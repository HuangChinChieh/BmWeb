<%@ WebService Language="C#" Class="AgentAPI" %>

using System;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Collections;
using System.Collections.Generic;
using System.Web.Script.Services;
using System.Web.Script.Serialization;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允許使用 ASP.NET AJAX 從指令碼呼叫此 Web 服務，請取消註解下列一行。
// [System.Web.Script.Services.ScriptService]
[System.ComponentModel.ToolboxItem(false)]
[System.Web.Script.Services.ScriptService]
public class AgentAPI : System.Web.Services.WebService {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult HeartBeat(string GUID, string Echo) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.HeartBeat(GUID, Echo);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.LoginResult AgentLoginByPhoneNumber(string LoginGUID, string GUID, string ContactPhonePrefix, string ContactPhoneNumber, string LoginPassword, string MainAccount, string UserIP) {
        EWin.Agent.LoginResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.AgentLoginByPhoneNumber(LoginGUID, GUID, ContactPhonePrefix, ContactPhoneNumber, LoginPassword, MainAccount, UserIP);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.LoginResult AgentLogin(string LoginGUID, string GUID, EWin.Agent.enumLoginType LoginType, string LoginAccount, string LoginPassword, string MainAccount, string UserIP) {
        EWin.Agent.LoginResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.AgentLogin(LoginGUID, GUID, LoginType, LoginAccount, LoginPassword, MainAccount, UserIP);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult AddUserBankCard(string AID, string GUID, string CurrencyType, int PaymentMethod, string BankName, string BranchName, string BankNumber, string AccountName, string BankProvince, string BankCity, string Description) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.AddUserBankCard(AID, GUID, CurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, BankProvince, BankCity, Description);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult RemoveUserBankCard(string AID, string GUID, string BankCardGUID) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.RemoveUserBankCard(AID, GUID, BankCardGUID);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult UpdateUserBankCard(string AID, string GUID, string BankCardGUID, string CurrencyType, int PaymentMethod, string BankName, string BranchName, string BankNumber, string AccountName, string BankProvince, string BankCity, string Description) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.UpdateUserBankCard(AID, GUID, BankCardGUID, CurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, BankProvince, BankCity, Description);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.UserBankCardListResult GetUserBankCard(string AID, string GUID) {
        EWin.Agent.UserBankCardListResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.GetUserBankCard(AID, GUID);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.QueryReportResult QueryReportInfo(string AID, string GUID, string ReportGUID) {
        EWin.Agent.QueryReportResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.QueryReportInfo(AID, GUID, ReportGUID);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.ReportResult RunReport(string AID, string GUID, string ReportGUID, EWin.Agent.ReportParam[] Param) {
        EWin.Agent.ReportResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.RunReport(AID, GUID, ReportGUID, Param);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult UpdateDeviceInfo(string AID, string GUID, string DeviceGUID, int PushType, string DeviceName, string DeviceKey, EWin.Agent.enumDeviceType DeviceType, string NotifyToken, string GPSPosition, string UserAgent) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.UpdateDeviceInfo(AID, GUID, DeviceGUID, PushType, DeviceName, DeviceKey, DeviceType, NotifyToken, GPSPosition, UserAgent);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult ValidatePassword(string AID, string GUID, EWin.Agent.enumPasswordType PasswordType, string Password) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.ValidatePassword(AID, GUID, PasswordType, Password);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.ETHCoinTxResult GetETHCoinTxLog(string AID, string GUID, DateTime BeginDate, DateTime EndDate) {
        EWin.Agent.ETHCoinTxResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.GetETHCoinTxLog(AID, GUID, BeginDate, EndDate);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult ETHBitCoinTx(string AID, string GUID, string WalletPassword, string ToAddress, string CurrencyType, decimal Amount) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.ETHBitCoinTx(AID, GUID, WalletPassword, ToAddress, CurrencyType, Amount);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult ETHCheckBitCoinTxState(string AID, string GUID) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.ETHCheckBitCoinTxState(AID, GUID);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult KeepAID(string AID, string GUID) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.KeepAID(AID, GUID);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.OrderSummaryResult GetOrderSummary(string AID, string GUID, string LoginAccount, string QueryBeginDate, string QueryEndDate, string CurrencyType) {
        EWin.Agent.OrderSummaryResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.GetOrderSummary(AID, GUID, LoginAccount, QueryBeginDate, QueryEndDate, CurrencyType);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.OrderDetailListResult GetOrderDetail(string AID, string GUID, string LoginAccount, string QueryDate, int OrderType, string CurrencyType) {
        EWin.Agent.OrderDetailListResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.GetOrderDetail(AID, GUID, LoginAccount, QueryDate, OrderType, CurrencyType);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.CompanyInfoResult GetCompanyInfo(string AID, string GUID) {
        EWin.Agent.CompanyInfoResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.GetCompanyInfo(AID, GUID);

        return R;
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult DisableChildUser(string AID, string GUID, string LoginAccount) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.DisableChildUser(AID, GUID, LoginAccount);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.ChildUserAccountResult QueryChildUserAccountList(string AID, string GUID, string ParentLoginAccount) {
        EWin.Agent.ChildUserAccountResult R = new EWin.Agent.ChildUserAccountResult();
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.QueryChildUserAccountList(AID, GUID, ParentLoginAccount);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult AddMultiLogin(string AID, string GUID, string LoginAccount, string LoginPassword, string Description) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.AddMultiLogin(AID, GUID, LoginAccount, LoginPassword, Description);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult SetMultiLogin(string AID, string GUID, string LoginAccount, string Description) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.SetMultiLogin(AID, GUID, LoginAccount, Description);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.APIResult RemoveMultiLogin(string AID, string GUID, string LoginAccount) {
        EWin.Agent.APIResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.RemoveMultiLogin(AID, GUID, LoginAccount);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.UserInfoResult QueryUserInfo(string AID, string GUID) {
        EWin.Agent.UserInfoResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.QueryUserInfo(AID, GUID);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.WalletHistoryResult GetWalletHistory(string AID, string GUID, string LoginAccount, string StartDate, string EndDate, string ActionType, string CurrencyType) {
        EWin.Agent.WalletHistoryResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.GetWalletHistory(AID, GUID, LoginAccount, StartDate, EndDate, ActionType, CurrencyType);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Agent.AccountingSummaryResult GetAccountingSummary(string AID, string GUID, string LoginAccount, string QueryBeginDate, string QueryEndDate, string CurrencyType) {
        EWin.Agent.AccountingSummaryResult R;
        EWin.Agent.AgentAPI api = new EWin.Agent.AgentAPI();

        R = api.GetAccountingSummary(AID, GUID, LoginAccount, QueryBeginDate, QueryEndDate, CurrencyType);

        return R;
    }

}