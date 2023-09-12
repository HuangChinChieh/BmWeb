var common = function () {
    this.getParameter = function (varname) {
        return getUrlVars()[varname];
    }

    this.mathAdd = function (v1, v2) {
        var v1Neg = false;
        var v1Str = "";
        var v1StrIndex = "";
        var v2Neg = false;
        var v2Str = "";
        var v2StrIndex = "";
        var modValue = 0;
        var bigInt = 0;
        var bigIntNeg = false;
        var intValue = 0;
        var modValueStr = "";

        v1Str = "" + v1;
        if (v1Str.substr(0, 1) == "-") {
            v1Neg = true;
            v1Str = v1Str.substr(1, v1Str.length - 1);
        }

        v1StrIndex = v1Str.indexOf(".");
        if (v1StrIndex != -1) {
            var dotValue;

            dotValue = v1Str.substr(v1StrIndex + 1, v1Str.length - v1StrIndex);

            if (dotValue.length > 4)
                dotValue = dotValue.substr(0, 4);
            else if (dotValue.length == 3)
                dotValue = dotValue + "0";
            else if (dotValue.length == 2)
                dotValue = dotValue + "00";
            else if (dotValue.length == 1)
                dotValue = dotValue + "000";

            if (v1Str.substr(0, v1StrIndex) != "0")
                v1Str = v1Str.substr(0, v1StrIndex) + dotValue;
            else
                v1Str = dotValue;
        } else {
            v1Str = v1Str + "0000";
        }

        if (v1Neg)
            v1Str = "-" + v1Str;

        v2Str = "" + v2;
        if (v2Str.substr(0, 1) == "-") {
            v2Neg = true;
            v2Str = v2Str.substr(1, v2Str.length - 1);
        }
        v2StrIndex = v2Str.indexOf(".");
        if (v2StrIndex != -1) {
            var dotValue;

            dotValue = v2Str.substr(v2StrIndex + 1, v2Str.length - v2StrIndex);

            if (dotValue.length > 4)
                dotValue = dotValue.substr(0, 4);
            else if (dotValue.length == 3)
                dotValue = dotValue + "0";
            else if (dotValue.length == 2)
                dotValue = dotValue + "00";
            else if (dotValue.length == 1)
                dotValue = dotValue + "000";

            if (v2Str.substr(0, v2StrIndex) != "0")
                v2Str = v2Str.substr(0, v2StrIndex) + dotValue;
            else
                v2Str = dotValue;
        } else {
            v2Str = v2Str + "0000";
        }

        if (v2Neg)
            v2Str = "-" + v2Str;

        //alert(Number(v1Str) + ":" + Number(v2Str) + ":" + v2Str);

        bigInt = (Number(v1Str) + Number(v2Str));
        if (bigInt < 0) {
            bigIntNeg = true;
            bigInt = Math.abs(bigInt);
        }

        modValue = parseInt(bigInt % 10000);
        intValue = (bigInt - modValue);

        if (modValue < 10)
            modValueStr = "000" + modValue;
        else if (modValue < 100)
            modValueStr = "00" + modValue;
        else if (modValue < 1000)
            modValueStr = "0" + modValue;
        else
            modValueStr = "" + modValue;

        /*
        if (modValueStr.substr(modValueStr.length - 1, 1) == "9") {
            alert(bigInt + ":" + modValue + ":" + intValue + "/" + v1 + ":" + v2 + "/" + v1p + ":" + v2p);
        }
        */

        if (bigIntNeg)
            return "-" + Number(parseInt(intValue / 10000) + "." + modValueStr);
        else
            return Number(parseInt(intValue / 10000) + "." + modValueStr);

        //return (parseInt(Number(v1) * Math.pow(10, 4)) + parseInt(Number(v2) * Math.pow(10, 4))) * 0.0001;
    }

    this.showLoading = function (text, cb) {
        var scr = this.getScreenSize();
        var maskContainer;
        var maskDiv;
        var userDiv;
        var textDiv;
        var loadingImg;
        var top = 0;
        var left = 0;
        var width = scr.width;
        var height = scr.height;

        maskContainer = document.createElement("div");
        maskContainer.style.cssText = "position: absolute; display: inline; z-index:199997;";

        document.body.appendChild(maskContainer);

        maskContainer.style.top = top + "px";
        maskContainer.style.left = left + "px";
        maskContainer.style.width = width + "px";
        maskContainer.style.height = height + "px";

        maskDiv = document.createElement("div");
        maskDiv.style.cssText = "position: absolute; background-color: #000000; filter: alpha(opacity=50); -moz-opacity: 0.5; opacity: 0.5; display: inline; z-index:199998;";

        maskContainer.appendChild(maskDiv);

        maskDiv.style.width = maskContainer.clientWidth + "px";
        maskDiv.style.height = maskContainer.clientHeight + "px";

        userDiv = document.createElement("div");
        userDiv.style.cssText = "position: absolute; display: inline; z-index:199999;";

        maskContainer.appendChild(userDiv);

        userDiv.style.width = maskContainer.clientWidth + "px";
        userDiv.style.height = maskContainer.clientHeight + "px";


        loadingImg = document.createElement("img");
        loadingImg.src = "data:image/gif;base64,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";
        loadingImg.style.cssText = "position: absolute; display: inline; z-index:199999; width: 128px; height: 128px";

        userDiv.appendChild(loadingImg);

        this.centerObject(loadingImg);

        textDiv = document.createElement("div");
        textDiv.style.cssText = "position: absolute; display: inline; z-index:199999;";

        userDiv.appendChild(textDiv);

        textDiv.innerHTML = text;

        textDiv.style.left = parseInt((userDiv.clientWidth - textDiv.clientWidth) / 2) + userDiv.clientLeft + "px";
        textDiv.style.top = parseInt((userDiv.clientHeight - textDiv.clientHeight) / 2) + userDiv.clientTop + "px";

        if (cb) {
            cb();
        }
    }

    this.formatNumber = function (n, digiNumber) {
        var n1 = n.toString();
        var n2;
        var r;

        if (digiNumber == null)
            digiNumber = 4;

        n2 = n1.indexOf(".");
        if (n2 != -1) {
            var v1;
            var v2;

            v1 = n1.substr(0, n2);
            v2 = n1.substr(n2 + 1);

            if (v2.length >= digiNumber) {
                r = v1 + "." + v2.substr(0, digiNumber);
            } else {
                r = v1 + "." + v2;
            }

            // filter last 0
            while (-1) {
                var lastChar;

                if (r.length > 1) {
                    lastChar = r.substr(r.length - 1, 1);
                    if ((lastChar == "0") || (lastChar == ".")) {
                        r = r.substr(0, r.length - 1);
                    } else {
                        break;
                    }
                } else {
                    break;
                }
            }
        } else {
            r = n1;
        }

        return r;
    }


    this.centerObject = function (o) {
        var scr = this.getScreenSize();

        if (o) {
            o.style.top = ((scr.height / 2) - (o.clientHeight / 2)) + "px";
            o.style.left = ((scr.width / 2) - (o.clientWidth / 2)) + "px";
        }
    }

    this.fullscreenObject = function (o) {
        var scr = this.getScreenSize();

        if (o) {
            o.style.left = "0px";
            o.style.top = "0px";
            o.style.width = scr.width + "px";
            o.style.height = scr.height + "px";
        }
    }

    this.formatDecimal = function (s) {
        var iValue = 0;
        var leftValue = 0;
        var i = 1;

        iValue = Math[s < 0 ? 'ceil' : 'floor'](s) / 1;
        leftValue = s % 1;

        while (true) {
            var tmpValue = 0;

            tmpValue = (leftValue * Math.pow(10, i) % 1);
            if (tmpValue == 0) {
                iValue += (leftValue * Math.pow(10, i)) * Math.pow(10, -i);
                break;
            } else {
                i++;
            }
        }

        return iValue;
    }

    this.getScreenSize = function () {
        var scr = {
            width: 0,
            height: 0
        }

        scr.width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
        scr.height = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;

        return scr;
    }

    this.getTemplate = function (idTemplate) {
        var oTemplate = document.getElementById(idTemplate);
        var oInstance;

        if (oTemplate) {
            oInstance = oTemplate.children[0].cloneNode(true);
            this.findNeedClearChildren(oInstance);
        }

        return oInstance;
    }

    this.clearChildren = function (o) {
        while (o.firstChild) o.removeChild(o.firstChild);
    }

    this.findChildrenByAttr = function (o, matchClassName, attrName, attrValue) {
        var retValue = null;

        for (var i = 0; i < o.children.length; i++) {
            var o2 = o.children[i];
            var allowFindO2 = false;

            if (matchClassName == null || matchClassName == "") {
                allowFindO2 = true;
            } else {
                if (o2.className == matchClassName) {
                    allowFindO2 = true;
                }
            }

            if (allowFindO2 == true) {
                if (o2.getAttribute(attrName) == attrValue) {
                    retValue = o2;
                    break;
                }
            }
        }

        return retValue;
    }

    this.setElementClass = function (id, className) {
        var o = document.getElementById(id);

        if (o != null)
            o.className = className;
    }


    this.setClassText = function (o, className, color, text) {
        if (o) {
            var oTmp = this.getFirstClassElement(o, className);

            if (oTmp) {
                if (oTmp) {
                    if (color) {
                        oTmp.style.color = color;
                    } else {
                        oTmp.style.removeProperty("color");
                    }

                    oTmp.innerHTML = text;
                }
            }
        }
    }

    this.setElementText = function (id, color, text) {
        var o = document.getElementById(id);

        if (o) {
            if (color) {
                o.style.color = color;
            } else {
                o.style.removeProperty("color");
            }

            o.innerHTML = text;
        }
    }


    this.getFirstClassElement = function (o, className) {
        var retValue;
        var objectArray;

        objectArray = o.getElementsByClassName(className);
        if (objectArray) {
            if (objectArray.length) {
                if (objectArray.length > 0) {
                    retValue = objectArray[0];
                }
            }
        }

        return retValue;
    }

    this.getJSON = function (text) {
        var obj = JSON.parse(text);

        if (obj) {
            if (obj.hasOwnProperty('d')) {
                return obj.d;
            } else {
                return obj;
            }
        }
    }

    this.callService = function (URL, postObject, cb) {
        var xmlHttp = new XMLHttpRequest;
        var URL;
        var postData;

        if (postObject)
            postData = JSON.stringify(postObject);

        xmlHttp.open("POST", URL, true);
        xmlHttp.onreadystatechange = function () {
            if (this.readyState == 4) {
                var contentText = this.responseText;

                if (this.status == "200") {
                    if (cb) {
                        cb(true, contentText);
                    }
                } else {
                    cb(false, contentText);
                }
            }
        }

        xmlHttp.setRequestHeader("Content-Type", "application/json; charset=utf-8");
        xmlHttp.send(postData);
    }

    function findNeedClearChildren(o) {
        var cChildren = o.getAttribute("ClearChildren");

        if (cChildren) {
            if (cChildren == "1") {
                this.clearChildren(o);
            }
        } else {
            if (o.children) {
                if (o.children.length) {
                    for (var _child = 0; _child < o.children.length; _child++) {
                        var oChild = o.children[_child];

                        this.findNeedClearChildren(oChild);
                    }
                }
            }
        }
    }

    function getUrlVars() {
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
            function (m, key, value) {
                vars[key] = value;
            });
        return vars;
    }
}
