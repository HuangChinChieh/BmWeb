<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserAccountAgentMulti_Login.aspx.cs" Inherits="UserAccountAgentMulti_Login" %>

<%
    string AgentVersion = EWinWeb.AgentVersion;
%>
<!doctype html>
<html lang="zh-Hant-TW" class="innerHtml">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>代理網</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/basic.min.css?<%:AgentVersion%>">
    <link rel="stylesheet" href="css/main2.css?<%:AgentVersion%>">
    <link rel="stylesheet" href="css/layoutADJ.css?<%:AgentVersion%>">
    <link rel="stylesheet" href="css/downline.css?<%:AgentVersion%>">
    <script type="text/javascript" src="/Scripts/Common.js?20191127"></script>
    <script type="text/javascript" src="/Scripts/UIControl.js"></script>
    <script type="text/javascript" src="Scripts/MultiLanguage.js"></script>
    <script type="text/javascript" src="/Scripts/Math.uuid.js"></script>
    <script type="text/javascript" src="/Scripts/bignumber.min.js"></script>
    <script type="text/javascript" src="/Scripts/SelectItem.js"></script>
    <script type="text/javascript" src="js/AgentCommon.js"></script>
    <script type="text/javascript" src="../Scripts/jquery-3.3.1.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/google-libphonenumber/3.2.31/libphonenumber.min.js"></script>
    <script type="text/javascript">
        var c = new common();
        var ac = new AgentCommon();
        var ApiUrl = "UserAccountAgentMulti_Login.aspx";
        var mlp;
        var EWinInfo;
        var api;
        var lang;
        var childList;


        function SwitchUser(LoginAccount) {
            var postObj;

            window.parent.API_ShowMessage(mlp.getLanguageKey("帳號切換"), mlp.getLanguageKey("確定切換此帳號"), function () {
                postObj = {
                    AID: EWinInfo.ASID,
                    LoginAccount: LoginAccount
                };

                window.parent.c.callService(ApiUrl + "/AgentMultoLogin", postObj, function (success, o) {
                    if (success) {
                        var obj = c.getJSON(o);
                        if (obj.Result == 0) {
                            parent.API_setCookie("ASID", obj.Message, 365);
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("完成"), mlp.getLanguageKey("切換完成"), function () {
                                window.parent.location.reload();
                            });
                        }
                        else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message));
                        }

                    }
                    else {
                        if (o == "Timeout") {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後再嘗試"));
                        } else {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o));
                        }
                    }

                    window.parent.API_CloseLoading();

                });

            })
        }


        function setUserAccountAgentMuti(cb) {
            var idUserList = document.getElementById("idUserList");
            var postObj;
            var hasNoData = true;
            var btnSwitchUser;

            c.clearChildren(idUserList);
            api.QueryUserInfo(EWinInfo.ASID, Math.uuid(), function (success, o) {
                if (success) {
                    if (o.ResultState == 0) {
                        if (o.MultiLoginList.length > 1) {
                            hasNoData = false;
                            for (var i = 0; i < o.MultiLoginList.length; i++) {
                                if (o.MultiLoginList[i].LoginAccount != EWinInfo.UserInfo.LoginAccount) {
                                    var temp = c.getTemplate("templateTableItem");

                                    //c.setClassText(temp, "mtAgentLoignAccount", null, EWinInfo.UserInfo.LoginAccount);
                                    c.setClassText(temp, "mtAgentLoignAccount", null, o.MultiLoginList[i].LoginAccount);
                                    //c.setClassText(temp, "mtLoginAccount", null, o.MultiLoginList[i].LoginAccount);
                                    c.setClassText(temp, "mtDescription", null, o.MultiLoginList[i].Description);

                                    btnSwitchUser = c.getFirstClassElement(temp, "btnSwitchUser");
                                    btnSwitchUser.onclick = new Function("SwitchUser('" + o.MultiLoginList[i].LoginAccount + "')");


                                    idUserList.appendChild(temp);

                                }
                            }
                        }
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o.Message));

                        if (cb)
                            cb(false);
                    }
                } else {
                    if (o == "Timeout") {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey("網路異常, 請稍後再嘗試"));
                    } else {
                        window.parent.API_ShowMessageOK(mlp.getLanguageKey("錯誤"), mlp.getLanguageKey(o));
                    }
                }

                if (hasNoData) {
                    $("#idNoData").show();
                }

            });


        }



        function init() {
            EWinInfo = window.parent.EWinInfo;
            api = window.parent.API_GetAgentAPI();

            lang = window.localStorage.getItem("agent_lang");
            mlp = new multiLanguage();
            mlp.loadLanguage(lang, function () {
                setUserAccountAgentMuti();
                window.parent.API_CloseLoading();
            });
        }

        window.onload = init;

    </script>
</head>
<body class="innerBody">
    <main>
        <div class="container-fluid">
            <h1 class="page__title "><span class="language_replace">多重帳號切換</span></h1>

            <div class="MemberList MemberList__Assistant">
                <div id="idUserList" class="row">
                </div>

                <div class="MT__tableDiv MT_tableDiv__hasNoData" id="idNoData" style="display:none">
                    <!-- 自訂表格 -->
                    <div class="MT__table table-col-8 w-200">
                        <!-- 表格上下滑動框 -->
                        <div class="tbody tbody__hasNoData" id="idList">
                            <div id="hasNoData_DIV" class="td__content td__hasNoData">無數據</div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </main>

    <div id="templateTableItem" style="display: none">
        <div class="col-12 col-md-6 col-xl-4">
            <div class="item">
                <div class="downline__overview">
                    <div class="downline__header">
                        <span class="downline__account mtAgentLoignAccount">--</span>
                        <div class="function-execute">
                            <span class="downline__enterance downline-link btnSwitchUser">
                                <a class="" href=""><i class="icon icon-ewin-input-user-multi-exchange"></i><span class="language_replace">切換</span></a>
                            </span>
                        </div>
                    </div>
                    <div class="downline__info">
                        <%--<div class="name "><span class="language_replace mtLoginAccount">帳號</span></div>--%>
                        <div class="name "><span class="language_replace mtDescription">描述</span></div>
                    </div>

                </div>
            </div>
        </div>
    </div>

</body>
</html>
