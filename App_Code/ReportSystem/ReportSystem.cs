using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Web;

/// <summary>
/// RedisCache 的摘要描述
/// </summary>
public static class ReportSystem {

    static System.Collections.ArrayList iSyncRoot = new System.Collections.ArrayList();


    /// <summary>
    /// 金流(第四方)存款
    /// </summary>
    public static class UserAccountPayment {
        public static string GetUserAccountPayment(DateTime QueryDate, string LoginAccount) {
            string Folder;
            string Filename;
            string RetValue = string.Empty;

            Folder = GetReportFolder("/Payment/" + QueryDate.ToString("yyyy-MM-dd") + "/ByLoginAccount");
            Filename = Folder + "\\" + LoginAccount + ".json";

            if (System.IO.File.Exists(Filename)) {
                RetValue = ReadAllText(Filename);
            }

            return RetValue;
        }

        public static void CreateUserAccountPayment(string OrderNumber) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;
            string Folder;
            string Filename;

            SS = "SELECT P.*, PC.CategoryName, PM.PaymentCode, PaymentName , PC.PaymentCategoryCode,PM.PaymentType,PM.EWinPaymentType " +
                 "FROM UserAccountPayment AS P WITH (NOLOCK) " +
                 "LEFT JOIN PaymentMethod AS PM WITH (NOLOCK) ON P.forPaymentMethodID = PM.PaymentMethodID " +
                 "LEFT JOIN PaymentCategory AS PC WITH (NOLOCK) ON PM.PaymentCategoryCode = PC.PaymentCategoryCode " +
                 "WHERE P.OrderNumber=@OrderNumber";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@OrderNumber", System.Data.SqlDbType.VarChar).Value = OrderNumber;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            foreach (System.Data.DataRow DR in DT.Rows) {
                dynamic o = new System.Dynamic.ExpandoObject();
                string Content;
                o.PaymentType = (int)DR["PaymentType"];
                o.BasicType = (int)DR["EWinPaymentType"];
                o.PaymentFlowType = (int)DR["FlowStatus"];
                o.LoginAccount = (string)DR["LoginAccount"];
                o.PaymentSerial = (string)DR["PaymentSerial"];
                o.OrderNumber = (string)DR["OrderNumber"];
                o.Amount = (decimal)DR["Amount"];
                o.PointValue = (decimal)DR["PointValue"];
                o.HandingFeeRate = (decimal)DR["HandingFeeRate"];

                o.ThresholdValue = (decimal)DR["ThresholdValue"];
                o.ThresholdRate = (decimal)DR["ThresholdRate"];

                o.ExpireSecond = (int)DR["ExpireSecond"];
                o.PaymentMethodID = (int)DR["forPaymentMethodID"];
                o.PaymentMethodName = (string)DR["PaymentName"];
                o.PaymentCode = (string)DR["PaymentCode"];
                o.PaymentCategoryCode = Convert.IsDBNull(DR["PaymentCategoryCode"]) ? "" : (string)DR["PaymentCategoryCode"];
                o.ToWalletAddress = (string)DR["ToInfo"];

                o.FromInfo = (string)DR["FromInfo"];
                o.DetailData = (string)DR["DetailData"];
                o.ActivityData = Convert.IsDBNull(DR["ActivityData"]) ? "" : (string)DR["ActivityData"];
                o.FinishDate = ((DateTime)DR["FinishDate"]).ToString("yyyy/MM/dd HH:mm:ss");
                o.CreateDate = ((DateTime)DR["CreateDate"]).ToString("yyyy/MM/dd HH:mm:ss");

                Content = Newtonsoft.Json.JsonConvert.SerializeObject(o) + "\r\n";

