using System;
using System.Data;

public static class DBAccess
{
    private static EnumDBType iDBType = EnumDBType.SqlClient;

    public enum EnumDBType {
        OleDB = 0,
        SqlClient = 1
    }

    public static EnumDBType DBAccessSetType {
        set {
            iDBType = value;
        }
    }

    public static System.Data.DataTable GetDB(string DBConnStr, string SS) {
        System.Data.Common.DbCommand DBCmd;

        DBCmd = GetDBObjCommand();
        DBCmd.CommandType = System.Data.CommandType.Text;
        DBCmd.CommandText = SS;

        return GetDB(DBConnStr, DBCmd);
    }

    public static System.Data.DataTable GetDB(string DBConnStr, System.Data.Common.DbCommand DBCmd) {
        System.Data.DataTable DT;
        System.Data.Common.DbDataAdapter DA;
        System.Data.Common.DbConnection DBConn;
        string SS;

        DBConn = GetDBObjConnection();
        DBConn.ConnectionString = DBConnStr;
        DBCmd.Connection = DBConn;

        SS = DBCmd.CommandText;

        DT = new System.Data.DataTable();
        DA = GetDBObjDataAdapter();
        DA.SelectCommand = DBCmd;

        try {
            DBConn.Open();
            // DA.FillSchema(DT, System.Data.SchemaType.Source)
            DA.Fill(DT);
        }
        catch (Exception ex) {
            throw ex;
        } finally {
            try {
                DBConn.Close();
            } catch (Exception ex) {
            }
        }

        DT.ExtendedProperties.Add("CreateInstance", "DBAccess");
        DT.ExtendedProperties.Add("DBAccess_OleDBString", SS);
        DT.ExtendedProperties.Add("DBAccess_DBCommand", DBCmd);
        DT.ExtendedProperties.Add("DBAccess_AutoNumber", string.Empty);

        foreach (System.Data.DataColumn DC in DT.Columns) {
            if (DC.AutoIncrement) {
                DT.ExtendedProperties["DBAccess_AutoNumber"] = DC.ColumnName;
                DC.AutoIncrementSeed = -1;
                DC.AutoIncrementStep = -1;
                break;
            }
        }

        return DT;
    }

    public static System.Data.DataSet GetMultipleDB(string DBConnStr, System.Data.Common.DbCommand DBCmd)
    {
        System.Data.DataSet DS;
        System.Data.Common.DbDataAdapter DA;
        System.Data.Common.DbConnection DBConn;
        string SS;

        DBConn = GetDBObjConnection();
        DBConn.ConnectionString = DBConnStr;
        DBCmd.Connection = DBConn;

        SS = DBCmd.CommandText;

        DS = new System.Data.DataSet();
        DA = GetDBObjDataAdapter();
        DA.SelectCommand = DBCmd;

        try
        {
            DBConn.Open();
            DA.Fill(DS);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            try
            {
                DBConn.Close();
            }
            catch (Exception ex)
            {
            }
        }

        return DS;
    }

    public static object GetDBValue(string DBConnStr, string SS) {
        System.Data.Common.DbCommand DBCmd;

        DBCmd = GetDBObjCommand();
        DBCmd.CommandType = System.Data.CommandType.Text;
        DBCmd.CommandText = SS;

        return GetDBValue(DBConnStr, DBCmd);
    }

    public static object GetDBValue(string DBConnStr, System.Data.Common.DbCommand DBCmd) {
        System.Data.Common.DbConnection DBConn;
        object RetValue = null;
        TransactionDB T = null;
        bool DoTrans = false;
        System.LocalDataStoreSlot LDS;

        LDS = System.Threading.Thread.GetNamedDataSlot("DBAccess_Transaction");
        if (LDS != null) {
            T = (TransactionDB)System.Threading.Thread.GetData(LDS);
            if (T != null) {
                if (T.ConnectionString == DBConnStr)
                    DoTrans = true;
            }
        }

        if (DoTrans) {
            RetValue = T.GetDBValue(DBCmd);
        } else {
            DBConn = GetDBObjConnection();
            DBConn.ConnectionString = DBConnStr;
            DBCmd.Connection = DBConn;

            try {
                DBConn.Open();
                RetValue = DBCmd.ExecuteScalar();
            } catch (Exception ex) {
                throw ex;
            } finally {
                try {
                    DBConn.Close();
                } catch (Exception ex) {
                }
            }

            DBConn.Dispose();
            DBConn = null;
        }

        return RetValue;
    }

    public static int ExecuteDB(string DBConnStr, string SS) {
        System.Data.Common.DbCommand DBCmd;
        int RetValue;

        DBCmd = GetDBObjCommand();

        DBCmd.CommandText = SS;
        DBCmd.CommandType = System.Data.CommandType.Text;

        RetValue = ExecuteDB(DBConnStr, DBCmd);

        return RetValue;
    }

