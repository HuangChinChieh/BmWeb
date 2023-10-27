<%@ Page Language="C#" %>

<%

    RedisCache.SessionContext.SIDInfo SI;
    string SID = Request["SID"];
    string Lang = Request["Lang"];
    string CurrencyType = Request["CurrencyType"];
    string GameCode = Request["GameCode"];
    string HomeUrl = Request["HomeUrl"];
    string DemoPlay = string.IsNullOrEmpty(Request["DemoPlay"]) ? "0" : Request["DemoPlay"]; //���䴩DEMO�����̥~�h�P�_

    SI = RedisCache.SessionContext.GetSIDInfo(SID);

    if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
           Response.Redirect(EWinWeb.EWinGameUrl + "/API/GamePlatformAPI2/UserLogin.aspx?SID=" + SI.EWinSID + "&Language=" + Lang + "&CurrencyType=" + CurrencyType + "&GameCode=" + GameCode + "&HomeUrl=" + HomeUrl + "&DemoPlay=" + DemoPlay + "&InvalidGameCodeAccessUrl=" + EWinWeb.CasinoWorldUrl + "/InvalidGameCodeAccess.aspx");
    } else {
        if (DemoPlay == "1") {
            Response.Redirect(EWinWeb.EWinGameUrl + "/API/GamePlatformAPI2/UserLogin.aspx?Language=" + Lang + "&CurrencyType=" + CurrencyType + "&GameCode=" + GameCode + "&HomeUrl=" + HomeUrl + "&DemoPlay=" + DemoPlay + "&InvalidGameCodeAccessUrl=" + EWinWeb.CasinoWorldUrl + "/InvalidGameCodeAccess.aspx");
        } else {
            Response.Write("LoginStateExpire");
            Response.Flush();
            Response.End();
        }
    }
%>
<!doctype html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BM</title>
</head>

<body>
    <div class="loader-container">
        <div class="loader-box">
            <div class="loader-spinner">
                <div></div>
            </div>
            <div class="loader-text">Loading...</div>
        </div>
        <div class="loader-backdrop"></div>
    </div>
</body>
</html>
