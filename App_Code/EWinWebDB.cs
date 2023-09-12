using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// EWin 的摘要描述
/// </summary>
public static class EWinWebDB {

    public static class UserAccount {

        public static int UpdateUserAccountLevel(int UserLevelIndex, string LoginAccount, string UserLevelUpdateDate) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " UPDATE UserAccountTable SET UserLevelIndex=@UserLevelIndex,UserLevelUpdateDate=@UserLevelUpdateDate " +
                      " WHERE LoginAccount=@LoginAccount";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@UserLevelIndex", System.Data.SqlDbType.Int).Value = UserLevelIndex;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@UserLevelUpdateDate", System.Data.SqlDbType.DateTime).Value = DateTime.Parse(UserLevelUpdateDate);
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

        public static int UpdateUserAccountValidBetValue(string LoginAccount, decimal ValidBetValue) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " UPDATE UserAccountTable SET ValidBetValue= ValidBetValue + @ValidBetValue " +
                      " WHERE LoginAccount=@LoginAccount";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@ValidBetValue", System.Data.SqlDbType.Decimal).Value = ValidBetValue;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }
        //更新用戶VIP進度條有效投注資料
        public static int UpdateUserAccountAccumulationValue(string LoginAccount, decimal ValidBetValueFromSummary, decimal UserLevelAccumulationValidBetValue, DateTime LastValidBetValueSummaryDate) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " UPDATE UserAccountTable SET ValidBetValueFromSummary = @ValidBetValueFromSummary, UserLevelAccumulationValidBetValue = UserLevelAccumulationValidBetValue + @UserLevelAccumulationValidBetValue, ValidBetValue= ValidBetValue + @UserLevelAccumulationValidBetValue, LastValidBetValueSummaryDate = @LastValidBetValueSummaryDate, LastUpdateDate = getdate() " +
                      " WHERE LoginAccount=@LoginAccount";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@ValidBetValueFromSummary", System.Data.SqlDbType.Decimal).Value = ValidBetValueFromSummary;
            DBCmd.Parameters.Add("@UserLevelAccumulationValidBetValue", System.Data.SqlDbType.Decimal).Value = UserLevelAccumulationValidBetValue;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@LastValidBetValueSummaryDate", System.Data.SqlDbType.DateTime).Value = LastValidBetValueSummaryDate;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