    public static int ExecuteDB(string DBConnStr, System.Data.Common.DbCommand Cmd) {
        System.Data.Common.DbConnection DBConn;
        int RetValue;
        TransactionDB T = null;
        bool DoTrans = false;
        System.LocalDataStoreSlot LDS;

        LDS = System.Threading.Thread.GetNamedDataSlot("DBAccess_Transaction");
        if (LDS != null) {
            T = (TransactionDB)System.Threading.Thread.GetData(LDS);
            if (T != null) {
                if (T.ConnectionString == DBConnStr)
                    DoTrans = true;
            }
        }

        if (DoTrans) {
            RetValue = T.ExecuteDB(Cmd);
        } else {
            DBConn = GetDBObjConnection();
            DBConn.ConnectionString = DBConnStr;
            Cmd.Connection = DBConn;

            try {
                DBConn.Open();
                RetValue = Cmd.ExecuteNonQuery();
            } catch (Exception ex) {
                throw ex;
            } finally {
                try {
                    DBConn.Close();
                } catch (Exception ex) {
                }
            }

            DBConn.Dispose();
            DBConn = null;
        }

        return RetValue;
    }

    public static void ExecuteTransDB(string DBConnStr, Action<TransactionDB> Func) {
        TransactionDB TransDB = null;
        bool ExecuteSuccess = false;
        System.LocalDataStoreSlot LDS;

        LDS = System.Threading.Thread.GetNamedDataSlot("DBAccess_Transaction");
        if (LDS == null)
            LDS = System.Threading.Thread.AllocateNamedDataSlot("DBAccess_Transaction");

        TransDB = new TransactionDB(DBConnStr);
        System.Threading.Thread.SetData(LDS, TransDB);
        try {
            Func.Invoke(TransDB);
            ExecuteSuccess = true;
        } catch (Exception ex) {
            if (TransDB != null) {
                try {
                    TransDB.Rollback();
                } catch (Exception ex2) {
                }
            }

            System.Threading.Thread.FreeNamedDataSlot("DBAccess_Transaction");

            throw ex;
        }

        if (ExecuteSuccess) {
            if (TransDB != null) {
                try {
                    TransDB.Commit();
                } catch (Exception ex) {
                }
            }

            System.Threading.Thread.FreeNamedDataSlot("DBAccess_Transaction");
        }
    }

    public static System.Data.DataTable SubmitDB(string DBConnStr, System.Data.DataTable DT) {
        System.Data.Common.DbConnection DBConn;
        System.Data.Common.DbDataAdapter DA;
        System.Data.Common.DbCommand DBCmd;
        System.Data.Common.DbCommandBuilder DBCmdBuilder;
        System.Data.DataView DV;
        bool NeedUpdate;
        string QueryString;

        NeedUpdate = false;
        if ((string)DT.ExtendedProperties["CreateInstance"] == "DBAccess")
        {
            QueryString = (string)DT.ExtendedProperties["DBAccess_OleDBString"];
            DBCmd = (System.Data.Common.DbCommand)DT.ExtendedProperties["DBAccess_DBCommand"];

            DBConn = GetDBObjConnection();
            DBConn.ConnectionString = DBConnStr;

            // DBCmd = GetDBObjCommand()
            // DBCmd.CommandText = QueryString
            DBCmd.Connection = DBConn;

            DA = GetDBObjDataAdapter();
            DA.SelectCommand = DBCmd;

            // DA = DT.ExtendedProperties.Item("DBAccess_DataAdapter")

            DBCmdBuilder = GetDBObjCommandBuilder(DA);

            DV = new System.Data.DataView(DT);

            // 檢查是否有新增資料
            DV.RowStateFilter = System.Data.DataViewRowState.Added;
            if (DV.Count > 0)
            {
                DA.InsertCommand = DBCmdBuilder.GetInsertCommand();
                NeedUpdate = true;
            }

            // 檢查是否有刪除資料
            DV.RowStateFilter = System.Data.DataViewRowState.Deleted;
            if (DV.Count > 0)
            {
                DA.DeleteCommand = DBCmdBuilder.GetDeleteCommand();
                NeedUpdate = true;
            }

            // 檢查是否有更新資料
            DV.RowStateFilter = System.Data.DataViewRowState.ModifiedCurrent;
            if (DV.Count > 0)
            {
                DA.UpdateCommand = DBCmdBuilder.GetUpdateCommand();
                NeedUpdate = true;
            }

            if (NeedUpdate)
            {
                DBConn.Open();
                DBHandleUpdate(DA, DT);
                DBConn.Close();

                DT.AcceptChanges();
            }

            DV.Dispose();
            DBCmdBuilder.Dispose();
            DA.Dispose();
            DBCmd.Dispose();
            DBConn.Dispose();

            DA = null;
            DV = null;
            DBCmdBuilder = null;
            DBCmd = null;
            DBConn = null;
        } else {
            throw new Exception("DataTable 無法識別");
        }

        return DT;
    }

