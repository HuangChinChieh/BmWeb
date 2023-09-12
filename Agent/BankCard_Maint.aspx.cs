using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;

public partial class BankCard_Maint : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserBankCardListResult GetUserBankCard(string AID) {

        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        return api.GetUserBankCard(AID); 

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult SetUserBankCardState(string AID, string BankCardGUID, int BankCardState)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        return api.SetUserBankCardState(AID, BankCardGUID, BankCardState);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult AddUserBankCard(string AID,int PaymentMethod, string BankName, string BranchName, string BankNumber, string AccountName, string BankProvince, string BankCity, string Description)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        return api.AddUserBankCard(AID,EWinWeb.MainCurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, BankProvince, BankCity, Description);
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult CheckPassword(string AID, string Password)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        return api.CheckPassword(AID, EWin.BmAgent.enumPasswordType.WalletPassword, Password);
    }
}