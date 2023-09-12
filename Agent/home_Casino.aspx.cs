using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using System.Data;

public partial class home_Casino : System.Web.UI.Page { 

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.ChidUserData GetChildUserData(string AID, string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.ChidUserData RetValue = new EWin.BmAgent.ChidUserData();
        string RedisTmp = string.Empty;

        RedisTmp = RedisCache.Agent.GetHomeChildDetailByLoginAccount(LoginAccount);

        if (string.IsNullOrEmpty(RedisTmp)) {
            RetValue = api.GetChildUserData(AID);

            RedisCache.Agent.UpdateHomeChildDetailByLoginAccount(Newtonsoft.Json.JsonConvert.SerializeObject(RetValue), LoginAccount);
        } else {
            RetValue = Newtonsoft.Json.JsonConvert.DeserializeObject<EWin.BmAgent.ChidUserData>(RedisTmp);

            if (RetValue.Result == EWin.BmAgent.enumResult.ERR) {
                RetValue = api.GetChildUserData(AID);

                RedisCache.Agent.UpdateHomeChildDetailByLoginAccount(Newtonsoft.Json.JsonConvert.SerializeObject(RetValue), LoginAccount);
            }
        }

        return RetValue;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.TotalSummaryResult GetOrderSummary(string AID, string QueryBeginDate, string QueryEndDate, string CurrencyType, string LoginAccount) {
        EWin.BmAgent.TotalSummaryResult RetValue = null;
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        string RedisTmp = string.Empty;

        RedisTmp = RedisCache.Agent.GetHomeAccountDetailByLoginAccount(LoginAccount, QueryBeginDate, QueryEndDate);

        if (string.IsNullOrEmpty(RedisTmp)) {
            RetValue = api.GetOrderSummary(AID, QueryBeginDate, QueryEndDate, CurrencyType);

            RedisCache.Agent.UpdateHomeAccountDetailByLoginAccount(Newtonsoft.Json.JsonConvert.SerializeObject(RetValue), LoginAccount, QueryBeginDate, QueryEndDate);
        } else {
            RetValue = Newtonsoft.Json.JsonConvert.DeserializeObject<EWin.BmAgent.TotalSummaryResult>(RedisTmp);

            if (RetValue.Result == EWin.BmAgent.enumResult.ERR) {
                RetValue = api.GetOrderSummary(AID, QueryBeginDate, QueryEndDate, CurrencyType);

                RedisCache.Agent.UpdateHomeAccountDetailByLoginAccount(Newtonsoft.Json.JsonConvert.SerializeObject(RetValue), LoginAccount, QueryBeginDate, QueryEndDate);
            }
        }
        
        return RetValue;
    }
}