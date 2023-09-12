var uiControl = function () {
    var maskClickCB = null;

    this.showMessageOK = function (text, cbOK) {
        var scr = getScreenSize();
        var messageContainer;
        var maskDiv;
        var mBoxDiv;
        var mBoxBtnDiv;
        var mBoxOKBtn;

        if (document.getElementById("_MessageContainer") == null) {
            messageContainer = document.createElement("div");
            messageContainer.id = "_MessageContainer";
            messageContainer.style.cssText = "position: absolute; display: inline; z-index:99997;";

            document.body.appendChild(messageContainer);
        } else {
            messageContainer = document.getElementById("_MessageContainer");
        }

        messageContainer.style.top = "0px";
        messageContainer.style.left = "0px";
        messageContainer.style.width = scr.width + "px";
        messageContainer.style.height = scr.height + "px";

        if (document.getElementById("_idMessageMask") == null) {
            maskDiv = document.createElement("div");
            maskDiv.id = "_idMessageMask";
            maskDiv.style.cssText = "position: absolute; background-color: #000000; filter: alpha(opacity=50); -moz-opacity: 0.5; opacity: 0.5; display: inline; z-index:99998;";

            messageContainer.appendChild(maskDiv);
        } else {
            maskDiv = document.getElementById("_idMessageMask");
        }

        /*maskDiv.style.width = messageContainer.clientWidth + "px";
        maskDiv.style.height = messageContainer.clientHeight + "px";*/
        maskDiv.style.width = 100 + "%";
        maskDiv.style.height = 100 + "%";


        if (document.getElementById("_idMessageBox") == null) {
            mBoxDiv = document.createElement("div");
            mBoxDiv.id = "_idMessageBox";
            mBoxDiv.style.cssText = "position: absolute; display: inline; z-index:99999;border: 1px solid white;-webkit-border-radius: 15px;-moz-border-radius: 15px;border-radius: 15px; background-color: #000020; padding: 50px 10px; color: #ffffff; text-align: center; font-size: 32pt";

            messageContainer.appendChild(mBoxDiv);
        } else {
            mBoxDiv = document.getElementById("_idMessageBox");
        }

        mBoxDiv.style.height = "380px";
        mBoxDiv.style.width = "640px";

        mBoxDiv.style.left = parseInt((messageContainer.clientWidth - mBoxDiv.clientWidth) / 2) + messageContainer.clientLeft + "px";
        mBoxDiv.style.top = parseInt((messageContainer.clientHeight - mBoxDiv.clientHeight) / 2) + messageContainer.clientTop + "px";


        // 按鈕區, 寬度應設為 100%
        if (document.getElementById("_idMessageBoxButtonDIV") == null) {
            mBoxBtnDiv = document.createElement("div");
            mBoxBtnDiv.id = "_idMessageBoxButtonDIV";
            mBoxBtnDiv.align = "center";
            mBoxBtnDiv.style.cssText = "position: absolute; display: inline; z-index:100000;";

            messageContainer.appendChild(mBoxBtnDiv);
        } else {
            mBoxBtnDiv = document.getElementById("_idMessageBoxButtonDIV");
        }

        if (document.getElementById("_idMessageBoxButtonOK") == null) {
            mBoxOKBtn = document.createElement("div");
            mBoxOKBtn.id = "_idMessageBoxButtonOK";
            //mBoxOKBtn.className = "btn";
            mBoxOKBtn.style.cssText = "display: inline; width: 120px; font-size: 32pt; background-color: rgba(255, 255, 255, 0.4); -webkit-border-radius: 128; -moz-border-radius: 128; border-radius: 128px; font-family: Arial; color: #ffffff; padding: 10px 40px 10px 40px; text-decoration: none; text-align: center;";

            mBoxOKBtn.addEventListener("click", function () {
                var oMsgContainer = document.getElementById("_MessageContainer");

                document.body.removeChild(oMsgContainer);
            });

            if (cbOK)
                mBoxOKBtn.addEventListener("click", cbOK);

            mBoxBtnDiv.appendChild(mBoxOKBtn);
        } else {
            mBoxOKBtn = document.getElementById("_idMessageBoxButtonOK");
        }

        mBoxDiv.innerText = text;
        mBoxOKBtn.innerText = "OK";

        // 修正按鈕區域位置
        mBoxBtnDiv.style.left = "0px";
        mBoxBtnDiv.style.width = scr.width + "px";
        mBoxBtnDiv.style.top = parseInt((messageContainer.clientHeight - mBoxDiv.clientHeight) / 2) + messageContainer.clientTop + mBoxDiv.clientHeight - mBoxBtnDiv.clientHeight - 30 + "px";
        
    }

    this.showMessage = function (text, cbOK, cbCancel) {
        var scr = getScreenSize();
        var messageContainer;
        var maskDiv;
        var mBoxDiv;
        var mBoxBtnDiv;
        var mBoxOKBtn;
        var mBoxCancelBtn;

        if (document.getElementById("_MessageContainer") == null) {
            messageContainer = document.createElement("div");
            messageContainer.id = "_MessageContainer";
            messageContainer.style.cssText = "position: absolute; display: inline; z-index:99997;";

            document.body.appendChild(messageContainer);
        } else {
            messageContainer = document.getElementById("_MessageContainer");
        }

        messageContainer.style.top = "0px";
        messageContainer.style.left = "0px";
        messageContainer.style.width = scr.width + "px";
        messageContainer.style.height = scr.height + "px";
		/*messageContainer.style.width = 100 + "%";
        messageContainer.style.height = 100 + "%";*/

        if (document.getElementById("_idMessageMask") == null) {
            maskDiv = document.createElement("div");
            maskDiv.id = "_idMessageMask";
            maskDiv.style.cssText = "position: absolute; background-color: #000000; filter: alpha(opacity=50); -moz-opacity: 0.5; opacity: 0.5; display: inline; z-index:99998;";
			
			maskDiv.onmouseover = function(){
				
				maskDiv.className = "";
			}

            messageContainer.appendChild(maskDiv);
        } else {
            maskDiv = document.getElementById("_idMessageMask");
        }

        maskDiv.style.width = messageContainer.clientWidth + "px";
        maskDiv.style.height = messageContainer.clientHeight + "px";
		
		/*maskDiv.style.width = 100 + "%";
        maskDiv.style.height = 100 + "%";*/



        if (document.getElementById("_idMessageBox") == null) {
            mBoxDiv = document.createElement("div");
            mBoxDiv.id = "_idMessageBox";
            mBoxDiv.style.cssText = "position: absolute; display: inline; z-index:99999;border: 1px solid white;-webkit-border-radius: 15px;-moz-border-radius: 15px;border-radius: 15px; background-color: #000020; padding: 50px 10px; color: #ffffff; text-align: center; font-size: 32pt";

            messageContainer.appendChild(mBoxDiv);
        } else {
            mBoxDiv = document.getElementById("_idMessageBox");
        }

        mBoxDiv.style.height = "380px";
        mBoxDiv.style.width = "640px";

        mBoxDiv.style.left = parseInt((messageContainer.clientWidth - mBoxDiv.clientWidth) / 2) + messageContainer.clientLeft + "px";
        mBoxDiv.style.top = parseInt((messageContainer.clientHeight - mBoxDiv.clientHeight) / 2) + messageContainer.clientTop + "px";


        // 按鈕區, 寬度應設為 100%
        if (document.getElementById("_idMessageBoxButtonDIV") == null) {
            mBoxBtnDiv = document.createElement("div");
            mBoxBtnDiv.id = "_idMessageBoxButtonDIV";
            mBoxBtnDiv.align = "center";
            mBoxBtnDiv.style.cssText = "position: absolute; display: inline; z-index:100000;";

            messageContainer.appendChild(mBoxBtnDiv);
        } else {
            mBoxBtnDiv = document.getElementById("_idMessageBoxButtonDIV");
        }



        if (document.getElementById("_idMessageBoxButtonOK") == null) {
            mBoxOKBtn = document.createElement("div");
            mBoxOKBtn.id = "_idMessageBoxButtonOK";
            //mBoxOKBtn.className = "btn";
            mBoxOKBtn.style.cssText = "display: inline; width: 120px; font-size: 32pt; margin: 10px; background-color: rgba(255, 255, 255, 0.4); -webkit-border-radius: 128; -moz-border-radius: 128; border-radius: 128px; font-family: Arial; color: #ffffff; padding: 10px 40px 10px 40px; text-decoration: none; text-align: center;";

            mBoxOKBtn.addEventListener("click", function () {
                var oMsgContainer = document.getElementById("_MessageContainer");

                document.body.removeChild(oMsgContainer);
            });

            if (cbOK)
                mBoxOKBtn.addEventListener("click", cbOK);

            mBoxBtnDiv.appendChild(mBoxOKBtn);
        } else {
            mBoxOKBtn = document.getElementById("_idMessageBoxButtonOK");
        }

        if (document.getElementById("_idMessageBoxButtonCancel") == null) {
            mBoxCancelBtn = document.createElement("div");
            mBoxCancelBtn.id = "_idMessageBoxButtonCancel";
            //mBoxCancelBtn.className = "btn";
            mBoxCancelBtn.style.cssText = "display: inline; width: 120px; font-size: 32pt; margin: 10px; background-color: rgba(255, 255, 255, 0.4); -webkit-border-radius: 128; -moz-border-radius: 128; border-radius: 128px; font-family: Arial; color: #ffffff; padding: 10px 40px 10px 40px; text-decoration: none; text-align: center;";
            //mBoxCancelBtn.style.cssText = "display: inline; width: 120px; font-size: 32pt; margin: 10px";

            mBoxCancelBtn.addEventListener("click", function () {
                var oMsgContainer = document.getElementById("_MessageContainer");

                document.body.removeChild(oMsgContainer);
            });

            if (cbCancel)
                mBoxCancelBtn.addEventListener("click", cbCancel);

            mBoxBtnDiv.appendChild(mBoxCancelBtn);
        } else {
            mBoxCancelBtn = document.getElementById("_idMessageBoxButtonCancel");
        }

        mBoxDiv.innerText = text;
        mBoxOKBtn.innerText = "OK";
        mBoxCancelBtn.innerText = "Cancel";

        // 修正按鈕區域位置
        mBoxBtnDiv.style.left = "0px";
        mBoxBtnDiv.style.width = scr.width + "px";
        mBoxBtnDiv.style.top = parseInt((messageContainer.clientHeight - mBoxDiv.clientHeight) / 2) + messageContainer.clientTop + mBoxDiv.clientHeight - mBoxBtnDiv.clientHeight - 80 + "px";
    }

    this.showMask = function (refElement, text, clickCB) {
        var scr = getScreenSize();
        var maskContainer;
        var maskDiv;
        var textDiv;
        var top = 0;
        var left = 0;
        var width = scr.width;
        var height = scr.height;

        //alert(document.body.clientHeight);

        if (refElement) {
            /*
            var rect = refElement.getBoundingClientRect();

            top = rect.top;
            left = rect.left;
            width = rect.width;
            height = rect.height;
            */
            top = 0;
            left = 0;
            width = refElement.clientWidth;
            height = refElement.clientHeight;
        }

        if (document.getElementById("_MaskContainer") == null) {
            maskContainer = document.createElement("div");
            maskContainer.id = "_MaskContainer";
            maskContainer.style.cssText = "position: absolute; display: inline; z-index:99997;";

            if (refElement)
                refElement.appendChild(maskContainer);
            else
                document.body.appendChild(maskContainer);
        } else {
            maskContainer = document.getElementById("_MaskContainer");

            if (refElement == null) {
                // 檢查 parent 是否 body
                if (maskContainer.parentElement.tagName.toUpperCase() != "body".toUpperCase()) {
                    // 改由 body 承接
                    maskContainer.parentElement.removeChild(maskContainer);
                    document.body.appendChild(maskContainer);
                }
            } else {
                // 檢查 parent 是否相同
                if (maskContainer.parentElement != refElement) {
                    maskContainer.parentElement.removeChild(maskContainer);
                    refElement.appendChild(maskContainer);
                }
            }
        }

        maskContainer.style.top = top + "px";
        maskContainer.style.left = left + "px";
        maskContainer.style.width = width + "px";
        maskContainer.style.height = height + "px";

        if (document.getElementById("_idMask") == null) {
            maskDiv = document.createElement("div");
            maskDiv.id = "_idMask";
            maskDiv.style.cssText = "position: absolute; background-color: #000000; filter: alpha(opacity=50); -moz-opacity: 0.5; opacity: 0.5; display: inline; z-index:99998;";

            maskContainer.appendChild(maskDiv);
        } else {
            maskDiv = document.getElementById("_idMask");
        }

        if (maskClickCB != null)
            maskDiv.removeEventListener("click", maskClickCB);

        if (clickCB)
            maskDiv.addEventListener("click", clickCB);

        maskDiv.style.top = "0px";
        maskDiv.style.left = "0px";
        maskDiv.style.width = maskContainer.clientWidth + "px";
        maskDiv.style.height = maskContainer.clientHeight + "px";
		/*maskDiv.style.width = 100 + "%";
        maskDiv.style.height = 100 + "%";*/

        if (document.getElementById("_idMaskText") == null) {
            textDiv = document.createElement("div");
            textDiv.id = "_idMaskText";
            textDiv.style.cssText = "position: absolute; display: inline; z-index:99999; -webkit-border-radius: 6px; -moz-border-radius: 6px; border-radius: 6px; text-decoration: none; text-align: center;";

            maskContainer.appendChild(textDiv);
        } else {
            textDiv = document.getElementById("_idMaskText");
        }

        if (maskClickCB != null)
            textDiv.removeEventListener("click", maskClickCB);

        if (clickCB)
            textDiv.addEventListener("click", clickCB);

        maskClickCB = clickCB;

        if ((text != null) && (text != "")) {
            textDiv.style.backgroundColor = "rgba(50, 50, 50, 1.0)";
            textDiv.style.border = "1px solid rgba(255, 255, 255, 1.0)";
            textDiv.style.padding = "5px 20px 5px 20px";
            textDiv.style.color = "rgb(255, 255, 255)";
            textDiv.innerHTML = text;
        }

        if (maskContainer.clientHeight <= scr.height) {
            textDiv.style.position = "absolute";
            textDiv.style.left = parseInt((maskContainer.clientWidth - textDiv.clientWidth) / 2) + maskContainer.clientLeft + "px";
            textDiv.style.top = parseInt((maskContainer.clientHeight - textDiv.clientHeight) / 2) + maskContainer.clientTop + "px";
        } else {
            textDiv.style.position = "fixed";
            textDiv.style.left = parseInt((maskContainer.clientWidth - textDiv.clientWidth) / 2) + maskContainer.clientLeft + "px";
            textDiv.style.top = parseInt((scr.height - textDiv.clientHeight) / 2) + "px";
        }

        return maskContainer;
    }

    this.hideMask = function () {
        var oMaskContainer = document.getElementById("_MaskContainer");
        var oMask = document.getElementById("_idMask");
        var oMaskText = document.getElementById("_idMaskText");

        if (oMaskText) {
            var pElement = document.body;

            if (oMaskText.parentElement)
                pElement = oMaskText.parentElement;

            pElement.removeChild(oMaskText);

        }

        if (oMask) {
            var pElement = document.body;

            if (oMask.parentElement)
                pElement = oMask.parentElement;

            pElement.removeChild(oMask);
        }

        if (oMaskContainer) {
            var pElement = document.body;

            if (oMaskContainer.parentElement)
                pElement = oMaskContainer.parentElement;

            pElement.removeChild(oMaskContainer);
        }

        maskClickCB = null;
    }

    this.isMaskOpened = function () {
        var oMaskContainer = document.getElementById("_MaskContainer");
        var retValue = false;

        if (oMaskContainer) {
            retValue = true;
        }

        return retValue;
    }

    this.openDialogURL = function (left, top, width, height, url, scroll) {
        //var scr = getScreenSize();
        var scr = document.body.getBoundingClientRect();
        var messageContainer;
        var maskDiv;
        var mBoxDiv;
        var mInnerFrame;
        var mCloseButton;
        var rect;

        if (document.getElementById("_InnerFrameContainer") == null) {
            messageContainer = document.createElement("div");
            messageContainer.id = "_InnerFrameContainer";
            messageContainer.style.cssText = "position: absolute; display: inline; z-index:99997;";

            document.body.appendChild(messageContainer);
        } else {
            messageContainer = document.getElementById("_InnerFrameContainer");
        }

        messageContainer.style.top = "0px";
        messageContainer.style.left = "0px";
        messageContainer.style.width = scr.width + "px";
        messageContainer.style.height = scr.height + "px";

        if (document.getElementById("_idInnerFrameMask") == null) {
            maskDiv = document.createElement("div");
            maskDiv.id = "_idInnerFrameMask";
            maskDiv.style.cssText = "position: absolute; background-color: #000000; filter: alpha(opacity=50); -moz-opacity: 0.5; opacity: 0.5; display: inline; z-index:99998;";

            messageContainer.appendChild(maskDiv);
        } else {
            maskDiv = document.getElementById("_idInnerFrameMask");
        }

        maskDiv.style.width = messageContainer.clientWidth + "px";
        maskDiv.style.height = messageContainer.clientHeight + "px";
		/*maskDiv.style.width = 100 + "%";
        maskDiv.style.height = 100 + "%";*/



        if (document.getElementById("_idInnerFrameBox") == null) {
            mBoxDiv = document.createElement("div");
            mBoxDiv.id = "_idMessageBox";
            mBoxDiv.style.cssText = "position: absolute; display: inline; z-index:99999;border: 1px solid white;-webkit-border-radius: 15px;-moz-border-radius: 15px;border-radius: 15px; background-color: #000020; color: #ffffff; text-align: center; font-size: 32pt; overflow: hidden; -webkit-overflow-scrolling:touch;";

            messageContainer.appendChild(mBoxDiv);
        } else {
            mBoxDiv = document.getElementById("_idInnerFrameBox");
        }

        mBoxDiv.style.height = height + "px";
        mBoxDiv.style.width = width + "px";
        mBoxDiv.style.left = left + "px";
        mBoxDiv.style.top = top + "px";

        if (document.getElementById("_idInnerFrame") == null) {
            mInnerFrame = document.createElement("iframe");
            mInnerFrame.id = "_idInnerFrame";
            mInnerFrame.style.cssText = "z-index:100000; -webkit-border-radius: 15px;-moz-border-radius: 15px;border-radius: 15px;";

            mInnerFrame.border = "0";
            mInnerFrame.frameBorder = "0";
            mInnerFrame.marginWidth = "0";
            mInnerFrame.marginHeight = "0";

            if (scroll != null) {
                if (scroll == false) {
                    mInnerFrame.scrolling = "no";
                }
            }

            mBoxDiv.appendChild(mInnerFrame);
        } else {
            mInnerFrame = document.getElementById("_idInnerFrame");
        }

        rect = mBoxDiv.getBoundingClientRect();

        mInnerFrame.style.left = "0px";
        mInnerFrame.style.top = "0px";
        mInnerFrame.style.width = rect.width + "px";
        mInnerFrame.style.height = rect.height + "px";

        mInnerFrame.src = url;


        if (document.getElementById("_idInnerFrameCloseButton") == null) {
            mCloseButton = document.createElement("img");
            mCloseButton.id = "_idInnerFrameCloseButton";
            mCloseButton.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACwAAAAsCAYAAAAehFoBAAAABmJLR0QA6AC4ADl1rxDBAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4AMGEBkexXKjJQAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAA3klEQVRYw+2YQQ7FIAhEZe5/Z7r4f9E02ooMWhtmTeGFAiqlpFKp1KckLEeqqo/BRGQpcA8kG17YoDUQqz0VuBbcEtT7vXhgPTU56ktWwHp8yirYUd+Y1d3Tmu6cATbsSByUzQTGr9O/njLImMdgnmQte5YfWkmcs3MNxu4BsDq5Bm2F7bFB1IiKmi70KXGFY49COvBdDb8OuFUGTGh4x8wdrBW6xwaRmY3INKgXk4Y9y09efl7zzI/OssU/PM5n7TO+/6bb8tW85V5iy80PqwGn7tZG4SMPnlQqlfrpACym1CcHWDQfAAAAAElFTkSuQmCC";
            mCloseButton.style.cssText = "position: absolute; display: inline; z-index:100001;";
            mCloseButton.style.width = "64px";
            mCloseButton.style.height = "64px";
            mCloseButton.style.cursor = "pointer";

            mCloseButton.addEventListener("click", this.closeDialogURL);

            messageContainer.appendChild(mCloseButton);
        } else {
            mCloseButton = document.getElementById("_idInnerFrameCloseButton");
        }

        mCloseButton.style.left = ((left + width) - 30) + "px";
        mCloseButton.style.top = (top - 30) + "px";

        messageContainer.el = mInnerFrame;

        return messageContainer;
    }

    this.closeDialogURL = function () {
        var oContainer = document.getElementById("_InnerFrameContainer");
        var oMask = document.getElementById("_idInnerFrameMask");
        var oFrame = document.getElementById("_idInnerFrameBox");

        if (oFrame) {
            var pElement = document.body;

            if (oFrame.parentElement)
                pElement = oFrame.parentElement;

            pElement.removeChild(oFrame);

        }

        if (oMask) {
            var pElement = document.body;

            if (oMask.parentElement)
                pElement = oMask.parentElement;

            pElement.removeChild(oMask);
        }

        if (oContainer) {
            var pElement = document.body;

            if (oContainer.parentElement)
                pElement = oContainer.parentElement;

            pElement.removeChild(oContainer);
        }
    }

    this.isDialogOpened = function () {
        var messageContainer;

        if (document.getElementById("_InnerFrameContainer") != null) {
            messageContainer = document.getElementById("_InnerFrameContainer");
        }

        return messageContainer;
    }

    this.popUpMessage = function (rootElement, text, timeoutMS) {
        var divEl = document.createElement("div");
        var d = new Date();
        var root;
        var tMS;

        function checkPopUpMessageTimeout(rootEl, timeout) {
            setTimeout(function () {
                var removeEl = [];

                for (var i = 0; i < rootEl.children.length; i++) {
                    var o = rootEl.children[i];

                    if (o.hasAttribute("PopUpMsg")) {
                        var ct = new Date(Number(o.getAttribute("CreateTime")));
                        var dur = Number(o.getAttribute("Duration"));
                        var cd = new Date(); //current date

                        if (dur > 0) {
                            if ((cd - ct) >= dur) {
                                removeEl[removeEl.length] = o;
                            }
                        }
                    }
                }

                if (removeEl.length > 0) {
                    for (var i = 0; i < removeEl.length; i++) {
                        rootEl.removeChild(removeEl[i]);
                    }
                }
            }, timeout);
        }

        if (timeoutMS == null)
            tMS = 3000;
        else
            tMS = timeoutMS;

        if (rootElement == null)
            root = document.body;
        else
            root = rootElement;

        divEl.innerHTML = text;
        divEl.setAttribute("PopUpMsg", "1");
        divEl.setAttribute("CreateTime", Number(d));
        divEl.setAttribute("Duration", tMS);

        root.appendChild(divEl);

        if (tMS > 0) {
            checkPopUpMessageTimeout(root, tMS);
        }
    }

    function getScreenSize() {
        var scr = {
            width: 0,
            height: 0
        }

        scr.width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
        scr.height = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;

        return scr;
    }
}