<%@ Page Language="C#" AutoEventWireup="true" CodeFile="LoginRecover.aspx.cs" Inherits="LoginRecover" %>

<%
    EWin.Login.LoginAPI LoginAPI = new EWin.Login.LoginAPI();
    RecoverResult ResultObj = new RecoverResult();


    string Token = string.Empty;
    string SID = string.Empty;
    string MsgContent = string.Empty;
    string RecoverToken = string.Empty;
    string LoginAccount = string.Empty;

    LoginAccount = Request["LoginAccount"];
    RecoverToken = Request["RecoverToken"];

    //if ((string.IsNullOrEmpty(RecoverToken) == false) && (string.IsNullOrEmpty(Token) == false))
    if ((string.IsNullOrEmpty(RecoverToken) == false)) {
        EWin.Login.LoginResult LoginResult;
        int RValue;
        Random R = new Random();

        // 重新產生 Token
        RValue = R.Next(100000, 9999999);
        Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());

        // 嘗試恢復登入狀態
        LoginResult = LoginAPI.RecoverLogin(Token, RecoverToken, CodingControl.GetUserIP());
        if (LoginResult != null) {
            if (LoginResult.ResultState == EWin.Login.enumResultState.OK) {
                SID = RedisCache.SessionContext.CreateSID(EWinWeb.CompanyCode, LoginAccount, CodingControl.GetUserIP(), false, LoginResult.SID, LoginResult.CT);

                if (string.IsNullOrEmpty(SID) == false) {
                    ResultObj.ResultCode = RecoverResult.enumResultCode.OK;
                    ResultObj.Token = Token;
                    ResultObj.LoginAccount = LoginAccount;
                    ResultObj.SID = SID;
                    ResultObj.CT = LoginResult.CT;
                    ResultObj.RecoverToken = LoginResult.RecoverToken;
                } else {
                    ResultObj.ResultCode = RecoverResult.enumResultCode.ERR;
                    ResultObj.Message = "ServerError";
                }
            } else {
                ResultObj.ResultCode = RecoverResult.enumResultCode.ERR;
                ResultObj.Message = "";
            }
        } else {
            ResultObj.ResultCode = RecoverResult.enumResultCode.ERR;
            ResultObj.Message = "ServerError";
        }
    } else {
        ResultObj.ResultCode = RecoverResult.enumResultCode.ERR;
        ResultObj.Message = "InvalidToken";
    }

    Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(ResultObj));
    Response.Flush();
    Response.End();
%>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
</body>
</html>