        public static int InsertUserAccountLevelAndBirthday(int UserLevelIndex, string LoginAccount, string UserLevelUpdateDate, string Birthday) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " INSERT INTO UserAccountTable (UserLevelIndex, LoginAccount, UserLevelUpdateDate, Birthday,RegisterIP) " +
                                  " VALUES (@UserLevelIndex, @LoginAccount, @UserLevelUpdateDate, @Birthday,@RegisterIP) ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@UserLevelIndex", System.Data.SqlDbType.Int).Value = UserLevelIndex;
            DBCmd.Parameters.Add("@UserLevelUpdateDate", System.Data.SqlDbType.DateTime).Value = DateTime.Parse(UserLevelUpdateDate);
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@RegisterIP", System.Data.SqlDbType.VarChar).Value = CodingControl.GetUserIP();
            DBCmd.Parameters.Add("@Birthday", System.Data.SqlDbType.DateTime).Value = DateTime.Parse(Birthday);
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

        public static int InsertUserAccountData(string LoginAccount) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " INSERT INTO UserAccountTable (LoginAccount) " +
                                  " VALUES (@LoginAccount) ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

        public static int UpdateFingerPrint(string FingerPrints, string LoginAccount) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " UPDATE UserAccountTable WITH (ROWLOCK) SET FingerPrints=@FingerPrints " +
                      " WHERE LoginAccount=@LoginAccount";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@FingerPrints", System.Data.SqlDbType.VarChar).Value = FingerPrints;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

        public static int InsertUserAccountTotalSummary(string FingerPrints, string LoginAccount) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " INSERT INTO UserAccountTable (LoginAccount, FingerPrints) " +
                      " VALUES (@LoginAccount, @FingerPrints) ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@FingerPrints", System.Data.SqlDbType.VarChar).Value = FingerPrints;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

        public static System.Data.DataTable GetUserAccount() {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT * " +
                     " FROM UserAccountTable WITH (NOLOCK) ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static System.Data.DataTable GetUserAccount(string LoginAccount) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT * " +
                     " FROM UserAccountTable WITH (NOLOCK)" +
                     " WHERE LoginAccount = @LoginAccount ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        //當月壽星
        public static System.Data.DataTable GetBirthdayOfTheMonth(string month) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT * " +
                     " FROM UserAccountTable WITH (NOLOCK) " +
                     " WHERE  MONTH(Birthday) = @month";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@month", System.Data.SqlDbType.Int).Value = month;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static System.Data.DataTable GetUserAccountNeedCheckPromotion(string StartDate, string EndDate) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT * " +
                     " FROM   UserAccountTable WITH (nolock) " +
                     " WHERE  LoginAccount IN(SELECT DISTINCT LoginAccount " +
                     "                                                  FROM   UserAccountSummary " +
                     "                                                  WHERE  SummaryDate >= @StartDate " +
                     "                                                         AND SummaryDate < @EndDate)  ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@StartDate", System.Data.SqlDbType.DateTime).Value = DateTime.Parse(StartDate);
            DBCmd.Parameters.Add("@EndDate", System.Data.SqlDbType.DateTime).Value = DateTime.Parse(EndDate).AddDays(1);
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }
         
        public static int UpdateUserVipValidBetValueInfo(string LoginAccount, decimal ValidBetValueFromSummary, decimal UserLevelAccumulationValidBetValue, DateTime LastValidBetValueSummaryDate) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int ReturnValue = -1;
            SS = "spUpdateUserVipValidBetValueInfo";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.StoredProcedure;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@ValidBetValue", System.Data.SqlDbType.Decimal).Value = ValidBetValueFromSummary;
            DBCmd.Parameters.Add("@UserLevelAccumulationValidBetValue", System.Data.SqlDbType.Decimal).Value = UserLevelAccumulationValidBetValue;
            DBCmd.Parameters.Add("@SummaryDate", System.Data.SqlDbType.DateTime).Value = LastValidBetValueSummaryDate;
            DBCmd.Parameters.Add("@RETURN", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;
            DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);
            ReturnValue = Convert.ToInt32(DBCmd.Parameters["@RETURN"].Value);

            return ReturnValue;
        }

        public static System.Data.DataTable GetNeedCheckVipUpgradeUser(DateTime LastUpdateDate) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT * " +
                     " FROM   UserAccountTable WITH (NOLOCK) " +
                     " WHERE  ( LastDepositDate >= @LastUpdateDate " +
                     "           OR LastUpdateDate >= @LastUpdateDate )  ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LastUpdateDate", System.Data.SqlDbType.DateTime).Value = LastUpdateDate;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static System.Data.DataTable GetNeedCheckVipUpgradeUserByLoginAccount(DateTime LastUpdateDate,string LoginAccount) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT * " +
                     " FROM   UserAccountTable WITH (NOLOCK) " +
                     " WHERE  ( LastDepositDate >= @LastUpdateDate " +
                     "           OR LastUpdateDate >= @LastUpdateDate )  " +
                     "           AND LoginAccount = @LoginAccount ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LastUpdateDate", System.Data.SqlDbType.DateTime).Value = LastUpdateDate;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        /// <summary>
        ///  
        /// </summary>
        /// <param name="Type"> 0降級/1升級</param>
        /// <param name="DeposiAmount">等級異動時當下計算的入金金額</param>
        /// <param name="ValidBetValue">等級異動時當下計算的有效投注</param>
        /// <param name="UserLevelAccumulationDepositAmount">等級異動後VIP進度條累積的入金金額</param>
        /// <param name="UserLevelAccumulationValidBetValue">等級異動後VIP進度條累積的有效投注</param>
        /// <returns></returns>
        public static int UserAccountLevelIndexChange(string LoginAccount, int Type, int OldUserLevelIndex, int NewUserLevelIndex, decimal DeposiAmount, decimal ValidBetValue, decimal UserLevelAccumulationDepositAmount, decimal UserLevelAccumulationValidBetValue, string Description, string UserLevelUpdateDate) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int ReturnValue = -1;
            SS = "spUserAccountLevelIndexChange";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.StoredProcedure;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@Type", System.Data.SqlDbType.Int).Value = Type;
            DBCmd.Parameters.Add("@OldUserLevelIndex", System.Data.SqlDbType.Int).Value = OldUserLevelIndex;
            DBCmd.Parameters.Add("@NewUserLevelIndex", System.Data.SqlDbType.Int).Value = NewUserLevelIndex;
            DBCmd.Parameters.Add("@DeposiAmount", System.Data.SqlDbType.Decimal).Value = DeposiAmount;
            DBCmd.Parameters.Add("@ValidBetValue", System.Data.SqlDbType.Decimal).Value = ValidBetValue;
            DBCmd.Parameters.Add("@UserLevelAccumulationDepositAmount", System.Data.SqlDbType.Decimal).Value = UserLevelAccumulationDepositAmount;
            DBCmd.Parameters.Add("@UserLevelAccumulationValidBetValue", System.Data.SqlDbType.Decimal).Value = UserLevelAccumulationValidBetValue;
            DBCmd.Parameters.Add("@Description", System.Data.SqlDbType.NVarChar).Value = Description;
            DBCmd.Parameters.Add("@UserLevelUpdateDate", System.Data.SqlDbType.DateTime).Value = DateTime.Parse(UserLevelUpdateDate);
            DBCmd.Parameters.Add("@RETURN", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;
            DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);
            ReturnValue = Convert.ToInt32(DBCmd.Parameters["@RETURN"].Value);

            return ReturnValue;
        }

        //保級成功
        public static int RelegationUserAccountLevelSuccess(int UserLevelIndex, string LoginAccount, string UserLevelUpdateDate) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " UPDATE UserAccountTable SET UserLevelIndex=@UserLevelIndex,UserLevelUpdateDate=@UserLevelUpdateDate,UserLevelAccumulationValidBetValue=0 " +
                      " WHERE LoginAccount=@LoginAccount";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@UserLevelIndex", System.Data.SqlDbType.Int).Value = UserLevelIndex;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@UserLevelUpdateDate", System.Data.SqlDbType.DateTime).Value = DateTime.Parse(UserLevelUpdateDate);
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }
    }

    public static class APIException {

        public static System.Data.DataTable GetAPIExceptionByExceptionType(int ExceptionType) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            System.Data.DataTable DT;

            SS = " SELECT * " +
                     " FROM APIException WITH (NOLOCK) " +
                     " WHERE ExceptionType = @ExceptionType";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@ExceptionType", System.Data.SqlDbType.Int).Value = ExceptionType;
            DT = DBAccess.GetDB(EWinWeb.DBConnStr, DBCmd);

            return DT;
        }

        public static int InsertAPIException(string LoginAccount, int ExceptionType, int ExceptionCode, string JSONContent) {
            string SS;
            System.Data.SqlClient.SqlCommand DBCmd;
            int RetValue = 0;

            SS = " INSERT INTO APIException (LoginAccount, ExceptionType, ExceptionCode, JSONContent) " +
                                  " VALUES (@LoginAccount, @ExceptionType, @ExceptionCode, @JSONContent) ";
            DBCmd = new System.Data.SqlClient.SqlCommand();
            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.Parameters.Add("@LoginAccount", System.Data.SqlDbType.VarChar).Value = LoginAccount;
            DBCmd.Parameters.Add("@ExceptionType", System.Data.SqlDbType.Int).Value = ExceptionType;
            DBCmd.Parameters.Add("@ExceptionCode", System.Data.SqlDbType.Int).Value = ExceptionCode;
            DBCmd.Parameters.Add("@JSONContent", System.Data.SqlDbType.NVarChar).Value = JSONContent;
            RetValue = DBAccess.ExecuteDB(EWinWeb.DBConnStr, DBCmd);

            return RetValue;
        }

    }
}