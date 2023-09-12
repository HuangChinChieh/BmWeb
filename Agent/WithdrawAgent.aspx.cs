using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class WithdrawAgent : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserBankCardListResult GetUserBankCard(string AID)
    {

        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        return api.GetUserBankCard(AID);

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.PaymentChannelResult ListPaymentChannel(string AID, int DirectionType)
    {

        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        return api.ListPaymentChannel(AID, EWinWeb.MainCurrencyType, (EWin.BmAgent.enumPaymentDirectionType)DirectionType);

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static PaymentMethodResult GetPaymentMethodByPaymentCodeFilterPaymentChannel(string AID, string PaymentCategoryCode, int PaymentType, string PaymentCode, int UserLevel, int DirectionType)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.AgentSessionResult ASR = null;
        PaymentMethodResult R = new PaymentMethodResult() { Result = enumResult.ERR, PaymentMethodResults = new List<PaymentMethod>() };
        EWin.BmAgent.PaymentChannelResult PaymentChannelResult = null;
        System.Data.DataTable DT = new System.Data.DataTable();
        ASR = api.GetAgentSessionByID(AID);
        DT = RedisCache.PaymentMethod.GetPaymentMethodByCategory(PaymentCategoryCode);
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.BmAgent.PaymentChannel Channel = null;
        if (ASR.Result == EWin.BmAgent.enumResult.OK)
        {
            PaymentChannelResult = api.ListPaymentChannel(AID, EWinWeb.MainCurrencyType,(EWin.BmAgent.enumPaymentDirectionType)DirectionType);
            if (PaymentChannelResult.Result== EWin.BmAgent.enumResult.OK)
            {
                if (DT != null)
                {
                    if (DT.Rows.Count > 0)
                    {
                        if (PaymentType == 0)
                        {
                            Channel = PaymentChannelResult.ChannelList.Where(w => w.CurrencyType == EWinWeb.MainCurrencyType && w.PaymentChannelCode == PaymentCode && w.UserLevelIndex <= UserLevel).FirstOrDefault();
                        }
                        else if (PaymentType == 1)
                        {
                            Channel = PaymentChannelResult.ChannelList.Where(w => w.CurrencyType == EWinWeb.MainCurrencyType && w.PaymentChannelCode == PaymentCode && w.UserLevelIndex <= UserLevel).FirstOrDefault();
                        }

                        if (Channel != null)
                        {
                            R.Result = enumResult.OK;
                            R.PaymentMethodResults = EWinWeb.ToList<PaymentMethod>(DT).Where(x => x.PaymentType == PaymentType && x.PaymentCode == PaymentCode).ToList();
                        }


                    }
                    else
                    {
                        SetResultException(R, "NoData");
                    }
                }
                else
                {
                    SetResultException(R, "NoData");
                }
            }
            else
            {
                SetResultException(R, "NoData");
            }
        }
        else
        {
            SetResultException(R, "InvalidAID");
        }

        return R;

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.PaymentChannelResult GetPaymentChannelByGroupIndex(string AID, int DirectionType, int GroupIndex, decimal Amount)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.AgentSessionResult ASR = null;
        System.Data.DataTable DT = new System.Data.DataTable();
        EWin.BmAgent.PaymentChannelResult R = new EWin.BmAgent.PaymentChannelResult() { Result= EWin.BmAgent.enumResult.ERR };
        ASR = api.GetAgentSessionByID(AID);
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.BmAgent.PaymentChannel Channel = null;
        if (ASR.Result == EWin.BmAgent.enumResult.OK)
        {
            var GetPaymentChannelResult = api.GetPaymentChannelByGroupIndex(AID, EWinWeb.MainCurrencyType, (EWin.BmAgent.enumPaymentDirectionType)DirectionType, GroupIndex, Amount);
            if (GetPaymentChannelResult.Result == EWin.BmAgent.enumResult.OK)
            {
                return GetPaymentChannelResult;
            }
            else
            {
                var ListPaymentChannelResult = api.ListPaymentChannel(AID, EWinWeb.MainCurrencyType, (EWin.BmAgent.enumPaymentDirectionType)DirectionType);
                if (ListPaymentChannelResult.Result == EWin.BmAgent.enumResult.OK)
                {

                    ListPaymentChannelResult.ChannelList = ListPaymentChannelResult.ChannelList.Where(w => w.GroupIndex == GroupIndex && w.CurrencyType == EWinWeb.MainCurrencyType).OrderByDescending(o => o.GroupIndex).ThenByDescending(o => o.WeightIndex).ThenByDescending(o => o.UserLevelIndex).ToArray();


                    if (ListPaymentChannelResult.ChannelList.Length > 0)
                    {
                        var ChannelList = new EWin.BmAgent.PaymentChannel[1];
                        ChannelList[0] = new EWin.BmAgent.PaymentChannel() { PaymentChannelCode = ListPaymentChannelResult.ChannelList[0].PaymentChannelCode };
                        R = new EWin.BmAgent.PaymentChannelResult()
                        {
                            Result = EWin.BmAgent.enumResult.OK,
                            ChannelList = ChannelList,
                            Message = ""
                            
                        };
                    }
                    else
                    {
                        R.Message = "InvalidAID";
                        return R;
                    }
                }
                else
                {
                    R.Message = "InvalidAID";
                    return R;
                }
            }
        }
        else
        {
            R.Message = "InvalidAID";
        }

        return R;

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.APIResult CheckPassword(string AID, string Password)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        return api.CheckPassword(AID, EWin.BmAgent.enumPasswordType.WalletPassword, Password);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static UserAccountPaymentResult GetInProgressPaymentByLoginAccount(string AID, string LoginAccount, int PaymentType)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.AgentSessionResult ASR = null;
        UserAccountPaymentResult R = new UserAccountPaymentResult();
        System.Data.DataTable DT = new System.Data.DataTable();
        ASR = api.GetAgentSessionByID(AID);

        if (ASR.Result == EWin.BmAgent.enumResult.OK)
        {
            DT = EWinWebDB.UserAccountPayment.GetInProgressPaymentByLoginAccount(LoginAccount, PaymentType);

            if (DT != null && DT.Rows.Count > 0)
            {
                R.Result = enumResult.OK;
                R.UserAccountPayments = EWinWeb.ToList<UserAccountPayment>(DT).ToList();
            }
            else
            {
                R.Result = enumResult.OK;
                R.UserAccountPayments = new List<UserAccountPayment>();
            }
        }
        else
        {
            SetResultException(R, "InvalidAID");
        }

        return R;

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static PaymentCommonResult CreateEPayWithdrawalAgent(string AID,decimal Amount, int PaymentMethodID, string PaymentChannelCode)
    {
        PaymentCommonResult R = new PaymentCommonResult() { Result = enumResult.ERR };
        PaymentCommonData PaymentCommonData = new PaymentCommonData() { PaymentCryptoDetailList = new List<CryptoDetail>() };
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.BmAgent.APIResult CheckPaymentChannelAmountResult;
        RedisCache.SessionContext.SIDInfo SI;
        string PaymentMethodName;
        string PaymentCode;
        string ReceiveCurrencyType;
        int DailyMaxAmount;
        int DailyMaxCount;
        decimal ReceiveTotalAmount;
        decimal HandingFeeRate;
        int HandingFeeAmount;
        int ExpireSecond;
        int DecimalPlaces;
        System.Data.DataTable PaymentMethodDT;
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.AgentSessionResult ASR = null;
        ASR = api.GetAgentSessionByID(AID);

        if (ASR.Result == EWin.BmAgent.enumResult.OK)
        {
            if (!EWinWeb.IsWithdrawlTemporaryMaintenance())
            {
                PaymentMethodDT = RedisCache.PaymentMethod.GetPaymentMethodByID(PaymentMethodID);

                if (PaymentMethodDT != null && PaymentMethodDT.Rows.Count > 0)
                {
                    CheckPaymentChannelAmountResult = api.CheckPaymentChannelAmount(AID, (EWin.BmAgent.enumPaymentDirectionType)1, EWinWeb.MainCurrencyType, PaymentChannelCode, Amount);
                    if (CheckPaymentChannelAmountResult.Result != EWin.BmAgent.enumResult.OK)
                    {
                        SetResultException(R, CheckPaymentChannelAmountResult.Message);
                        return R;
                    }

                    if ((int)PaymentMethodDT.Rows[0]["PaymentType"] == 1)
                    {

                        DailyMaxCount = (int)PaymentMethodDT.Rows[0]["DailyMaxCount"];
                        DailyMaxAmount = (int)PaymentMethodDT.Rows[0]["DailyMaxAmount"];
                        DecimalPlaces = (int)PaymentMethodDT.Rows[0]["DecimalPlaces"];

                        if ((int)PaymentMethodDT.Rows[0]["EWinPaymentType"] == 1)
                        {
                            //Check ThresholdValue
                            var userTag = api.GetUserTag(AID);

                            if (userTag.Tag != null && userTag.Tag.Length > 0)
                            {
                                for (int i = 0; i < userTag.Tag.Length; i++)
                                {
                                    if (userTag.Tag[i].TagText == "黑名單" || userTag.Tag[i].TagText == "數據延遲/異常" || userTag.Tag[i].TagText == "技術排查中" || userTag.Tag[i].TagText == "凍結出款")
                                    {
                                        SetResultException(R, "請聯繫客服");
                                        return R;
                                    }
                                }
                            }

                            PaymentMethodName = (string)PaymentMethodDT.Rows[0]["PaymentName"];
                            PaymentCode = PaymentChannelCode;
                            ReceiveCurrencyType = (string)PaymentMethodDT.Rows[0]["CurrencyType"];
                            ExpireSecond = (int)PaymentMethodDT.Rows[0]["ExpireSecond"];


                            HandingFeeRate = (decimal)PaymentMethodDT.Rows[0]["HandingFeeRate"];
                            HandingFeeAmount = (int)PaymentMethodDT.Rows[0]["HandingFeeAmount"];
                            ReceiveTotalAmount = (Amount * (1 - (decimal)PaymentMethodDT.Rows[0]["HandingFeeRate"])) - HandingFeeAmount;


                            ReceiveTotalAmount = CodingControl.FormatDecimal(ReceiveTotalAmount, 0);
                            CryptoDetail Dcd = new CryptoDetail()
                            {
                                TokenCurrencyType = ReceiveCurrencyType,
                                TokenContractAddress = "",
                                ExchangeRate = 1,
                                PartialRate = 1,
                                ReceiveAmount = ReceiveTotalAmount,
                            };

                            PaymentCommonData.PaymentCryptoDetailList.Add(Dcd);

                            string OrderNumber = System.Guid.NewGuid().ToString();
                            int InsertRet;
                            
                            PaymentCommonData.PaymentType = 1;
                            PaymentCommonData.BasicType = 1;
                            PaymentCommonData.OrderNumber = OrderNumber;
                            PaymentCommonData.LoginAccount = ASR.AgentSessionInfo.LoginAccount;
                            PaymentCommonData.Amount = Amount;
                            PaymentCommonData.ReceiveTotalAmount = ReceiveTotalAmount;
                            PaymentCommonData.HandingFeeRate = HandingFeeRate;
                            PaymentCommonData.HandingFeeAmount = HandingFeeAmount;
                            PaymentCommonData.ExpireSecond = ExpireSecond;
                            PaymentCommonData.PaymentMethodID = PaymentMethodID;
                            PaymentCommonData.PaymentMethodName = PaymentMethodName;
                            PaymentCommonData.PaymentCode = PaymentCode;
                            PaymentCommonData.CreateDate = DateTime.Now.ToString("yyyy/MM/dd hh:mm");

                            InsertRet = EWinWebDB.UserAccountPayment.InsertPayment(OrderNumber, PaymentCommonData.PaymentType, PaymentCommonData.BasicType, PaymentCommonData.LoginAccount, PaymentCommonData.Amount, PaymentCommonData.HandingFeeRate, PaymentCommonData.HandingFeeAmount, 0, 0, PaymentCommonData.PaymentMethodID, "", "", Newtonsoft.Json.JsonConvert.SerializeObject(PaymentCommonData.PaymentCryptoDetailList), PaymentCommonData.ExpireSecond);

                            if (InsertRet == 1)
                            {
                                R.Result = enumResult.OK;
                                R.Data = PaymentCommonData;
                                RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(R.Data), PaymentCommonData.OrderNumber);
                            }
                            else
                            {
                                SetResultException(R, "InsertFailure");
                            }

                        }
                        else
                        {
                            SetResultException(R, "PaymentMethodNotCrypto");
                        }

                    }
                    else
                    {
                        SetResultException(R, "PaymentMethodNotSupportDeposit");
                    }
                }
                else
                {
                    SetResultException(R, "PaymentMethodNotExist");
                }
            }
            else
            {
                SetResultException(R, "WithdrawlTemporaryMaintenance");
            }
        }
        else
        {
            SetResultException(R, "InvalidAID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static APIResult ConfirmEPayWithdrawal(string AID, string OrderNumber, string BankCard, string BankCardName, string BankName, string BankBranchCode, string PhoneNumber)
    {
        APIResult R = new APIResult() {Result = enumResult.ERR };
        //APIResult CreateEPayWithdrawalReturn = new APIResult() { GUID = GUID, Result = enumResult.ERR };

        PaymentCommonData TempCryptoData;
        RedisCache.SessionContext.SIDInfo SI;
        decimal PointValue;
        string Token = GetToken();
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        Newtonsoft.Json.Linq.JObject BankDatas = new Newtonsoft.Json.Linq.JObject();
        Newtonsoft.Json.Linq.JObject BankDecription = new Newtonsoft.Json.Linq.JObject();
        EWin.BmAgent.AgentSessionResult ASR = null;
        ASR = api.GetAgentSessionByID(AID);
        System.Data.DataTable PaymentMethodDT;

        if (BankName.ToUpper() == "GCASH")
        {
            if (string.IsNullOrEmpty(PhoneNumber))
            {
                R.Message = "PhoneNumber Empty";
                return R;
            }
            else
            {
                BankCard = PhoneNumber;
            }
        }
        else
        {
            if (string.IsNullOrEmpty(BankCard))
            {
                R.Message = "BankCard Empty";
                return R;
            }

            if (string.IsNullOrEmpty(BankCardName))
            {
                R.Message = "BankCardName Empty";
                return R;
            }
        }


        if (string.IsNullOrEmpty(BankName))
        {
            R.Message = "BankName Empty";
            return R;
        }

        if (ASR.Result == EWin.BmAgent.enumResult.OK)
        {
            if (EWinWeb.CheckInWithdrawalTime())
            {
                if (!EWinWeb.IsWithdrawlTemporaryMaintenance())
                {
                    //取得Temp(未確認)訂單
                    TempCryptoData = RedisCache.PaymentContent.GetPaymentContent<PaymentCommonData>(OrderNumber);

                    if (TempCryptoData != null)
                    {

                        PaymentMethodDT = RedisCache.PaymentMethod.GetPaymentMethodByID(TempCryptoData.PaymentMethodID);
                        if (!(PaymentMethodDT != null && PaymentMethodDT.Rows.Count > 0))
                        {
                            SetResultException(R, "AgentAccountCannotDeposit");
                            return R;
                        }

                        //ProviderHandingFeeRate = (decimal)PaymentMethodDT.Rows[0]["ProviderHandingFeeRate"];
                        //ProviderHandingFeeAmount = (int)PaymentMethodDT.Rows[0]["ProviderHandingFeeAmount"];

                        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
            
                                    PointValue = TempCryptoData.Amount;

                                    BankDatas.Add("BankCard", BankCard);
                                    BankDatas.Add("BankCardName", BankCardName);
                                    BankDatas.Add("BankName", BankName);
                                    BankDatas.Add("ReceiveAmount", PointValue);
                                    //準備送出至EWin

                                    EWin.Payment.PaymentAPI paymentAPI = new EWin.Payment.PaymentAPI();
                                    EWin.Payment.PaymentResult paymentResult;
                                    List<EWin.Payment.PaymentDetailBankCard> paymentDetailBankCards = new List<EWin.Payment.PaymentDetailBankCard>();

                                    //Description待實際測試後調整

                                    string Decription = BankDatas.ToString();

                                    EWin.Payment.PaymentDetailBankCard paymentDetailWallet = new EWin.Payment.PaymentDetailBankCard()
                                    {
                                        Status = EWin.Payment.enumBankCardStatus.None,
                                        BankCardType = EWin.Payment.enumBankCardType.UserAccountBankCard,
                                        BankCode = "",
                                        BankName = BankName,
                                        BranchName = BankBranchCode,
                                        BankNumber = BankCard,
                                        AccountName = BankCardName,
                                        AmountMax = 9999999999,
                                        BankCardGUID = Guid.NewGuid().ToString("N"),
                                        Description = "",
                                        TaxFeeValue = TempCryptoData.Amount - TempCryptoData.ReceiveTotalAmount
                                    };
                                    paymentDetailBankCards.Add(paymentDetailWallet);
                                    string PaymentCode = "";
                                    if (TempCryptoData.PaymentCode == ".Withdrawal.Gcash")
                                    {
                                        PaymentCode = "@2";
                                    }
                                    else if (TempCryptoData.PaymentCode == ".Withdrawal.BANK")
                                    {
                                        PaymentCode = "@1";
                                    }
                                    else
                                    {
                                        PaymentCode = TempCryptoData.PaymentCode;
                                    }

                                    paymentResult = paymentAPI.CreatePaymentWithdrawal(GetToken(), TempCryptoData.LoginAccount, System.Guid.NewGuid().ToString(), EWinWeb.MainCurrencyType, OrderNumber, TempCryptoData.Amount, paymentDetailWallet.TaxFeeValue, Decription, true, PointValue * -1, PaymentCode, "", CodingControl.GetUserIP(), TempCryptoData.ExpireSecond, paymentDetailBankCards.ToArray());
                                    if (paymentResult.ResultStatus == EWin.Payment.enumResultStatus.OK)
                                    {
                                        int UpdateRet = EWinWebDB.UserAccountPayment.ConfirmPayment(OrderNumber, BankDatas.ToString(), paymentResult.PaymentSerial, PointValue, "");

                                        if (UpdateRet == 1)
                                        {
                                            R.Result = enumResult.OK;
                                            R.Message = paymentResult.PaymentSerial;
                                            TempCryptoData.PaymentSerial = paymentResult.PaymentSerial;
                                            TempCryptoData.PointValue = PointValue;
                        
                                        }
                                        else
                                        {
                                            SetResultException(R, "UpdateFailure");
                                        }
                                    }
                                    else
                                    {
                                        SetResultException(R, paymentResult.ResultMessage);
                                    }
                    }
                    else
                    {
                        SetResultException(R, "OrderNotExist");
                    }
                }
                else
                {
                    SetResultException(R, "WithdrawlTemporaryMaintenance");
                }
            }
            else
            {
                SetResultException(R, "NotInOpenTime");
            }
        }
        else
        {
            SetResultException(R, "InvalidWebSID");
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


    private static void SetResultException(APIResult R, string Msg)
    {
        if (R != null)
        {
            R.Result = enumResult.ERR;
            R.Message = Msg;
        }
    }

    public class APIResult
    {
        public enumResult Result { get; set; }
        public string Message { get; set; }
    }

    public enum enumResult
    {
        OK = 0,
        ERR = 1
    }

    public class PaymentMethodResult : APIResult
    {
        public List<PaymentMethod> PaymentMethodResults { get; set; }
    }

    public class PaymentMethod
    {
        public int PaymentMethodID { get; set; }
        public int PaymentType { get; set; }
        public string PaymentName { get; set; }
        public string PaymentCode { get; set; }
        public string PaymentCategoryCode { get; set; }
        public int State { get; set; }
        public string EwinPayServiceType { get; set; }
        public int EWinPaymentType { get; set; }
        public int EWinCryptoWalletType { get; set; }
        public decimal ThresholdRate { get; set; }
        public decimal MinLimit { get; set; }
        public decimal MaxLimit { get; set; }
        public decimal HandingFeeRate { get; set; }
        public decimal HandingFeeAmount { get; set; }
        public string CurrencyType { get; set; }
        public string MultiCurrencyInfo { get; set; }
        public string ExtraData { get; set; }
        public string HintText { get; set; }
    }

    public class UserAccountPaymentResult : APIResult
    {
        public List<UserAccountPayment> UserAccountPayments { get; set; }
    }

    public class UserAccountPayment
    {
        public string OrderNumber { get; set; }
        public string PaymentSerial { get; set; }
        public string PaymentName { get; set; }
        public int PaymentType { get; set; }
        public int BasicType { get; set; }
        public int FlowStatus { get; set; }
        public string LoginAccount { get; set; }
        public decimal Amount { get; set; }
        public decimal PointValue { get; set; }
        public decimal HandingFeeRate { get; set; }
        public int HandingFeeAmount { get; set; }
        public decimal ThresholdRate { get; set; }
        public decimal ThresholdValue { get; set; }
        public int forPaymentMethodID { get; set; }
        public string FromInfo { get; set; }
        public string ToInfo { get; set; }
        public string DetailData { get; set; }
        public string ActivityData { get; set; }
        public int ExpireSecond { get; set; }
        public DateTime FinishDate { get; set; }
        public DateTime CreateDate { get; set; }
        public string CreateDate1 { get; set; }
    }

    public class PaymentCommonResult : APIResult
    {
        public PaymentCommonData Data { get; set; }
    }

    public class PaymentCommonData
    {
        public int PaymentType { get; set; } // 0=入金,1=出金
        public int BasicType { get; set; } // 0=一般/1=銀行卡/2=區塊鏈
        public int PaymentFlowType { get; set; } // 0=建立/1=進行中/2=成功/3=失敗
        public string LoginAccount { get; set; }
        public string PaymentSerial { get; set; }
        public string OrderNumber { get; set; }
        public string ReceiveCurrencyType { get; set; }
        public decimal Amount { get; set; }
        public decimal PointValue { get; set; }
        public decimal HandingFeeRate { get; set; }
        public int HandingFeeAmount { get; set; }
        public decimal ReceiveTotalAmount { get; set; }
        public int ProviderHandingFeeAmount { get; set; }
        public decimal ProviderHandingFeeRate { get; set; }
        public decimal ThresholdValue { get; set; }
        public decimal ThresholdRate { get; set; }
        public int ExpireSecond { get; set; }
        public int PaymentMethodID { get; set; }
        public string PaymentMethodName { get; set; }
        public string PaymentCode { get; set; }
        public string CreateDate { get; set; }
        public string FinishDate { get; set; }
        public string LimitDate { get; set; }
        public int WalletType { get; set; } // 0=ERC,1=XRP
        public string ToWalletAddress { get; set; }
        public List<CryptoDetail> PaymentCryptoDetailList { get; set; }
        public List<EWinTagInfoActivityData> ActivityDatas { get; set; }
        public string ActivityData { get; set; }
        public string FromInfo { get; set; }
        public string ToInfo { get; set; }
    }

    public class CryptoDetail
    {
        public string TokenCurrencyType { get; set; }
        public string TokenContractAddress { get; set; }
        public decimal ReceiveAmount { get; set; }
        public decimal ExchangeRate { get; set; }
        public decimal PartialRate { get; set; }
    }

    public class EWinTagInfoActivityData
    {
        public string ActivityName { get; set; }
        public string JoinActivityCycle { get; set; }
        public decimal BonusRate { get; set; }
        public decimal BonusValue { get; set; }
        public decimal ThresholdRate { get; set; }
        public decimal ThresholdValue { get; set; }
        public int JoinCount { get; set; }
        public string CollectAreaType { get; set; }
    }
}