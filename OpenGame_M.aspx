<%@ Page Language="C#" %>

<% 
    string SID;
    string Lang;
    string GameCode;
    string CurrencyType;
    string LoginAccount;
    string CompanyCode;

    string EWinUrl = EWinWeb.EWinUrl;

    SID = Request["SID"];
    Lang = Request["Lang"];
    GameCode = Request["GameCode"];
    CurrencyType = Request["CurrencyType"];
    LoginAccount = Request["LoginAccount"];
    CompanyCode = Request["CompanyCode"];
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link rel="stylesheet" href="css/basic.min.css">
    <link rel="stylesheet" href="css/main.css">
    <script type="text/javascript" src="/Scripts/LobbyAPI.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
    <script type="text/javascript" src="/Scripts/NoSleep.js"></script>
    <script type="text/javascript" src="/Scripts/Common.js"></script>
</head>
<script>
    var SID = "<%=SID%>";
    var Lang = "<%=Lang%>";
    var GameCode = "<%=GameCode%>";
    var CurrencyType = "<%=CurrencyType%>";
    var EWinUrl = "<%=EWinUrl%>";
    var LoginAccount = "<%=LoginAccount%>";
    var CompanyCode = "<%=CompanyCode%>";
    var lobbyClient;
    var noSleep;
    var c = new common();

    function GoBack() {
        noSleep.disable();
        userlogout(function () {
            window.location.href = "/index.aspx?SID=" + SID;
        });
    
    }

    function init() {
     
        noSleep = new NoSleep();
        noSleep.disable();

        document.addEventListener('click', function enableNoSleep() {
            document.removeEventListener('click', enableNoSleep, false);
            noSleep.enable();
        }, false);

        lobbyClient = new LobbyAPI("/API/LobbyAPI.asmx");
        var IFramePage = document.getElementById("GameIFramePage");

        IFramePage.src = "/OpenGame.aspx?SID=" + SID + "&Lang=" + Lang + "&CurrencyType=" + CurrencyType + "&GameCode=" + GameCode + "&HomeUrl=" + "<%=EWinWeb.CasinoWorldUrl%>/CloseGame.aspx";;

        window.setInterval(function () {
            var guid = Math.uuid();

            lobbyClient.KeepSID(SID, guid, function (success, o) {
                if (success == true) {
                    if (o.Result == 0) {

                    } else {

                    }
                }
            });
        }, 10000);
    }

    function userlogout(cb) {
        var guid = Math.uuid();
        lobbyClient.GetUserAccountGameCodeOnlineList(SID, guid, function (success, o) {
            if (success == true) {
                if (o.Result == 0) {
                    if (o.OnlineList && o.OnlineList.length > 0) {
                        var promiseAll=[];
                        for (var i = 0; i < o.OnlineList.length; i++) {
                            var gameBrand = o.OnlineList[i].GameBrand;
                            var url = EWinUrl + "/API/GamePlatformAPI2/" + gameBrand + "/UserLogout.aspx?LoginAccount=" + LoginAccount + "&CompanyCode=" + CompanyCode + "&SID=" + o.Message;
                            var promise = new Promise((resolve, reject) => {
                                $.get(url, function (result) {
                                    console.log(result);
                                    resolve();
                                });
                            });

                            promiseAll.push(promise);
                        }
                    }

                    Promise.all(promiseAll).then(values => {
                        cb();
                    });
                } else {
                    cb();
                }
            }
        });
    }

    window.onload = init;
</script>
<body>
    <div class="divGameWrapperMobile">
        <div class="divGameFrameMobile"> 
            <iframe style="height: 100%; width: 100%; background-color: black" id="GameIFramePage"></iframe>
        </div>
        <div class="menu-bar">
            <button class="btn btn-game-close" onclick="GoBack()">
                <i class="icon icon-mask icon-error"></i>
            </button>
        </div>
    </div>   
</body>
</html>
