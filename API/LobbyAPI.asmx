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
        string Ret="";
        if (EWinWeb.IsTestSite)
            Ret = "{\"Url\":\"https://gcfdev.ewin888.com/" + EWinWeb.CompanyID + EWinWeb.CompanyCode + "\",\"Domain\":\"gcfdev.ewin888.com\"}";
        else
            Ret = "{\"Url\":\"https://gcfprod.ewin888.com/" + EWinWeb.CompanyID + EWinWeb.CompanyCode + "\",\"Domain\":\"gcfprod.ewin888.com\"}";


        Context.Response.Write(Ret);
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
    public EWin.Lobby.PaymentChannelResult ListPaymentChannel(string WebSID, string GUID, int DirectionType)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;
        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.ListPaymentChannel(GetToken(), SI.EWinSID, GUID, EWinWeb.MainCurrencyType, (EWin.Lobby.enumPaymentDirectionType)DirectionType);
        }
        else
        {
            var R = new EWin.Lobby.PaymentChannelResult()
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
    public EWin.Lobby.PaymentChannelResult GetPaymentChannelByGroupIndex(string WebSID, string GUID, int DirectionType, int GroupIndex, decimal Amount)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;
        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);
        System.Data.DataTable DT = new System.Data.DataTable();
        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            var GetPaymentChannelResult = lobbyAPI.GetPaymentChannelByGroupIndex(GetToken(), SI.EWinSID, GUID, EWinWeb.MainCurrencyType, (EWin.Lobby.enumPaymentDirectionType)DirectionType, GroupIndex, Amount);
            if (GetPaymentChannelResult.Result == EWin.Lobby.enumResult.OK)
            {
                return GetPaymentChannelResult;
            }
            else
            {
                var ListPaymentChannelResult = lobbyAPI.ListPaymentChannel(GetToken(), SI.EWinSID, GUID, EWinWeb.MainCurrencyType, (EWin.Lobby.enumPaymentDirectionType)DirectionType);
                if (ListPaymentChannelResult.Result == EWin.Lobby.enumResult.OK)
                {

                    ListPaymentChannelResult.ChannelList = ListPaymentChannelResult.ChannelList.Where(w => w.GroupIndex == GroupIndex && w.CurrencyType == EWinWeb.MainCurrencyType).OrderByDescending(o => o.GroupIndex).ThenByDescending(o => o.WeightIndex).ThenByDescending(o => o.UserLevelIndex).ToArray();


                    if (ListPaymentChannelResult.ChannelList.Length > 0)
                    {
                        var ChannelList = new EWin.Lobby.PaymentChannel[1];
                        ChannelList[0] = new EWin.Lobby.PaymentChannel() { PaymentChannelCode = ListPaymentChannelResult.ChannelList[0].PaymentChannelCode };
                        var R = new EWin.Lobby.PaymentChannelResult()
                        {
                            Result = EWin.Lobby.enumResult.OK,
                            ChannelList = ChannelList,
                            Message = "",
                            GUID = GUID
                        };

                        return R;
                    }
                    else
                    {
                        var R = new EWin.Lobby.PaymentChannelResult()
                        {
                            Result = EWin.Lobby.enumResult.ERR,
                            Message = "InvalidWebSID",
                            GUID = GUID
                        };

                        return R;
                    }
                }
                else
                {
                    var R = new EWin.Lobby.PaymentChannelResult()
                    {
                        Result = EWin.Lobby.enumResult.ERR,
                        Message = "InvalidWebSID",
                        GUID = GUID
                    };

                    return R;
                }
            }
        }
        else
        {
            var R = new EWin.Lobby.PaymentChannelResult()
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
    public EWin.Lobby.APIResult CheckPaymentChannelAmount(string WebSID, string GUID, string CurrencyType, int DirectionType, decimal Amount, string PaymentChannelCode)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;
        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.CheckPaymentChannelAmount(GetToken(), SI.EWinSID, GUID, (EWin.Lobby.enumPaymentDirectionType)DirectionType, CurrencyType, PaymentChannelCode, Amount);
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
    public EWin.Lobby.APIResult AddUserBankCard(string WebSID, string GUID, string CurrencyType, int PaymentMethod, string BankName, string BranchName, string BankNumber, string AccountName, string BankProvince, string BankCity, string Description)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;
        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.AddUserBankCard(GetToken(), SI.EWinSID, GUID, CurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, BankProvince, BankCity, Description);
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
    public EWin.Lobby.APIResult SetUserBankCardState(string WebSID, string GUID, string BankCardGUID, int BankCardState)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.SetUserBankCardState(GetToken(), SI.EWinSID, GUID, BankCardGUID, BankCardState);
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
    public EWin.Lobby.GameCodeOnlineListResult GetUserAccountGameCodeOnlineList(string WebSID, string GUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;
        EWin.Lobby.GameCodeOnlineListResult Result;
        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            Result = lobbyAPI.GetUserAccountGameCodeOnlineList(GetToken(), SI.EWinSID, GUID);
            Result.Message = SI.EWinSID;
            return Result;
        }
        else
        {
            var R = new EWin.Lobby.GameCodeOnlineListResult()
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
    public EWin.Lobby.APIResult RemoveUserBankCard(string WebSID, string GUID, string BankCardGUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.RemoveUserBankCard(GetToken(), SI.EWinSID, GUID, BankCardGUID);
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
    public EWin.Lobby.APIResult UpdateUserBankCard(string WebSID, string GUID, string BankCardGUID, string CurrencyType, int PaymentMethod, string BankName, string BranchName, string BankNumber, string AccountName, string BankProvince, string BankCity, string Description)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.UpdateUserBankCard(GetToken(), SI.EWinSID, GUID, BankCardGUID, CurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, BankProvince, BankCity, Description);
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
    public EWin.Lobby.UserBankCardListResult GetUserBankCard(string WebSID, string GUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.GetUserBankCard(GetToken(), SI.EWinSID, GUID);
        }
        else
        {
            var R = new EWin.Lobby.UserBankCardListResult()
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
    public UserAccountEventSummaryResult GetUserAccountEventSummary(string WebSID, string GUID)
    {
        UserAccountEventSummaryResult R = new UserAccountEventSummaryResult() { Result = EWin.Lobby.enumResult.ERR };
        List<UserAccountEventSummary> Datas = new List<UserAccountEventSummary>();
        RedisCache.SessionContext.SIDInfo SI;
        System.Data.DataTable DT;
        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            DT = RedisCache.UserAccountEventSummary.GetUserAccountEventSummaryByLoginAccount(SI.LoginAccount);
            if (DT != null && DT.Rows.Count > 0)
            {
                for (int i = 0; i < DT.Rows.Count; i++)
                {
                    var Data = new UserAccountEventSummary();
                    Data.ActivityName = (string)DT.Rows[i]["ActivityName"];
                    Data.BonusValue = (decimal)DT.Rows[i]["BonusValue"];
                    Data.CollectCount = (int)DT.Rows[i]["CollectCount"];
                    Data.JoinCount = (int)DT.Rows[i]["JoinCount"];
                    Data.LoginAccount = (string)DT.Rows[i]["LoginAccount"];
                    Data.ThresholdValue = (decimal)DT.Rows[i]["ThresholdValue"];
                    Datas.Add(Data);

                }
                R.Datas = Datas;
                R.Result = EWin.Lobby.enumResult.OK;
            }
        }
        return R;
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

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult RequireRegister(string GUID, string ParentPersonCode, EWin.Lobby.PropertySet[] PS, EWin.Lobby.UserBankCard[] UBC)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.RequireRegister(GetToken(), GUID, ParentPersonCode, PS, UBC);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CreateAccount(string GUID, string LoginAccount, string LoginPassword, string ParentPersonCode, string CurrencyList, EWin.Lobby.PropertySet[] PS)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.OCW.OCW ocwAPI = new EWin.OCW.OCW();
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult();
        EWin.OCW.ParentUserAccountInfoResult Parent = new EWin.OCW.ParentUserAccountInfoResult();
        System.Data.DataTable DT = null;
        System.Data.DataTable ActivityLoginAccountDT = null;
        string ParentLoginAccount = string.Empty;
        string CollectAreaType;
        string Birthday = DateTime.Now.ToString("yyyy/MM/dd");
        int ActivityCount = 0;

        R = lobbyAPI.CreateAccount(GetToken(), GUID, LoginAccount, LoginPassword, ParentPersonCode, CurrencyList, PS);

        if (R.Result == EWin.Lobby.enumResult.OK)
        {
            //建立會員等級資料
            foreach (EWin.Lobby.PropertySet EachPS in PS)
            {
                if (EachPS.Name.ToUpper() == "Birthday".ToUpper())
                {
                    Birthday = EachPS.Value;
                }
            }
            EWinWebDB.UserAccount.InsertUserAccountLevelAndBirthday(0, LoginAccount, DateTime.Now.ToString("yyyy/MM/dd"), Birthday);

            ActivityCount = EWinWebDB.UserAccountEventSummary.GetActivityCountByActivityName("RegisterBouns");

            if (ActivityCount > 2)
            {
                string LoginAccounts = "";
                ActivityLoginAccountDT = EWinWebDB.UserAccountEventSummary.GetActivityLoginAccountByActivityName("RegisterBouns");
                if (ActivityLoginAccountDT != null && ActivityLoginAccountDT.Rows.Count > 0)
                {
                    for (int i = 0; i < ActivityLoginAccountDT.Rows.Count; i++)
                    {
                        LoginAccounts += ActivityLoginAccountDT.Rows[i]["LoginAccount"].ToString() + ",";
                    }
                    LoginAccounts += "IP:" + CodingControl.GetUserIP();
                }
                lobbyAPI.SetUserAccountProperty(GetToken(), GUID, EWin.Lobby.enumUserTypeParam.ByLoginAccount, LoginAccount, "RegisterBouns IP duplicate", LoginAccounts);
            }
            else
            {
                var GetRegisterResult = ActivityCore.GetRegisterResult(LoginAccount);

                if (GetRegisterResult.Result == ActivityCore.enumActResult.OK)
                {
                    List<EWin.Lobby.PropertySet> PropertySets = new List<EWin.Lobby.PropertySet>();
                    foreach (var activityData in GetRegisterResult.Data)
                    {

                        string description = activityData.ActivityName;
                        string JoinActivityCycle = activityData.JoinActivityCycle == null ? "1" : activityData.JoinActivityCycle;
                        string PromotionCode = description;
                        string PromotionCategoryCode = "";
                        CollectAreaType = activityData.CollectAreaType == null ? "2" : activityData.CollectAreaType;

                        PropertySets.Add(new EWin.Lobby.PropertySet { Name = "ThresholdValue", Value = activityData.ThresholdValue.ToString() });
                        PropertySets.Add(new EWin.Lobby.PropertySet { Name = "PointValue", Value = activityData.BonusValue.ToString() });
                        PropertySets.Add(new EWin.Lobby.PropertySet { Name = "JoinActivityCycle", Value = JoinActivityCycle.ToString() });

                        lobbyAPI.AddPromotionCollect(GetToken(), description + "_" + LoginAccount, LoginAccount, EWinWeb.BonusCurrencyType, PromotionCode, PromotionCategoryCode, int.Parse(CollectAreaType), 90, description, PropertySets.ToArray());
                        EWinWebDB.UserAccountEventSummary.UpdateUserAccountEventSummary(LoginAccount, description, JoinActivityCycle, 1, activityData.ThresholdValue, activityData.BonusValue);
                    }
                }
            }

            var GetRegisterToParentResult = ActivityCore.GetRegisterToParentResult();
            if (GetRegisterToParentResult.Result == ActivityCore.enumActResult.OK)
            {
                List<EWin.Lobby.PropertySet> PropertySets = new List<EWin.Lobby.PropertySet>();

                Parent = ocwAPI.GetParentUserAccountInfo(GetToken(), LoginAccount);

                if (Parent.ResultState == EWin.OCW.enumResultState.OK)
                {
                    ParentLoginAccount = Parent.ParentLoginAccount;
                }

                DT = RedisCache.UserAccount.GetUserAccountByLoginAccount(ParentLoginAccount);

                if (DT != null)
                {
                    if (DT.Rows.Count > 0)
                    {
                        decimal DepositAmount = (decimal)DT.Rows[0]["DepositAmount"];

                        if (DepositAmount >= 500)
                        {
                            PropertySets = new List<EWin.Lobby.PropertySet>();

                            foreach (var activityData in GetRegisterToParentResult.Data)
                            {
                                string description = activityData.ActivityName;
                                string JoinActivityCycle = activityData.JoinActivityCycle == null ? "1" : activityData.JoinActivityCycle;
                                string PromotionCode = description;
                                string PromotionCategoryCode = "";
                                CollectAreaType = activityData.CollectAreaType == null ? "2" : activityData.CollectAreaType;

                                PropertySets.Add(new EWin.Lobby.PropertySet { Name = "ThresholdValue", Value = activityData.ThresholdValue.ToString() });
                                PropertySets.Add(new EWin.Lobby.PropertySet { Name = "PointValue", Value = activityData.BonusValue.ToString() });
                                PropertySets.Add(new EWin.Lobby.PropertySet { Name = "JoinActivityCycle", Value = JoinActivityCycle.ToString() });

                                lobbyAPI.AddPromotionCollect(GetToken(), description + "_" + ParentLoginAccount + "_From_" + LoginAccount, ParentLoginAccount, EWinWeb.MainCurrencyType, PromotionCode, PromotionCategoryCode, int.Parse(CollectAreaType), 90, description, PropertySets.ToArray());
                                EWinWebDB.UserAccountEventSummary.UpdateUserAccountEventSummary(ParentLoginAccount, description, JoinActivityCycle, 1, activityData.ThresholdValue, activityData.BonusValue);
                            }
                        }
                    }
                }
            }
        }

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
    public OcwLoginMessageResult GetLoginMessage(string WebSID, string GUID)
    {
        RedisCache.SessionContext.SIDInfo SI;
        OcwLoginMessageResult R = new OcwLoginMessageResult() { Result = EWin.Lobby.enumResult.ERR };
        Newtonsoft.Json.Linq.JObject SettingData;
        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            SettingData = EWinWeb.GetSettingJObj();
            if (SettingData != null)
            {
                if (SettingData["LoginMessage"] != null)
                {
                    R.Title = SettingData["LoginMessage"]["Title"] == null ? "" : SettingData["LoginMessage"]["Title"].ToString();
                    R.Message = SettingData["LoginMessage"]["Message"].ToString();
                    R.Version = SettingData["LoginMessage"]["Version"].ToString();
                    R.Result = EWin.Lobby.enumResult.OK;
                }
                else
                {
                    R.Result = EWin.Lobby.enumResult.ERR;
                    R.Message = "NoData";
                }
            }
            else
            {
                R.Result = EWin.Lobby.enumResult.ERR;
                R.Message = "NoData";
            }
        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "InvalidWebSID";
        }

        return R;
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
    public EWin.Lobby.APIResult GetUserOtherSMSNumber(string WebSID, string GUID)
    {
        EWin.FANTA.FANTA fantaAPI = new EWin.FANTA.FANTA();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            var R2 = fantaAPI.GetUserOtherSMSNumber(GetToken(), SI.EWinSID, GUID);
            if (R2.ResultState == EWin.FANTA.enumResultState.OK)
            {
                var R = new EWin.Lobby.UserInfoResult()
                {
                    Result = EWin.Lobby.enumResult.OK,
                    Message = R2.Message,
                    GUID = GUID
                };
                return R;
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

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public CompanyGameCodeResult1 GetCompanyGameCode(string GUID, string GameCode)
    {
        CompanyGameCodeResult1 R = new CompanyGameCodeResult1() { Result = EWin.Lobby.enumResult.ERR };
        System.Data.DataTable DT;

        DT = RedisCache.CompanyGameCode.GetCompanyGameCode(GameCode.Split('.').First(), GameCode);
        if (DT != null && DT.Rows.Count > 0)
        {
            R.Result = EWin.Lobby.enumResult.OK;
            R.Data = DT.ToList<CompanyGameCode>().First();
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public OcwCompanyCategoryGameCodeResult GetCompanyGameCodeThree(string GUID, string Location)
    {
        OcwCompanyCategoryGameCodeResult Ret = new OcwCompanyCategoryGameCodeResult() { LobbyGameList = new List<GroupOcwCompanyCategoryGameCode>() };
        System.Data.DataTable CompanyCategoryDT;
        System.Data.DataTable CompanyGameCodeDT;
        List<GroupOcwCompanyCategoryGameCode> LobbyGameList = new List<GroupOcwCompanyCategoryGameCode>();
        int CompanyCategoryID;
        CompanyCategoryDT = RedisCache.CompanyCategory.GetCompanyCategory();
        try
        {
            if (CompanyCategoryDT != null && CompanyCategoryDT.Rows.Count > 0)
            {
                for (int i = 0; i < CompanyCategoryDT.Rows.Count; i++)
                {
                    if (((string)CompanyCategoryDT.Rows[i]["Location"]).Contains(Location))
                    {
                        if ((int)CompanyCategoryDT.Rows[i]["State"] == 0)
                        {
                            CompanyCategoryID = (int)CompanyCategoryDT.Rows[i]["CompanyCategoryID"];
                            CompanyGameCodeDT = RedisCache.CompanyCategoryGameCode.GetCompanyCategoryGameCodeByID(CompanyCategoryID);

                            var companyCategoryData = new OcwCompanyCategorysGameCode();
                            companyCategoryData.CompanyCategoryID = CompanyCategoryID;
                            companyCategoryData.CategoryName = (string)CompanyCategoryDT.Rows[i]["CategoryName"];
                            companyCategoryData.SortIndex = (int)CompanyCategoryDT.Rows[i]["SortIndex"];
                            companyCategoryData.State = (int)CompanyCategoryDT.Rows[i]["State"];
                            companyCategoryData.Location = (string)CompanyCategoryDT.Rows[i]["Location"];
                            companyCategoryData.ShowType = (int)CompanyCategoryDT.Rows[i]["ShowType"];
                            companyCategoryData.Datas = new List<OcwCompanyCategoryGameCode>();


                            if (CompanyGameCodeDT != null && CompanyGameCodeDT.Rows.Count > 0)
                            {
                                for (int k = 0; k < CompanyGameCodeDT.Rows.Count; k++)
                                {
                                    var data = new OcwCompanyCategoryGameCode();
                                    data.forCompanyCategoryID = (int)CompanyGameCodeDT.Rows[k]["forCompanyCategoryID"];
                                    data.GameCode = (string)CompanyGameCodeDT.Rows[k]["GameCode"];
                                    data.SortIndex = (int)CompanyGameCodeDT.Rows[k]["SortIndex"];
                                    companyCategoryData.Datas.Add(data);
                                }
                            }
                            if (LobbyGameList.Where(w => w.Location == companyCategoryData.Location).Count() > 0)
                            {
                                LobbyGameList.Find(w => w.Location == companyCategoryData.Location).Categories.Add(companyCategoryData);
                            }
                            else
                            {
                                LobbyGameList.Add(new GroupOcwCompanyCategoryGameCode() { Categories = new List<OcwCompanyCategorysGameCode>() { companyCategoryData }, Location = companyCategoryData.Location });
                            }
                        }
                    }
                }

                if (LobbyGameList.Count > 0)
                {
                    Ret.LobbyGameList = LobbyGameList;
                    Ret.Result = EWin.Lobby.enumResult.OK;
                }
                else
                {
                    Ret.Result = EWin.Lobby.enumResult.ERR;
                }
            }
            else
            {
                Ret.Result = EWin.Lobby.enumResult.ERR;
            }
        }
        catch (Exception ex)
        {
            var a = ex;
            throw;
        }


        return Ret;

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public OcwCompanyGameCodeResult GetCompanyCategoryID(string GUID, string Location)
    {
        System.Data.DataTable CompanyCategoryDT;
        int CompanyCategoryID;
        CompanyCategoryDT = RedisCache.CompanyCategory.GetCompanyCategory();
        OcwCompanyGameCodeResult Ret = new OcwCompanyGameCodeResult() { CompanyCategoryDatas = new List<OcwCompanyCategory>() };
        if (CompanyCategoryDT != null && CompanyCategoryDT.Rows.Count > 0)
        {
            for (int i = 0; i < CompanyCategoryDT.Rows.Count; i++)
            {
                if ((string)CompanyCategoryDT.Rows[i]["Location"] == Location)
                {
                    if ((int)CompanyCategoryDT.Rows[i]["State"] == 0)
                    {
                        CompanyCategoryID = (int)CompanyCategoryDT.Rows[i]["CompanyCategoryID"];

                        var companyCategoryData = new OcwCompanyCategory();
                        companyCategoryData.CompanyCategoryID = CompanyCategoryID;
                        companyCategoryData.CategoryName = (string)CompanyCategoryDT.Rows[i]["CategoryName"];
                        companyCategoryData.SortIndex = (int)CompanyCategoryDT.Rows[i]["SortIndex"];
                        companyCategoryData.State = (int)CompanyCategoryDT.Rows[i]["State"];
                        companyCategoryData.Location = (string)CompanyCategoryDT.Rows[i]["Location"];
                        companyCategoryData.ShowType = (int)CompanyCategoryDT.Rows[i]["ShowType"];
                        companyCategoryData.Datas = null;

                        Ret.CompanyCategoryDatas.Add(companyCategoryData);
                    }
                }
            }

            Ret.Result = EWin.Lobby.enumResult.OK;
        }
        else
        {
            Ret.Result = EWin.Lobby.enumResult.ERR;
        }
        return Ret;

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult GetCompanyMarqueeText(string GUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.GetCompanyMarqueeText(GetToken(), GUID);
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.GameOrderDetailListResult GetGameOrderDetailHistoryBySummaryDate(string WebSID, string GUID, string QueryDate)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.GetGameOrderDetailHistoryBySummaryDate(GetToken(), SI.EWinSID, GUID, QueryDate);
        }
        else
        {
            var R = new EWin.Lobby.GameOrderDetailListResult()
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
    public EWin.Lobby.GameOrderDetailListResult GetGameOrderHistoryBySummaryDateAndGameCode(string WebSID, string GUID, string QueryDate)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.GameOrderDetailListResult callResult = new EWin.Lobby.GameOrderDetailListResult();
        EWin.Lobby.GameOrderDetailListResult R;
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            callResult = lobbyAPI.GetGameOrderDetailHistoryBySummaryDate(GetToken(), SI.EWinSID, GUID, QueryDate);
            if (callResult.Result == EWin.Lobby.enumResult.OK)
            {
                R = new EWin.Lobby.GameOrderDetailListResult()
                {
                    Result = EWin.Lobby.enumResult.OK,
                    GUID = GUID
                };

                R.DetailList = callResult.DetailList.Where(x => x.CurrencyType == EWinWeb.BonusCurrencyType || x.CurrencyType == EWinWeb.MainCurrencyType).GroupBy(x => new { x.GameCode, x.CurrencyType, x.SummaryDate }, x => x, (key, detail) => new EWin.Lobby.GameOrderDetail
                {
                    GameCode = key.GameCode,
                    ValidBetValue = detail.Sum(y => y.ValidBetValue),
                    BuyChipValue = detail.Sum(y => y.BuyChipValue),
                    RewardValue = detail.Sum(y => y.RewardValue),
                    OrderValue = detail.Sum(y => y.OrderValue),
                    SummaryType = detail.FirstOrDefault().SummaryType,
                    GameAccountingCode = detail.FirstOrDefault().GameAccountingCode,
                    CurrencyType = key.CurrencyType,
                    LoginAccount = detail.FirstOrDefault().LoginAccount,
                    RealName = detail.FirstOrDefault().RealName,
                    SummaryDate = key.SummaryDate
                }).ToArray();

            }
            else
            {
                R = callResult;
            }
        }
        else
        {
            R = new EWin.Lobby.GameOrderDetailListResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.OrderSummaryResult GetGameOrderSummaryHistoryGroupGameCode(string WebSID, string GUID, string QueryBeginDate, string QueryEndDate)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.OrderSummaryResult callResult = new EWin.Lobby.OrderSummaryResult();
        EWin.Lobby.OrderSummaryResult R;
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            callResult = lobbyAPI.GetGameOrderSummaryHistory(GetToken(), SI.EWinSID, GUID, QueryBeginDate, QueryEndDate);
            if (callResult.Result == EWin.Lobby.enumResult.OK)
            {
                R = new EWin.Lobby.OrderSummaryResult()
                {
                    Result = EWin.Lobby.enumResult.OK,
                    GUID = GUID
                };

                R.SummaryList = callResult.SummaryList.Where(x => x.OrderValue > 0 && (x.CurrencyType == EWinWeb.BonusCurrencyType || x.CurrencyType == EWinWeb.MainCurrencyType)).GroupBy(x => new { x.SummaryDate }, x => x, (key, sum) => new EWin.Lobby.OrderSummary
                {
                    ValidBetValue = sum.Sum(y => y.ValidBetValue),
                    RewardValue = sum.Sum(y => y.RewardValue),
                    OrderValue = sum.Sum(y => y.OrderValue),
                    TotalValidBetValue = sum.Sum(y => y.TotalValidBetValue),
                    TotalRewardValue = sum.Sum(y => y.TotalRewardValue),
                    TotalOrderValue = sum.Sum(y => y.TotalOrderValue),
                    LoginAccount = sum.FirstOrDefault().LoginAccount,
                    SummaryDate = key.SummaryDate
                }).ToArray();

            }
            else
            {
                R = callResult;
            }
        }
        else
        {
            R = new EWin.Lobby.OrderSummaryResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
        }

        return R;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.OrderSummaryResult GetGameOrderSummaryHistory(string WebSID, string GUID, string QueryBeginDate, string QueryEndDate)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.GetGameOrderSummaryHistory(GetToken(), SI.EWinSID, GUID, QueryBeginDate, QueryEndDate);
        }
        else
        {
            var R = new EWin.Lobby.OrderSummaryResult()
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
    public EWin.Lobby.APIResult CheckPassword(string WebSID, string GUID, int PasswordType, string Password)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.CheckPassword(GetToken(), SI.EWinSID, GUID, (EWin.Lobby.enumPasswordType)PasswordType, Password);
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
    public EWin.Lobby.APIResult SetWalletPassword(string WebSID, string GUID, string LoginPassword, string NewWalletPassword)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.SetWalletPassword(GetToken(), SI.EWinSID, GUID, LoginPassword, NewWalletPassword);
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
    public EWin.Lobby.APIResult SetUserPassword(string WebSID, string GUID, string OldPassword, string NewPassword)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.SetUserPassword(GetToken(), SI.EWinSID, GUID, OldPassword, NewPassword);
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
    public UserAccountThisWeekTotalValidBetValueResult GetUserAccountThisWeekTotalValidBetValueResult(string WebSID, string GUID)
    {
        UserAccountThisWeekTotalValidBetValueResult R;
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.OrderSummaryResult callResult = new EWin.Lobby.OrderSummaryResult();
        List<UserAccountThisWeekTotalValidBetValue> k = new List<UserAccountThisWeekTotalValidBetValue>();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            DateTime currentTime = DateTime.UtcNow.AddHours(09);
            int week = Convert.ToInt32(currentTime.DayOfWeek);
            week = week == 0 ? 7 : week;
            DateTime start;
            DateTime end;

            if (week > 4)
            {
                start = currentTime.AddDays(5 - week);        //這禮拜5
                end = currentTime.AddDays(4 - week + 7);
            }
            else
            {
                start = currentTime.AddDays(5 - week - 7); //上禮拜5
                end = currentTime.AddDays(4 - week);  //這禮拜4
            }


            TimeSpan ts = end.Subtract(start); //兩時間天數相減

            int dayCount = ts.Days + 1; //相距天數

            for (int i = 0; i < dayCount; i++)
            {
                UserAccountThisWeekTotalValidBetValue d = new UserAccountThisWeekTotalValidBetValue();
                d.Date = start.AddDays(i).ToString("yyyy-MM-dd");
                d.TotalValidBetValue = 0;
                d.Status = 0;
                k.Add(d);
            }

            callResult = lobbyAPI.GetGameOrderSummaryHistory(GetToken(), SI.EWinSID, System.Guid.NewGuid().ToString(), start.ToString("yyyy-MM-dd 00:00:00"), end.ToString("yyyy-MM-dd 00:00:00"));

            if (callResult.Result == EWin.Lobby.enumResult.OK)
            {

                var GameOrderList = callResult.SummaryList.GroupBy(x => new { x.CurrencyType, x.SummaryDate }, x => x, (key, sum) => new EWin.Lobby.OrderSummary
                {
                    TotalValidBetValue = sum.Sum(y => y.ValidBetValue),
                    CurrencyType = key.CurrencyType,
                    SummaryDate = key.SummaryDate
                }).ToList();

                for (int i = 0; i < k.Count; i++)
                {
                    for (int j = 0; j < GameOrderList.Count; j++)
                    {
                        if (k[i].Date == GameOrderList[j].SummaryDate)
                        {
                            k[i].TotalValidBetValue = GameOrderList[j].TotalValidBetValue;
                            if (GameOrderList[j].TotalValidBetValue > 20000 || GameOrderList[j].TotalValidBetValue == 20000)
                            {
                                k[i].Status = 1;
                            }
                        }
                    }
                }

                R = new UserAccountThisWeekTotalValidBetValueResult()
                {
                    Result = EWin.Lobby.enumResult.OK,
                    Datas = k,
                    GUID = GUID
                };
            }
            else
            {
                R = new UserAccountThisWeekTotalValidBetValueResult()
                {
                    Result = EWin.Lobby.enumResult.ERR,
                    Message = "NotEligible",
                    GUID = GUID
                };
            }
        }
        else
        {
            R = new UserAccountThisWeekTotalValidBetValueResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "EMailNotFind",
                GUID = GUID
            };
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetUserPasswordByValidateCode(string GUID, string LoginAccount, int ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, string ValidateCode, string NewPassword)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.FANTA.FANTA fantaAPI = new EWin.FANTA.FANTA();
        EWin.Lobby.APIResult R;
        EWin.FANTA.APIResult R2;
        R2 = fantaAPI.SetUserPasswordByValidateCode(GetToken(), LoginAccount, GUID, (EWin.FANTA.enumValidateType)ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, ValidateCode, NewPassword);

        if (R2.ResultState == EWin.FANTA.enumResultState.OK)
        {
            R = new EWin.Lobby.APIResult()
            {
                Result = EWin.Lobby.enumResult.OK,
                Message = "",
                GUID = GUID
            };
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

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetWalletPasswordByValidateCode(string WebSID, string GUID, int ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, string ValidateCode, string NewPassword)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.FANTA.FANTA fantaAPI = new EWin.FANTA.FANTA();
        RedisCache.SessionContext.SIDInfo SI;
        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);
        EWin.Lobby.APIResult R;
        EWin.FANTA.APIResult R2;
        string Token = GetToken();
        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            var UserInfoResult = lobbyAPI.GetUserInfo(Token, SI.EWinSID, GUID);
            if (UserInfoResult.Result == EWin.Lobby.enumResult.OK)
            {
                R2 = fantaAPI.SetWalletPasswordByValidateCode(Token, UserInfoResult.LoginAccount, (EWin.FANTA.enumValidateType)ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, ValidateCode, NewPassword);

                if (R2.ResultState == EWin.FANTA.enumResultState.OK)
                {
                    R = lobbyAPI.SetUserAccountProperty(GetToken(), GUID, EWin.Lobby.enumUserTypeParam.BySID, SI.EWinSID, "IsSetWalletPassword", "true");
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
            }
            else
            {
                R = new EWin.Lobby.APIResult()
                {
                    Result = EWin.Lobby.enumResult.ERR,
                    Message = "InvalidWebSID",
                    GUID = GUID
                };
            }
        }
        else
        {
            R = new EWin.Lobby.APIResult()
            {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.ValidateCodeResult SetValidateCode(string GUID, EWin.Lobby.enumValidateType ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.SetValidateCodeOnlyNumber(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetValidateCodeByMail(string GUID, EWin.Lobby.enumValidateType ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, CodingControl.enumSendMailType SendMailType)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.ValidateCodeResult validateCodeResult;
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult() { GUID = GUID, Result = EWin.Lobby.enumResult.ERR };

        validateCodeResult = lobbyAPI.SetValidateCodeOnlyNumber(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber);

        if (validateCodeResult.Result == EWin.Lobby.enumResult.OK)
        {
            R = SendMail(EMail, validateCodeResult.ValidateCode, R, SendMailType);
        }
        else
        {
            R.Result = validateCodeResult.Result;
            R.Message = validateCodeResult.Message;
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CheckValidateCode(string GUID, EWin.Lobby.enumValidateType ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, string ValidateCode)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.CheckValidateCode(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, ValidateCode);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.PaymentResult GetPaymentHistory(string WebSID, string GUID, string BeginDate, string EndDate)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return lobbyAPI.GetPaymentHistory(GetToken(), SI.EWinSID, GUID, BeginDate, EndDate);
        }
        else
        {
            var R = new EWin.Lobby.PaymentResult()
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
    public EWin.Lobby.CompanyExchangeResult GetCompanyExchange(string GUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.GetCompanyExchange(GetToken(), GUID);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult GetWebSiteMaintainStatus()
    {
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult();
        R.Result = EWin.Lobby.enumResult.OK;
        R.Message = "0";
        string Filename;

        Filename = HttpContext.Current.Server.MapPath("/App_Data/Setting.json");

        if (System.IO.File.Exists(Filename))
        {
            string SettingContent;

            SettingContent = System.IO.File.ReadAllText(Filename);

            if (string.IsNullOrEmpty(SettingContent) == false)
            {
                try
                {
                    Newtonsoft.Json.Linq.JObject o = Newtonsoft.Json.Linq.JObject.Parse(SettingContent);
                    int mainTain = (int)o["InMaintenance"];

                    if (mainTain == 1)
                    {
                        R.Message = "1";
                    }
                }
                catch (Exception ex) { }
            }
        }

        return R;
    }

    private EWin.Lobby.APIResult SendMail(string EMail, string ValidateCode, EWin.Lobby.APIResult result, CodingControl.enumSendMailType SendMailType) {
        string Subject = string.Empty;
        string SendBody = string.Empty;
        string apiURL = "https://mail.surenotifyapi.com/v1/messages";
        string apiKey = "NDAyODgxNDM4MGJiZTViMjAxODBkYjZjMmRjYzA3NDgtMTY1NDE0Mzc1NC0x";
        Subject = "Verify Code";

        SendBody = CodingControl.GetEmailTemp(EMail, ValidateCode, SendMailType);

        try {
            Newtonsoft.Json.Linq.JObject objBody = new Newtonsoft.Json.Linq.JObject();
            Newtonsoft.Json.Linq.JObject objRecipients = new Newtonsoft.Json.Linq.JObject();
            Newtonsoft.Json.Linq.JArray aryRecipients = new Newtonsoft.Json.Linq.JArray();

            objBody.Add("subject", Subject);
            objBody.Add("fromName", "マハラジャ");
            objBody.Add("fromAddress", "edm@casino-maharaja.com");
            objBody.Add("content", SendBody);

            objRecipients.Add("name", EMail);
            objRecipients.Add("address", EMail);
            aryRecipients.Add(objRecipients);

            objBody.Add("recipients", aryRecipients);

            CodingControl.GetWebTextContent(apiURL, "POST", objBody.ToString(), "x-api-key:" + apiKey, "application/json", System.Text.Encoding.UTF8);
            result.Result = EWin.Lobby.enumResult.OK;
            result.Message = "";

        } catch (Exception ex) {
            result.Result = EWin.Lobby.enumResult.ERR;
            result.Message = "";
        }
        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetUserMail(string GUID, EWin.Lobby.enumValidateType ValidateType, CodingControl.enumSendMailType SendMailType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, string ReceiveRegisterRewardURL) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.ValidateCodeResult validateCodeResult;
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult() { GUID = GUID, Result = EWin.Lobby.enumResult.ERR };
        string ValidateCode = string.Empty;
        TelPhoneNormalize telPhoneNormalize = new TelPhoneNormalize(ContactPhonePrefix, ContactPhoneNumber);
        if (telPhoneNormalize != null) {
            ContactPhonePrefix = telPhoneNormalize.PhonePrefix;
            ContactPhoneNumber = telPhoneNormalize.PhoneNumber;
        }

        switch (SendMailType) {
            case CodingControl.enumSendMailType.Register:
                validateCodeResult = lobbyAPI.SetValidateCodeOnlyNumber(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber);
                if (validateCodeResult.Result == EWin.Lobby.enumResult.OK) {
                    ValidateCode = validateCodeResult.ValidateCode;
                }
                break;
            case CodingControl.enumSendMailType.ForgetPassword:
                validateCodeResult = lobbyAPI.SetValidateCodeOnlyNumber(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber);
                if (validateCodeResult.Result == EWin.Lobby.enumResult.OK) {
                    ValidateCode = validateCodeResult.ValidateCode;
                }
                break;
            case CodingControl.enumSendMailType.ThanksLetter:

                break;
        }

        switch (ValidateType) {
            case EWin.Lobby.enumValidateType.EMail:
                R = SendMail(EMail, ValidateCode, R, SendMailType);
                break;
            case EWin.Lobby.enumValidateType.PhoneNumber:
                string smsContent = "Your Lucky Sprite OTP code is " + ValidateCode;
                R = SendSMS(GUID, "0", 0, ContactPhonePrefix + ContactPhoneNumber, smsContent);
                break;
            default:
                break;
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SendSMS(string GUID, string SMSTypeCode, int RecvUserAccountID, string ContactNumber, string SendContent)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult() { GUID = GUID, Result = EWin.Lobby.enumResult.ERR };
        string ValidateCode = string.Empty;

        R = lobbyAPI.SendSMS(GetToken(), GUID, SMSTypeCode, RecvUserAccountID, "LuckySprite", ContactNumber, SendContent);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.PaymentResult CreatePayment(string WebSID, string GUID, decimal Value, int PaymentMethodID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            return null;
        }
        else
        {
            var R = new EWin.Lobby.PaymentResult()
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
    public OcwBulletinBoardResult GetBulletinBoard(string GUID)
    {

        OcwBulletinBoardResult R = new OcwBulletinBoardResult() { Datas = new List<OcwBulletinBoard>(), Result = EWin.Lobby.enumResult.ERR };
        System.Data.DataTable DT;
        RedisCache.SessionContext.SIDInfo SI;

        DT = RedisCache.BulletinBoard.GetBulletinBoard();
        if (DT != null && DT.Rows.Count > 0)
        {
            for (int i = 0; i < DT.Rows.Count; i++)
            {
                var data = new OcwBulletinBoard();
                if ((int)DT.Rows[i]["State"] == 0)
                {
                    data.BulletinBoardID = (int)DT.Rows[i]["BulletinBoardID"];
                    data.BulletinTitle = (string)DT.Rows[i]["BulletinTitle"];
                    data.BulletinContent = (string)DT.Rows[i]["BulletinContent"];
                    data.CreateDate = (DateTime)DT.Rows[i]["CreateDate"];
                    data.State = (int)DT.Rows[i]["State"];
                    R.Datas.Add(data);
                }
            }

            if (R.Datas.Count > 0)
            {
                R.Result = (int)EWin.Lobby.enumResult.OK;
                R.Datas = R.Datas.OrderByDescending(x => x.CreateDate).ToList();
            }
            else
            {
                R.Result = EWin.Lobby.enumResult.ERR;
                R.Message = "NoData";
            }
        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "NoData";
        }


        return R;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CreateBigEagle(string LoginAccount)
    {
        EWin.OCW.OCW OCWAPI = new EWin.OCW.OCW();
        EWin.OCW.APIResult OcwAPIResult = OCWAPI.CreateBigEagle(LoginAccount);
        EWin.Lobby.APIResult result = new EWin.Lobby.APIResult();

        if (OcwAPIResult.ResultState == EWin.OCW.enumResultState.OK)
        {
            result.Result = EWin.Lobby.enumResult.OK;
        }
        else
        {
            result.Result = EWin.Lobby.enumResult.ERR;
            result.Message = OcwAPIResult.Message;
        }

        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult UpdateUserAccount(string WebSID, string GUID, EWin.OCW.UserAccount UserInfo)
    {
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult();
        EWin.OCW.APIResult OcwAPIResult = new EWin.OCW.APIResult();
        EWin.OCW.OCW OCWAPI = new EWin.OCW.OCW();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            OcwAPIResult = OCWAPI.UpdateUserAccount(GetToken(), SI.EWinSID, GUID, UserInfo);

            if (OcwAPIResult.ResultState == EWin.OCW.enumResultState.OK)
            {
                R.Result = EWin.Lobby.enumResult.OK;
            }
            else
            {
                R.Message = OcwAPIResult.Message;
                R.Result = EWin.Lobby.enumResult.ERR;
            }
        }
        else
        {
            R.Message = "InvalidWebSID";
            R.Result = EWin.Lobby.enumResult.ERR;
        }
        return R;
    }

    #region 領取專區

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CollectUserAccountPromotion(string WebSID, string GUID, int CollectID, string Description)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.FANTA.FANTA fantaAPI = new EWin.FANTA.FANTA();
        List<EWin.FANTA.VipBuyChipRateSetting> ThresholdAddRateSetting = new List<EWin.FANTA.VipBuyChipRateSetting>();
        RedisCache.SessionContext.SIDInfo SI;
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult() { Result = EWin.Lobby.enumResult.ERR };
        string Token = GetToken();
        int CollectLimit = 100;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            var PromotionCollectResult = lobbyAPI.GetPromotionCollectAvailable(Token, SI.EWinSID, GUID);

            if (PromotionCollectResult.Result == EWin.Lobby.enumResult.OK)
            {
                var Collect = PromotionCollectResult.CollectList.Where(x => x.CollectID == CollectID).FirstOrDefault();
                var UserInfoResult = lobbyAPI.GetUserInfo(Token, SI.EWinSID, GUID);
                if (UserInfoResult.Result == EWin.Lobby.enumResult.OK)
                {
                    var Wallet = UserInfoResult.WalletList.Where(x => x.CurrencyType == EWinWeb.MainCurrencyType).FirstOrDefault();

                    decimal OldThresholdValue = 0.0M;
                    if (UserInfoResult.ThresholdInfo.Length > 0)
                    {
                        OldThresholdValue = UserInfoResult.ThresholdInfo[0].ThresholdValue;
                    }

                    if (Collect != null)
                    {
                        EWin.Lobby.APIResult CollecResult;

                        if (Collect.CollectAreaType == 2)
                        {

                            CollecResult = lobbyAPI.CollectUserAccountPromotion(Token, SI.EWinSID, GUID, CollectID);

                            if (CollecResult.Result == EWin.Lobby.enumResult.OK)
                            {

                                string JoinActivityCycle = "1";
                                Newtonsoft.Json.Linq.JObject actioncontent = Newtonsoft.Json.Linq.JObject.Parse(Collect.ActionContent);

                                if (actioncontent["ActionList"] != null)
                                {
                                    Newtonsoft.Json.Linq.JArray actionlist = Newtonsoft.Json.Linq.JArray.Parse(actioncontent["ActionList"].ToString());

                                    foreach (var item in actionlist)
                                    {
                                        if (item["Field"].ToString() == "JoinActivityCycle")
                                        {
                                            JoinActivityCycle = item["Value"].ToString();
                                        }
                                    }
                                }

                                EWinWebDB.UserAccountEventSummary.UpdateUserAccountEventSummary(SI.LoginAccount, Collect.Description, JoinActivityCycle, 0, 0, 0);
                                R.Result = EWin.Lobby.enumResult.OK;
                            }
                            else
                            {
                                lobbyAPI.AddThreshold(Token, GUID, System.Guid.NewGuid().ToString(), SI.LoginAccount, EWinWeb.MainCurrencyType, OldThresholdValue, "Undo ResetCollectPromotion. CollectID=" + CollectID.ToString(), true);
                                R.Result = EWin.Lobby.enumResult.ERR;
                                R.Message = "Collect Failure";
                            }
                        }
                        else
                        {

                            if (Wallet.PointValue <= CollectLimit)
                            {
                                var ResetResult = lobbyAPI.AddThreshold(Token, System.Guid.NewGuid().ToString(), System.Guid.NewGuid().ToString(), SI.LoginAccount, EWinWeb.MainCurrencyType, 0, "ResetCollettPromotion. CollectID=" + CollectID.ToString(), true);

                                if (ResetResult.Result == EWin.Lobby.enumResult.OK)
                                {
                                    OldThresholdValue = 0;
                                }
                                else
                                {
                                    R.Result = EWin.Lobby.enumResult.ERR;
                                    R.Message = "Reset Failure : " + ResetResult.Message;
                                }
                            }

                            EWin.Lobby.UserAccountPropertyResult UP = GetUserAccountProperty(WebSID, GUID, "JoinActivity");

                            if (OldThresholdValue == 0 || (UP.Result == EWin.Lobby.enumResult.ERR && UP.Message == "NoExist"))
                            {

                                CollecResult = lobbyAPI.CollectUserAccountPromotion(Token, SI.EWinSID, GUID, CollectID);

                                if (CollecResult.Result == EWin.Lobby.enumResult.OK)
                                {
                                    //領取Bouns要加上只能遊玩電子遊戲的限制
                                    string[] GameAccountingCodeBanList = { "Live", "Sport" };
                                    lobbyAPI.SetGameAcl(Token, SI.EWinSID, System.Guid.NewGuid().ToString(), EWin.Lobby.enumGameAclType.GameAccountingCode, GameAccountingCodeBanList, "Receive Bonus. CollectID=" + CollectID.ToString());

                                    string JoinActivityCycle = "1";
                                    decimal ThresholdValue = 0;
                                    decimal PointValue = 0;
                                    Newtonsoft.Json.Linq.JObject actioncontent = Newtonsoft.Json.Linq.JObject.Parse(Collect.ActionContent);

                                    if (actioncontent["ActionList"] != null)
                                    {
                                        Newtonsoft.Json.Linq.JArray actionlist = Newtonsoft.Json.Linq.JArray.Parse(actioncontent["ActionList"].ToString());

                                        foreach (var item in actionlist)
                                        {
                                            if (item["Field"].ToString() == "JoinActivityCycle")
                                            {
                                                JoinActivityCycle = item["Value"].ToString();
                                            }
                                            if (item["Field"].ToString() == "ThresholdValue")
                                            {
                                                ThresholdValue = decimal.Parse(item["Value"].ToString());
                                            }
                                            if (item["Field"].ToString() == "PointValue")
                                            {
                                                PointValue = decimal.Parse(item["Value"].ToString());
                                            }
                                        }
                                    }

                                    dynamic o = new System.Dynamic.ExpandoObject();
                                    o.ActivityName = Collect.Description;
                                    o.ThresholdValue = ThresholdValue;
                                    o.PointValue = PointValue;

                                    lobbyAPI.SetUserAccountProperty(GetToken(), GUID, EWin.Lobby.enumUserTypeParam.ByLoginAccount, SI.LoginAccount, "JoinActivity", Newtonsoft.Json.JsonConvert.SerializeObject(o));

                                    //檢查該活動是否有門檻扣除遊戲限制
                                    var getActivityResult = ActivityCore.GetActInfo(Description);

                                    if (getActivityResult.Result == ActivityCore.enumActResult.OK)
                                    {
                                        string DetailPath = getActivityResult.Data.DetailPath;

                                        if (!string.IsNullOrEmpty(DetailPath))
                                        {
                                            Newtonsoft.Json.Linq.JObject ActivitySetting = GetActivityDetail(DetailPath);

                                            if (ActivitySetting != null)
                                            {

                                                if (ActivitySetting["ThresholdAddRate"] != null)
                                                {
                                                    Newtonsoft.Json.Linq.JArray TH = Newtonsoft.Json.Linq.JArray.Parse(ActivitySetting["ThresholdAddRate"].ToString());
                                                    string GameAccountingCode = string.Empty;

                                                    if (TH.Count > 0)
                                                    {
                                                        ThresholdAddRateSetting = TH.ToObject<List<EWin.FANTA.VipBuyChipRateSetting>>();

                                                        fantaAPI.UpdateThresholdAddRate(GetToken(), SI.LoginAccount, ThresholdAddRateSetting.ToArray());
                                                        lobbyAPI.SetUserAccountProperty(GetToken(), GUID, EWin.Lobby.enumUserTypeParam.ByLoginAccount, SI.LoginAccount, "JoinHasThresholdAddRateActivity", "true");
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    EWinWebDB.UserAccountEventSummary.UpdateUserAccountEventSummary(SI.LoginAccount, Collect.Description, JoinActivityCycle, 0, 0, 0);
                                    R.Result = EWin.Lobby.enumResult.OK;
                                }
                                else
                                {
                                    lobbyAPI.AddThreshold(Token, GUID, System.Guid.NewGuid().ToString(), SI.LoginAccount, EWinWeb.MainCurrencyType, OldThresholdValue, "Undo ResetCollectPromotion. CollectID=" + CollectID.ToString(), true);
                                    R.Result = EWin.Lobby.enumResult.ERR;
                                    R.Message = "Collect Failure";
                                }
                            }
                            else
                            {
                                R.Result = EWin.Lobby.enumResult.ERR;
                                R.Message = "Mismatch Condition";
                            }

                        }
                    }
                    else
                    {
                        R.Message = "Not Search CollectID";
                        R.Result = EWin.Lobby.enumResult.ERR;
                    }

                }
                else
                {
                    R.Result = EWin.Lobby.enumResult.ERR;
                    R.Message = UserInfoResult.Message;
                }
            }
            else
            {
                R.Message = "Not Search CollectID";
                R.Result = EWin.Lobby.enumResult.ERR;
            }
        }
        else
        {
            R.Message = "InvalidWebSID";
            R.Result = EWin.Lobby.enumResult.ERR;
        }
        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public OcwPromotionCollectHistoryResult GetPromotionCollectHistory(string WebSID, string GUID, string BeginDate, string EndDate)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;
        OcwPromotionCollectHistoryResult R = new OcwPromotionCollectHistoryResult() { CollectList = null, QueryBeginDate = BeginDate, QueryEndDate = EndDate, Result = EWin.Lobby.enumResult.ERR };

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            EWin.Lobby.PromotionCollectHistoryResult EWinReturn = lobbyAPI.GetPromotionCollectHistory(GetToken(), SI.EWinSID, GUID, DateTime.Parse(BeginDate), DateTime.Parse(EndDate));

            if (EWinReturn.Result == EWin.Lobby.enumResult.OK)
            {
                List<OcwPromotionCollect> collectList = new List<OcwPromotionCollect>();

                foreach (var item in EWinReturn.CollectList)
                {
                    OcwPromotionCollect PC = new OcwPromotionCollect()
                    {

                        CollectID = item.CollectID,
                        CurrencyType = item.CurrencyType,
                        PromotionID = item.PromotionID,
                        PromotionDetailID = item.PromotionDetailID,
                        CollectAreaType = item.CollectAreaType,
                        Status = (OcwPromotionCollect.OcwEnumStatus)item.Status,
                        Description = item.Description,
                        ActionContent = item.ActionContent,
                        ExpireDate = item.ExpireDate,
                        CollectDate = item.CollectDate,
                        CreateDate = item.CreateDate
                    };

                    if (!string.IsNullOrEmpty(PC.ActionContent))
                    {
                        var obj_ActionContent = Newtonsoft.Json.Linq.JObject.Parse(PC.ActionContent);

                        List<OcwActionContentSet> actions = Newtonsoft.Json.JsonConvert.DeserializeObject<List<OcwActionContentSet>>(obj_ActionContent["ActionList"].ToString());

                        PC.PointValue = 0;

                        for (int i = 0; i < actions.Count; i++)
                        {
                            if (actions[i].Field == "PointValue")
                            {
                                PC.PointValue = decimal.Parse(actions[i].Value);
                            }
                        }
                    }

                    if (!string.IsNullOrEmpty(PC.Description))
                    {
                        var getTitleResult = ActivityCore.GetActInfo(PC.Description);

                        if (getTitleResult.Result == ActivityCore.enumActResult.OK)
                        {
                            PC.PromotionTitle = getTitleResult.Data.Title;
                        }

                        //if (string.IsNullOrEmpty(PC.PromotionTitle)) {
                        //        PC.PromotionTitle = PC.Description;
                        //}
                    }

                    collectList.Add(PC);

                }

                var UserInfoResult = lobbyAPI.GetUserInfo(GetToken(), SI.EWinSID, GUID);

                if (UserInfoResult.Result == EWin.Lobby.enumResult.OK)
                {
                    var Wallet = UserInfoResult.WalletList.Where(x => x.CurrencyType == EWinWeb.MainCurrencyType).FirstOrDefault();

                    decimal ThresholdValue = 0.0M;
                    if (UserInfoResult.ThresholdInfo.Length > 0)
                    {
                        ThresholdValue = UserInfoResult.ThresholdInfo[0].ThresholdValue;
                    }

                    if (ThresholdValue == 0)
                    {
                        lobbyAPI.RemoveUserAccountProperty(GetToken(), GUID, EWin.Lobby.enumUserTypeParam.ByLoginAccount, SI.LoginAccount, "JoinActivity");
                    }

                }

                R.Result = EWin.Lobby.enumResult.OK;
                R.CollectList = collectList.ToArray();

            }
            else
            {
                R.Result = EWin.Lobby.enumResult.ERR;
                R.Message = "NoData";
            }
        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "InvalidWebSID";
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public OcwPromotionCollectResult GetPromotionCollectAvailable(string WebSID, string GUID)
    {

        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;
        int RegisterBounsID = 0;
        System.Data.DataTable DT;
        OcwPromotionCollectResult R = new OcwPromotionCollectResult() { CollectList = null, Result = EWin.Lobby.enumResult.ERR };

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            EWin.Lobby.PromotionCollectResult EWinReturn = lobbyAPI.GetPromotionCollectAvailable(GetToken(), SI.EWinSID, GUID);

            if (EWinReturn.Result == EWin.Lobby.enumResult.OK)
            {
                List<OcwPromotionCollect> collectList = new List<OcwPromotionCollect>();

                foreach (var item in EWinReturn.CollectList)
                {

                    if (item.Description == "RegisterBouns")
                    {
                        RegisterBounsID = item.CollectID;
                    }

                    OcwPromotionCollect PC = new OcwPromotionCollect()
                    {

                        CollectID = item.CollectID,
                        CurrencyType = item.CurrencyType,
                        PromotionID = item.PromotionID,
                        PromotionDetailID = item.PromotionDetailID,
                        CollectAreaType = item.CollectAreaType,
                        Status = (OcwPromotionCollect.OcwEnumStatus)item.Status,
                        Description = item.Description,
                        ActionContent = item.ActionContent,
                        ExpireDate = item.ExpireDate,
                        CollectDate = item.CollectDate,
                        CreateDate = item.CreateDate
                    };

                    if (!string.IsNullOrEmpty(PC.ActionContent))
                    {
                        var obj_ActionContent = Newtonsoft.Json.Linq.JObject.Parse(PC.ActionContent);

                        List<OcwActionContentSet> actions = Newtonsoft.Json.JsonConvert.DeserializeObject<List<OcwActionContentSet>>(obj_ActionContent["ActionList"].ToString());

                        PC.PointValue = 0;

                        for (int i = 0; i < actions.Count; i++)
                        {
                            if (actions[i].Field == "PointValue")
                            {
                                PC.PointValue = decimal.Parse(actions[i].Value);
                            }
                        }
                    }

                    if (!string.IsNullOrEmpty(PC.Description))
                    {
                        var getTitleResult = ActivityCore.GetActInfo(PC.Description);

                        if (getTitleResult.Result == ActivityCore.enumActResult.OK)
                        {
                            PC.PromotionTitle = getTitleResult.Data.Title;
                        }

                        //if (string.IsNullOrEmpty(PC.PromotionTitle)) {
                        //    PC.PromotionTitle = PC.Description;
                        //}
                    }

                    collectList.Add(PC);

                }

                if (RegisterBounsID != 0)
                {
                    DT = EWinWebDB.UserAccountPayment.GetPaymentInfoByLoginAccount(SI.LoginAccount, 0, 2);

                    if (DT != null && DT.Rows.Count > 0)
                    {
                        EWin.Lobby.APIResult k = lobbyAPI.SetExpireUserAccountPromotionByID(GetToken(), SI.EWinSID, GUID, RegisterBounsID);
                        if (k.Result == EWin.Lobby.enumResult.OK)
                        {
                            var itemToRemove = collectList.Single(r => r.CollectID == RegisterBounsID);
                            collectList.Remove(itemToRemove);
                        }
                    }
                }

                R.Result = EWin.Lobby.enumResult.OK;
                R.CollectList = collectList.OrderByDescending(o => o.CreateDate).ToArray();

            }
            else
            {
                R.Result = EWin.Lobby.enumResult.ERR;
                R.Message = "NoData";
            }
        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "InvalidWebSID";
        }

        return R;
    }

    #endregion

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public UserTwoMonthSummaryResult GetUserTwoMonthSummaryData(string WebSID, string GUID)
    {
        EWin.OCW.OCW OCWAPI = new EWin.OCW.OCW();
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;
        UserTwoMonthSummaryResult R = new UserTwoMonthSummaryResult() { PaymentResult = null, GameResult = null, Result = EWin.Lobby.enumResult.ERR };
        System.Data.DataTable PaymentDT;
        EWin.Lobby.OrderSummaryResult GameRet = new EWin.Lobby.OrderSummaryResult();
        List<UserTwoMonthSummaryResult.Payment> PaymentResult = new List<UserTwoMonthSummaryResult.Payment>();
        UserTwoMonthSummaryResult.Payment P = new UserTwoMonthSummaryResult.Payment();
        List<UserTwoMonthSummaryResult.Game> GameResult = new List<UserTwoMonthSummaryResult.Game>();
        UserTwoMonthSummaryResult.Game G = new UserTwoMonthSummaryResult.Game();

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            var pre = DateTime.Now.AddMonths(-1).ToString("yyyy-MM") + "-01";
            var now = DateTime.Now.ToString("yyyy-MM") + "-01";
            var next = DateTime.Now.AddMonths(1).ToString("yyyy-MM") + "-01";

            for (int i = 0; i < 2; i++)
            {
                PaymentDT = null;
                GameRet = new EWin.Lobby.OrderSummaryResult();
                if (i == 0)
                {
                    PaymentDT = EWinWebDB.UserAccountSummary.GetUserAccountPaymentSummaryData(SI.LoginAccount, pre, now);
                    GameRet = lobbyAPI.GetGameOrderSummaryHistory(GetToken(), SI.EWinSID, GUID, pre, now);
                }
                else
                {
                    PaymentDT = EWinWebDB.UserAccountSummary.GetUserAccountPaymentSummaryData(SI.LoginAccount, now, next);
                    GameRet = lobbyAPI.GetGameOrderSummaryHistory(GetToken(), SI.EWinSID, GUID, now, next);
                }

                if (PaymentDT != null)
                {
                    if (PaymentDT.Rows.Count > 0)
                    {
                        P = new UserTwoMonthSummaryResult.Payment();
                        P.SortIndex = i;
                        P.DepositAmount = (decimal)PaymentDT.Rows[0]["DepositAmount"];
                        P.WithdrawalAmount = (decimal)PaymentDT.Rows[0]["WithdrawalAmount"];
                    }
                    else
                    {
                        P = new UserTwoMonthSummaryResult.Payment();
                        P.SortIndex = i;
                        P.DepositAmount = 0;
                        P.WithdrawalAmount = 0;
                    }
                }
                else
                {
                    P = new UserTwoMonthSummaryResult.Payment();
                    P.SortIndex = i;
                    P.DepositAmount = 0;
                    P.WithdrawalAmount = 0;
                }

                PaymentResult.Add(P);

                if (GameRet.Result == EWin.Lobby.enumResult.OK)
                {
                    if (GameRet.SummaryList.Length > 0)
                    {
                        G = GameRet.SummaryList.GroupBy(x => new { x.LoginAccount }, x => x, (key, sum) => new UserTwoMonthSummaryResult.Game
                        {
                            ValidBetValue = sum.Sum(y => y.ValidBetValue),
                            RewardValue = sum.Sum(y => y.RewardValue),
                            OrderValue = sum.Sum(y => y.OrderValue),
                            SortIndex = i
                        }).ToList().FirstOrDefault();
                    }
                    else
                    {
                        G = new UserTwoMonthSummaryResult.Game();
                        G.SortIndex = i;
                        G.OrderValue = 0;
                        G.ValidBetValue = 0;
                        G.RewardValue = 0;
                    }
                }
                else
                {
                    G = new UserTwoMonthSummaryResult.Game();
                    G.SortIndex = i;
                    G.OrderValue = 0;
                    G.ValidBetValue = 0;
                    G.RewardValue = 0;
                }
                GameResult.Add(G);
            }

            R.Result = EWin.Lobby.enumResult.OK;
            R.PaymentResult = PaymentResult;
            R.GameResult = GameResult;
        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "InvalidWebSID";
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.GameBrandResult GetGameBrand(string GUID)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        var a = lobbyAPI.GetGameBrand(GetToken(), GUID);
        return a;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.DocumentListResult CheckDocumentByTagName(string GUID, string TagName)
    {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        var a = lobbyAPI.CheckDocumentByTagName(GetToken(), GUID, TagName);
        return a;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public UserAccountTotalSummaryResult GetTotalSummaryBySID(string WebSID, string GUID)
    {
        UserAccountTotalSummaryResult R = new UserAccountTotalSummaryResult() { Datas = new List<UserAccountTotalSummary>(), Result = EWin.Lobby.enumResult.ERR, GUID = GUID };
        System.Data.DataTable DT;
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {

            DT = RedisCache.UserAccount.GetUserAccountByLoginAccount(SI.LoginAccount);

            if (DT != null && DT.Rows.Count > 0)
            {
                for (int i = 0; i < DT.Rows.Count; i++)
                {
                    var data = new UserAccountTotalSummary();

                    data.LoginAccount = (string)DT.Rows[i]["LoginAccount"];
                    data.DepositCount = (int)DT.Rows[i]["DepositCount"];
                    data.DepositRealAmount = (decimal)DT.Rows[i]["DepositRealAmount"];
                    data.DepositAmount = (decimal)DT.Rows[i]["DepositAmount"];
                    data.WithdrawalCount = (int)DT.Rows[i]["WithdrawalCount"];
                    data.WithdrawalRealAmount = (decimal)DT.Rows[i]["WithdrawalRealAmount"];
                    data.WithdrawalAmount = (decimal)DT.Rows[i]["WithdrawalAmount"];
                    data.LastDepositDate = (DateTime)DT.Rows[i]["LastDepositDate"];
                    data.LastWithdrawalDate = (DateTime)DT.Rows[i]["LastWithdrawalDate"];
                    data.FingerPrints = (string)DT.Rows[i]["FingerPrints"];
                    R.Datas.Add(data);

                }
            }

            if (R.Datas.Count > 0)
            {
                R.Result = (int)EWin.Lobby.enumResult.OK;
            }
            else
            {
                R.Result = EWin.Lobby.enumResult.ERR;
                R.Message = "NoData";
            }
        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "InvalidWebSID";
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public UserVIPResult GetUserVIPData(string WebSID, string GUID)
    {
        UserVIPResult R = new UserVIPResult() { Result = EWin.Lobby.enumResult.ERR, Data = new UserVIPResult.UserVIPInfo() };
        UserVIPResult.UserVIPInfo k = new UserVIPResult.UserVIPInfo();
        RedisCache.SessionContext.SIDInfo SI;
        EWin.FANTA.FANTA api = new EWin.FANTA.FANTA();
        System.Data.DataTable UserLevDT = new System.Data.DataTable();
        System.Data.DataTable DT = new System.Data.DataTable();
        EWin.FANTA.APIResult R1 = new EWin.FANTA.APIResult();
        Newtonsoft.Json.Linq.JObject VIPSetting;
        Newtonsoft.Json.Linq.JArray VIPSettingDetail;
        int UserLevelIndex = 0;
        int UserNextLevelIndex = 0;
        int KeepLevelDays = 30;
        int Setting_UserLevelIndex = 0;
        decimal DeposiAmount = 0;
        decimal ValidBetValue = 0;
        DateTime UserLevelUpdateDate = DateTime.Now;
        string RedisVIPInfo = string.Empty;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {

            RedisVIPInfo = RedisCache.UserAccountVIPInfo.GetUserAccountVIPInfo(SI.LoginAccount);

            if (string.IsNullOrEmpty(RedisVIPInfo))
            {
                VIPSetting = GetActivityDetail("../App_Data/VIPSetting.json");

                if (VIPSetting != null)
                {
                    VIPSettingDetail = Newtonsoft.Json.Linq.JArray.Parse(VIPSetting["VIPSetting"].ToString());
                    KeepLevelDays = (int)VIPSetting["KeepLevelDays"];

                    UserLevDT = RedisCache.UserAccount.GetUserAccountByLoginAccount(SI.LoginAccount);
                    if (UserLevDT != null)
                    {
                        if (UserLevDT.Rows.Count > 0)
                        {
                            UserLevelIndex = (int)UserLevDT.Rows[0]["UserLevelIndex"];
                            UserLevelUpdateDate = (DateTime)UserLevDT.Rows[0]["UserLevelUpdateDate"];
                            DeposiAmount = (decimal)UserLevDT.Rows[0]["UserLevelAccumulationDepositAmount"];
                            ValidBetValue = (decimal)UserLevDT.Rows[0]["UserLevelAccumulationValidBetValue"];
                        }
                    }

                    UserNextLevelIndex = UserLevelIndex + 1;

                    for (int i = UserLevelIndex; i < VIPSettingDetail.Count; i++)
                    {
                        Setting_UserLevelIndex = (int)VIPSettingDetail[i]["UserLevelIndex"];

                        //當前等級資訊
                        if (UserLevelIndex == Setting_UserLevelIndex)
                        {
                            k.VIPDescription = (string)VIPSettingDetail[i]["Description"];
                            k.DepositMaxValue = (decimal)VIPSettingDetail[i]["DepositMaxValue"];
                            k.KeepValidBetValue = (decimal)VIPSettingDetail[i]["KeepValidBetValue"];
                            k.ValidBetMaxValue = (decimal)VIPSettingDetail[i]["ValidBetMaxValue"];
                        }

                        if (UserNextLevelIndex == Setting_UserLevelIndex)
                        {
                            k.NextVIPDescription = (string)VIPSettingDetail[i]["Description"];
                        }
                        //已達到最高等級
                        if (UserNextLevelIndex == VIPSettingDetail.Count - 1)
                        {
                            k.NextVIPDescription = (string)VIPSettingDetail[i]["Description"];
                        }
                    }

                    double UserLevelUpdatedays = DateTime.Now.Date.Subtract(UserLevelUpdateDate).TotalDays;

                    k.UserLevelIndex = UserLevelIndex;
                    k.KeepLevelDays = KeepLevelDays;
                    k.ValidBetValue = ValidBetValue;
                    k.DepositValue = DeposiAmount;
                    k.ElapsedDays = (int)UserLevelUpdatedays;

                    R.Data = k;
                    R.Result = EWin.Lobby.enumResult.OK;

                    RedisCache.UserAccountVIPInfo.UpdateUserAccountVIPInfo(Newtonsoft.Json.JsonConvert.SerializeObject(k), SI.LoginAccount);
                }
                else
                {
                    R.Result = EWin.Lobby.enumResult.ERR;
                    R.Message = "InvalidVIPSetting";
                }
            }
            else
            {
                R.Data = Newtonsoft.Json.JsonConvert.DeserializeObject<UserVIPResult.UserVIPInfo>(RedisVIPInfo);
                R.Result = EWin.Lobby.enumResult.OK;
            }
        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "InvalidWebSID";
        }
        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult UserManualUpgradeVipLevel(string WebSID, string GUID)
    {
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult() { Result = EWin.Lobby.enumResult.ERR, Message = "Not eligible for upgrade" };
        RedisCache.SessionContext.SIDInfo SI;
        System.Data.DataTable DT = new System.Data.DataTable();
        System.Data.DataTable UserDT = new System.Data.DataTable();
        Newtonsoft.Json.Linq.JObject VIPSetting;
        Newtonsoft.Json.Linq.JArray VIPSettingDetail;
        int UserLevelIndex = 0;
        int NewUserLevelIndex = 0;
        string LoginAccount = string.Empty;
        decimal UserLevelAccumulationDepositAmount = 0; //下一級累積入金金額(若有晉級，當前累積要扣除升級所需條件，再更新至資料表中讓使用者繼續累積下一等級)
        decimal UserLevelAccumulationValidBetValue = 0;    //下一級累積有效投注(若有晉級，當前累積要扣除升級所需條件，再更新至資料表中讓使用者繼續累積下一等級)
        decimal DeposiAmount = 0;
        decimal ValidBetValue = 0;
        int Setting_UserLevelIndex = 0;
        decimal Setting_DepositMinValue = 0;
        decimal Setting_DepositMaxValue = 0;
        decimal Setting_ValidBetMinValue = 0;
        decimal Setting_ValidBetMaxValue = 0;
        int DepositLevel = 0;    //儲值符合等級
        int ValidBetLevel = 0;   //流水符合等級
        bool CheckDeposit = true;
        bool CheckValidBet = true;
        List<UserLevelUpgradeTempData> UserLevelUpgradeTempDatas = new List<UserLevelUpgradeTempData>();

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {

            VIPSetting = GetActivityDetail("../App_Data/VIPSetting.json");
            if (VIPSetting != null)
            {
                UserDT = EWinWebDB.UserAccount.GetUserAccount(SI.LoginAccount);

                if (UserDT != null && UserDT.Rows.Count > 0)
                {
                    VIPSettingDetail = Newtonsoft.Json.Linq.JArray.Parse(VIPSetting["VIPSetting"].ToString());
                    foreach (System.Data.DataRow dr in UserDT.Rows)
                    {
                        UserLevelIndex = (int)dr["UserLevelIndex"];
                        LoginAccount = (string)dr["LoginAccount"];
                        UserLevelAccumulationDepositAmount = (decimal)dr["UserLevelAccumulationDepositAmount"];
                        UserLevelAccumulationValidBetValue = (decimal)dr["UserLevelAccumulationValidBetValue"];
                        DeposiAmount = UserLevelAccumulationDepositAmount;
                        ValidBetValue = UserLevelAccumulationValidBetValue;
                        DepositLevel = UserLevelIndex;
                        ValidBetLevel = UserLevelIndex;

                        //最高等時不處理
                        if (UserLevelIndex != VIPSettingDetail.Count - 1)
                        {
                            for (int i = UserLevelIndex + 1; i < VIPSettingDetail.Count; i++)
                            {
                                Setting_UserLevelIndex = (int)VIPSettingDetail[i]["UserLevelIndex"];
                                Setting_DepositMinValue += (decimal)VIPSettingDetail[i]["DepositMinValue"];
                                Setting_DepositMaxValue += (decimal)VIPSettingDetail[i]["DepositMaxValue"];
                                Setting_ValidBetMinValue += (decimal)VIPSettingDetail[i]["ValidBetMinValue"];
                                Setting_ValidBetMaxValue += (decimal)VIPSettingDetail[i]["ValidBetMaxValue"];

                                UserLevelUpgradeTempData k = new UserLevelUpgradeTempData()
                                {
                                    NewLevelIndex = Setting_UserLevelIndex,
                                    DepositMinValue = Setting_DepositMinValue,
                                    ValidBetMinValue = Setting_ValidBetMinValue
                                };

                                UserLevelUpgradeTempDatas.Add(k);

                                if (CheckDeposit)
                                {
                                    if (DeposiAmount >= Setting_DepositMinValue)
                                    {
                                        if (DeposiAmount < Setting_DepositMaxValue)
                                        {
                                            DepositLevel = Setting_UserLevelIndex;
                                            CheckDeposit = false;
                                        }
                                        else
                                        {
                                            DepositLevel = Setting_UserLevelIndex;
                                        }
                                    }
                                    else
                                    {
                                        CheckDeposit = false;
                                    }
                                }

                                if (CheckValidBet)
                                {
                                    if (ValidBetValue >= Setting_ValidBetMinValue)
                                    {
                                        if (ValidBetValue < Setting_ValidBetMaxValue)
                                        {
                                            ValidBetLevel = Setting_UserLevelIndex;
                                            CheckValidBet = false;
                                        }
                                        else
                                        {
                                            ValidBetLevel = Setting_UserLevelIndex;
                                        }
                                    }
                                    else
                                    {
                                        CheckValidBet = false;
                                    }
                                }
                            }

                            if (DepositLevel == ValidBetLevel)
                            {
                                NewUserLevelIndex = DepositLevel;
                            }
                            else if (DepositLevel < ValidBetLevel)
                            {
                                NewUserLevelIndex = DepositLevel;
                            }
                            else
                            {
                                NewUserLevelIndex = ValidBetLevel;
                            }

                            //等級有變動再處裡
                            if (NewUserLevelIndex > UserLevelIndex)
                            {

                                foreach (var item in UserLevelUpgradeTempDatas)
                                {
                                    if (item.NewLevelIndex == NewUserLevelIndex)
                                    {
                                        UserLevelAccumulationDepositAmount = UserLevelAccumulationDepositAmount - item.DepositMinValue;
                                        UserLevelAccumulationValidBetValue = UserLevelAccumulationValidBetValue - item.ValidBetMinValue;
                                    }
                                }

                                //發升級禮物
                                if (NewUserLevelIndex > UserLevelIndex)
                                {
                                    for (int i = 1; i <= NewUserLevelIndex - UserLevelIndex; i++)
                                    {
                                        SendUpgradeGiftByUserLevelIndex(LoginAccount, UserLevelIndex + 1);
                                    }
                                }

                                updateEwinUserLevelInfo(LoginAccount, NewUserLevelIndex);
                                EWinWebDB.UserAccount.UserAccountLevelIndexChange(LoginAccount, 1, UserLevelIndex, NewUserLevelIndex, DeposiAmount, ValidBetValue, UserLevelAccumulationDepositAmount, UserLevelAccumulationValidBetValue, "SystemAutoCheckUserLevel", DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss"));

                                RedisCache.UserAccount.UpdateUserAccountByLoginAccount(LoginAccount);
                                RedisCache.UserAccountVIPInfo.DeleteUserAccountVIPInfo(LoginAccount);

                                R.Message = "Upgrade Success";
                                R.Result = EWin.Lobby.enumResult.OK;
                            }
                            else
                            {
                                R.Message = "Not eligible for upgrade";
                                R.Result = EWin.Lobby.enumResult.ERR;
                            }
                        }
                        else
                        {
                            R.Message = "Not eligible for upgrade";
                            R.Result = EWin.Lobby.enumResult.ERR;
                        }

                    }
                }
            }

        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "InvalidWebSID";
        }
        return R;
    }

    private void SendUpgradeGift(string LoginAccount)
    {
        var UpgradeBonusResult = ActivityCore.GetVIPUpgradeBonusResult(LoginAccount);

        if (UpgradeBonusResult.Result == ActivityCore.enumActResult.OK)
        {
            EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
            List<EWin.Lobby.PropertySet> PropertySets = new List<EWin.Lobby.PropertySet>();
            string CollectAreaType;

            foreach (var activityData in UpgradeBonusResult.Data)
            {

                string description = activityData.ActivityName;
                string JoinActivityCycle = activityData.JoinActivityCycle == null ? "1" : activityData.JoinActivityCycle;
                string PromotionCode = "VIPLev";
                string PromotionCategoryCode = "";
                CollectAreaType = activityData.CollectAreaType == null ? "2" : activityData.CollectAreaType;

                PropertySets.Add(new EWin.Lobby.PropertySet { Name = "ThresholdValue", Value = activityData.ThresholdValue.ToString() });
                PropertySets.Add(new EWin.Lobby.PropertySet { Name = "PointValue", Value = activityData.BonusValue.ToString() });
                PropertySets.Add(new EWin.Lobby.PropertySet { Name = "JoinActivityCycle", Value = JoinActivityCycle.ToString() });

                lobbyAPI.AddPromotionCollect(GetToken(), description + "_" + LoginAccount + "_UpgradeGift", LoginAccount, EWinWeb.MainCurrencyType, PromotionCode, PromotionCategoryCode, int.Parse(CollectAreaType), 90, description, PropertySets.ToArray());
                EWinWebDB.UserAccountEventSummary.UpdateUserAccountEventSummary(LoginAccount, description, JoinActivityCycle, 1, activityData.ThresholdValue, activityData.BonusValue);
            }
        }
    }

    private void SendUpgradeGiftByUserLevelIndex(string LoginAccount, int UserLevelIndex) {
        System.Data.DataTable DT;
        string ActivityName = string.Empty;
        Newtonsoft.Json.Linq.JObject ActivityDetail;
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        bool ActivityIsAlreadyJoin = false;
        ActivityDetail = GetActivityDetail("/App_Data/ActivityDetail/VIPSetting/VIPLev" + UserLevelIndex + ".json");
        if (ActivityDetail != null) {
            ActivityName = (string)ActivityDetail["Name"];

            DT = RedisCache.UserAccountEventSummary.GetUserAccountEventSummaryByLoginAccount(LoginAccount);

            if (DT != null && DT.Rows.Count > 0) {
                for (int i = 0; i < DT.Rows.Count; i++) {
                    if ((string)DT.Rows[i]["ActivityName"] == ActivityName) {
                        ActivityIsAlreadyJoin = true;
                    }
                }
            }

            if (ActivityIsAlreadyJoin) {

            } else {
                List<EWin.Lobby.PropertySet> PropertySets = new List<EWin.Lobby.PropertySet>();

                string description = ActivityDetail["Name"].ToString();
                decimal ThresholdValue = (decimal)ActivityDetail["ThresholdValue"];
                decimal BonusValue = (decimal)ActivityDetail["BonusValue"];
                string PromotionCode = "VIPLev";
                string PromotionCategoryCode = "";
                string JoinActivityCycle = "1";
                string CollectAreaType = ActivityDetail["CollectAreaType"].ToString() == null ? "2" : ActivityDetail["CollectAreaType"].ToString();

                PropertySets.Add(new EWin.Lobby.PropertySet { Name = "ThresholdValue", Value = ThresholdValue.ToString() });
                PropertySets.Add(new EWin.Lobby.PropertySet { Name = "PointValue", Value = BonusValue.ToString() });

                lobbyAPI.AddPromotionCollect(GetToken(), description + "_" + LoginAccount + "_UpgradeGift", LoginAccount, EWinWeb.MainCurrencyType, PromotionCode, PromotionCategoryCode, int.Parse(CollectAreaType), 90, description, PropertySets.ToArray());
                EWinWebDB.UserAccountEventSummary.UpdateUserAccountEventSummary(LoginAccount, description, JoinActivityCycle, 1, ThresholdValue, BonusValue);
            }
        }
    }

    private void updateEwinUserLevelInfo(string LoginAccount, int UserLevelIndex)
    {
        updateEwinUserLevel(LoginAccount, UserLevelIndex);
        setUserAccountProperty(LoginAccount, System.Guid.NewGuid().ToString(), "UserLevelUpdateDate", DateTime.Now.ToString("yyyy/MM/dd"));
    }

    private void updateEwinUserLevel(string LoginAccount, int UserLevelIndex)
    {
        EWin.FANTA.APIResult R = new EWin.FANTA.APIResult();
        EWin.FANTA.FANTA API = new EWin.FANTA.FANTA();
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