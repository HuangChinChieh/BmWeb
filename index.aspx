<%@ Page Language="C#" %>

<%
    string Token;
    int RValue;
    Random R = new Random();
    EWin.Login.GeoClass GC;
    EWin.Login.LoginAPI API = new EWin.Login.LoginAPI();
    EWin.Login.LoginResult Ret;
    string UserIP = CodingControl.GetUserIP();
    string LoginGUID;
    string Bulletin = string.Empty;
    string Lang;
    MultiLanguageParser MLP;
    bool IsChina = false;
    string FileData = string.Empty;
    string isModify = "0";
    string[] stringSeparators = new string[] { "&&_" };
    string[] Separators;
    string ViVerify;
    string UnixTimeStamp;


    GC = API.GetGeoCode(UserIP);

    if (GC != null)
    {
        if ((GC.GeoCountry == "TW") && (UserIP != "112.121.69.46"))
        {
            //Response.Redirect("IPDenied.html");
            //Response.Flush();
            //Response.End();
        }
        else if (GC.GeoCountry == "CN")
        {
            IsChina = true;
        }
        else if (GC.GeoCountry == "PH")
        {
            string[] ipList = new string[] {
                "103.151.28.225",
                "103.151.28.226",
                "103.151.28.227",
                "103.151.28.228",
                "103.151.28.229",
                "103.151.28.230",
                "103.151.28.231"
            };

            if (!ipList.Contains(UserIP))
            {
                Response.Redirect("IPDenied.html");
                Response.Flush();
                Response.End();
            }
        }
        //Response.Write(GC.GeoCountry)
    }

    IsChina = false;

    Token = EWinWeb.GetToken();

    if (CodingControl.FormSubmit())
    {
        string LoginAccount = Request["LoginAccount"];
        string LoginPassword = Request["LoginPassword"];
        string ImageCode = Request["ImageCode"];
        string GuestLogin = Request["GuestLogin"];
        string CT;

        Lang = Request["Lang"];
        LoginGUID = Request["LoginGUID"];
        MLP = new MultiLanguageParser(Lang);

        if (GuestLogin != "1")
        {
            if ((LoginAccount != string.Empty) && (LoginAccount != null))
            {
                if ((LoginPassword != string.Empty) && (LoginPassword != null))
                {
                    if ((ImageCode != string.Empty) && (ImageCode != null))
                    {
                        Ret = API.UserLogin(Token, LoginGUID, LoginAccount, LoginPassword, EWinWeb.CompanyCode, ImageCode, CodingControl.GetUserIP());
                        if (Ret.ResultState == EWin.Login.enumResultState.OK)
                        {
                            CT = Ret.CT;

                            Response.Redirect(EWinWeb.EWinUrl + "/Game/Login.aspx?CT=" + Server.UrlEncode(CT) + "&Lang=" + Lang + "&Action=Game");

                            //if (IsChina == true)
                            //    Response.Redirect(EWinWeb.EWinUrl + ":1443" + "/Game/Login.aspx?CT=" + Server.UrlEncode(CT) + "&Lang=" + Lang + "&Action=Game");
                            //else
                            //    Response.Redirect(EWinWeb.EWinUrl + "/Game/Login.aspx?CT=" + Server.UrlEncode(CT) + "&Lang=" + Lang + "&Action=Game");
                        }
                        else
                        {
                            EWinWeb.AlertMessage(MLP.GetLanguageKey("Login failure:") + MLP.GetLanguageKey(Ret.Message), "/Refresh.aspx?index.aspx");
                        }
                    }
                    else
                    {
                        EWinWeb.AlertMessage(MLP.GetLanguageKey("invalid image validate code"), "/Refresh.aspx?index.aspx");
                    }
                }
                else
                {
                    EWinWeb.AlertMessage(MLP.GetLanguageKey("invalid login password"), "/Refresh.aspx?index.aspx");
                }
            }
            else
            {
                EWinWeb.AlertMessage(MLP.GetLanguageKey("invalid login account"), "/Refresh.aspx?index.aspx");
            }
        }
        else
        {
            // 訪客登入
            if ((ImageCode != string.Empty) && (ImageCode != null))
            {
                Response.Redirect(EWinWeb.EWinUrl + "/Game/LoginGuest.aspx?Lang=" + Lang + "&LoginGUID=" + LoginGUID + "&ImageCode=" + ImageCode + "&Action=Game");

                //if (IsChina == true)
                //    Response.Redirect("https://cngame.ewin-soft.com:1443/Game/LoginGuest.aspx?Lang=" + Lang + "&LoginGUID=" + LoginGUID + "&ImageCode=" + ImageCode + "&Action=Game");
                //else
                //    Response.Redirect(EWinWeb.EWinUrl + "/Game/LoginGuest.aspx?Lang=" + Lang + "&LoginGUID=" + LoginGUID + "&ImageCode=" + ImageCode + "&Action=Game");
            }
            else
            {
                EWinWeb.AlertMessage(MLP.GetLanguageKey("invalid image validate code"), "/Refresh.aspx?index.aspx");
            }
        }
    }

    LoginGUID = API.CreateLoginGUID(Token);

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

    UnixTimeStamp = CodingControl.GetUnixTimestamp(DateTime.Now, CodingControl.enumUnixTimestampType.Seconds).ToString();
    ViVerify = UnixTimeStamp + "-" + HttpUtility.UrlEncode(CodingControl.GetSHA256("/ValidateImage.aspx" + UnixTimeStamp));
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>BM VIP CLUB</title>
    <meta name="viewport" content="width=device-width, initial-scale=1,user-scalable=yes">
    <link rel="shortcut icon" href="images/logo_300.png" />
    <link rel="Bookmark" href="images/logo_300.png" />
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="images/logo_300.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="images/logo_300.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="images/logo_300.png">
    <link rel="apple-touch-icon-precomposed" href="images/logo_300.png">
    <link rel="stylesheet" href="css/reset.css">
    <link rel="stylesheet" href="css/css.css">
    <link rel="stylesheet" href="css/iconfont.css">
    <link href="https://fonts.googleapis.com/css?family=Amiri|Open+Sans" rel="stylesheet">
    <!-- banner -->
    <link rel="stylesheet" href="css/flexslider.css" type="text/css" media="screen" />
    <link rel="stylesheet" href="css/magnific-popup.css">
    <link rel="stylesheet" href="css/magnific.css">

    <!--  script         -->
    <script type="text/javascript">
        function codepopup() {
            var codeDivPopUp = document.getElementById("codeDiv");
            var loginDivHidden = document.getElementById("loginDiv");
            codeDivPopUp.classList.add("codeDivPopUp");
            loginDivHidden.classList.add("loginDivHidden");
        }
        function codeHidden() {
            var codeDivPopUp = document.getElementById("codeDiv");
            var loginDivHidden = document.getElementById("loginDiv");
            codeDivPopUp.classList.remove("codeDivPopUp");
            loginDivHidden.classList.remove("loginDivHidden");
        }
    </script>


