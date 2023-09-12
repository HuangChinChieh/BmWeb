using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// MultiLanguageParser 的摘要描述
/// </summary>
public class MultiLanguageParser
{
    private System.Collections.Generic.Dictionary<string, object> iObject;

    public string GetLanguageKey(string Key)
    {
        string RetValue = Key;
        string LanguageReturn;

        LanguageReturn = (string)GetJSONObject_Internal(iObject, Key);
        if (string.IsNullOrEmpty(LanguageReturn) == false)
        {
            RetValue = LanguageReturn;
        }

        return RetValue;
    }

    private object GetJSONObject_Internal(object o, string JSONName)
    {
        Dictionary<string, object> oDic = null;
        string FirstName;
        string LastName;
        int TmpIndex;
        object RetValue = null;
        bool ConvertSuccess = false;

        if (o != null)
        {
            try
            {
                oDic = (Dictionary<string, object>)o;
                ConvertSuccess = true;
            }
            catch (Exception ex)
            {
            }

            if (ConvertSuccess)
            {
                object tmpObject;
                object destObject;
                int tmp1;
                int tmp2;
                int arrayIndex = 0;
                bool isSetArray = false;

                TmpIndex = JSONName.IndexOf(".");
                if (TmpIndex != -1)
                {
                    FirstName = JSONName.Substring(0, TmpIndex).Trim();
                    LastName = JSONName.Substring(TmpIndex + 1).Trim();
                }
                else
                {
                    FirstName = JSONName;
                    LastName = string.Empty;
                }

                tmp1 = FirstName.IndexOf("[");
                if (tmp1 != -1)
                {
                    tmp2 = FirstName.IndexOf("]", tmp1);
                    if (tmp2 != -1)
                    {
                        isSetArray = true;
                        arrayIndex = Convert.ToInt32(FirstName.Substring(tmp1 + 1, tmp2 - tmp1 - 1));
                        FirstName = FirstName.Substring(0, tmp1);
                    }
                }

                if (oDic.ContainsKey(FirstName))
                {
                    tmpObject = oDic[FirstName];

                    if (tmpObject.GetType().IsArray)
                    {
                        if (isSetArray)
                        {
                            destObject = ((object[])tmpObject)[arrayIndex];
                        }
                        else
                        {
                            destObject = tmpObject;
                        }
                    }
                    else
                    {
                        destObject = tmpObject;
                    }

                    if (string.IsNullOrEmpty(LastName))
                    {
                        RetValue = destObject;
                    }
                    else
                    {
                        RetValue = GetJSONObject_Internal(destObject, LastName);
                    }
                }
            }
        }

        return RetValue;
    }

    public MultiLanguageParser(string Lang)
    {
        string CurrentPage;
        string PageURL;
        int TmpIndex;
        string LanguageFilename;
        string LanguageFileURL;

        PageURL = HttpContext.Current.Request.Path;
        TmpIndex = PageURL.IndexOf("?");
        if (TmpIndex != -1)
        {
            CurrentPage = PageURL.Substring(0, TmpIndex);
        }
        else
        {
            CurrentPage = PageURL;
        }

        LanguageFileURL = CurrentPage + "." + Lang + ".json";
        LanguageFilename = HttpContext.Current.Server.MapPath(LanguageFileURL);

        if (System.IO.File.Exists(LanguageFilename))
        {
            string LanguageContent = null;

            try
            {
                LanguageContent = System.IO.File.ReadAllText(LanguageFilename);
            }
            catch (Exception ex)
            {
            }

            if (string.IsNullOrEmpty(LanguageContent) == false)
            {
                System.Web.Script.Serialization.JavaScriptSerializer iSer = new System.Web.Script.Serialization.JavaScriptSerializer();

                iObject = iSer.Deserialize<Dictionary<string, object>>(LanguageContent);
            }
        }
    }
}