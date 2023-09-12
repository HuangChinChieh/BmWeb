<%@ Page Language="VB" %>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scale=no">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>JO168 APP</title>
    <script src="js/jquery-1.11.3.min.js"></script>
    <script type="text/javascript">
         $(document).ready(function () {
             $("#and").click(function () {
                 location.href = "/apk/fbs.apk";
             });
            $("#ios").click(function() {
            location.href = "/ios_web";

            location.href = "https://lckc8.com/fbs";
            });
             $("#ios2").click(function () {
                 location.href = "/ios_web";
             });
             IsPC();
         });
         function IsPC() {
             var u = navigator.userAgent;
             var isAndroid = u.indexOf('Android') > -1 || u.indexOf('Adr') > -1; //android终端
             var isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/); //ios终端
             var device = "";
             if (isAndroid) {
                 $(".iosAPP").hide();
             }
             else if (!!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)) //ios终端)
             {                
                 $(".andriodAPP").hide();
             }
             else {                
             }
         }
        function tabPage(p, ele) {
            let gamePage = document.getElementById('game');
            let agentPage = document.getElementById('agent');
            if (p == 'game') {
                ele.nextElementSibling.classList.remove('active');
                ele.nextElementSibling.style.background = 'rgba(30, 30, 30, 0.75)';
                ele.classList.add('active');
                agentPage.classList.add('hide');
                gamePage.classList.remove('hide');
            } else {
                ele.previousElementSibling.classList.remove('active'); 
                ele.classList.add('active');
                ele.style.background = '#4cb3ff';
                gamePage.classList.add('hide');                
                agentPage.classList.remove('hide');
            }
        }
        function changeLang(val,ele){
            let array_languageSwitch = [...document.querySelectorAll('.languageSwitch > .btn_lang')];
            for (const i in array_languageSwitch) {
                array_languageSwitch[i].classList.remove('active');
            }
            switch (val) {
                case 'cht':
                    ele.classList.add('active');
                    break;
                case 'chs':
                    ele.classList.add('active');
                    break;
                case 'eng':
                    ele.classList.add('active');
                    break;
                case 'jpn':
                    ele.classList.add('active');
                    break;
                case 'kor':
                    ele.classList.add('active');
                    break;
                default:
                    break;
            }
        }
    </script>
	<script type="text/javascript">
        $(window).on("load",function(){
            function is_weixin() {
                var ua = navigator.userAgent.toLowerCase();
                if (ua.match(/MicroMessenger/i) == "micromessenger") {
                    alert("請使用其他瀏覽器開啟");
                } else {
                    return false;
                }
            }
        })
    </script>
    <link rel="stylesheet" type="text/css" href="css/main.css">
    <style>
    #agent button span{color: #4cb3ff;}
    #agent button:hover{background: #4cb3ff;}
    #agent button:hover span{color: #fff;}
		.APPICON img {
			width: 70px;
			height: 70px;
		}
		.mainBox .qrCodeGroup .img{
			height: 180px;
			width: 180px;
		}
		.mainBox .qrCodeGroup::after{
			    background-size: 40px;
			top: -20px;
		}
        @media (-webkit-min-device-pixel-ratio: 2) and (max-width: 375px) {
            .mainBox .qrCodeGroup::after{
			    top: -10px;
		    }
        }
    </style>
</head>

