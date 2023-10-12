<%@ Page Language="C#" %>

<%
    string CT = Request["CT"];
    string SID = "";
    string SelectGameBrand = Request["SelectGameBrand"];
    string CurrencyType = Request["CurrencyType"];
    string Lang;

    if (string.IsNullOrEmpty(Request["Lang"]))
    {
        string userLang = CodingControl.GetDefaultLanguage();

        if (userLang.ToUpper() == "zh-TW".ToUpper()) { Lang = "CHT"; }
        else if (userLang.ToUpper() == "zh-HK".ToUpper()) { Lang = "CHT"; }
        else if (userLang.ToUpper() == "zh-MO".ToUpper()) { Lang = "CHT"; }
        else if (userLang.ToUpper() == "zh-CHT".ToUpper()) { Lang = "CHT"; }
        else if (userLang.ToUpper() == "zh-CHS".ToUpper()) { Lang = "CHS"; }
        else if (userLang.ToUpper() == "zh-SG".ToUpper()) { Lang = "CHS"; }
        else if (userLang.ToUpper() == "zh-CN".ToUpper()) { Lang = "CHS"; }
        else if (userLang.ToUpper() == "zh".ToUpper()) { Lang = "CHS"; }
        else if (userLang.ToUpper() == "en-US".ToUpper()) { Lang = "ENG"; }
        else if (userLang.ToUpper() == "en-CA".ToUpper()) { Lang = "ENG"; }
        else if (userLang.ToUpper() == "en-PH".ToUpper()) { Lang = "ENG"; }
        else if (userLang.ToUpper() == "en".ToUpper()) { Lang = "ENG"; }
        else if (userLang.ToUpper() == "ko-KR".ToUpper()) { Lang = "KOR"; }
        else if (userLang.ToUpper() == "ko-KP".ToUpper()) { Lang = "KOR"; }
        else if (userLang.ToUpper() == "ko".ToUpper()) { Lang = "KOR"; }
        else if (userLang.ToUpper() == "ja".ToUpper()) { Lang = "JPN"; }
        else { Lang = "ENG"; }
    }
    else
    {
        Lang = Request["Lang"];
    }

    if (string.IsNullOrEmpty(CT) || string.IsNullOrEmpty(SelectGameBrand) || string.IsNullOrEmpty(CurrencyType))
    {
        Response.Redirect("index.html");
    }
    else
    {
        try
        {
            // 轉換出 Token 與 SID
            SID = EWinWeb.DecodeClientToken(CT).SID;        

        }
        catch (Exception ex) { }

        if (!string.IsNullOrEmpty(SID))
        {
            EWin.Lobby.APIResult R;
            EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();

            R = lobbyAPI.KeepSID(EWinWeb.GetToken(), SID, System.Guid.NewGuid().ToString());

            if (R.Result == EWin.Lobby.enumResult.OK)
            {


                try { CodingControl.GetWebTextContent(EWinWeb.EWinAPIUrl + "/API/GamePlatformAPI2/UserLogout.aspx?CT=" + Server.UrlEncode(CT) + "&CurrencyType=" + CurrencyType, "GET"); }
                catch (Exception ex) { }

                if (SelectGameBrand == "BM")
                {
                    Response.Redirect(EWinWeb.EWinUrl + "/Game/Login.aspx?CT=" + Server.UrlEncode(CT) + "&Lang=" + Lang + "&Action=Game");
                }
                else if (SelectGameBrand == "PS")
                {
                    Response.Redirect(EWinWeb.EWinUrl + "/API/GamePlatformAPI2/UserLogin.aspx?SID=" + SID + "&Language=" + Lang + "&CurrencyType=" + CurrencyType + "&GameCode=" + "PS.Sport" + "&HomeUrl=" + HttpUtility.UrlEncode(EWinWeb.WebUrl) + "&DemoPlay=0" + "&InvalidGameCodeAccessUrl=" + HttpUtility.UrlEncode(EWinWeb.WebUrl + "/InvalidGameCodeAccess.aspx"));
                }
                else if (SelectGameBrand == "DBES")
                {
                    Response.Redirect(EWinWeb.EWinUrl + "/API/GamePlatformAPI2/UserLogin.aspx?SID=" + SID + "&Language=" + Lang + "&CurrencyType=" + CurrencyType + "&GameCode=" + "DBES.eSport" + "&HomeUrl=" + HttpUtility.UrlEncode(EWinWeb.WebUrl) + "&DemoPlay=0" + "&InvalidGameCodeAccessUrl=" + HttpUtility.UrlEncode(EWinWeb.WebUrl + "/InvalidGameCodeAccess.aspx"));
                }
                else
                {
                    Response.Redirect("index.html");
                }
            }
            else
            {
                Response.Redirect("index.html");
            }
        }
        else
        {
            Response.Redirect("index.html");
        }
    }


%>
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="Content-Language" content="zh-cn">
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="pragma" content="no-cache" />
</head>
<body style="width: 100%">
</body>
</html>
