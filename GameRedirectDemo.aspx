<%@ Page Language="C#" %>

<%        
    string SelectGameBrand = Request["SelectGameBrand"];
    string Lang;
    EWinWeb.enumUserDeviceType UDT = EWinWeb.GetUserDeviceType(Request.UserAgent);

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



    if (SelectGameBrand == "BM")
    {
        var loginAPI = new EWin.Login.LoginAPI();
        var LoginGUID = loginAPI.CreateLoginGUID(EWinWeb.GetToken());


       // Response.Redirect(EWinWeb.EWinUrl + "/Game/LoginGuest.aspx?Lang=" + Lang + "&LoginGUID=" + LoginGUID + "&ImageCode=" + ImageCode + "&Action=Game");
    }
    else if (SelectGameBrand == "PS")
    {
        Response.Redirect(EWinWeb.EWinUrl + "/API/GamePlatformAPI2/UserLogin.aspx?Language=" + Lang + "&CurrencyType=" + "USDT" + "&GameCode=" + "PS.Sport" + "&HomeUrl=" + HttpUtility.UrlEncode(EWinWeb.WebUrl) + "&DemoPlay=1" + "&InvalidGameCodeAccessUrl=" + HttpUtility.UrlEncode(EWinWeb.WebUrl + "/InvalidGameCodeAccess.aspx"));
    }
    else if (SelectGameBrand == "DBES")
    {
        Response.Redirect(EWinWeb.EWinUrl + "/API/GamePlatformAPI2/UserLogin.aspx?Language=" + Lang + "&CurrencyType=" + "USDT" + "&GameCode=" + "DBES.eSport" + "&HomeUrl=" + HttpUtility.UrlEncode(EWinWeb.WebUrl) + "&DemoPlay=1" + "&InvalidGameCodeAccessUrl=" + HttpUtility.UrlEncode(EWinWeb.WebUrl + "/InvalidGameCodeAccess.aspx"));
    }
    else
    {
        Response.Redirect("index.html");
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
