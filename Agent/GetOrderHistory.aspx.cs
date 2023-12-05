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

public partial class GetOrderHistory : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.GameOrderHistoryResult GetGameOrderHistory(string AID, string LoginAccount, DateTime QueryBeginDate, DateTime QueryEndDate, int RowsPage, int PageNumber, string CurrencyType, string GameBrand) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.GameOrderHistoryResult RetValue = new EWin.BmAgent.GameOrderHistoryResult();
        string strRedisData = string.Empty;
        JObject redisSaveData = new JObject();
        int ExpireTimeoutSeconds = 300;

        strRedisData = RedisCache.Agent.GetGameOrderByLoginAccount(LoginAccount, GameBrand, CurrencyType, QueryBeginDate.ToString("yyyy-MM-dd"), QueryEndDate.ToString("yyyy-MM-dd"));
        
        if (string.IsNullOrEmpty(strRedisData)) {
            RetValue = api.GetGameOrderHistory(AID, LoginAccount, GameBrand, QueryBeginDate, QueryEndDate, CurrencyType, RowsPage, 1);

            if (RetValue.Result == EWin.BmAgent.enumResult.OK) {
                redisSaveData.Add(PageNumber.ToString(), JsonConvert.SerializeObject(RetValue));

                RedisCache.Agent.UpdateGameOrderByLoginAccount(JsonConvert.SerializeObject(redisSaveData), LoginAccount, GameBrand, ExpireTimeoutSeconds, CurrencyType, QueryBeginDate.ToString("yyyy-MM-dd"), QueryEndDate.ToString("yyyy-MM-dd"));
            }
        } else {
            redisSaveData = JObject.Parse(strRedisData);
            //有該頁面的資料
            if (redisSaveData[PageNumber.ToString()] != null) {
                RetValue = JsonConvert.DeserializeObject<EWin.BmAgent.GameOrderHistoryResult>((string)redisSaveData[PageNumber.ToString()]);
            } else {

                RetValue = api.GetGameOrderHistory(AID, LoginAccount, GameBrand, QueryBeginDate, QueryEndDate, CurrencyType, RowsPage, PageNumber);

                if (RetValue.Result == EWin.BmAgent.enumResult.OK) {
                    redisSaveData.Add(PageNumber.ToString(), JsonConvert.SerializeObject(RetValue));

                    RedisCache.Agent.UpdateGameOrderByLoginAccount(JsonConvert.SerializeObject(redisSaveData), LoginAccount, GameBrand, ExpireTimeoutSeconds, CurrencyType, QueryBeginDate.ToString("yyyy-MM-dd"), QueryEndDate.ToString("yyyy-MM-dd"));
                }
            }

        }

        return RetValue;
    }
}