                Folder = PrepareReportFolder("/Payment/" + ((DateTime)DR["FinishDate"]).ToString("yyyy-MM-dd") + "/ByLoginAccount");
                Filename = Folder + "\\" + DR["LoginAccount"].ToString() + ".json";
                AppendAllText(Filename, Content);

            }
        }

        public static void ResetUserAccountPayment(string LoginAccount, DateTime SummaryDate) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;
            string Folder;
            string Filename;

            SS = "SELECT P.*, PC.CategoryName, PM.PaymentCode, PaymentName , PC.PaymentCategoryCode,PM.PaymentType,PM.EWinPaymentType " +
                 "FROM UserAccountPayment AS P WITH (NOLOCK) " +
                 "LEFT JOIN PaymentMethod AS PM WITH (NOLOCK) ON P.forPaymentMethodID = PM.PaymentMethodID " +
                 "LEFT JOIN PaymentCategory AS PC WITH (NOLOCK) ON PM.PaymentCategoryCode = PC.PaymentCategoryCode " +
                 "WHERE P.LoginAccount=@LoginAccount AND dbo.GetReportDate(FinishDate) = dbo.GetReportDate(@SummaryDate) AND FlowStatus IN (2,3,4) ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@SummaryDate", System.Data.SqlDbType.DateTime).Value = SummaryDate;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            string Content = "";

            foreach (System.Data.DataRow DR in DT.Rows) {
                dynamic o = new System.Dynamic.ExpandoObject();

                o.PaymentType = (int)DR["PaymentType"];
                o.BasicType = (int)DR["EWinPaymentType"];
                o.PaymentFlowType = (int)DR["FlowStatus"];
                o.LoginAccount = (string)DR["LoginAccount"];
                o.PaymentSerial = (string)DR["PaymentSerial"];
                o.OrderNumber = (string)DR["OrderNumber"];
                o.Amount = (decimal)DR["Amount"];
                o.PointValue = (decimal)DR["PointValue"];
                o.HandingFeeRate = (decimal)DR["HandingFeeRate"];

                o.ThresholdValue = (decimal)DR["ThresholdValue"];
                o.ThresholdRate = (decimal)DR["ThresholdRate"];

                o.ExpireSecond = (int)DR["ExpireSecond"];
                o.PaymentMethodID = (int)DR["forPaymentMethodID"];
                o.PaymentMethodName = (string)DR["PaymentName"];
                o.PaymentCode = (string)DR["PaymentCode"];
                o.PaymentCategoryCode = (string)DR["PaymentCategoryCode"];
                o.ToWalletAddress = (string)DR["ToInfo"];

                o.FromInfo = (string)DR["FromInfo"];
                o.DetailData = (string)DR["DetailData"];
                o.ActivityData = Convert.IsDBNull(DR["ActivityData"]) ? "" : (string)DR["ActivityData"];
                o.FinishDate = ((DateTime)DR["FinishDate"]).ToString("yyyy/MM/dd HH:mm:ss");
                o.CreateDate = ((DateTime)DR["CreateDate"]).ToString("yyyy/MM/dd HH:mm:ss");

                Content += Newtonsoft.Json.JsonConvert.SerializeObject(o) + "\r\n";


            }


            Folder = PrepareReportFolder("/Payment/" + SummaryDate.ToString("yyyy-MM-dd") + "/ByLoginAccount");
            Filename = Folder + "\\" + LoginAccount + ".json";

            WriteAllText(Filename, Content);
        }
    }

    public class UserAccountEventBonusHistory {
        public static void CreateUserAccountEventBonusHistory(int EventBonusHistoryID) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;
            string Folder;
            string Filename;

            SS = "SELECT * " +
                 "FROM UserAccountEventBonusHistory WITH (NOLOCK) " +
                 "WHERE EventBonusHistoryID=@EventBonusHistoryID";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@EventBonusHistoryID", System.Data.SqlDbType.Int).Value = EventBonusHistoryID;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            foreach (System.Data.DataRow DR in DT.Rows) {
                dynamic o = new System.Dynamic.ExpandoObject();
                string Content;
                o.EventBonusHistoryID = (int)DR["EventBonusHistoryID"];
                o.LoginAccount = (string)DR["LoginAccount"];
                o.RelationID = (string)DR["RelationID"];
                o.EventType = (int)DR["EventType"];
                o.ActivityName = (string)DR["ActivityName"];
                o.ThresholdRate = (decimal)DR["ThresholdRate"];
                o.ThresholdValue = (decimal)DR["ThresholdValue"];
                o.BonusRate = (decimal)DR["BonusRate"];
                o.BonusValue = (decimal)DR["BonusValue"];
                o.CreateDate = ((DateTime)DR["CreateDate"]).ToString("yyyy/MM/dd HH:mm:ss");

                Content = Newtonsoft.Json.JsonConvert.SerializeObject(o) + "\r\n";

                Folder = PrepareReportFolder("/EventBonusHistory/" + ((DateTime)DR["CreateDate"]).ToString("yyyy-MM-dd") + "/ByLoginAccount");
                Filename = Folder + "\\" + DR["LoginAccount"].ToString() + ".json";
                AppendAllText(Filename, Content);

            }
        }

        public static string GetUserAccountEventBonusHistory(DateTime QueryDate, string LoginAccount) {
            string Folder;
            string Filename;
            string RetValue = string.Empty;

            Folder = GetReportFolder("/EventBonusHistory/" + QueryDate.ToString("yyyy-MM-dd") + "/ByLoginAccount");
            Filename = Folder + "\\" + LoginAccount + ".json";

            if (System.IO.File.Exists(Filename)) {
                RetValue = ReadAllText(Filename);
            }

            return RetValue;
        }
    }

    public class UserAccountPromotionCollect {
        public static void CreateUserAccountPromotionCollect(string Token, string LoginAccount, string CurrencyType, string Description) {
            string Folder;
            string Filename;

            dynamic o = new System.Dynamic.ExpandoObject();
            string Content;
            o.Token = Token;
            o.LoginAccount = LoginAccount;
            o.CurrencyType = CurrencyType;
            o.Description = Description;

            Content = Newtonsoft.Json.JsonConvert.SerializeObject(o) + "\r\n";

            Folder = PrepareReportFolder("/UserAccountPromotionCollect/ByLoginAccount");
            Filename = Folder + "\\" + LoginAccount + ".json";
            AppendAllText(Filename, Content);
        }
    }

    public class SevenDateBonusForConsole {
        public static void CreateSevenDateBonusForConsoleHistory(string SummaryDate, string Content) {
            string Folder;
            string Filename;
            Folder = PrepareReportFolder("/SevenDateBonusHistory/BySummaryDate");
            Filename = Folder + "\\" + SummaryDate + ".json";
            AppendAllText(Filename, Content);
        }
    }

    private static string[] CheckAndGetJSONRecordByIDRange(string AllContent, string KeyField, long LimitValueBegin = -1, long LimitValueEnd = -1)
    {
        List<Newtonsoft.Json.Linq.JObject> ObjList = new List<Newtonsoft.Json.Linq.JObject>();
        Dictionary<string, Newtonsoft.Json.Linq.JObject> ObjDict = new Dictionary<string, Newtonsoft.Json.Linq.JObject>();
        List<string> DestJSONList = new List<string>();

        foreach (string EachJSON in AllContent.Split('\r', '\n')) {
            if (string.IsNullOrEmpty(EachJSON) == false) {
                bool stringIsExist = false;
                string tmpJSON = EachJSON.Replace("\r", "").Replace("\n", "");
                Newtonsoft.Json.Linq.JObject o = null;

                try { o = Newtonsoft.Json.Linq.JObject.Parse(tmpJSON); } catch (Exception ex) { }

                if (o != null) {
                    object KeyValue = EWinWeb.GetJValue(o, KeyField);

                    if (KeyValue != null) {
                        bool AllowProcess = false;

                        if (LimitValueBegin != -1) {
                            long v = 0;

                            if (System.Int64.TryParse(Convert.ToString(KeyValue), out v)) {
                                if (v >= LimitValueBegin)
                                    AllowProcess = true;
                            }
                        } else {
                            AllowProcess = true;
                        }

                        if (AllowProcess == true) {
                            if (LimitValueEnd != -1) {
                                long v = 0;

                                if (System.Int64.TryParse(Convert.ToString(KeyValue), out v)) {
                                    if (v > LimitValueEnd)
                                        AllowProcess = false;
                                }
                            }
                        }

                        if (AllowProcess) {
                            if (ObjDict.ContainsKey(Convert.ToString(KeyValue))) {
                                int objectIndex;
                                Newtonsoft.Json.Linq.JObject old_o = ObjDict[Convert.ToString(KeyValue)];

                                objectIndex = ObjList.IndexOf(old_o);
                                if (objectIndex != -1) {
                                    ObjList[objectIndex] = o;
                                }

                                ObjDict[Convert.ToString(KeyValue)] = o;
                                stringIsExist = true;
                            }

                            if (stringIsExist == false) {
                                ObjList.Add(o);
                                ObjDict.Add(EWinWeb.GetJValue(o, KeyField), o);
                            }
                        }
                    }
                }
            }
        }

        foreach (Newtonsoft.Json.Linq.JObject o in ObjList.ToArray()) {
            DestJSONList.Add(Newtonsoft.Json.JsonConvert.SerializeObject(o));
        }

        return DestJSONList.ToArray();
    }

    private static string CheckAndGetJSONRecord(string AllContent, string KeyField)
    {
        List<Newtonsoft.Json.Linq.JObject> ObjList = new List<Newtonsoft.Json.Linq.JObject>();
        Dictionary<string, Newtonsoft.Json.Linq.JObject> ObjDict = new Dictionary<string, Newtonsoft.Json.Linq.JObject>();
        System.Text.StringBuilder DestJSON = new System.Text.StringBuilder();

        foreach (string EachJSON in AllContent.Split('\r', '\n')) {
            if (string.IsNullOrEmpty(EachJSON) == false) {
                bool stringIsExist = false;
                string tmpJSON = EachJSON.Replace("\r", "").Replace("\n", "");
                Newtonsoft.Json.Linq.JObject o = null;

                try { o = Newtonsoft.Json.Linq.JObject.Parse(tmpJSON); } catch (Exception ex) { }

                if (o != null) {
                    object KeyValue = EWinWeb.GetJValue(o, KeyField);

                    if (KeyValue != null) {
                        if (ObjDict.ContainsKey(Convert.ToString(KeyValue))) {
                            int objectIndex;
                            Newtonsoft.Json.Linq.JObject old_o = ObjDict[Convert.ToString(KeyValue)];

                            objectIndex = ObjList.IndexOf(old_o);
                            if (objectIndex != -1) {
                                ObjList[objectIndex] = o;
                            }

                            ObjDict[Convert.ToString(KeyValue)] = o;
                            stringIsExist = true;
                        }
                    }

                    if (stringIsExist == false) {
                        ObjList.Add(o);
                        ObjDict.Add(EWinWeb.GetJValue(o, KeyField), o);
                    }
                }
            }
        }

        foreach (Newtonsoft.Json.Linq.JObject o in ObjList.ToArray()) {
            DestJSON.Append(Newtonsoft.Json.JsonConvert.SerializeObject(o) + "\r\n");
        }

        return DestJSON.ToString();
    }

    private static void CheckAndAppendJSONRecord(string Filename, string NewRecordJSON, string KeyField)
    {
        string AllContent = null;
        System.Text.StringBuilder DestJSON = new System.Text.StringBuilder();
        bool newRecordIsAppend = false;

        if (System.IO.File.Exists(Filename)) {
            AllContent = ReadAllText(Filename);
        }

        if (string.IsNullOrEmpty(AllContent) == false) {
            Newtonsoft.Json.Linq.JObject new_o = null;

            try {
                new_o = Newtonsoft.Json.Linq.JObject.Parse(NewRecordJSON);
            } catch (Exception ex) {
            }

            if (new_o != null) {
                object new_KeyValue = EWinWeb.GetJValue(new_o, KeyField);

                foreach (string EachJSON in AllContent.Split('\r', '\n')) {
                    if (string.IsNullOrEmpty(EachJSON) == false) {
                        bool stringIsExist = false;
                        string tmpJSON = EachJSON.Replace("\r", "").Replace("\n", "");
                        Newtonsoft.Json.Linq.JObject src_o = null;

                        try {
                            src_o = Newtonsoft.Json.Linq.JObject.Parse(tmpJSON);
                        } catch (Exception ex) {
                        }

                        if (src_o != null) {
                            object src_KeyValue = EWinWeb.GetJValue(src_o, KeyField);

                            if (src_KeyValue != null) {
                                if (Convert.ToString(src_KeyValue) == Convert.ToString(new_KeyValue)) {
                                    stringIsExist = true;
                                }
                            }
                        }

                        if (stringIsExist == false) {
                            DestJSON.Append(tmpJSON + "\r\n");
                        } else {
                            DestJSON.Append(NewRecordJSON);
                            newRecordIsAppend = true;
                        }
                    }
                }
            }
        }

        if (newRecordIsAppend == false)
            DestJSON.Append(NewRecordJSON);

        WriteAllText(Filename, DestJSON.ToString());
    }

    private static string ReadAllText(string Filename)
    {
        string RetValue = null;
        bool ReadSuccess = false;
        Exception throwEx = null;

        for (var i = 0; i < 3; i++) {
            lock (iSyncRoot) {
                try {
                    RetValue = System.IO.File.ReadAllText(Filename);

                    ReadSuccess = true;
                    throwEx = null;
                    break;
                } catch (Exception ex) {
                    ReadSuccess = false;
                    throwEx = ex;
                }
            }

            System.Threading.Thread.Sleep(0);
        }

        if (ReadSuccess == false) {
            if (throwEx != null)
                throw throwEx;
        }

        return RetValue;
    }

    private static void AppendAllText(string Filename, string Content)
    {
        byte[] ContentArray = System.Text.Encoding.UTF8.GetBytes(Content);
        Exception throwEx = null;

        for (var i = 0; i < 10; i++) {
            lock (iSyncRoot) {
                try {
                    System.IO.File.AppendAllText(Filename, Content);
                    /*
                    System.IO.FileStream FS = System.IO.File.Open(Filename, System.IO.FileMode.Append, System.IO.FileAccess.ReadWrite, System.IO.FileShare.ReadWrite);
                    //System.IO.File.AppendAllText(Filename, Content);

                    FS.Write(ContentArray, 0, ContentArray.Length);
                    FS.Close();
                    FS = null;
                    */
                    throwEx = null;
                    break;
                } catch (Exception ex) {
                    throwEx = ex;
                }
            }

            System.Threading.Thread.Sleep(100);
        }

        if (throwEx != null)
            throw throwEx;
    }

    private static void WriteAllText(string Filename, string Content)
    {
        byte[] ContentArray = System.Text.Encoding.UTF8.GetBytes(Content);
        Exception throwEx = null;

        for (var i = 0; i < 3; i++) {
            lock (iSyncRoot) {
                try {
                    System.IO.File.WriteAllText(Filename, Content);
                    throwEx = null;
                    break;
                } catch (Exception ex) {
                    throwEx = ex;
                }
            }

            System.Threading.Thread.Sleep(100);
        }

        if (throwEx != null)
            throw new Exception(throwEx.ToString() + "\r\n" + "  Filename:" + Filename);
    }

    private static string PrepareReportFolder(string C)
    {
        string ReportFolder;

        lock (iSyncRoot) {
            ReportFolder = GetReportFolder(C);
            if (System.IO.Directory.Exists(ReportFolder) == false) {
                try { System.IO.Directory.CreateDirectory(ReportFolder); } catch (Exception ex) { }
            }
        }

        return ReportFolder;
    }

    private static string GetReportFolder(string C)
    {
        string ReportFolder;

        ReportFolder = EWinWeb.SharedFolder + C.Replace('/', '\\');
        
        return ReportFolder;
    }


    public static string GetPaymentHistoryByUserAccountID(DateTime SummaryDate, int CompanyID, int UserAccountID)
    {
        string Folder;
        string Filename;
        string RetValue = string.Empty;

        Folder = GetReportFolder("/GameOrderHistory/" + SummaryDate.ToString("yyyy-MM-dd") + "/ByUserAccountID/" + CompanyID.ToString());
        Filename = Folder + "\\" + UserAccountID.ToString() + ".json";

        if (System.IO.File.Exists(Filename)) {
            RetValue = CheckAndGetJSONRecord(ReadAllText(Filename), "OrderHistoryID");
        }

        return RetValue;
    }

    public static void CreateTestContent(string Content)
    {
        string Folder;
        string Filename;

        Folder = PrepareReportFolder("/test");
        Filename = Folder + "\\test.json";
        AppendAllText(Filename, Content);
    }

    public static void CreatePaymentContent(string Content,string ProviderCode,string OrderID)
    {
        string Folder;
        string Filename;

        Folder = PrepareReportFolder("/"+ ProviderCode+"/"+ DateTime.Now.ToString("yyyy-MM-dd"));
        Filename = Folder + "\\"  + OrderID + ".json";
        AppendAllText(Filename, Content + "\r\n");
    }

}