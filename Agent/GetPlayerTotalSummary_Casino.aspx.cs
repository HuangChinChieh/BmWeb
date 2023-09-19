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

public partial class GetPlayerTotalSummary_Casino : System.Web.UI.Page
{
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.OrderSummaryResult GetPlayerTotalOrderSummary(string AID, string LoginAccount, DateTime QueryBeginDate, DateTime QueryEndDate, string CurrencyType, int RowsPage, int PageNumber)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.OrderSummaryResult RetValue = new EWin.BmAgent.OrderSummaryResult();
        EWin.BmAgent.OrderSummaryResult k = new EWin.BmAgent.OrderSummaryResult();
        string strRedisData = string.Empty;
        JObject redisSaveData = new JObject();
        int ExpireTimeoutSeconds = 0;
        int TotalPage = 0;

        //strRedisData = RedisCache.Agent.GetPlayerTotalSummaryInfoByLoginAccount(LoginAccount, QueryBeginDate.ToString("yyyy-MM-dd"), QueryEndDate.ToString("yyyy-MM-dd"), CurrencyType);

        if (string.IsNullOrEmpty(strRedisData))
        {
            RetValue = api.GetPlayerTotalOrderSummary(AID, QueryBeginDate, QueryEndDate, CurrencyType);

            if (RetValue.Result == EWin.BmAgent.enumResult.OK)
            {
                if (RetValue.SummaryList.Count() > 0)
                {
                    TotalPage = int.Parse(Math.Ceiling((double)RetValue.SummaryList.Count() / (double)RowsPage).ToString());

                    redisSaveData.Add("TotalPage", TotalPage);
                    redisSaveData.Add("All", JsonConvert.SerializeObject(RetValue.SummaryList));
                    ExpireTimeoutSeconds = 600;

                    for (int i = 0; i < TotalPage; i++)
                    {
                        k = new EWin.BmAgent.OrderSummaryResult();
                        k.Result = EWin.BmAgent.enumResult.OK;
                        k.SummaryList = RetValue.SummaryList.Skip(i).Take(RowsPage).ToArray();

                        redisSaveData.Add((i + 1).ToString(), JsonConvert.SerializeObject(k));
                    }

                    if (TotalPage > 1)
                    {
                        RetValue.HasNextPage = true;
                    }
                    else
                    {
                        RetValue.HasNextPage = false;
                    }

                    //RedisCache.Agent.UpdatePlayerTotalSummaryByLoginAccount(JsonConvert.SerializeObject(redisSaveData), LoginAccount, QueryBeginDate.ToString("yyyy-MM-dd"), QueryEndDate.ToString("yyyy-MM-dd"), CurrencyType);
                }
            }

        }
        else
        {
            redisSaveData = JObject.Parse(strRedisData);

            if (redisSaveData["TotalPage"] != null)
            {
                TotalPage = (int)redisSaveData["TotalPage"];
            }

            if (redisSaveData[PageNumber.ToString()] != null)
            {
                RetValue = JsonConvert.DeserializeObject<EWin.BmAgent.OrderSummaryResult>((string)redisSaveData[PageNumber.ToString()]);

                if (PageNumber >= TotalPage)
                {
                    RetValue.HasNextPage = false;
                }
                else
                {
                    RetValue.HasNextPage = true;
                }
            }
        }

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.OrderSummaryResult GetSearchPlayerTotalOrderSummary(string AID, string TargetLoginAccount, DateTime QueryBeginDate, DateTime QueryEndDate, string CurrencyType)
    {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.OrderSummaryResult RetValue = new EWin.BmAgent.OrderSummaryResult();

        RetValue = api.GetSearchPlayerTotalOrderSummary(AID, TargetLoginAccount, QueryBeginDate, QueryEndDate, CurrencyType);

        return RetValue;
    }
}