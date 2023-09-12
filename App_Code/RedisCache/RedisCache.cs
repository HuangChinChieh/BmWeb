using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Web;

/// <summary>
/// RedisCache 的摘要描述
/// </summary>
public static class RedisCache {
    public static class Company {
        private static string XMLPath = "Company";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetCompanyGameCode() {
            string Key4;
            System.Data.DataTable DT = null;

            Key4 = XMLPath + ":CompanyGameCode";
            if (KeyExists(DBIndex, Key4) == false)
                return null;

            if (KeyExists(DBIndex, Key4))
                DT = DTReadFromRedis(DBIndex, Key4);

            return DT;
        }

        public static System.Data.DataTable UpdateCompanyGameCode(System.Data.DataTable DT) {
            string Key4;

            Key4 = XMLPath + ":CompanyGameCode";
            for (int I = 0; I <= 3; I++) {
                try {
                    DTWriteToRedis(DBIndex, DT, Key4);
                    break;
                } catch (Exception ex) {
                }
            }

            return DT;
        }

        public static string GetCompanyGameCodeString() {
            string R = string.Empty;
            string Key4;

            Key4 = XMLPath + ":CompanyGameCode";
            if (KeyExists(DBIndex, Key4) == false) {
                return null;
            }

            if (KeyExists(DBIndex, Key4)) {
                R = JsonReadFromRedis(DBIndex, Key4);
            }

            return R;
        }

