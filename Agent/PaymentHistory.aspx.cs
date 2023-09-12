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

public partial class PaymentHistory : System.Web.UI.Page {
  
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static PaymentCommonListResult GetPaymentHistory(string AID, DateTime StartDate, DateTime EndDate)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        PaymentCommonListResult R = new PaymentCommonListResult() { Result = enumResult.ERR };
        EWin.BmAgent.AgentSessionResult ASR = null;
        System.Data.DataTable DT;
        ASR = api.GetAgentSessionByID(AID);

        if (ASR.Result == EWin.BmAgent.enumResult.OK)
        {
            R.Datas = new List<PaymentCommonData>();
            R.NotFinishDatas = new List<PaymentCommonData>();
            R.Result = enumResult.OK;

            for (int i = 0; i <= EndDate.Subtract(StartDate).TotalDays; i++)
            {
                var QueryDate = StartDate.AddDays(i);
                string Content = string.Empty;
                Content = ReportSystem.UserAccountPayment.GetUserAccountPayment(QueryDate, ASR.AgentSessionInfo.LoginAccount);

                foreach (string EachString in Content.Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries))
                {
                    PaymentCommonData data = null;
                    try { data = Newtonsoft.Json.JsonConvert.DeserializeObject<PaymentCommonData>(EachString); } catch (Exception ex) { }
                    if (data != null)
                    {
                        R.Datas.Add(data);
                    }
                }
            }

            DT = EWinWebDB.UserAccountPayment.GetPaymentByNonFinishedByLoginAccount(ASR.AgentSessionInfo.LoginAccount);

            if (DT != null && DT.Rows.Count > 0)
            {
                for (int i = 0; i < DT.Rows.Count; i++)
                {
                    var Row = DT.Rows[i];
                    PaymentCommonData data = CovertFromRow(Row);

                    if (StartDate<= DateTime.Parse(data.CreateDate)&& DateTime.Parse(data.CreateDate) <= EndDate)
                    {
                        R.NotFinishDatas.Add(data);
                    }
                }
            }

            if (R.Datas.Count > 0 || R.NotFinishDatas.Count > 0)
            {
                R.Datas = R.Datas.OrderByDescending(x => x.FinishDate).ToList();
                R.NotFinishDatas = R.NotFinishDatas.OrderByDescending(x => x.CreateDate).ToList();
                R.Result = enumResult.OK;
            }
            else
            {
                R.Datas = new List<PaymentCommonData>();
                R.NotFinishDatas = new List<PaymentCommonData>();
                R.Result = enumResult.OK;
            }
        }
        else
        {
            SetResultException(R, "InvalidAID");
        }

        return R;
    }


    private static PaymentCommonData CovertFromRow(System.Data.DataRow row)
    {
        string DetailDataStr = "";
        string ActivityDataStr = "";

        if (!Convert.IsDBNull(row["DetailData"]))
        {
            DetailDataStr = row["DetailData"].ToString();
        }

        if (!Convert.IsDBNull(row["ActivityData"]))
        {
            ActivityDataStr = row["ActivityData"].ToString();
        }



        if (string.IsNullOrEmpty(DetailDataStr))
        {
            PaymentCommonData result = new PaymentCommonData()
            {
                PaymentType = (int)row["PaymentType"],
                BasicType = (int)row["BasicType"],
                LoginAccount = (string)row["LoginAccount"],
                OrderNumber = (string)row["OrderNumber"],
                Amount = (decimal)row["Amount"],
                HandingFeeRate = (decimal)row["HandingFeeRate"],
                //ReceiveTotalAmount = (decimal)row["ReceiveTotalAmount"],
                ThresholdValue = (decimal)row["ThresholdValue"],
                ThresholdRate = (decimal)row["ThresholdRate"],
                CreateDate = ((DateTime)row["CreateDate"]).ToString("yyyy/MM/dd HH:mm:ss"),
                LimitDate = ((DateTime)row["CreateDate"]).AddSeconds((int)row["ExpireSecond"]).ToString("yyyy/MM/dd HH:mm:ss"),
                ExpireSecond = (int)row["ExpireSecond"],
                PaymentMethodID = (int)row["PaymentMethodID"],
                PaymentMethodName = (string)row["PaymentName"],
                PaymentCode = (string)row["PaymentCode"],
                PaymentSerial = (string)row["PaymentSerial"]
            };

            return result;
        }
        else
        {
            PaymentCommonData result = new PaymentCommonData()
            {
                PaymentType = (int)row["PaymentType"],
                BasicType = (int)row["BasicType"],
                LoginAccount = (string)row["LoginAccount"],
                OrderNumber = (string)row["OrderNumber"],
                Amount = (decimal)row["Amount"],
                HandingFeeRate = (decimal)row["HandingFeeRate"],
                //ReceiveTotalAmount = (decimal)row["ReceiveTotalAmount"],
                ThresholdValue = (decimal)row["ThresholdValue"],
                ThresholdRate = (decimal)row["ThresholdRate"],
                CreateDate = ((DateTime)row["CreateDate"]).ToString("yyyy/MM/dd HH:mm:ss"),
                LimitDate = ((DateTime)row["CreateDate"]).AddSeconds((int)row["ExpireSecond"]).ToString("yyyy/MM/dd HH:mm:ss"),
                ExpireSecond = (int)row["ExpireSecond"],
                PaymentMethodID = (int)row["PaymentMethodID"],
                PaymentMethodName = (string)row["PaymentName"],
                PaymentCode = (string)row["PaymentCode"],
                ToWalletAddress = (string)row["ToInfo"],
                WalletType = (int)row["EWinCryptoWalletType"],
                PaymentSerial = (string)row["PaymentSerial"]
            };

            result.PaymentCryptoDetailList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<CryptoDetail>>(DetailDataStr);

            if (!string.IsNullOrEmpty(ActivityDataStr))
            {
                result.ActivityDatas = Newtonsoft.Json.JsonConvert.DeserializeObject<List<EWinTagInfoActivityData>>(ActivityDataStr);
            }

            return result;
        }
    }

    public class APIResult
    {
        public enumResult Result { get; set; }
        public string GUID { get; set; }
        public string Message { get; set; }
    }

    public enum enumResult
    {
        OK = 0,
        ERR = 1
    }

    private static void SetResultException(APIResult R, string Msg)
    {
        if (R != null)
        {
            R.Result = enumResult.ERR;
            R.Message = Msg;
        }
    }

    public class PaymentCommonListResult : APIResult
    {
        public List<PaymentCommonData> Datas { get; set; }
        public List<PaymentCommonData> NotFinishDatas { get; set; }
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

    public class CryptoDetail
    {
        public string TokenCurrencyType { get; set; }
        public string TokenContractAddress { get; set; }
        public decimal ReceiveAmount { get; set; }
        public decimal ExchangeRate { get; set; }
        public decimal PartialRate { get; set; }
    }
}