<%@ Page Language="C#" %>
<%
    string Version=EWinWeb.Version;
    bool showMsg = false;
    string msgContent = null;
    string DefaultCompany = Request["CompanyCode"];
    string Lang = string.Empty;

    if (string.IsNullOrEmpty(Request["Lang"]) == false) {
        Lang = Request["Lang"];
    } else {
        Lang = "ENG";
    }

    string AgentVersion = EWinWeb.AgentVersion;
    //EWin.Agent.AgentAPI agentAPI = new EWin.Agent.AgentAPI();
    EWin.BmAgent.BmAgent agentAPI = new EWin.BmAgent.BmAgent();
    EWin.Login.LoginAPI loginAPI = new EWin.Login.LoginAPI();
    EWin.BmAgent.BmAgent api = new EWin.BmAgent.BmAgent();
    if (CodingControl.FormSubmit()) {

        EWin.BmAgent.LoginResult ASS = null;
        string CompanyCode = Request["CompanyCode"];
        string LoginType = Request["LoginType"];  //0=主帳戶登入/1=助手登入
        string LoginAccount = Request["LoginAccount"];
        string LoginPassword = Request["LoginPassword"];
        string LoginGUID = string.Empty;
        string Token;
        int RValue;
        Random R = new Random();

        RValue = R.Next(100000, 9999999);
        Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());
        LoginGUID = loginAPI.CreateLoginGUID(Token);

        if (LoginType == "0") {
            ASS = agentAPI.AgentLogin(LoginGUID, System.Guid.NewGuid().ToString(), 0, LoginAccount, LoginPassword, LoginAccount, CodingControl.GetUserIP());

        } else if (LoginType == "1") {
            string MainAccount = Request["MainAccount"];
            ASS = agentAPI.AgentLogin(LoginGUID, System.Guid.NewGuid().ToString(), 1, LoginAccount, LoginPassword, MainAccount, CodingControl.GetUserIP());
        }

        if (ASS != null) {
            if (ASS.Result ==  EWin.BmAgent.enumResult.OK) {
                Response.SetCookie(new HttpCookie("ASID", ASS.AID));
                Response.Redirect("Index.aspx?DefaultCompany=" + DefaultCompany + "&Lang=" + Lang);
            } else {
                switch (ASS.Message) {
                    case "AccountIsLocked":
                        showMsg = true;
                        msgContent = "帳號鎖定,請等待10分鐘後再嘗試登入";
                        break;
                    case "Denied":
                        showMsg = true;
                        msgContent = "此帳號無使用權限";
                        break;
                    case "IdentityMismatch":
                        showMsg = true;
                        msgContent = "此帳號無使用權限";
                        break;
                    default:
                        showMsg = true;
                        msgContent = "登入失敗,帳號或密碼錯誤";
                        break;
                }
            }
        } else {
            showMsg = true;
            msgContent = "登入失敗";
        }
    } else {
        if (string.IsNullOrEmpty(DefaultCompany) == false) {
            Response.Redirect("login.aspx?C=" + DefaultCompany);
        } else {
            Response.Redirect("login.aspx");
        }
    }
%>
<!doctype html>
<html lang="zh-Hant-TW">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/basic.min.css?<%:AgentVersion%>">
    <link rel="stylesheet" href="css/main2.css?<%:AgentVersion%>">
</head>
<script src="/Scripts/Common.js"></script>
<script src="/Scripts/bignumber.min.js"></script>
<script src="/Scripts/Math.uuid.js"></script>
<script src="Scripts/MultiLanguage.js"></script>
<script>
    var c = new common();
    var lang;
    var defaultCompany = "<%=CodingControl.JSEncodeString(DefaultCompany)%>";
    var showMsg = <%=((showMsg) ? "true" : "false") %>;
    //var msgContent = "<%=CodingControl.JSEncodeString(msgContent)%>";
    var msgContent = "<%=msgContent%>";
    var mlp;
    var v ="<%:Version%>";
    function showMessage(title, msg, cbOK, cbCancel) {
        var idMessageBox = document.getElementById("idMessageBox");
        var idMessageTitle = document.getElementById("idMessageTitle");
        var idMessageText = document.getElementById("idMessageText");
        var idMessageButtonOK = document.getElementById("idMessageButtonOK");
        var idMessageButtonCancel = document.getElementById("idMessageButtonCancel");

        var funcOK = function () {
            c.removeClassName(idMessageBox, "show");

            if (cbOK != null)
                cbOK();
        }

        var funcCancel = function () {
            c.removeClassName(idMessageBox, "show");

            if (cbCancel != null)
                cbCancel();
        }

        if (idMessageTitle != null)
            idMessageTitle.innerHTML = title;

        if (idMessageText != null)
            idMessageText.innerHTML = msg;

        if (idMessageButtonOK != null) {
            idMessageButtonOK.style.display = "block";
            idMessageButtonOK.onclick = funcOK;
        }

        if (idMessageButtonCancel != null) {
            idMessageButtonCancel.style.display = "block";
            idMessageButtonCancel.onclick = funcCancel;
        }

        c.addClassName(idMessageBox, "show");
    }

    function showMessageOK(title, msg, cbOK) {
        var idMessageBox = document.getElementById("idMessageBox");
        var idMessageTitle = document.getElementById("idMessageTitle");
        var idMessageText = document.getElementById("idMessageText");
        var idMessageButtonOK = document.getElementById("idMessageButtonOK");
        var idMessageButtonCancel = document.getElementById("idMessageButtonCancel");

        var funcOK = function () {
            c.removeClassName(idMessageBox, "show");

            if (cbOK != null)
                cbOK();
        }

        if (idMessageTitle != null)
            idMessageTitle.innerHTML = title;

        if (idMessageText != null)
            idMessageText.innerHTML = msg;

        if (idMessageButtonOK != null) {
            idMessageButtonOK.style.display = "block";
            idMessageButtonOK.onclick = funcOK;
        }

        if (idMessageButtonCancel != null) {
            idMessageButtonCancel.style.display = "none";
        }

        c.addClassName(idMessageBox, "show");
    }

    function init() {
        lang = window.localStorage.getItem("agent_lang");

        mlp = new multiLanguage(v);
        mlp.loadLanguage(lang, function () {
            if (showMsg) {
                showMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(msgContent), function () {
                    if ((defaultCompany != null) && (defaultCompany != ""))
                        window.location.href = "login.aspx?C=" + defaultCompany;
                    else
                        window.location.href = "login.aspx";
                });
            }
        });

        
    }

    window.onload = init;
</script>
<body>
    <div class="popUp" id="idMessageBox">
        <div class="popUpWrapper">
            <div class="popUp__title" id="idMessageTitle">[Title]</div>
            <div class="popUp__content" id="idMessageText">
                [Msg]
            </div>
            <div class="popUp__footer">
                <div class="form-group-popupBtn">
                    <div class="btn btn-popup-confirm" id="idMessageButtonOK">OK</div>
                    <div class="btn btn-popup-cancel" id="idMessageButtonCancel">Cancel</div>
                </div>
            </div>           
        </div>
    </div>
</body>

</html>
