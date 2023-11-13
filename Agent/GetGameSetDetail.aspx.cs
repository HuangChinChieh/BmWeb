using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

public partial class GetGameSetDetail : System.Web.UI.Page {
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static EWin.BmAgent.GameSetDetailResult GetGameSetDetailData(string AID, int GameSetID) {
        EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
        EWin.BmAgent.GameSetDetailResult RetValue = new EWin.BmAgent.GameSetDetailResult();
        string RedisTmp = string.Empty;

        RedisTmp = RedisCache.Agent.GetGameSetDetailByID(GameSetID);

        if (string.IsNullOrEmpty(RedisTmp)) {
            RetValue = api.GetGameSetDetailByID(AID, GameSetID);

            RedisCache.Agent.UpdateGameSetDetailByID(GameSetID, Newtonsoft.Json.JsonConvert.SerializeObject(RetValue));
        } else {
            RetValue = Newtonsoft.Json.JsonConvert.DeserializeObject<EWin.BmAgent.GameSetDetailResult>(RedisTmp);
        }

        return RetValue;
    }
}