<body>
    <div class="bg"></div>
    <div class="main">
        <div class="bgShadow">
            <!-- 當前tab被選中需額外加上class="active" -->
            <div class="tab active" onclick="tabPage('game', this)">
                <span class="language_replace">客戶端 APP</span>
            </div>
            <div class="tab tab1" onclick="tabPage('agent', this)">
                <span class="language_replace">代理网 APP</span>
            </div>
            <div id="game" class="mainBox">
                <div class="title">
                    <div class="APPICON">
                        <img src="images/DDicon-App_gold.png" alt="icon_game">
                        <h1><span>GAME APP</span></h1>
                    </div>
                    <p><span>九盈 客戶APP</span></p>
                    <div class="line">
                        <div class="light"></div>
                    </div>
                </div>
                <div class="qrCodeGroup">
                    <%-- If IsTestSite Then --%>
                    <img class="img" src="images/QRCode.png" alt="qrcode" />
                    <%-- Else --%>
                    <!-- <img class="img" src="images/QRCode.png" alt="qrcode" /> -->
                    <%-- End If --%>
                </div>
                <div class="downloadGroup andriodAPP" id="andriodAPP">
                    <p class="buttonTitle">
                        <img src="images/APPSTOREICON2.png"><span class="language_replace">Android</span></p>
                    <div class="buttonGroup">
                        <button onclick="javascript:location.href='/apk/Jo168Game.apk'">
                            <div class="button_inner">
                                <!-- 如果為ios下載 src="images/APPSTOREICON.png" -->
                                <!-- 如果為Android下載 src="images/APPSTOREICON2.png" -->
                                <img src="images/APPSTOREICON2.png">
                                <span>下载应用</span>
                            </div>
                        </button>
                        <!-- <button>
                            <div class="button_inner">
                                <img src="images/APPSTOREICON2.png">
                                <span>載點2</span>
                            </div>
                        </button> -->
                        <!--<button>
                            <div class="button_inner">
                                <img src="images/APPSTOREICON2.png">
                                <span>載點3</span>
                            </div>
                        </button>-->
                    </div>
                </div>
                <div class="downloadGroup iosAPP" id="iosAPP">
                    <p class="buttonTitle">
                        <img src="images/APPSTOREICON.png"><span class="language_replace">ios</span></p>
                    <div class="buttonGroup">
                        <!--button onclick="javascript:location.href='https://web.xjplawyer.com/j9OIPX'">
                            <div class="button_inner">
                                <img src="images/APPSTOREICON.png">
                                <span>载点 1</span>
                            </div>
                        </button-->
						<!--button onclick="javascript:location.href='https://xinlanyx.com/app/detail/qg3-HNrJQ'"-->
						<button onclick="javascript:location.href='/ios_web'">
                            <div class="button_inner">
                                <img src="images/APPSTOREICON.png">
                                <span>下载应用</span>
                            </div>
                        </button>
                        <!-- <button onclick="javascript:location.href='http://52sg.vip/app.php/3759'">
                            <div class="button_inner">
                                <img src="images/APPSTOREICON.png">
                                <span>載點2</span>
                            </div>
                        </button>
                        <button>
                            <div class="button_inner">
                                <img src="images/APPSTOREICON.png">
                                <span>載點3</span>
                            </div>
                        </button> -->
                    </div>
                </div>
            </div>
            <!-- 當前區塊隱藏需額外加上class="hide" -->
            <div id="agent" class="mainBox hide">
                <div class="title">
                    <div class="APPICON">
                        <img src="images/DDicon-App_gold_agnet.png" alt="icon_agent">
                        <h1><span>AGENT APP</span></h1>
                    </div>
                    <p><span class="language_replace" style="color: #4cb3ff;">九盈 代理APP</span></p>
                    <div class="line" style="background-color: #4cb3ff;">
                        <div class="light"></div>
                    </div>
                </div>
                <div class="qrCodeGroup">
                    <%-- If IsTestSite Then --%>
                    <img class="img" src="images/QRCode.png" alt="qrcode" />
                    <%-- Else --%>
                    <!-- <img class="img" src="images/QRCode.png" alt="qrcode" /> -->
                    <%-- End If --%>
                </div>
                <div class="downloadGroup andriodAPP" id="andriodAPP">
                    <p class="buttonTitle">
                        <img src="images/APPSTOREICON2.png"><span class="language_replace">Android</span></p>
                    <div class="buttonGroup">
                        <button onclick="javascript:location.href='/apk/Jo168Agent.apk'" style="border-color: #4cb3ff;">
                            <div class="button_inner">
                                <!-- 如果為ios下載 src="images/APPSTOREICON.png" -->
                                <!-- 如果為Android下載 src="images/APPSTOREICON2.png" -->
                                <img src="images/APPSTOREICON2.png">
                                <span class="language_replace">下载应用</span>
                            </div>
                        </button>
                        <!-- <button>
                            <div class="button_inner">
                                <img src="images/APPSTOREICON2.png">
                                <span>載點2</span>
                            </div>
                        </button> -->
                        <!--<button>
                            <div class="button_inner">
                                <img src="images/APPSTOREICON2.png">
                                <span>載點3</span>
                            </div>
                        </button>-->
                    </div>
                </div>
                <div class="downloadGroup iosAPP" id="iosAPP">
                    <p class="buttonTitle">
                        <img src="images/APPSTOREICON.png"><span class="language_replace">ios</span></p>
                    <div class="buttonGroup">
                        <!--button onclick="javascript:location.href='https://web.xjplawyer.com/JsK0W4 '" style="border-color: #4cb3ff;">
                            <div class="button_inner">
                                <img src="images/APPSTOREICON.png">
                                <span class="language_replace">载点 1</span>
                            </div>
                        </button-->
						<!--button onclick="javascript:location.href='https://xinlanyx.com/app/detail/NmWWNqJJQ'" style="border-color: #4cb3ff;"-->
						<button onclick="javascript:location.href='/ios_web'" style="border-color: #4cb3ff;">
                            <div class="button_inner">
                                <img src="images/APPSTOREICON.png">
                                <span class="language_replace">下载应用</span>
                            </div>
                        </button>
                        <!-- <button onclick="javascript:location.href='http://52sg.vip/app.php/3759'">
                            <div class="button_inner">
                                <img src="images/APPSTOREICON.png">
                                <span>載點2</span>
                            </div>
                        </button>
                        <button>
                            <div class="button_inner">
                                <img src="images/APPSTOREICON.png">
                                <span>載點3</span>
                            </div>
                        </button> -->
                    </div>
                </div>
            </div>
        </div>
        <!-- <div class="languageSwitch"> -->
            <!-- 當前語言選項需額外加上class="active" -->
            <!-- <div class="btn_lang active" onclick="changeLang('cht', this)" >
                <img src="images/lan_cht.png"alt="">
                <span>繁中</span>
            </div>
            <div class="btn_lang" onclick="changeLang('chs', this)" >
                <img src="images/lan_chs.png" alt="">
                <span>简中</span>
            </div>
            <div class="btn_lang" onclick="changeLang('eng', this)" >
                <img src="images/lan_eng.png" alt="">
                <span>English</span>
            </div>
            <div class="btn_lang" onclick="changeLang('jpn', this)" >
                <img src="images/lan_jpn.png" alt="">
                <span>日本語</span>
            </div>
            <div class="btn_lang" onclick="changeLang('kor', this)" >
                <img src="images/lan_kor.png" alt="">
                <span>한국어</span>
            </div>
        </div> -->
    </div>
</body>

</html>
