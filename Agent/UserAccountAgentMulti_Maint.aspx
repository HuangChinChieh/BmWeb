<%@ Page Language="C#" %>

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
        var mlp;
        var EWinInfo;
        var api;
        var lang;
        var childList;


        function EditAccount(LoginAccount) {
            window.parent.API_NewWindow(mlp.getLanguageKey("多重帳號編輯"), "UserAccountAgentMuti_Edit.aspx?LoginAccount=" + LoginAccount);
        }

        function DelAccount(LoginAccount) {
            window.parent.API_ShowMessage(mlp.getLanguageKey("多重帳號移除"), mlp.getLanguageKey("確定移除此帳號"), function () {
                api.RemoveMultiLogin(EWinInfo.ASID, Math.uuid(), LoginAccount, function (success, o) {
                    if (success) {
                        if (o.ResultState == 0) {
                            window.parent.API_ShowMessageOK(mlp.getLanguageKey("完成"), mlp.getLanguageKey("更新完成"), function () {
                                window.parent.API_CloseWindow(true);
                            });
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
                })
            },null)
        }


        function setUserAccountAgentMuti(cb) {
            var idUserList = document.getElementById("idUserList");
            var postObj;
            var hasNoData = true;
            var btnEditUser;
            var btnDelUser;

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

                                    btnEditUser = c.getFirstClassElement(temp, "btnEditUser");
                                    btnEditUser.onclick = new Function("EditAccount('" + o.MultiLoginList[i].LoginAccount + "')");

                                    btnDelUser = c.getFirstClassElement(temp, "btnDelUser");
                                    btnDelUser.onclick = new Function("DelAccount('" + o.MultiLoginList[i].LoginAccount + "')");


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
            <h1 class="page__title "><span class="language_replace">多重帳號維護</span></h1>

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
                            <span class="downline__enterance downline-link btnEditUser">
                                <a class="" href=""><i class="icon icon2020-pencil-1"></i><span class="language_replace">編輯</span></a>
                            </span>
                            <span class="downline__enterance downline-link btnDelUser">
                                <a class="" href=""><i class="icon icon-ewin-input-delete"></i><span class="language_replace">移除</span></a>
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