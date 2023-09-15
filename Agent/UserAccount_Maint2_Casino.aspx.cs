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

public partial class UserAccount_Maint2_Casino : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.UserAccountSummaryResult GetUserAccountSummary(string AID, string SearchLoginAccount, string LoginAccount, int RowsPage, int PageNumber, string CurrencyType) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.UserAccountSummaryResult RetValue = new EWin.BmAgent.UserAccountSummaryResult();
        int MaxSearchUserAccountID = 0;
        string strRedisData = string.Empty;
        JObject redisSaveData = new JObject();
        int ExpireTimeoutSeconds = 0;

        if (string.IsNullOrEmpty(SearchLoginAccount)) {

            strRedisData = RedisCache.Agent.GetTeamMemberInfoByLoginAccount(LoginAccount, CurrencyType);

            //沒有redis資料一律將PageNumber改為1，避免用戶在該頁面放置到Redis已消失的狀態，最大會員編號已失效資料的數量會有問題
            if (string.IsNullOrEmpty(strRedisData)) {
                RetValue = api.GetUserAccountSummary(AID, SearchLoginAccount, CurrencyType, RowsPage, 1, MaxSearchUserAccountID);

                if (RetValue.Result == EWin.BmAgent.enumResult.OK) {
                    MaxSearchUserAccountID = RetValue.MaxUserID;
                    redisSaveData.Add("MaxSearchUserAccountID", MaxSearchUserAccountID.ToString());
                    ExpireTimeoutSeconds = 300;
                    redisSaveData.Add(PageNumber.ToString(), JsonConvert.SerializeObject(RetValue));

                    RedisCache.Agent.UpdateTeamMemberInfoByLoginAccount(JsonConvert.SerializeObject(redisSaveData), LoginAccount, ExpireTimeoutSeconds, CurrencyType);
                }
            } else {
                redisSaveData = JObject.Parse(strRedisData);
                //有該頁面的資料
                if (redisSaveData[PageNumber.ToString()] != null) {
                    RetValue = JsonConvert.DeserializeObject<EWin.BmAgent.UserAccountSummaryResult>((string)redisSaveData[PageNumber.ToString()]);
                } else {

                    if (redisSaveData["MaxSearchUserAccountID"] != null) {
                        MaxSearchUserAccountID = (int)redisSaveData["MaxSearchUserAccountID"];
                    }

                    RetValue = api.GetUserAccountSummary(AID, SearchLoginAccount, CurrencyType, RowsPage, PageNumber, MaxSearchUserAccountID);

                    if (RetValue.Result == EWin.BmAgent.enumResult.OK) {
                        redisSaveData.Add(PageNumber.ToString(), JsonConvert.SerializeObject(RetValue));

                        RedisCache.Agent.UpdateTeamMemberInfoByLoginAccount(JsonConvert.SerializeObject(redisSaveData), LoginAccount, ExpireTimeoutSeconds, CurrencyType);
                    }
                }

            }

        } else {
            RetValue = api.GetUserAccountSummary(AID, SearchLoginAccount, CurrencyType, RowsPage, PageNumber, MaxSearchUserAccountID);
        }

        return RetValue;
    }
}