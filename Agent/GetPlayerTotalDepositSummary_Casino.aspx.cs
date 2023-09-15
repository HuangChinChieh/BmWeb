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

public partial class GetPlayerTotalDepositSummary_Casino : System.Web.UI.Page
{

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.DepositeSummaryResult GetPlayerTotalDepositSummary(string AID, string LoginAccount, DateTime QueryBeginDate, DateTime QueryEndDate, string CurrencyType, int RowsPage, int PageNumber)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.DepositeSummaryResult RetValue = new EWin.BmAgent.DepositeSummaryResult();
        List<EWin.BmAgent.DepositeSummary> tmpRetValue = new List<EWin.BmAgent.DepositeSummary>();
        List<EWin.BmAgent.DepositeSummary> tmpAgentTotalSummaryResult = null;
        int tmpPageNumber = 0;
        string strRedisData = string.Empty;
        JObject redisSaveData = new JObject();
        int ExpireTimeoutSeconds = 300;

        strRedisData = RedisCache.Agent.GetPlayerTotalDepositSummaryByLoginAccount(LoginAccount, QueryBeginDate, QueryEndDate, CurrencyType);

        if (string.IsNullOrEmpty(strRedisData))
        {

            RetValue = api.GetPlayerTotalDepositSummary(AID, QueryBeginDate, QueryEndDate, CurrencyType);

            if (RetValue.Result == EWin.BmAgent.enumResult.OK && RetValue.SummaryList.Length > 0)
            {

                tmpPageNumber = 1;
                tmpAgentTotalSummaryResult = new List<EWin.BmAgent.DepositeSummary>();

                for (int i = 0; i < RetValue.SummaryList.Length; i++)
                {
                    tmpAgentTotalSummaryResult.Add(RetValue.SummaryList[i]);
                    if ((i + 1) % RowsPage == 0)
                    {
                        redisSaveData.Add(tmpPageNumber.ToString(), JsonConvert.SerializeObject(tmpAgentTotalSummaryResult));
                        tmpPageNumber++;
                        tmpAgentTotalSummaryResult = new List<EWin.BmAgent.DepositeSummary>();
                    }

                    if (RetValue.SummaryList.Length == i + 1)
                    {
                        redisSaveData.Add(tmpPageNumber.ToString(), JsonConvert.SerializeObject(tmpAgentTotalSummaryResult));
                    }
                }

                RedisCache.Agent.UpdatePlayerTotalDepositSummaryByLoginAccount(JsonConvert.SerializeObject(redisSaveData), QueryBeginDate, QueryEndDate, LoginAccount, ExpireTimeoutSeconds, CurrencyType);

                tmpRetValue = JsonConvert.DeserializeObject<List<EWin.BmAgent.DepositeSummary>>((string)redisSaveData[PageNumber.ToString()]);
                if (redisSaveData[(PageNumber + 1).ToString()] != null)
                {
                    RetValue.Message = "HasNextPage";
                }

                RetValue.SummaryList = tmpRetValue.ToArray();
                RetValue.Result = EWin.BmAgent.enumResult.OK;
            }
        }
        else
        {
            redisSaveData = JObject.Parse(strRedisData);

            //有該頁面的資料
            if (redisSaveData[PageNumber.ToString()] != null)
            {
                tmpRetValue = JsonConvert.DeserializeObject<List<EWin.BmAgent.DepositeSummary>>((string)redisSaveData[PageNumber.ToString()]);
                if (redisSaveData[(PageNumber + 1).ToString()] != null)
                {
                    RetValue.Message = "HasNextPage";
                }

                RetValue.SummaryList = tmpRetValue.ToArray();
                RetValue.Result = EWin.BmAgent.enumResult.OK;
            }
            else
            {
                RetValue.SummaryList = null;
                RetValue.Result = EWin.BmAgent.enumResult.ERR;
                RetValue.Message = "NoData";
            }

        }


        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.DepositeSummaryResult GetSearchPlayerTotalDepositSummary(string AID, string TargetLoginAccount, DateTime QueryBeginDate, DateTime QueryEndDate, string CurrencyType)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.DepositeSummaryResult RetValue = new EWin.BmAgent.DepositeSummaryResult();

        RetValue = api.GetSearchPlayerTotalDepositSummary(AID, TargetLoginAccount, QueryBeginDate, QueryEndDate, CurrencyType);

        return RetValue;
    }
}