using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class GetAgentAccountingDetail_CasinoExcludeLogin : System.Web.UI.Page {

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.AgentAccountingDetailResult GetAgentAccountingDetail(int AccountingID, string LoginAccount) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.AgentAccountingDetailResult RetValue = new EWin.BmAgent.AgentAccountingDetailResult();
        string RedisTmp = string.Empty;

        RedisTmp = RedisCache.Agent.GetAccountDetailByLoginAccount(LoginAccount, AccountingID);

        if (string.IsNullOrEmpty(RedisTmp)) {
            RetValue = api.GetAgentAccountingDetailExcludeLogin(EWinWeb.CompanyCode, LoginAccount, EWinWeb.MainCurrencyType, AccountingID);

            RedisCache.Agent.UpdateAccountDetailByLoginAccount(Newtonsoft.Json.JsonConvert.SerializeObject(RetValue), LoginAccount, AccountingID);
        } else {
            RetValue = Newtonsoft.Json.JsonConvert.DeserializeObject<EWin.BmAgent.AgentAccountingDetailResult>(RedisTmp);
        }

        return RetValue;
    }
}