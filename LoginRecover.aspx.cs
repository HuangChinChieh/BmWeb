using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Services;

public partial class LoginRecover : System.Web.UI.Page
{
    public class RecoverResult
    {
        public enum enumResultCode
        {
            OK = 0,
            ERR = 1
        }

        public enumResultCode ResultCode;
        public string LoginAccount;
        public string Message;
        public string Token;
        public string RecoverToken;
        public string SID;
        public string CT;
    }
}