        public static void UpdateCompanyGameCode(string JsonData) {
            string Key4;

            Key4 = XMLPath + ":CompanyGameCode";
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key4, 300);
                    break;
                } catch (Exception ex) {
                }
            }
        }
    }

    public class SessionContext {
        private static string XMLPath = "Session";
        private static int DBIndex = 0;

        // SIDM 用來給 Pad 統計人數使用, 訪客或餘額 0 不會計入

        public static bool CheckSIDExist(string SID) {
            string Key;
            bool RetValue = false;

            Key = XMLPath + ":SID." + SID;
            if (KeyExists(DBIndex, Key) == true) {
                RetValue = true;
            }

            return RetValue;
        }

        public static string[] ListAllSID() {
            string Key3;
            List<string> RetValue = new List<string>();
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
            StackExchange.Redis.HashEntry[] HEList;

            ClearExpireSID();

            Key3 = XMLPath + ":AllSID";
            HEList = Client.HashGetAll(Key3.ToUpper());
            if (HEList != null) {
                if (HEList.Length > 0) {
                    foreach (StackExchange.Redis.HashEntry EachHE in HEList) {
                        string HEName = EachHE.Name;
                        string HEValue = EachHE.Value;

                        if (string.IsNullOrEmpty(HEName) == false) {
                            if (HEName.Length >= 4) {
                                if (HEName.Substring(0, 4).ToUpper() == "SID_".ToUpper()) {
                                    string SID = HEName.Substring(4);
                                    string Value = HEValue.ToString();

                                    RetValue.Add(SID);
                                }
                            }
                        }
                    }
                }
            }


            return RetValue.ToArray();
        }

        public static string GetSIDParam(string SID, string ParamName) {
            string RetValue = null;

            if (string.IsNullOrEmpty(SID) == false) {
                string Key;
                StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

                Key = XMLPath + ":SID." + SID;

                if (Client.KeyExists(Key.ToUpper())) {
                    if (Client.HashExists(Key.ToUpper(), ("Param." + ParamName).ToUpper())) {
                        RetValue = Client.HashGet(Key.ToUpper(), ("Param." + ParamName).ToUpper());
                    }
                }
            }

            return RetValue;
        }

        public static bool SetSIDParam(string SID, string ParamName, string ParamValue) {
            bool RetValue = false;

            if (string.IsNullOrEmpty(SID) == false) {
                string Key;
                StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

                Key = XMLPath + ":SID." + SID;

                if (Client.KeyExists(Key.ToUpper())) {
                    Client.HashSet(Key.ToUpper(), ("Param." + ParamName).ToUpper(), ParamValue);
                    RetValue = true;
                }
            }

            return RetValue;
        }

        public static string CreateSID(string CompanyCode, string LoginAccount, string AccessIP, bool IsGuestAccount, string EWinSID, string EWinCT) {
            SIDInfo SI = null;
            string SID = System.Guid.NewGuid().ToString();
            string DateTimeSerial = System.DateTime.UtcNow.ToString("yyyyMMddHHmmss");
            int BaseValue1 = new Random().Next(100000, 999999);
            int UserAccountEncID;
            string RndString = CodingControl.RandomPassword(8);


            UserAccountEncID = BaseValue1;
            //SID = RndString + UserAccountEncID + "-" + BaseValue1 + DateTimeSerial;
            SID = RndString + System.Guid.NewGuid().ToString() + "-" + BaseValue1 + DateTimeSerial;
            CreateSID(SID, LoginAccount, CompanyCode, AccessIP, IsGuestAccount, EWinSID, EWinCT);

            return SID;
        }

        public static SIDInfo CreateSID(string NewSID, string LoginAccount, string CompanyCode, string AccessIP, bool IsGuestAccount, string EWinSID, string EWinCT) {
            SIDInfo SI = null;

            SI = new SIDInfo();

            SI.SID = NewSID;
            SI.LoginAccount = LoginAccount;
            SI.CompanyCode = CompanyCode;
            //SI.ImageValidated = ImageValidated;
            SI.IsGuestAccount = IsGuestAccount;
            //SI.UserLevel = (int)UserAccountDR["UserLevelIndex"];
            SI.Language = string.Empty;
            SI.EWinSID = EWinSID;
            SI.EWinCT = EWinCT;
            SI.AccessIP = AccessIP;
            //SI.UserCountry = (string)UserAccountDR["UserCountry"];
            //SI.CashUnit = (int)CompanyDR["CashUnit"];
            //SI.Timezone = (decimal)CompanyDR["Timezone"];

            //ClearExpireSIDByUserAccountID(SI.UserAccountID);
            ClearExpireSIDByLoginAccount(LoginAccount);
            ClearExpireSID();
            UpdateSID(SI);

            return SI;
        }

        public static bool BindingUID(string SID, int BindingType, string BindingUID, string BindingNickname, string BindingHeadImg) {
            string Key;
            bool RetValue = false;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
            StackExchange.Redis.HashEntry[] HE;

            Key = XMLPath + ":SID." + SID;

            if (Client.KeyExists(Key.ToUpper())) {
                StackExchange.Redis.ITransaction T;

                T = Client.CreateTransaction();

                T.HashSetAsync(Key.ToUpper(), "IsBindingAccount", "1");
                T.HashSetAsync(Key.ToUpper(), "BindingType", BindingType.ToString());
                T.HashSetAsync(Key.ToUpper(), "BindingUID", BindingUID);
                T.HashSetAsync(Key.ToUpper(), "BindingNickname", BindingNickname);
                T.HashSetAsync(Key.ToUpper(), "BindingHeadImg", BindingHeadImg);

                T.Execute();

                RetValue = true;
            }

            return RetValue;
        }

        public static void ExpireSID(string SID) {
            string Key1;

            Key1 = XMLPath + ":SID." + SID;
            if (KeyExists(DBIndex, Key1)) {
                try {
                    KeyDelete(DBIndex, Key1);
                } catch (Exception ex) {
                }
            }
        }

        public static void ExpireByUserAccountID(int UserAccountID) {
            string Key2;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient();
            string[] SIDList;

            Key2 = XMLPath + ":UserAccountID:" + UserAccountID;

            SIDList = GetSIDByUserAccountID(UserAccountID);
            if (SIDList != null) {
                foreach (string EachSID in SIDList) {
                    ExpireSID(EachSID);
                }
            }

            Client.KeyDelete(Key2.ToUpper());
        }

        public static string[] GetSIDByUserAccountID(int UserAccountID) {
            string Key2;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient();
            StackExchange.Redis.HashEntry[] HEList;
            System.Collections.Generic.List<string> iList = new List<string>();

            Key2 = XMLPath + ":UserAccountID:" + UserAccountID;
            HEList = Client.HashGetAll(Key2.ToUpper());
            if (HEList != null) {
                if (HEList.Length > 0) {
                    foreach (StackExchange.Redis.HashEntry EachHE in HEList) {
                        string HEName = EachHE.Name;
                        string HEValue = EachHE.Value;

                        if (string.IsNullOrEmpty(HEName) == false) {
                            if (HEName.Length >= 4) {
                                if (HEName.Substring(0, 4).ToUpper() == "SID_".ToUpper()) {
                                    string SID = HEName.Substring(4);

                                    if (CheckSIDExist(SID)) {
                                        iList.Add(SID);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return iList.ToArray();
        }

        public static string[] GetSIDByLoginAccount(string LoginAccount) {
            string Key2;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient();
            StackExchange.Redis.HashEntry[] HEList;
            System.Collections.Generic.List<string> iList = new List<string>();

            Key2 = XMLPath + ":LoginAccount:" + LoginAccount;
            HEList = Client.HashGetAll(Key2.ToUpper());
            if (HEList != null) {
                if (HEList.Length > 0) {
                    foreach (StackExchange.Redis.HashEntry EachHE in HEList) {
                        string HEName = EachHE.Name;
                        string HEValue = EachHE.Value;

                        if (string.IsNullOrEmpty(HEName) == false) {
                            if (HEName.Length >= 4) {
                                if (HEName.Substring(0, 4).ToUpper() == "SID_".ToUpper()) {
                                    string SID = HEName.Substring(4);

                                    if (CheckSIDExist(SID)) {
                                        iList.Add(SID);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return iList.ToArray();
        }

        public static SIDInfo GetSIDInfo(string SID) {
            SIDInfo RetValue = null;

            if (string.IsNullOrEmpty(SID) == false) {
                string Key;
                StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
                StackExchange.Redis.HashEntry[] HE;

                Key = XMLPath + ":SID." + SID;

                if (Client.KeyExists(Key.ToUpper())) {
                    HE = Client.HashGetAll(Key.ToUpper());
                    if (HE != null) {
                        if (HE.Length > 0) {
                            RetValue = new SIDInfo();

                            foreach (StackExchange.Redis.HashEntry EachHE in HE) {
                                string Name = EachHE.Name.ToString();
                                string Value = EachHE.Value.ToString();

                                if (Name.ToUpper() == "SID".ToUpper()) {
                                    RetValue.SID = Value;
                                } else if (Name.ToUpper() == "CompanyCode".ToUpper()) {
                                    RetValue.CompanyCode = Value;
                                } else if (Name.ToUpper() == "LoginAccount".ToUpper()) {
                                    RetValue.LoginAccount = Value;
                                } else if (Name.ToUpper() == "IsGuestAccount".ToUpper()) {
                                    RetValue.IsGuestAccount = Convert.ToBoolean(Value);
                                } else if (Name.ToUpper() == "Language".ToUpper()) {
                                    RetValue.Language = Value;
                                } else if (Name.ToUpper() == "AccessIP".ToUpper()) {
                                    RetValue.AccessIP = Value;
                                } else if (Name.ToUpper() == "EWinSID".ToUpper()) {
                                    RetValue.EWinSID = Value;
                                } else if (Name.ToUpper() == "EWinCT".ToUpper()) {
                                    RetValue.EWinCT = Value;
                                } else if (Name.ToUpper() == "IsBindingAccount".ToUpper()) {
                                    if (Value == "1") {
                                        RetValue.IsBindingAccount = true;
                                    }
                                } else if (Name.ToUpper() == "BindingType".ToUpper()) {
                                    RetValue.BindingType = Convert.ToInt32(Value);
                                } else if (Name.ToUpper() == "BindingUID".ToUpper()) {
                                    RetValue.BindingUID = Value;
                                } else if (Name.ToUpper() == "BindingNickname".ToUpper()) {
                                    RetValue.BindingNickname = Value;
                                } else if (Name.ToUpper() == "BindingHeadImg".ToUpper()) {
                                    RetValue.BindingHeadImg = Value;
                                } else { }
                                //else if (Name.ToUpper() == "CashUnit".ToUpper()) { RetValue.CashUnit = Convert.ToInt32(Value); }
                                //else if (Name.ToUpper() == "Timezone".ToUpper()) { RetValue.Timezone = Convert.ToDecimal(Value); }

                            }
                        }
                    }
                }
            }

            return RetValue;
        }

        public static bool RefreshSID(string SID) {
            string Key;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
            bool RetValue = false;

            Key = XMLPath + ":SID." + SID;

            if (Client.KeyExists(Key.ToUpper()) == true) {
                Client.KeyExpire(Key.ToUpper(), new TimeSpan(0, 0, 120));

                RetValue = true;
            }

            return RetValue;
        }

        public static ExpireSIDCounter ClearExpireSIDByUserAccountID(int UserAccountID) {
            string Key2;
            ExpireSIDCounter RetValue = new ExpireSIDCounter();
            List<ExpireSIDCounter.AliveSID> AList = new List<ExpireSIDCounter.AliveSID>();
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient();
            StackExchange.Redis.HashEntry[] HEList;
            StackExchange.Redis.ITransaction T;

            Key2 = XMLPath + ":UserAccountID:" + UserAccountID;
            HEList = Client.HashGetAll(Key2.ToUpper());
            if (HEList != null) {
                if (HEList.Length > 0) {
                    T = Client.CreateTransaction();

                    foreach (StackExchange.Redis.HashEntry EachHE in HEList) {
                        string HEName = EachHE.Name;
                        string HEValue = EachHE.Value;

                        if (string.IsNullOrEmpty(HEName) == false) {
                            if (HEName.Length >= 4) {
                                if (HEName.Substring(0, 4).ToUpper() == "SID_".ToUpper()) {
                                    string SID = HEName.Substring(4);
                                    string Value = HEValue.ToString();

                                    RetValue.TotalCount++;

                                    if (CheckSIDExist(SID) == false) {
                                        T.HashDeleteAsync(Key2.ToUpper(), HEName);
                                        RetValue.ExpireCount++;
                                    } else {
                                        ExpireSIDCounter.AliveSID ASID = new ExpireSIDCounter.AliveSID();

                                        ASID.SID = SID;
                                        ASID.LastUpdate = System.DateTime.FromBinary(Convert.ToInt64(Value));

                                        AList.Add(ASID);

                                        RetValue.AliveCount++;
                                    }
                                }
                            }
                        }
                    }

                    T.Execute();
                }
            }

            RetValue.AliveList = AList.ToArray();

            return RetValue;
        }

        public static ExpireSIDCounter ClearExpireSIDByLoginAccount(string LoginAccount) {
            string Key2;
            ExpireSIDCounter RetValue = new ExpireSIDCounter();
            List<ExpireSIDCounter.AliveSID> AList = new List<ExpireSIDCounter.AliveSID>();
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient();
            StackExchange.Redis.HashEntry[] HEList;
            StackExchange.Redis.ITransaction T;

            Key2 = XMLPath + ":LoginAccount:" + LoginAccount;
            HEList = Client.HashGetAll(Key2.ToUpper());
            if (HEList != null) {
                if (HEList.Length > 0) {
                    T = Client.CreateTransaction();

                    foreach (StackExchange.Redis.HashEntry EachHE in HEList) {
                        string HEName = EachHE.Name;
                        string HEValue = EachHE.Value;

                        if (string.IsNullOrEmpty(HEName) == false) {
                            if (HEName.Length >= 4) {
                                if (HEName.Substring(0, 4).ToUpper() == "SID_".ToUpper()) {
                                    string SID = HEName.Substring(4);
                                    string Value = HEValue.ToString();

                                    RetValue.TotalCount++;

                                    if (CheckSIDExist(SID) == false) {
                                        T.HashDeleteAsync(Key2.ToUpper(), HEName);
                                        RetValue.ExpireCount++;
                                    } else {
                                        ExpireSIDCounter.AliveSID ASID = new ExpireSIDCounter.AliveSID();

                                        ASID.SID = SID;
                                        ASID.LastUpdate = System.DateTime.FromBinary(Convert.ToInt64(Value));

                                        AList.Add(ASID);

                                        RetValue.AliveCount++;
                                    }
                                }
                            }
                        }
                    }

                    T.Execute();
                }
            }

            RetValue.AliveList = AList.ToArray();

            return RetValue;
        }

        private static ExpireSIDCounter ClearExpireSID() {
            string Key3;
            ExpireSIDCounter RetValue = new ExpireSIDCounter();
            List<ExpireSIDCounter.AliveSID> AList = new List<ExpireSIDCounter.AliveSID>();
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient();
            StackExchange.Redis.HashEntry[] HEList;
            StackExchange.Redis.ITransaction T;

            Key3 = XMLPath + ":AllSID";
            HEList = Client.HashGetAll(Key3.ToUpper());
            if (HEList != null) {
                if (HEList.Length > 0) {
                    T = Client.CreateTransaction();

                    foreach (StackExchange.Redis.HashEntry EachHE in HEList) {
                        string HEName = EachHE.Name;
                        string HEValue = EachHE.Value;

                        if (string.IsNullOrEmpty(HEName) == false) {
                            if (HEName.Length >= 4) {
                                if (HEName.Substring(0, 4).ToUpper() == "SID_".ToUpper()) {
                                    string SID = HEName.Substring(4);
                                    string Value = HEValue.ToString();

                                    RetValue.TotalCount++;

                                    if (CheckSIDExist(SID) == false) {
                                        T.HashDeleteAsync(Key3.ToUpper(), HEName);
                                        RetValue.ExpireCount++;
                                    } else {
                                        ExpireSIDCounter.AliveSID ASID = new ExpireSIDCounter.AliveSID();

                                        ASID.SID = SID;
                                        ASID.LastUpdate = System.DateTime.FromBinary(Convert.ToInt64(Value));

                                        AList.Add(ASID);

                                        RetValue.AliveCount++;
                                    }
                                }
                            }
                        }
                    }

                    T.Execute();
                }
            }

            RetValue.AliveList = AList.ToArray();

            return RetValue;
        }

        public static bool UpdateSIDByField(string SID, string Field, string Value) {
            string Key1;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient();
            StackExchange.Redis.ITransaction T;
            bool RetValue = false;

            Key1 = XMLPath + ":SID." + SID;
            if (Client.KeyExists(Key1.ToUpper())) {
                T = Client.CreateTransaction();
                T.HashSetAsync(Key1.ToUpper(), Field, Value);

                for (int _I = 1; _I <= 3; _I++) {
                    try {
                        T.Execute();
                        RetValue = true;
                        break;
                    } catch (Exception ex) { }
                }
            }

            return RetValue;
        }

        private static void UpdateSID(SIDInfo SI) {
            string Key1;
            string Key2;
            string Key3;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient();
            StackExchange.Redis.ITransaction T;

            Key1 = XMLPath + ":SID." + SI.SID;
            Key2 = XMLPath + ":LoginAccount:" + SI.LoginAccount;
            Key3 = XMLPath + ":AllSID";

            T = Client.CreateTransaction();
            T.HashSetAsync(Key1.ToUpper(), "SID", SI.SID);
            T.HashSetAsync(Key1.ToUpper(), "CompanyCode", SI.CompanyCode);
            T.HashSetAsync(Key1.ToUpper(), "LoginAccount", SI.LoginAccount);
            //T.HashSetAsync(Key1.ToUpper(), "UserAccountID", System.Convert.ToString(SI.UserAccountID));
            //T.HashSetAsync(Key1.ToUpper(), "CompanyID", System.Convert.ToString(SI.CompanyID));

            T.HashSetAsync(Key1.ToUpper(), "IsGuestAccount", SI.IsGuestAccount.ToString());
            //T.HashSetAsync(Key1.ToUpper(), "UserLevel", SI.UserLevel.ToString());
            T.HashSetAsync(Key1.ToUpper(), "Language", SI.Language);
            //T.HashSetAsync(Key1.ToUpper(), "UserCountry", SI.UserCountry);
            //T.HashSetAsync(Key1.ToUpper(), "CashUnit", SI.CashUnit.ToString());
            //T.HashSetAsync(Key1.ToUpper(), "Timezone", SI.Timezone.ToString());



            T.HashSetAsync(Key1.ToUpper(), "AccessIP", SI.AccessIP);
            T.HashSetAsync(Key1.ToUpper(), "EWinSID", SI.EWinSID);
            T.HashSetAsync(Key1.ToUpper(), "EWinCT", SI.EWinCT);
            T.HashSetAsync(Key2.ToUpper(), "SID_" + SI.SID, System.DateTime.Now.ToBinary());
            T.HashSetAsync(Key3.ToUpper(), "SID_" + SI.SID, System.DateTime.Now.ToBinary());

            for (int _I = 1; _I <= 3; _I++) {
                try {
                    T.Execute();
                    Client.KeyExpire(Key1.ToUpper(), new TimeSpan(0, 0, 120));
                    break;
                } catch (Exception ex) {
                }
            }
        }

        public class ExpireSIDCounter {
            public int TotalCount { get; set; }
            public int ExpireCount { get; set; }
            public int AliveCount { get; set; }
            public AliveSID[] AliveList { get; set; }

            public class AliveSID {
                public string SID { get; set; }
                public DateTime LastUpdate { get; set; }
            }
        }

        public class SIDInfo {
            public string SID { get; set; }
            public string CompanyCode { get; set; }
            public string LoginAccount { get; set; }
            //public int CompanyID { get; set; }
            //public int UserAccountID { get; set; }
            public bool IsGuestAccount { get; set; }
            public string Language { get; set; }
            public string AccessIP { get; set; }
            public string EWinSID { get; set; }
            public string EWinCT { get; set; }
            public bool IsBindingAccount { get; set; }
            public int BindingType { get; set; }
            public string BindingUID { get; set; }
            public string BindingNickname { get; set; }
            public string BindingHeadImg { get; set; }
        }
    }

    public static class PaymentContent {
        private static string XMLPath = "PaymentContent";
        private static int DBIndex = 0;

        public static T GetPaymentContent<T>(string OrderNumber) {
            T R = default(T);
            string Key;

            Key = XMLPath + ":OrderNumber:" + OrderNumber;
            if (KeyExists(DBIndex, Key) == false) {
                return default(T);
            }

            if (KeyExists(DBIndex, Key)) {
                R = JsonReadFromRedis<T>(DBIndex, Key);
            }

            return R;
        }

        public static void UpdatePaymentContent(string JsonData, string OrderNumber) {
            string Key;

            Key = XMLPath + ":OrderNumber:" + OrderNumber;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, 600);
                    break;
                } catch (Exception ex) {
                }
            }
        }

        public static void UpdatePaymentContent(string JsonData, string OrderNumber, int ExpireTime) {
            string Key;

            Key = XMLPath + ":OrderNumber:" + OrderNumber;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, ExpireTime);
                    break;
                } catch (Exception ex) {
                }
            }
        }

        public static void DeletePaymentContent(string OrderNumber) {
            string Key2;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient();

            Key2 = XMLPath + ":OrderNumber:" + OrderNumber;

            Client.KeyDelete(Key2.ToUpper());
        }

        public static void KeepPaymentContents<T>(T Target, string LoginAccount) {
            string Key;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
            List<T> NowDatas;

            Key = XMLPath + ":LoginAccount:" + LoginAccount;

            if (KeyExists(DBIndex, Key)) {
                NowDatas = JsonReadFromRedis<List<T>>(DBIndex, Key);
            } else {
                NowDatas = new List<T>();
            }

            NowDatas.Add(Target);

            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, Newtonsoft.Json.JsonConvert.SerializeObject(NowDatas), Key);
                    break;
                } catch (Exception ex) {
                }
            }
        }

        public static List<T> GetPaymentContents<T>(string LoginAccount) {
            string Key;
            string Key2Base;
            bool IsNeedReWrite = false; ;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
            List<T> NowDatas = new List<T>();

            Key = XMLPath + ":LoginAccount:" + LoginAccount;
            Key2Base = XMLPath + ":OrderNumber:";

            if (KeyExists(DBIndex, Key)) {
                Newtonsoft.Json.Linq.JArray checkData = Newtonsoft.Json.Linq.JArray.Parse(RedisRead(DBIndex, Key));

                foreach (var item in checkData) {
                    string Key2 = Key2Base + item["OrderNumber"];

                    if (KeyExists(DBIndex, Key2)) {
                        NowDatas.Add(item.ToObject<T>());
                    } else {
                        IsNeedReWrite = true;
                    }
                }
            }

            if (IsNeedReWrite) {
                for (int I = 0; I <= 3; I++) {
                    try {
                        JsonStringWriteToRedis(DBIndex, Newtonsoft.Json.JsonConvert.SerializeObject(NowDatas), Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return NowDatas;
        }
    }

    public static class JKCDeposit {
        private static string XMLPath = "JKCDeposit";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetJKCDepositByContactPhoneNumber(string ContactPhoneNumber) {
            string Key;
            System.Data.DataTable DT;

            Key = XMLPath + ":ContactPhoneNumber:" + ContactPhoneNumber;
            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateJKCDepositByContactPhoneNumber(ContactPhoneNumber);
            }

            return DT;
        }

        public static System.Data.DataTable UpdateJKCDepositByContactPhoneNumber(string ContactPhoneNumber) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;

            SS = "SELECT * FROM JKCDeposit WITH (NOLOCK) WHERE ContactPhoneNumber=@ContactPhoneNumber";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@ContactPhoneNumber", System.Data.SqlDbType.VarChar).Value = ContactPhoneNumber;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                Key = XMLPath + ":ContactPhoneNumber:" + ContactPhoneNumber;

                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
    }

    public static class AppLogin {
        private static string XMLPath = "AppLogin";
        private static int DBIndex = 1;

        public static string CreateAppLoginToken(string ParentPersonCode, string CompanyCode, string BindingLoginAccount) {
            return CreateAppLoginToken(ParentPersonCode, CompanyCode, BindingLoginAccount, string.Empty, string.Empty);
        }

        public static string CreateAppLoginToken(string ParentPersonCode, string CompanyCode, string BindingLoginAccount, string CallbackURL, string TagData) {
            string RetValue = System.Guid.NewGuid().ToString();
            string Key;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
            StackExchange.Redis.IBatch T;

            Key = XMLPath + ":" + RetValue;

            T = Client.CreateBatch();
            T.HashSetAsync(Key.ToUpper(), "AppToken", RetValue);
            T.HashSetAsync(Key.ToUpper(), "ParentPersonCode", ParentPersonCode);
            T.HashSetAsync(Key.ToUpper(), "CompanyCode", CompanyCode);
            T.HashSetAsync(Key.ToUpper(), "BindingLoginAccount", BindingLoginAccount);
            T.HashSetAsync(Key.ToUpper(), "CallbackURL", CallbackURL);
            T.HashSetAsync(Key.ToUpper(), "TagData", TagData);
            T.KeyExpireAsync(Key.ToUpper(), new TimeSpan(0, 0, 300));

            T.Execute();

            return RetValue;
        }

        public static void UpdateUserCreateType(string AppToken, TokenContent.enumUserCreateType UserCreateType) {
            string Key;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

            Key = XMLPath + ":" + AppToken;
            Client.HashSet(Key.ToUpper(), "UserCreateType", ((int)UserCreateType).ToString());
        }

        public static bool CheckTokenExist(string Token) {
            string Key;

            Key = XMLPath + ":" + Token;

            return KeyExists(DBIndex, Key);
        }

        public static TokenContent GetToken(string Token) {
            TokenContent RetValue = null;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
            StackExchange.Redis.HashEntry[] HEList = null;
            string Key;

            Key = XMLPath + ":" + Token;
            HEList = Client.HashGetAll(Key.ToUpper());
            if (HEList != null) {
                RetValue = new TokenContent();

                foreach (StackExchange.Redis.HashEntry EachHE in HEList) {
                    string HEName = EachHE.Name.ToString();
                    string HEValue = EachHE.Value.ToString();

                    if (HEName.ToUpper() == "ParentUserAccountID".ToUpper()) { RetValue.ParentPersonCode = HEValue; } else if (HEName.ToUpper() == "AppToken".ToUpper()) { RetValue.AppToken = HEValue; } else if (HEName.ToUpper() == "CompanyCode".ToUpper()) { RetValue.CompanyCode = HEValue; } else if (HEName.ToUpper() == "BindingUserAccountID".ToUpper()) { RetValue.BindingLoginAccount = HEValue; } else if (HEName.ToUpper() == "CallbackURL".ToUpper()) { RetValue.CallbackURL = HEValue; } else if (HEName.ToUpper() == "TagData".ToUpper()) { RetValue.TagData = HEValue; } else if (HEName.ToUpper() == "UserCreateType".ToUpper()) { RetValue.UserCreateType = (TokenContent.enumUserCreateType)Convert.ToInt32(HEValue); }
                }
            }

            return RetValue;
        }

        public class TokenContent {
            public enum enumUserCreateType {
                NewUser = 0,
                ExistUser = 1
            }

            public string AppToken { get; set; }
            public string ParentPersonCode { get; set; }
            public string CompanyCode { get; set; }
            public string BindingLoginAccount { get; set; }
            public enumUserCreateType UserCreateType { get; set; }
            public string CallbackURL { get; set; }
            public string TagData { get; set; }
        }
    }

    public static class PaymentCategory {
        private static string XMLPath = "PaymentCategory";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetPaymentCategory() {
            string Key;
            System.Data.DataTable DT;

            Key = XMLPath;
            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdatePaymentCategory();
            }

            return DT;
        }

        public static System.Data.DataTable UpdatePaymentCategory() {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;

            SS = "SELECT * FROM PaymentCategory WITH (NOLOCK)";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                Key = XMLPath;

                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
    }

    public static class PaymentMethod {
        private static string XMLPath = "PaymentMethod";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetPaymentMethodByID(int PaymentMethodID) {
            string Key;
            System.Data.DataTable DT;

            Key = XMLPath + ":" + PaymentMethodID.ToString();
            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdatePaymentMethodByID(PaymentMethodID);
            }

            return DT;
        }

        public static System.Data.DataTable UpdatePaymentMethodByID(int PaymentMethodID) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;

            SS = "SELECT * FROM PaymentMethod WITH (NOLOCK)" +
                     " WHERE PaymentMethodID = @PaymentMethodID  ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@PaymentMethodID", System.Data.SqlDbType.Int).Value = PaymentMethodID;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                Key = XMLPath + ":" + DT.Rows[0]["PaymentMethodID"].ToString();

                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }

        public static System.Data.DataTable GetPaymentMethodByEWinTaginfoDefault(string EWinTaginfoDefault) {
            string Key;
            System.Data.DataTable DT;

            Key = XMLPath + ":" + EWinTaginfoDefault;
            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdatePaymentMethodByEWinTaginfoDefault(EWinTaginfoDefault);
            }

            return DT;
        }

        public static System.Data.DataTable UpdatePaymentMethodByEWinTaginfoDefault(string EWinTaginfoDefault) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;

            SS = "SELECT * FROM PaymentMethod WITH (NOLOCK)" +
                     " WHERE EWinTaginfoDefault = @EWinTaginfoDefault  ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@EWinTaginfoDefault", System.Data.SqlDbType.VarChar).Value = EWinTaginfoDefault;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                Key = XMLPath + ":" + (string)DT.Rows[0]["EWinTaginfoDefault"];

                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }

        public static System.Data.DataTable GetPaymentMethodByCategory(string Category) {
            string Key;
            System.Data.DataTable DT;

            Key = XMLPath + ":" + Category;
            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdatePaymentMethodByCategory(Category);
            }

            return DT;
        }

        public static System.Data.DataTable UpdatePaymentMethodByCategory(string Category) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;

            SS = "SELECT * FROM PaymentMethod WITH (NOLOCK)" +
                     " WHERE PaymentCategoryCode = @PaymentCategoryCode  ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@PaymentCategoryCode", System.Data.SqlDbType.VarChar).Value = Category;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                Key = XMLPath + ":" + (string)DT.Rows[0]["PaymentCategoryCode"];

                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
    }

    public static class UserAccountSummary {
        private static string XMLPath = "UserAccountSummary";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetUserAccountSummary(string LoginAccount, DateTime SummaryDate) {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath + ":" + LoginAccount + ":SummaryDaye:" + SummaryDate.ToString("yyyy/MM/dd");

            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateUserAccountSummary(LoginAccount, SummaryDate);
            }

            return DT;
        }

        public static System.Data.DataTable UpdateUserAccountSummary(string LoginAccount, DateTime SummaryDate) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;
            Key = XMLPath + ":" + LoginAccount + ":SummaryDaye:" + SummaryDate.ToString("yyyy/MM/dd");


            SS = "SELECT * FROM UserAccountSummary WITH (NOLOCK)" +
                     " WHERE LoginAccount = @LoginAccount AND SummaryDate=@SummaryDate ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@SummaryDate", System.Data.SqlDbType.DateTime).Value = SummaryDate;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {


                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key, 86400);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
    }

    public static class FingerPrint {
        private static string XMLPath = "FingerPrint";
        private static int DBIndex = 0;

        public static void UpdatePaymentContent(string JsonData, string FingerPrint) {
            string Key;

            Key = XMLPath + ":FingerPrint:" + FingerPrint;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, 600);
                    break;
                } catch (Exception ex) {
                }
            }
        }

        public static string GetFingerPrint(string FingerPrint) {
            string R = "";
            string Key;

            Key = XMLPath + ":FingerPrint:" + FingerPrint;

            if (KeyExists(DBIndex, Key)) {
                R = JsonReadFromRedis(DBIndex, Key);
            }

            return R;
        }

        public static string DelFingerPrint(string FingerPrint) {
            string R = "";
            string Key;

            Key = XMLPath + ":FingerPrint:" + FingerPrint;

            if (KeyExists(DBIndex, Key)) {
                KeyDelete(DBIndex, Key);
            }

            return R;
        }
    }

    public static class CryptoExchangeRate {
        private static string XMLPath = "CryptoExchangeRate";
        private static int DBIndex = 0;

        public static string GetCryptoExchangeRate() {
            string Key;
            string strRet = string.Empty;

            Key = XMLPath;
            if (KeyExists(DBIndex, Key) == true) {
                strRet = JsonReadFromRedis(DBIndex, Key);
            }

            return strRet;
        }

        public static void UpdateCryptoExchangeRate(string JsonData) {
            string Key;

            Key = XMLPath;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, 60);
                    break;
                } catch (Exception ex) {
                }
            }
        }
    }

    public static class BulletinBoard {
        private static string XMLPath = "BulletinBoard";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetBulletinBoard() {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath;

            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateBulletinBoard();
            }

            return DT;
        }

        public static System.Data.DataTable UpdateBulletinBoard() {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;
            Key = XMLPath;

            SS = "SELECT * " +
             "FROM BulletinBoard AS BB WITH (NOLOCK) ";

            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key, 86400);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
    }

    public static class UserAccountEventBonusHistory {
        private static string XMLPath = "UserAccountEventBonusHistory";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetEventBonusHistoryByLoginAccountAndDate(string LoginAccount, DateTime StartDate, DateTime EndDate) {
            string Key;
            System.Data.DataTable DT;
            string strMonth = EndDate.ToString("yyyy-MM");
            Key = XMLPath + ":Date:" + strMonth + ":LoginAccount:" + LoginAccount;

            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateEventBonusHistoryByLoginAccountAndDate(LoginAccount, StartDate, EndDate);
            }

            return DT;
        }

        public static System.Data.DataTable UpdateEventBonusHistoryByLoginAccountAndDate(string LoginAccount, DateTime StartDate, DateTime EndDate) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;
            string strMonth = EndDate.ToString("yyyy-MM");
            Key = XMLPath + ":Date:" + strMonth + ":LoginAccount:" + LoginAccount;

            SS = " SELECT * " +
                      " FROM UserAccountEventBonusHistory  WITH (NOLOCK) " +
                      " WHERE LoginAccount = @LoginAccount " +
                      "      AND CreateDate >= @StartDate " +
                      "      AND CreateDate < @EndDate ";

            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@StartDate", System.Data.SqlDbType.DateTime).Value = StartDate;
            DBCmd.Parameters.Add("@EndDate", System.Data.SqlDbType.DateTime).Value = EndDate;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key, 86400);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
    }

    public static class UserAccountFingerprint {
        private static string XMLPath = "UserAccountFingerprint";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetUserAccountFingerprint(string LoginAccount) {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath + ":" + LoginAccount;

            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateUserAccountFingerprint(LoginAccount);
            }

            return DT;
        }

        public static System.Data.DataTable UpdateUserAccountFingerprint(string LoginAccount) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;
            Key = XMLPath + ":" + LoginAccount;

            SS = "SELECT * FROM UserAccountFingerprint WITH (NOLOCK)" +
                     " WHERE LoginAccount = @LoginAccount ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {

                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key, 86400);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
    }

    public static class CompanyCategory {
        private static string XMLPath = "CompanyCategory";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetCompanyCategory() {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath;

            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateCompanyCategory();
            }

            return DT;
        }

        public static System.Data.DataTable UpdateCompanyCategory() {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;

            SS = "SELECT * FROM CompanyCategory WITH (NOLOCK)";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                Key = XMLPath;

                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
    }

    public static class CompanyCategoryGameCode {
        private static string XMLPath = "CompanyCategoryGameCode";
        private static int DBIndex = 0;

        public static void DeleteCompanyCategoryGameCode(int CompanyCategoryID) {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath + ":CompanyCategoryID:" + CompanyCategoryID;

            if (KeyExists(DBIndex, Key) == true) {
                KeyDelete(DBIndex, Key);
            }
        }

        public static System.Data.DataTable GetCompanyCategoryGameCodeByID(int CompanyCategoryID) {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath + ":CompanyCategoryID:" + CompanyCategoryID;

            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateCompanyGameCodeByID(CompanyCategoryID);
            }

            return DT;
        }

        public static System.Data.DataTable UpdateCompanyGameCode() {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;
            System.Data.DataTable CompanyGameCodeDT = null;

            SS = "SELECT * FROM CompanyCategory WITH (NOLOCK)";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {

                foreach (System.Data.DataRow DR in DT.Rows) {
                    int CompanyCategoryID = (int)DR["CompanyCategoryID"];
                    Key = XMLPath + ":CompanyCategoryID:" + CompanyCategoryID;

                    CompanyGameCodeDT = new System.Data.DataTable();

                    SS = "SELECT * FROM CompanyCategoryGameCode WITH (NOLOCK) WHERE forCompanyCategoryID = @forCompanyCategoryID";
                    DBCmd = new System.Data.SqlClient.SqlCommand();
                    DBCmd.CommandText = SS;
                    DBCmd.CommandType = System.Data.CommandType.Text;
                    DBCmd.Parameters.Add("@forCompanyCategoryID", System.Data.SqlDbType.Int).Value = CompanyCategoryID;
                    CompanyGameCodeDT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

                    if (CompanyGameCodeDT.Rows.Count > 0) {
                        for (int I = 0; I <= 3; I++) {
                            try {
                                DTWriteToRedis(DBIndex, CompanyGameCodeDT, Key);
                                break;
                            } catch (Exception ex) {
                            }
                        }
                    }

                }
            }

            return DT;
        }

        public static string UpdateAllCompanyGameCode(string JsonString) {
            string Key;

            Key = XMLPath + ":All";

            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(0, JsonString, Key);
                    break;
                } catch (Exception ex) {
                }
            }

            return JsonString;
        }

        public static string UpdateAllCompanyGameCodeFromDB() {
            string Key;
            string JsonString = "";
            System.Data.SqlClient.SqlCommand DBCmd;
            EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
            EWin.Lobby.CompanyGameCodeResult companyGameCodeResult;

            companyGameCodeResult = lobbyAPI.GetCompanyGameCode(GetToken(), Guid.NewGuid().ToString());
            if (companyGameCodeResult.Result == EWin.Lobby.enumResult.OK) {
                JsonString = Newtonsoft.Json.JsonConvert.SerializeObject(companyGameCodeResult);
                Key = XMLPath + ":All";

                for (int I = 0; I <= 3; I++) {
                    try {
                        JsonStringWriteToRedis(0, JsonString, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return JsonString;
        }

        private static string GetToken() {
            string Token;
            int RValue;
            Random R = new Random();
            RValue = R.Next(100000, 9999999);
            Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());

            return Token;
        }

        public static string GetAllCompanyGameCode() {
            string Key;
            string DATA = "";
            Key = XMLPath + ":All";

            if (KeyExists(DBIndex, Key) == true) {
                DATA = JsonReadFromRedis(DBIndex, Key);
            } else {
                DATA = UpdateAllCompanyGameCodeFromDB();
            }

            return DATA;
        }

        public static System.Data.DataTable UpdateCompanyGameCodeByID(int CompanyCategoryID) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable CompanyGameCodeDT = null;

            Key = XMLPath + ":CompanyCategoryID:" + CompanyCategoryID;

            SS = "SELECT * FROM CompanyCategoryGameCode WITH (NOLOCK) WHERE forCompanyCategoryID = @forCompanyCategoryID";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@forCompanyCategoryID", System.Data.SqlDbType.Int).Value = CompanyCategoryID;
            CompanyGameCodeDT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            if (CompanyGameCodeDT.Rows.Count > 0) {
                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, CompanyGameCodeDT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return CompanyGameCodeDT;
        }

    }

    public static class CompanyGameCode {
        private static string XMLPath = "CompanyGameCode";
        private static int DBIndex = 0;

        public static void DeleteCompanyGameCode(string BrandCode, string GameCode) {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath + ":" + BrandCode + ":" + GameCode;

            if (KeyExists(DBIndex, Key) == true) {
                KeyDelete(DBIndex, Key);
            }
        }

        public static System.Data.DataTable GetCompanyGameCode(string BrandCode, string GameCode) {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath + ":" + BrandCode + ":" + GameCode;

            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateCompanyGameCode(BrandCode, GameCode);
            }

            return DT;
        }

        public static System.Data.DataTable UpdateCompanyGameCode(string BrandCode, string GameCode) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;
            Key = XMLPath + ":" + BrandCode + ":" + GameCode;

            SS = "SELECT * FROM CompanyGameCode WITH (NOLOCK) WHERE GameCode=@GameCode";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@GameCode", System.Data.SqlDbType.VarChar).Value = GameCode;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }

    }

    public static class UserAccountEventSummary {
        private static string XMLPath = "UserAccountEventSummary";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetUserAccountEventSummaryByLoginAccount(string LoginAccount) {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath + ":LoginAccount:" + LoginAccount;

            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateUserAccountEventSummaryByLoginAccount(LoginAccount);
            }

            return DT;
        }

        public static System.Data.DataTable UpdateUserAccountEventSummaryByLoginAccount(string LoginAccount) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;

            SS = "SELECT * FROM UserAccountEventSummary WITH (NOLOCK)" +
                 " WHERE LoginAccount=@LoginAccount ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                Key = XMLPath + ":LoginAccount:" + LoginAccount;

                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
        
        public static System.Data.DataTable GetUserAccountEventSummaryByLoginAccountAndActivityName(string LoginAccount, string ActivityName) {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath + ":LoginAccount:" + LoginAccount + ":ActivityName:" + ActivityName;

            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateUserAccountEventSummaryByLoginAccountAndActivityName(LoginAccount, ActivityName);
            }

            return DT;
        }

        public static System.Data.DataTable UpdateUserAccountEventSummaryByLoginAccountAndActivityName(string LoginAccount, string ActivityName) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;

            SS = "SELECT * FROM UserAccountEventSummary WITH (NOLOCK)" +
                 " WHERE LoginAccount=@LoginAccount And ActivityName=@ActivityName";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@ActivityName", System.Data.SqlDbType.VarChar).Value = ActivityName;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                Key = XMLPath + ":LoginAccount:" + LoginAccount + ":ActivityName:" + ActivityName;

                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
    }

    public static class UserAccount {
        private static string XMLPath = "UserAccount";
        private static int DBIndex = 0;

        public static System.Data.DataTable GetUserAccountByLoginAccount(string LoginAccount) {
            string Key;
            System.Data.DataTable DT;
            Key = XMLPath + ":LoginAccount:" + LoginAccount;

            if (KeyExists(DBIndex, Key) == true) {
                DT = DTReadFromRedis(DBIndex, Key);
            } else {
                DT = UpdateUserAccountByLoginAccount(LoginAccount);
            }

            return DT;
        }

        public static System.Data.DataTable UpdateUserAccountByLoginAccount(string LoginAccount) {
            string Key;
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT = null;

            SS = "SELECT * FROM UserAccountTable WITH (NOLOCK)" +
                 " WHERE LoginAccount=@LoginAccount ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);
            if (DT.Rows.Count > 0) {
                Key = XMLPath + ":LoginAccount:" + LoginAccount;

                for (int I = 0; I <= 3; I++) {
                    try {
                        DTWriteToRedis(DBIndex, DT, Key);
                        break;
                    } catch (Exception ex) {
                    }
                }
            }

            return DT;
        }
    }

    public static class UserAccountVIPInfo {
        private static string XMLPath = "UserAccountVIPInfo";
        private static int DBIndex = 0;

        public static string GetUserAccountVIPInfo(string LoginAccount) {
            string Key;
            string strRet = string.Empty;

            Key = XMLPath + ":LoginAccount:" + LoginAccount;
            if (KeyExists(DBIndex, Key) == true) {
                strRet = JsonReadFromRedis(DBIndex, Key);
            }

            return strRet;
        }

        public static void UpdateUserAccountVIPInfo(string JsonData, string LoginAccount) {
            string Key;

            Key = XMLPath + ":LoginAccount:" + LoginAccount;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, 300);
                    break;
                } catch (Exception ex) {
                }
            }
        }

        public static void DeleteUserAccountVIPInfo(string LoginAccount) {
            string Key2;
            StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient();

            Key2 = XMLPath + ":LoginAccount:" + LoginAccount;

            Client.KeyDelete(Key2.ToUpper());
        }

        public static string GetVipSetting() {
            string Key;
            string strRet = string.Empty;

            Key = XMLPath + ":VipSetting";
            if (KeyExists(DBIndex, Key) == true) {
                strRet = JsonReadFromRedis(DBIndex, Key);
            }

            return strRet;
        }

        public static void UpdateVipSetting(string JsonData) {
            string Key;

            Key = XMLPath + ":VipSetting";
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, 86400);
                    break;
                } catch (Exception ex) {
                }
            }
        }
    }

    public static void UpdateRedisByPrivateKey() {
        PaymentCategory.UpdatePaymentCategory();
        PaymentMethod.UpdatePaymentMethodByCategory("Paypal");
        PaymentMethod.UpdatePaymentMethodByCategory("Crypto");
    }

    public static class UserAccountChild {
        private static string XMLPath = "UserAccountChild";
        private static int DBIndex = 0;

        public static string GetUserAccountChildByLoginAccount(string LoginAccount) {
            string Key;
            string strRet = string.Empty;

            Key = XMLPath + ":LoginAccount:" + LoginAccount;
            if (KeyExists(DBIndex, Key) == true) {
                strRet = JsonReadFromRedis(DBIndex, Key);
            }

            return strRet;
        }

        public static void UpdateUserAccountChild(string JsonData, string LoginAccount) {
            string Key;

            Key = XMLPath + ":LoginAccount:" + LoginAccount;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, 1800);
                    break;
                } catch (Exception ex) {
                }
            }
        }
    }

    public static class Agent {
        private static string XMLPath = "Agent";
        private static int DBIndex = 0;

        #region 傭金結算查詢-細節
        public static string GetAccountDetailByLoginAccount(string LoginAccount, int AccountingID) {
            string Key;
            string strRet = string.Empty;

            Key = XMLPath + ":AccountDetail:AccountingID:" + AccountingID + ":LoginAccount:" + LoginAccount;
            if (KeyExists(DBIndex, Key) == true) {
                strRet = JsonReadFromRedis(DBIndex, Key);
            }

            return strRet;
        }

        public static void UpdateAccountDetailByLoginAccount(string JsonData, string LoginAccount, int AccountingID) {
            string Key;

            Key = XMLPath + ":AccountDetail:AccountingID:" + AccountingID + ":LoginAccount:" + LoginAccount;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, 1800);
                    break;
                } catch (Exception ex) {
                }
            }
        }
        #endregion

        #region 首頁下方區塊統計資料
        public static string GetHomeAccountDetailByLoginAccount(string LoginAccount, string StratDate, string EndDate) {
            string Key;
            string strRet = string.Empty;

            Key = XMLPath + ":Home:AccountDetail:LoginAccount:" + LoginAccount + ":SearchDate:" + StratDate + "_" + EndDate;
            if (KeyExists(DBIndex, Key) == true) {
                strRet = JsonReadFromRedis(DBIndex, Key);
            }

            return strRet;
        }

        public static void UpdateHomeAccountDetailByLoginAccount(string JsonData, string LoginAccount, string StratDate, string EndDate) {
            string Key;

            Key = XMLPath + ":Home:AccountDetail:LoginAccount:" + LoginAccount + ":SearchDate:" + StratDate + "_" + EndDate;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, 300);
                    break;
                } catch (Exception ex) {
                }
            }
        }
        #endregion

        #region 首頁中間下線統計資料
        public static string GetHomeChildDetailByLoginAccount(string LoginAccount) {
            string Key;
            string strRet = string.Empty;

            Key = XMLPath + ":Home:ChildDetail:LoginAccount:" + LoginAccount;
            if (KeyExists(DBIndex, Key) == true) {
                strRet = JsonReadFromRedis(DBIndex, Key);
            }

            return strRet;
        }

        public static void UpdateHomeChildDetailByLoginAccount(string JsonData, string LoginAccount) {
            string Key;

            Key = XMLPath + ":Home:ChildDetail:LoginAccount:" + LoginAccount;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, 300);
                    break;
                } catch (Exception ex) {
                }
            }
        }
        #endregion

        #region 團隊管理-會員
        public static string GetTeamMemberInfoByLoginAccount(string LoginAccount) {
            string Key;
            string strRet = string.Empty;

            Key = XMLPath + ":TeamMemberInfo:LoginAccount:" + LoginAccount;
            if (KeyExists(DBIndex, Key) == true) {
                strRet = JsonReadFromRedis(DBIndex, Key);
            }

            return strRet;
        }

        public static void UpdateTeamMemberInfoByLoginAccount(string JsonData, string LoginAccount,int ExpireTimeoutSeconds) {
            string Key;

            Key = XMLPath + ":TeamMemberInfo:LoginAccount:"+ LoginAccount;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, ExpireTimeoutSeconds);
                    break;
                } catch (Exception ex) {
                }
            }
        }
        #endregion

        #region 團隊會員
        public static string GetPlayerTotalDepositSummaryByLoginAccount(string LoginAccount, DateTime QueryBeginDate, DateTime QueryEndDate)
        {
            string Key;
            string strRet = string.Empty;

            Key = XMLPath + ":TeamPlayerTotalDepositSummary:LoginAccount:"+ LoginAccount+ ":SummaryDate:" + QueryBeginDate.ToString("yyyy/MM/dd") + "-" + QueryEndDate.ToString("yyyy/MM/dd");
            if (KeyExists(DBIndex, Key) == true)
            {
                strRet = JsonReadFromRedis(DBIndex, Key);
            }

            return strRet;
        }

        public static void UpdatePlayerTotalDepositSummaryByLoginAccount(string JsonData, DateTime QueryBeginDate, DateTime QueryEndDate, string LoginAccount, int ExpireTimeoutSeconds)
        {
            string Key;

            Key = XMLPath + ":TeamPlayerTotalDepositSummary:LoginAccount:" + LoginAccount + ":SummaryDate:" + QueryBeginDate.ToString("yyyy/MM/dd") + "-" + QueryEndDate.ToString("yyyy/MM/dd");
            for (int I = 0; I <= 3; I++)
            {
                try
                {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, ExpireTimeoutSeconds);
                    break;
                }
                catch (Exception ex)
                {
                }
            }
        }
        #endregion

        #region 會員投注數據
        public static string GetPlayerTotalSummaryInfoByLoginAccount(string LoginAccount, string StratDate, string EndDate) {
            string Key;
            string strRet = string.Empty;

            Key = XMLPath + ":PlayerTotalSummaryInfo:LoginAccount:" + LoginAccount + ":SearchDate:" + StratDate + "_" + EndDate;
            if (KeyExists(DBIndex, Key) == true) {
                strRet = JsonReadFromRedis(DBIndex, Key);
            }

            return strRet;
        }

        public static void UpdatePlayerTotalSummaryByLoginAccount(string JsonData, string LoginAccount, string StratDate, string EndDate) {
            string Key;

            Key = XMLPath + ":PlayerTotalSummaryInfo:LoginAccount:" + LoginAccount + ":SearchDate:" + StratDate + "_" + EndDate;
            for (int I = 0; I <= 3; I++) {
                try {
                    JsonStringWriteToRedis(DBIndex, JsonData, Key, 300);
                    break;
                } catch (Exception ex) {
                }
            }
        }
        #endregion
        
    }

    public static void DTWriteToRedis(int DBIndex, System.Data.DataTable DT, string Key, int ExpireTimeoutSeconds = 0) {
        string XMLContent;

        XMLContent = DTSerialize(DT);
        RedisWrite(DBIndex, Key, XMLContent, ExpireTimeoutSeconds);
    }

    public static void JsonStringWriteToRedis(int DBIndex, string JsonString, string Key, int ExpireTimeoutSeconds = 0) {

        RedisWrite(DBIndex, Key, JsonString, ExpireTimeoutSeconds);
    }

    public static void DSWriteToRedis(int DBIndex, System.Data.DataSet DS, string Key, int ExpireTimeoutSeconds = 0) {
        string XMLContent;

        XMLContent = DSSerialize(DS);
        RedisWrite(DBIndex, Key, XMLContent, ExpireTimeoutSeconds);
    }

    public static System.Data.DataTable DTReadFromRedis(int DBIndex, string Key) {
        string XMLContent;

        XMLContent = RedisRead(DBIndex, Key);

        return DTDeserialize(XMLContent);
    }

    public static string JsonReadFromRedis(int DBIndex, string Key) {
        string JsonContent;

        JsonContent = RedisRead(DBIndex, Key);

        return JsonContent;
    }


    public static T JsonReadFromRedis<T>(int DBIndex, string Key) {
        string JsonContent;

        JsonContent = RedisRead(DBIndex, Key);

        return Newtonsoft.Json.JsonConvert.DeserializeObject<T>(JsonContent);
    }

    public static System.Data.DataSet DSReadFromRedis(int DBIndex, string Key) {
        string XMLContent;

        XMLContent = RedisRead(DBIndex, Key);

        return DSDeserialize(XMLContent);
    }

    public static string DTSerialize(System.Data.DataTable _dt) {
        string result = string.Empty;

        if (_dt != null) {
            System.IO.StringWriter writer = new System.IO.StringWriter();

            if (string.IsNullOrEmpty(_dt.TableName)) {
                _dt.TableName = "Datatable";
            }

            _dt.WriteXml(writer, System.Data.XmlWriteMode.WriteSchema);
            result = writer.ToString();
        }

        return result;
    }

    public static string DSSerialize(System.Data.DataSet _ds) {
        string result = string.Empty;

        if (_ds != null) {
            System.IO.StringWriter writer = new System.IO.StringWriter();
            int I = 0;

            foreach (System.Data.DataTable EachTable in _ds.Tables) {
                I += 1;

                if (string.IsNullOrEmpty(EachTable.TableName)) {
                    EachTable.TableName = "Datatable." + I.ToString();
                }
            }

            _ds.WriteXml(writer, System.Data.XmlWriteMode.WriteSchema);
            result = writer.ToString();
        }

        return result;
    }

    public static System.Data.DataTable DTDeserialize(string _strData) {
        if (string.IsNullOrEmpty(_strData) == false) {
            System.Data.DataTable DT = new System.Data.DataTable();
            System.IO.StringReader StringStream = new System.IO.StringReader(_strData);

            DT.ReadXml(StringStream);

            return DT;
        } else {
            return null;
        }
    }

    public static System.Data.DataSet DSDeserialize(string _strData) {
        if (string.IsNullOrEmpty(_strData) == false) {
            System.Data.DataSet DS = new System.Data.DataSet();
            System.IO.StringReader StringStream = new System.IO.StringReader(_strData);

            DS.ReadXml(StringStream);

            return DS;
        } else {
            return null;
        }
    }

    public static void KeyDelete(int DBIndex, string Key) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

        Client.KeyDelete(Key.ToUpper());
    }

    public static bool KeyExists(int DBIndex, string Key) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

        return Client.KeyExists(Key.ToUpper());
    }

    public static void RedisSetExpire(int DBIndex, string Key, int ExpireTimeoutSecond) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

        Client.KeyExpire(Key.ToUpper(), new TimeSpan(0, 0, ExpireTimeoutSecond));
    }

    public static void RedisWrite(int DBIndex, string Key, string Content, int ExpireTimeoutSecond = 0) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

        if (ExpireTimeoutSecond == 0) {
            Client.StringSet(Key.ToUpper(), Content);
        } else {
            StackExchange.Redis.ITransaction T = Client.CreateTransaction();

            T.StringSetAsync(Key.ToUpper(), Content);
            T.KeyExpireAsync(Key.ToUpper(), new TimeSpan(0, 0, ExpireTimeoutSecond));
            T.Execute();

            T = null;
        }
    }

    public static string RedisRead(int DBIndex, string Key) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
        string RetValue = string.Empty;

        if (Client.KeyExists(Key.ToUpper())) {
            RetValue = Client.StringGet(Key.ToUpper()).ToString();
        }

        return RetValue;
    }

    public static bool RedisHashExists(int DBIndex, string Key, string HashName) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

        return Client.HashExists(Key.ToUpper(), HashName.ToUpper());
    }

    public static void RedisHashDelete(int DBIndex, string Key, string HashName) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

        Client.HashDelete(Key.ToUpper(), HashName.ToUpper());
    }

    public static void RedisHashWrite(int DBIndex, string Key, string HashName, string Content, int ExpireTimeoutSecond = 0) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

        if (ExpireTimeoutSecond == 0) {
            Client.HashSet(Key.ToUpper(), HashName.ToUpper(), Content);
        } else {
            StackExchange.Redis.ITransaction T = Client.CreateTransaction();

            T.HashSetAsync(Key.ToUpper(), HashName.ToUpper(), Content);
            T.KeyExpireAsync(Key.ToUpper(), new TimeSpan(0, 0, ExpireTimeoutSecond));
            T.Execute();

            T = null;
        }
    }

    public static string RedisHashRead(int DBIndex, string Key, string HashName) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
        string RetValue = string.Empty;

        if (Client.KeyExists(Key.ToUpper())) {
            RetValue = Client.HashGet(Key.ToUpper(), HashName.ToUpper());
        }

        return RetValue;
    }

    public static StackExchange.Redis.HashEntry[] RedisHashReadAll(int DBIndex, string Key) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
        StackExchange.Redis.HashEntry[] RetValue = null;

        if (Client.KeyExists(Key.ToUpper())) {
            RetValue = Client.HashGetAll(Key.ToUpper());
        }

        return RetValue;
    }

    public static void RedisEnqueue(int DBIndex, string Key, string Content) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);

        Client.ListRightPush(Key.ToUpper(), Content);
    }

    public static string RedisDequeue(int DBIndex, string Key) {
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
        string RetValue = null;

        if (Client.KeyExists(Key.ToUpper())) {
            RetValue = Client.ListLeftPop(Key.ToUpper()).ToString();
        }

        return RetValue;
    }

    public static bool GetLocker(string Key, int WaitLockTimeoutSecond, Action Func) {
        int DBIndex = 0;
        string XMLPath = "Global:Transaction:" + Key;
        StackExchange.Redis.IDatabase Client = EWinWeb.GetRedisClient(DBIndex);
        DateTime EntryDate = System.DateTime.Now;
        string LockValue = System.Guid.NewGuid().ToString();
        bool RetValue = false;

        while (true) {
            if (System.DateTime.Now.Subtract(EntryDate).Seconds >= WaitLockTimeoutSecond)
                break;

            if (Client.LockTake(Key.ToUpper(), LockValue, new TimeSpan(0, 0, WaitLockTimeoutSecond))) {
                RetValue = true;

                try {
                    Func.Invoke();
                    Client.LockRelease(Key.ToUpper(), LockValue);
                    break;
                } catch (Exception ex) {
                    Client.LockRelease(Key.ToUpper(), LockValue);
                    throw ex;
                }
            }

            System.Threading.Thread.Sleep(100);
        }

        return RetValue;
    }
}