    private static void DBHandleUpdate(System.Data.Common.DbDataAdapter DA, System.Data.DataTable DT) {
        System.Data.SqlClient.SqlDataAdapter SqlDA;
        System.Data.OleDb.OleDbDataAdapter OleDA;

        switch (iDBType) {
            case EnumDBType.OleDB:
                OleDA = (System.Data.OleDb.OleDbDataAdapter)DA;

                OleDA.RowUpdated += DBAccess_onRowUpdate_OleDB;
                OleDA.Update(DT);
                OleDA.RowUpdated -= DBAccess_onRowUpdate_OleDB;
                break;
            case EnumDBType.SqlClient:
                SqlDA = (System.Data.SqlClient.SqlDataAdapter)DA;

                SqlDA.RowUpdated += DBAccess_onRowUpdate_SqlClient;
                SqlDA.Update(DT);
                SqlDA.RowUpdated -= DBAccess_onRowUpdate_SqlClient;
                break;
            default:
                DA.Update(DT);
                break;
        }
    }

    private static void DBAccess_onRowUpdate_OleDB(object sender, System.Data.OleDb.OleDbRowUpdatedEventArgs args)
    {
        object newID;
        string IDFieldName;
        System.Data.OleDb.OleDbCommand DBCmd;
        bool ColumnReadOnlyValue;

        if (args.StatementType == System.Data.StatementType.Insert) {
            IDFieldName = (string)args.Row.Table.ExtendedProperties["DBAccess_AutoNumber"];
            if (IDFieldName != string.Empty) {
                DBCmd = new System.Data.OleDb.OleDbCommand("SELECT @@IDENTITY");
                DBCmd.Connection = args.Command.Connection;
                newID = DBCmd.ExecuteScalar();

                if (newID != System.DBNull.Value) {
                    ColumnReadOnlyValue = args.Row.Table.Columns[IDFieldName].ReadOnly;

                    args.Row.Table.Columns[IDFieldName].ReadOnly = false;
                    args.Row[IDFieldName] = (int)newID;
                    args.Row.Table.Columns[IDFieldName].ReadOnly = ColumnReadOnlyValue;
                }
            }
        }
    }

    private static void DBAccess_onRowUpdate_SqlClient(object sender, System.Data.SqlClient.SqlRowUpdatedEventArgs args)
    {
        object newID;
        string IDFieldName;
        System.Data.SqlClient.SqlCommand DBCmd;
        bool ColumnReadOnlyValue;

        if (args.StatementType == System.Data.StatementType.Insert) {
            IDFieldName = (string)args.Row.Table.ExtendedProperties["DBAccess_AutoNumber"];
            if (IDFieldName != string.Empty) {
                DBCmd = new System.Data.SqlClient.SqlCommand("SELECT @@IDENTITY");
                DBCmd.Connection = args.Command.Connection;
                newID = DBCmd.ExecuteScalar();

                if (newID != System.DBNull.Value) {
                    ColumnReadOnlyValue = args.Row.Table.Columns[IDFieldName].ReadOnly;

                    args.Row.Table.Columns[IDFieldName].ReadOnly = false;
                    args.Row[IDFieldName] = (int)newID;
                    args.Row.Table.Columns[IDFieldName].ReadOnly = ColumnReadOnlyValue;
                }
            }
        }
    }

    private static System.Data.Common.DbConnection GetDBObjConnection() {
        System.Data.Common.DbConnection RetValue = null;

        switch (iDBType) {
            case EnumDBType.OleDB:
                RetValue = new System.Data.OleDb.OleDbConnection();
                break;
            case EnumDBType.SqlClient:
                RetValue = new System.Data.SqlClient.SqlConnection();
                break;
        }

        return RetValue;
    }

    private static System.Data.Common.DbCommand GetDBObjCommand() {
        System.Data.Common.DbCommand RetValue = null;

        switch (iDBType) {
            case EnumDBType.OleDB:
                RetValue = new System.Data.OleDb.OleDbCommand();
                break;
            case EnumDBType.SqlClient:
                RetValue = new System.Data.SqlClient.SqlCommand();
                break;
        }

        return RetValue;
    }

