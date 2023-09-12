var AgentCommon = function (APIUrl) {
    //抓取 body 加入 class => fixed，以使 Popup底層不滾動
    var innerBody = document.getElementsByClassName("innerBody");

    // Collapse 摺疊切換 ======================== 
    this.dataToggleCollapse = function (o) {
        var data_toggle = o.dataset.toggle; //get data-toggle
        var data_target = o.dataset.target; //get data-target
        var aria_Expanded = o.getAttribute("aria-expanded");
        var aria_mobile_expanded = o.getAttribute("aria-mobile-expanded");
        var aria_desktop_expanded = o.getAttribute("aria-desktop-expanded");

        var tabWrapper__TopCollapse = document.getElementsByClassName("tabWrapper__TopCollapse");
        var wrapper__TopCollapse = document.getElementsByClassName("wrapper__TopCollapse");

        //2021/6/19 ADD============
        var collapseTargetContent = o.parentNode.getElementsByClassName("collapse-content")[0];
        var data_targetRet = data_target.replace('#', '');

        if (data_toggle == "collapse") {
            
            if (aria_Expanded) {

                //預設 aria_Expanded=true or aria_mobile_expanded=true
                if (collapseTargetContent.classList.contains("show")) {

                    collapseTargetContent.classList.remove("show");
                    collapseTargetContent.style.maxHeight = null;

                }
                //預設 aria_Expanded=false or aria_mobile_expanded=false
                else {

                    collapseTargetContent.classList.add("show");
                    collapseTargetContent.style.maxHeight = collapseTargetContent.scrollHeight + "px";
                }

                // Collapse Button Setting 
                if (aria_Expanded == 'false') {

                    o.setAttribute("aria-expanded", "true");

                    if (tabWrapper__TopCollapse) {
                        if (tabWrapper__TopCollapse.length > 0) {
                            for (var i = 0; i < tabWrapper__TopCollapse.length; i++) {
                                tabWrapper__TopCollapse[i].classList.remove("top_collapse");
                            }
                        }
                    }

                    //2021/6/19 ADD============
                    if (wrapper__TopCollapse) {
                        if (wrapper__TopCollapse.length > 0) {

                            for (var i = 0; i < wrapper__TopCollapse.length; i++) {
                                wrapper__TopCollapse[i].classList.remove("top_collapse");
                            }

                        }
                    }

                }
                if (aria_Expanded == 'true') {
                    o.setAttribute("aria-expanded", "false");

                    if (tabWrapper__TopCollapse) {
                        if (tabWrapper__TopCollapse.length > 0) {
                            for (var i = 0; i < tabWrapper__TopCollapse.length; i++) {
                                tabWrapper__TopCollapse[i].classList.add("top_collapse");
                            }
                        }
                    }

                    //2021/6/19 ADD============
                    if (wrapper__TopCollapse) {
                        if (wrapper__TopCollapse.length > 0) {
                            for (var i = 0; i < wrapper__TopCollapse.length; i++) {
                                wrapper__TopCollapse[i].classList.add("top_collapse");
                            }
                        }
                    }

                }
            }
            else {
                if (window.innerWidth >= 1120) {
                    //假如大畫面大於1120
                    if (aria_desktop_expanded) {
                        collapseTargetContent.classList.remove("show"); //RESET

                        //預設 desktop-expand=true
                        if (collapseTargetContent.classList.contains("desktop-show")) {

                            collapseTargetContent.classList.remove("show");
                            collapseTargetContent.classList.remove("desktop-show");

                            
                            collapseTargetContent.style.maxHeight = null;
                        }
                        //預設 desktop-expand=false
                        else {

                            collapseTargetContent.classList.add("show");
                            collapseTargetContent.classList.add("desktop-show");
                            collapseTargetContent.style.maxHeight = collapseTargetContent.scrollHeight + "px";
                        }

                        // Collapse Button Setting 
                        //設定Button
                        if (aria_desktop_expanded == 'false') {
                            o.setAttribute("aria-mobile-expanded", "true");
                            o.setAttribute("aria-desktop-expanded", "true");
                        }

                        if (aria_desktop_expanded == 'true') {
                            o.setAttribute("aria-mobile-expanded", "false");
                            o.setAttribute("aria-desktop-expanded", "false");
                        }
                    }
                }
                else if (window.innerWidth < 1120 && aria_mobile_expanded) {
                    //假如畫面小於1120
                    // Collapse Button Setting 
                    if (aria_mobile_expanded == 'false') {
                        o.setAttribute("aria-mobile-expanded", "true");

                        collapseTargetContent.classList.add("show");
                        collapseTargetContent.style.maxHeight = collapseTargetContent.scrollHeight + "px";

                        if (aria_desktop_expanded) {
                            o.setAttribute("aria-desktop-expanded", "true");
                            //預設 desktop-expand=false
                            collapseTargetContent.classList.add("desktop-show");
                        }

                    }
                    else {
                        o.setAttribute("aria-mobile-expanded", "false");

                        collapseTargetContent.classList.remove("show");
                        collapseTargetContent.style.maxHeight = null;


                        if (aria_desktop_expanded) {
                            o.setAttribute("aria-desktop-expanded", "false");

                            //預設 desktop-expand=true
                            if (collapseTargetContent.classList.contains("desktop-show")) {
                                collapseTargetContent.classList.remove("desktop-show");
                            }
                        }
                    }
                }

            }

            //  例外--銀行卡-右側收合 => 也可用 CSS Overwrite 控制覆寫 => collapse.scss
            // if (data_targetRet == "idBankCardUnused") {
            //     collapseTargetContent.style.maxHeight = "100%";
            // }

            //側邊選單切換
            if (data_targetRet == "navbarMenu") {
                // navbartogglerToggle();
                mask_overlay.classList.toggle("open");
            }


        }
        else {
            // console.log("no collapse");
        }

    };


    this.dataTogglePopup = function (o) {
        var data_toggle = o.dataset.toggle;
        var data_target = o.dataset.target;
        var data_targetRet;
        var popupContent;

        if (data_toggle == "popup") {

            data_targetRet = data_target.replace('#', '');
            console.log(data_targetRet);

            popupContent = document.getElementById(data_targetRet);
            popupContent.classList.toggle("show");

            try {
                if (innerBody) {
                    innerBody[0].classList.add("fixed");
                }
            }
            catch (e) {
                document.body.classList.add("fixed");
            }

        }
        else {
            console.log("no popup");
        }
    }


    //PopUP半透明遮罩
    this.MaskPopUp = function (o) {

        console.log("obj.parentElement.id:" + o.parentElement.id);
        console.log("obj.parentNode.id:" + o.parentNode.id);

        var getParentElementNode = o.parentNode;
        getParentElementNode.classList.remove("show");

        try {
            if (innerBody) {
                innerBody[0].classList.remove("fixed");
            }
        }
        catch (e) {
            document.body.classList.remove("fixed");
        }

    }

    //closePopUp 關閉PopUp
    this.closePopUp = function (o) {

        var getParentElementNode = o.parentNode.parentNode;
        getParentElementNode.classList.remove("show");


        try {
            if (innerBody) {
                innerBody[0].classList.remove("fixed");
            }        }
        catch (e) {
            document.body.classList.remove("fixed");
        }

    }


    this.listenScreenMove = function () {
        var oldPageX;
        var oldPageY;

        document.body.addEventListener("touchstart", touchStart);
        document.body.addEventListener("touchmove", touchMove);

        function touchStart(event) {

            oldPageX = event.targetTouches[0].pageX;
            oldPageY = event.targetTouches[0].pageY;
            //alert(event.targetTouches[0].pageX + "," + event.targetTouches[0].pageY);
        }

        function touchMove(event) {
            var nowPageX;
            var nowPageY;
            var collapseEl;
            var idList = document.getElementById("idList");

            if (idList.childNodes.length > 0) {
                collapseEl = document.getElementsByClassName("collapse-header")[0];
                nowPageX = event.targetTouches[0].pageX;
                nowPageY = event.targetTouches[0].pageY;

                if (parseInt(nowPageY) < parseInt(oldPageY)) {
                    if (collapseEl.getAttribute("aria-expanded") == "true") {
                        ac.dataToggleCollapse(collapseEl);
                    }
                }
            }
        }
    }
    this.commafy = function (num) {
        var num1;
        var num2;

        var re = /(-?\d+)(\d{3})/
        num = num + "";
        if (num.indexOf(".") != -1) {
            num1 = num.substring(0, num.indexOf("."));
            num2 = num.substring(num.indexOf(".") + 1);

            while (re.test(num1)) {
                num1 = num1.replace(re, "$1,$2")
            }

            num = num1 + "." + num2;
        }
        else {
            while (re.test(num)) {
                num = num.replace(re, "$1,$2")
            }
        }

        return num;
    }
};