<%@ Page Language="C#" %>
<%
    EWin.Login.LoginAPI LoginAPI = new EWin.Login.LoginAPI();
    string LoginGUID;
    string Token;
    byte[] ContentBytes = null;
    int RValue;
    Random R = new Random();

    LoginGUID = Request["LoginGUID"];

    RValue = R.Next(100000, 9999999);
    Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());


    ContentBytes = LoginAPI.GetValidateImage(Token, LoginGUID);

    Response.Clear();

    if (ContentBytes != null) {
        Response.ContentType = "image/png";
        Response.AddHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        Response.AddHeader("Pragma", "no-cache");

        Response.BinaryWrite(ContentBytes);
    }

    Response.Flush();
    Response.End();
%>
<%="" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title></title>
</head>
<body>
</body>
</html>