</head>
<script language="javascript" src="Scripts/MultiLanguage.js"></script>
<script language="javascript" src="Scripts/Math.uuid.js"></script>
<script language="javascript" src="Scripts/qcode-decoder.min.js"></script>
<script language="javascript">
    var mlp;
    var Lang = "<%=Lang%>";
    var qr = new QCodeDecoder();
    var hasBulletin = <%=(string.IsNullOrEmpty(Bulletin) ? "false" : "true")%>;
   

    function btnLoginGuest() {
        document.forms[0].GuestLogin.value = "1";
        createValidateImage();
        codepopup();
    }

    function btnLogin() {
        document.forms[0].GuestLogin.value = "0";
        createValidateImage();
        codepopup();
    }

    function createValidateImage() {
        var iGUID;
        var viVerify;
        var iURL;
        var ValidateImage = document.getElementById("ValidateImage");

        viVerify = "<%=ViVerify%>";
        iGUID = "<%=LoginGUID%>";
        document.forms[0].LoginGUID.value = iGUID;

        iURL = "ValidateImage.aspx?verify=" + viVerify + "&LoginGUID=" + iGUID;



        ValidateImage.src = iURL;
        ValidateImage.style.display = "inline";
    }

    function setLanguage(c, cb) {
        Lang = c;

        window.localStorage.setItem("Lang", Lang);
        document.forms[0].Lang.value = Lang;

        mlp.loadLanguage(Lang, function () {
            if (cb)
                cb();
        });

    }

    function init() {
        if (window.localStorage.getItem("Lang") != null) {
            Lang = window.localStorage.getItem("Lang");
        }

        if ((Lang == "") || (Lang == null)) {
            Lang = "ENG";
        }


        document.getElementById("idlangSel").value = Lang;
        mlp = new multiLanguage();
        setLanguage(Lang, function () {
            //createValidateImage();
        });
    }

    function langSelChange(e) {
        var sel = e.currentTarget;
        var lang = sel.value;

        setLanguage(lang);
    }


    function downloadAPP() {
        // 獲取用戶代理字符串
        var userAgent = navigator.userAgent;

        // 定義一些常見的裝置關鍵字
        var isMobile = /iPhone|iPad|iPod|Android|Windows Phone/i.test(userAgent);
        var isTablet = /iPad|Android/i.test(userAgent);
        var isiOS = /iPad|iPhone|iPod/i.test(userAgent);

        // 顯示結果
        if (isMobile || isTablet) {
            if (isiOS) {
                window.open("./download/bm.mobileconfig");

                API_ShowMessageOK(mlp.getLanguageKey("提醒"), mlp.getLanguageKey("按下確認後開始安裝描述檔"), () => {
                    document.getElementById("loadFrame").src = './download/bm.mobileprovision';
                });
            } else {
                window.open("./download/bm.apk");
            }
        } else {
            API_ShowMessageOK(mlp.getLanguageKey("提醒"), mlp.getLanguageKey("僅提供移動裝置下載"));
        }
    }

    function API_ShowMessageOK(title, msg, cbOK) {
        return showMessageOK(title, msg, cbOK);
    }

    function showMessageOK(title, msg, cbOK) {
        var idMessageBox = document.getElementById("idMessageBox");
        var idMessageTitle = document.getElementById("idMessageTitle");
        var idMessageText = document.getElementById("idMessageText");
        var idMessageWrapper = document.getElementById("idMessageWrapper");


        var tempBtns = idMessageBox.getElementsByClassName("tempMessageBtn")
        while (tempBtns.length > 0) {
            tempBtns[0].remove();
        }

        var idMessageButtonOK = document.createElement("div");
        idMessageButtonOK.innerHTML = "<span>OK</span>"
        idMessageButtonOK.classList.add("popupBtn_red")
        idMessageButtonOK.classList.add("tempMessageBtn")



        idMessageWrapper.appendChild(idMessageButtonOK);


        var funcOK = function () {
            idMessageBox.style.display = "none";

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

        idMessageBox.style.display = "block";
    }


    window.onload = init;
</script>
<style type="text/css">
    .downloadBtn {
        vertical-align: middle;
        text-align: center;
        color: #fff;
        width: 100%;
    }
        /*.downloadBtn a{
		display: block;
		width: 90%;
		line-height: 55px;
		background:  linear-gradient(to top, #eae0bc 0%, #dec284 27%, #debf7a 52%, #d5b66d 92%, #eae0bc 100%);
		border: 1px #aa822d solid;
		vertical-align: middle;
		color: #5a4415;
		border-radius: 10px;
		margin: 10px auto;
		box-shadow: 0px 0px 8px 2px rgba(0,0,0,0.5);
		margin-top: 10px;
	}*/
        .downloadBtn a {
            display: block;
            width: 90%;
            line-height: 55px;
            background: linear-gradient(to top, #eae0bc 0%, #dec284 27%, #debf7a 52%, #d5b66d 92%, #eae0bc 100%);
            border: 1px #aa822d solid;
            vertical-align: middle;
            color: #5a4415;
            border-radius: 10px;
            margin: 10px auto;
            box-shadow: 0px 0px 8px 2px rgba(0,0,0,0.5);
            margin-top: 10px;
        }

            .downloadBtn a:hover {
                margin-top: 10px;
            }

        .downloadBtn img {
            position: relative;
            top: -2px;
            width: auto;
            height: 25px;
            vertical-align: middle;
            opacity: 0.8;
            margin-right: 8px;
        }

            .downloadBtn img:first-child {
                width: 28px;
                height: 28px;
                margin-right: 2px;
            }

            .downloadBtn img:last-child {
            }

    .width-wrap__qrcodebox {
        max-width: 280px !important;
    }

    @media only screen and (max-width: 640px) {
        .width-wrap .width-wrap__qrcodebox {
            bottom: -4vw;
        }
    }

    .langSel_container {
        margin: 0px 35px 15px 35px;
        background-color: rgba(8, 7, 6, 0.8);
        border: 1px solid #d9c38f;
    }

    .langSel {
        width: 100%;
        background-color: transparent;
        color: white;
    }

        .langSel option {
            background-color: rgba(8, 7, 6, 0.8);
            border: 1px solid #d9c38f;
        }
</style>
<body>
    <!-- container -->
    <div class="container">
        <div id="myModal" class="reveal-modal">
            <!--<p>Welcome to the Resorts World Manila ASIA GOLD</p>-->
            <p><%=Bulletin %></p>
            <a class="close-reveal-modal">&#215;</a>
        </div>

        <!-- banner -->
        <div class="container__banner">
            <div class="width-wrap">
                <div class="width-wrap__qrcodebox">
                    <div class="qrcode">
                        <span class="language_replace">Scan for mobile phones</span>
                        <img src="images/indexQRCode.png">
                    </div>
                    <div class="langSel_container">
                        <select id="idlangSel" class="langSel" onchange="langSelChange(event)">
                            <option value="ENG">English</option>
                            <option value="CHS">简体中文</option>
                            <option value="JPN">日本語</option>
                            <option value="KOR">한국어</option>
                            <option value="CHT">繁體中文</option>
                        </select>
                    </div>
                    <div class="downloadBtn">
                        <!--div><a href="pcdownload.aspx"><img src="images/APPSTOREICON4.png"><img src="images/APPSTOREICON3.png"><span class="language_replace">APP Download</span></a></div-->
                        <div>
                            <a onclick="downloadAPP();" style="cursor: pointer">
                                <img src="images/APPSTOREICON4.png"><img src="images/APPSTOREICON3.png"><span class="language_replace">APP Download</span></a>
                        </div>
                    </div>
                </div>
                <div class="width-wrap__login">
                    <div class="login-logo">
                        <img src="images/login.png">
                        <p><span>BM VIP CLUB</span></p>
                    </div>
                    <form method="post">
                        <input type="hidden" name="LoginGUID" value="" />
                        <input type="hidden" name="GuestLogin" value="" />
                        <input type="hidden" name="Lang" value="ENG" />
                        <div id="loginDiv" class="form">
                            <fieldset>
                                <div class="form__field">
                                    <label class="form__label form__label--hide" for="Account"><span class="language_replace">Account</span></label>
                                    <div class="form__inputgroup">
                                        <i class="form-icon icon-user"></i>
                                        <input class="form__control boxsizing" id="LoginAccount" name="LoginAccount" type="text" language_replace="placeholder" placeholder="Please Input Account">
                                    </div>
                                </div>
                                <div class="form__field">
                                    <label class="form__label form__label--hide" for="Password"><span class="language_replace">Password</span></label>
                                    <div class="form__inputgroup">

                                        <i class="form-icon icon-more-horizontal"></i>
                                        <input class="form__control boxsizing" id="LoginPassword" name="LoginPassword" type="password" language_replace="placeholder" placeholder="Please Input Password">
                                    </div>
                                </div>
                                <!--button class="btn btn--mt" type="button" value="LOGIN">
                                    <span class="language_replace">系統維護中</span>
                                <button-->

                                <button class="btn btn--mt" type="button" value="LOGIN" onclick="btnLogin()">
                                    <i class="btn__icon icon-log-in"></i><span class="language_replace">Login</span>
                                </button>
                                <button class="btn" type="button" value="Register" onclick="window.location.href='register.aspx'">
                                    <span style="color: #5a4415" class="language_replace">Register</span>
                                </button>
                                <button class="btn guestBtn" type="button" value="GUEST LOGIN" onclick="btnLoginGuest()">
                                    <span class="language_replace">GUEST LOGIN</span>
                                </button>
                                <!--div class="btn btn--mt">
						<label class="QRcodeFileBtn_m">
                        <input type="file" onchange="QRScan(this)" accept="image/*" id="idQRImage" name="idQRImage"><span class="inputfile"><img src="images/QRcodeIcon.png" width="20px" height="20px" alt="QRcodeIcon"><span class="language_replace">QR CODE LOGIN</span></span>
						</label>	
                    </div-->
                                <!--
								<button class="btn btn--mt" type="button" value="QRCODE LOGIN">
                                    <i class="btn__icon icon-log-in"></i><span class="language_replace">QR CODE LOGIN</span>
                                </button>
                                -->
                            </fieldset>
                        </div>
                        <div id="QRCodeResult" style="width: 100%; color: #ffffff; text-align: center"></div>
                        <div id="codeDiv" class="codeDiv">
                            <div class="form">
                                <fieldset>
                                    <div class="form__field">
                                        <label class="form__label form__label--hide" for="Code"><span class="language_replace">Code</span></label>
                                        <div class="form__img">
                                            <img id="ValidateImage" style="display: none">
                                        </div>
                                        <div class="form__inputgroup">
                                            <i class="form-icon icon-lock"></i>
                                            <input class="form__control boxsizing" id="ImageCode" name="ImageCode" type="text" language_replace="placeholder" placeholder="Please Input Code">
                                        </div>
                                    </div>
                                    <button class="btn btn--mt" type="submit" value="LOGIN">
                                        <span class="language_replace">CONFIRM</span>
                                    </button>
                                    <button class="btn btn--mt" type="button" value="LOGIN" onclick="codeHidden()">
                                        <span class="language_replace">CANCEL</span>
                                    </button>
                                </fieldset>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            <div class="flexslider">
                <div class="flexsMask"></div>
                <ul class="slides">
                    <li>
                        <a href="javascript:;" title="LST">
                            <picture>
                                <!--
                                上傳大小   1920x800(desktop)
                                                768x800(mobile)
                            -->
                                <!--[if IE 9]><video style="display: none;"><![endif]-->
                                <source media="(min-width: 1024px)" srcset="images/banner2.jpg">
                                <source media="(max-width: 768px)" srcset="images/banner2-s.jpg">
                                <!--[if IE 9]></video><![endif]-->
                                <img src="images/banner2.jpg" alt="LST">
                            </picture>
                        </a>
                    </li>

                    <li>
                        <a href="javascript:;" title="LST">
                            <picture>
                                <!--
                                上傳大小   1920x800(desktop)
                                                768x800(mobile)
                            -->
                                <!--[if IE 9]><video style="display: none;"><![endif]-->
                                <source media="(min-width: 1024px)" srcset="images/banner.jpg">
                                <source media="(max-width: 768px)" srcset="images/banner-s.jpg">
                                <!--[if IE 9]></video><![endif]-->
                                <img src="images/banner.jpg" alt="LST">
                            </picture>
                        </a>
                    </li>

                </ul>
            </div>
        </div>
        <!-- banner// -->
        <!-- step -->
        <div class="container__step flex">
            <dl class="step">
                <dt class="step__dt flex">
                    <span class="num">01</span>
                    <span class="steptitle language_replace">Login</span>
                </dt>
                <dd class="step__dd language_replace">Players can log into the system after becoming a member.</dd>
            </dl>
            <dl class="step">
                <dt class="step__dt flex">
                    <span class="num">02</span>
                    <span class="steptitle language_replace">Select the table</span>
                </dt>
                <dd class="step__dd language_replace">Players can choose their favorite table then start game. If easybet table is selected, players can bet immeditately without waiting for buying chips.
                </dd>
            </dl>
            <dl class="step">
                <dt class="step__dt flex">
                    <span class="num">03</span>
                    <span class="steptitle language_replace">Buy chips(apply to telebet)</span>
                </dt>
                <dd class="step__dd language_replace">Contact cage to buy chips, or requesting buy chip by clicking on the page.</dd>
            </dl>
            <dl class="step">
                <dt class="step__dt step__dt--sm flex">
                    <span class="num">04</span>
                    <span class="steptitle language_replace">Call from phone betting personnel(apply to telebet)</span>
                </dt>
                <dd class="step__dd language_replace">After chip buy in successfully, the phone betting personnel will immediately call the member.</dd>
            </dl>
            <dl class="step">
                <dt class="step__dt flex">
                    <span class="num">05</span>
                    <span class="steptitle language_replace">Bet</span>
                </dt>
                <dd class="step__dd language_replace">Once the VIPs receive calls from phone beting personnel,they can bet directly from the web or instruct phone beting personnel to bet on behalf of them.
                </dd>
            </dl>
            <dl class="step">
                <dt class="step__dt flex">
                    <span class="num">06</span>
                    <span class="steptitle language_replace">End Game</span>
                </dt>
                <dd class="step__dd language_replace">Upon completion of the game of traditional phone betting,the phone better will go to cage and make settlement for the VIPs.If Players are playing easybet,they can just leave the website straightly without noticing us.
                </dd>
            </dl>
        </div>
        <!-- step// -->
        <!-- contact -->
        <!--div class="container__contact contact flex">
            <div class="contact__bg"></div>
            <dl class="contact__info">
                <dt><span class="language_replace">contact us</span></dt>
                <dd>+XX XXX XXX XXXX</dd>
                <dd>+XX XXX XXX XXXX</dd>
                <dd><span class="language_replace">24 hour service</span></dd>
            </dl>
        </div-->
        <!-- contact// -->
        <div class="container__ft">
            <a class="popup1" id="popup1" onclick="termsDivSwitch()" href="#popup1"><span class="language_replace">Terms of Member Responsibilities</span></a>
        </div>
    </div>
    <!-- container// -->
    <div id="Terms-popup1" class="TermsDiv">
        <div class="white-popup" style="max-width: 1200px; color: #272727;">
            <h3 style="font-weight: bolder; margin-bottom: 10px;"><span class="language_replace">As a lawful internet gaming institution, our Company has the responsibility to remind all potential players to pay attention to the relevant laws and regulations of the countries or the regions of residence.</span></h3>
            <ul>
                <li><span class="language_replace">1.The player should verify and perform due diligence if on-line gaming complies with the local laws before starting the games.</span></li>
                <li><span class="language_replace">2.Our website provides services only for the players with the statutory age. Any misrepresentation as to the age of the player shall not make the company liable for any losses of said player.</span></li>
                <li><span class="language_replace">3.Our Company shall not be responsible for any liability to the player's illegal activities resulting from violating the local laws or participating into the games of our Company.</span></li>
                <li><span class="language_replace">4.Any user who installs, uses and participates into any game of the software is deemed to comply with the local legal age, understand and agree with the contents of this Agreement totally.</span></li>
                <li><span class="language_replace">5.Our website has the right to refuse any user who signs in in an illegal way to participate into any game in our website.</span></li>
                <li><span class="language_replace">6.If black screen or network delay occurs in the game, in order to protect your rights, the telephone betting agent will take back the chips on the gambling table after losing contact</span></li>
                <li><span class="language_replace">7.Cards dealing errors due to human factors, our Company will restore to the correct results, The final results will be subject to the restored correct results.</span></li>
                <li><span class="language_replace">8.When the player bets through telephone, the telephone betting agent will confirm the final betting amount and direction with player, if there is any question or if the bet amount needs to be revised prior to opening, the player should immediately contact the agent; once the bet is opened, the player is not allowed to make any change. Our company will take the final betting on system data as prevail, the chip amount is also subject to the total chips on system data, and our Company bears no liabilities.</span></li>
                <li><span class="language_replace">9.Website display is only for reference, and makes no difference to the gaming results. If there are abnormal results of the website display caused by internet errors, the gaming results on site gambling table shall prevail.</span></li>
                <li><span class="language_replace">10.In case of the website faults or information damage resulting from Force Majeure or man-made intrusion, the final data of our website shall be final.</span></li>
                <li><span class="language_replace">11.In any case, the decision of our Company is final.</span></li>
                <li><span class="language_replace">12.In any case that one or more provisions contained in this agreement shall be declared invalid, illegal or unenforceable in any respect by a competent authority, the validity and legality and enforceability of the remaining provisions herein shall not in any way be affected or impaired thereby.</span></li>
                <li><span class="language_replace">13.I hold the gaming institution / company, its officers and employees free from any and all liabilities of whatever nature and kind which may result from my activities of engaging and utilizing the services they provide.</span></li>
                <li><span class="language_replace">14.Any and all data or information that may come to the knowledge of the player shall be kept in strict confidence. However, the website is entitled to disclose such data and information to the third parties, its officers, employees and affiliates upon such disclosure is necessary for the performance of gaming and other judicial investigation.</span></li>
            </ul>

        </div>
    </div>


    <!-- 跳出確認框 -->
    <div id="idMessageBox" class="popup" style="display: none;">
        <div id="idMessageWrapper" class="popupWrapper">
            <div class="popupHeader">
                <div class="popuptit"><span id="idMessageTitle">[Title]</span></div>
                <!--<div class="popupBtn_close"><span class="fa fa-close fa-1x"></span></div>-->
            </div>
            <!--  -->
            <div class="popupText">
                <span id="idMessageText">[Msg]</span>
            </div>
            <div id="idMessageButtonOK" class="popupBtn_red tempMessageBtn"><span>OK</span></div>
            <div id="idMessageButtonCancel" class="popupBtn_redOL tempMessageBtn"><span>Cancel</span></div>
        </div>
    </div>

    <iframe id="loadFrame" style="display: none"></iframe>
</body>
<!-- banner -->
<script src="scripts/jquery-1.11.3.min.js"></script>
<script defer src="scripts/jquery.flexslider.js"></script>
<script defer src="scripts/jquery.fancybox.js"></script>
<script type="text/javascript">
    $(window).load(function () {
        $('.flexslider').flexslider({
            animation: "slide",
            start: function (slider) {
                $('body').removeClass('loading');
            }
        });
    });

</script>
<!-- banner// -->
<link rel="stylesheet" href="css/reveal.css">
<script type="text/javascript" src="https://code.jquery.com/jquery-1.6.min.js"></script>
<script type="text/javascript" src="scripts/jquery.reveal.js"></script>
<script type="text/javascript">
    $(document).ready(function () {
        if (hasBulletin)
            $('#myModal').reveal();
    });
</script>
<!--GSAP-->
<script src="//cdnjs.cloudflare.com/ajax/libs/gsap/2.0.2/TweenMax.min.js" type="text/javascript" charset="utf-8"></script>
<script src="//s3-us-west-2.amazonaws.com/s.cdpn.io/35984/AnticipateEase.min.js" type="text/javascript" charset="utf-8"></script>
<!-- <script src="js/action.js"></script> -->

<!--  Terms of Member Responsibilities        -->
<script type="text/javascript">
    function termsDivSwitch() {
        var Termspopup1 = document.getElementById("Terms-popup1");
        Termspopup1.classList.toggle("termsDivSwitch");
    }
</script>
</html>