    private static System.Data.Common.DbCommandBuilder GetDBObjCommandBuilder(System.Data.Common.DataAdapter DA) {
        System.Data.Common.DbCommandBuilder RetValue = null;

        switch (iDBType)
        {
            case EnumDBType.OleDB:
                RetValue = new System.Data.OleDb.OleDbCommandBuilder((System.Data.OleDb.OleDbDataAdapter)DA);
                break;
            case EnumDBType.SqlClient:
                RetValue = new System.Data.SqlClient.SqlCommandBuilder((System.Data.SqlClient.SqlDataAdapter)DA);
                break;
        }

        return RetValue;
    }

    private static System.Data.Common.DbDataAdapter GetDBObjDataAdapter() {
        System.Data.Common.DbDataAdapter RetValue = null;

        switch (iDBType) {
            case EnumDBType.OleDB:
                RetValue = new System.Data.OleDb.OleDbDataAdapter();
                break;
            case EnumDBType.SqlClient:
                RetValue = new System.Data.SqlClient.SqlDataAdapter();
                break;
        }

        return RetValue;
    }

    public class TransactionDB : IDisposable
    {
        private string iConnectionString = string.Empty;
        private System.Data.Common.DbConnection iDBConn = null;
        private System.Data.Common.DbTransaction iDBTrans = null;

        public string ConnectionString {
            get {
                return iConnectionString;
            }
        }

        public TransactionDB(string DBConnStr) {
            bool Success = false;

            iConnectionString = DBConnStr;
            iDBConn = GetDBObjConnection();
            iDBConn.ConnectionString = DBConnStr;

            try {
                iDBConn.Open();
                iDBTrans = iDBConn.BeginTransaction();
            } catch (Exception ex) {
                if (iDBTrans != null) {
                    try {
                        iDBTrans.Dispose();
                    } catch (Exception ex2) {
                    }
                }

                if (iDBConn != null) {
                    try {
                        iDBConn.Close();
                    } catch (Exception ex2) {
                    }

                    try {
                        iDBConn.Dispose();
                    } catch (Exception ex2) {
                    }
                }

                iDBConn = null;
                iDBTrans = null;

                throw ex;
            }
        }

        public int ExecuteDB(string SS) {
            System.Data.Common.DbCommand DBCmd;

            DBCmd = GetDBObjCommand();

            DBCmd.CommandText = SS;
            DBCmd.CommandType = System.Data.CommandType.Text;

            return ExecuteDB(DBCmd);
        }

        public int ExecuteDB(System.Data.Common.DbCommand Cmd) {
            int RetValue;

            Cmd.Connection = iDBConn;
            Cmd.Transaction = iDBTrans;

            try {
                RetValue = Cmd.ExecuteNonQuery();
            } catch (Exception ex) {
                throw ex;
            }

            return RetValue;
        }

        public object GetDBValue(string SS) {
            System.Data.Common.DbCommand DBCmd;

            DBCmd = GetDBObjCommand();
            DBCmd.CommandType = System.Data.CommandType.Text;
            DBCmd.CommandText = SS;

            return GetDBValue(DBCmd);
        }

        public object GetDBValue(System.Data.Common.DbCommand DBCmd) {
            object RetValue;

            DBCmd.Connection = iDBConn;
            DBCmd.Transaction = iDBTrans;

            try {
                RetValue = DBCmd.ExecuteScalar();
            } catch (Exception ex) {
                throw ex;
            }

            return RetValue;
        }

        public void Commit() {
            if (iDBTrans != null)
                iDBTrans.Commit();

            this.Dispose();
        }

        public void Rollback() {
            if (iDBTrans != null)
                iDBTrans.Rollback();

            this.Dispose();
        }

        private bool disposedValue; // 偵測多餘的呼叫

        // IDisposable
        protected virtual void Dispose(bool disposing) {
            if (!disposedValue) {
                if (disposing) {
                    // TODO: 處置 Managed 狀態 (Managed 物件)。
                    if (iDBTrans != null) {
                        try {
                            iDBTrans.Dispose();
                        } catch (Exception ex) {
                        }
                    }

                    if (iDBConn != null) {
                        try {
                            iDBConn.Close();
                        } catch (Exception ex) {
                        }

                        try {
                            iDBConn.Dispose();
                        } catch (Exception ex) {
                        }
                    }
                }
            }
            disposedValue = true;
        }

        // TODO: 只有當上方的 Dispose(disposing As Boolean) 具有要釋放 Unmanaged 資源的程式碼時，才覆寫 Finalize()。
        // Protected Overrides Sub Finalize()
        // ' 請勿變更這個程式碼。請將清除程式碼放在上方的 Dispose(disposing As Boolean) 中。
        // Dispose(False)
        // MyBase.Finalize()
        // End Sub

        // Visual Basic 加入這個程式碼的目的，在於能正確地實作可處置的模式。
        public void Dispose() {
            // 請勿變更這個程式碼。請將清除程式碼放在上方的 Dispose(disposing As Boolean) 中。
            Dispose(true);
        }
    }
}
