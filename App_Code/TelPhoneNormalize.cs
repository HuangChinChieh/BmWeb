using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public class TelPhoneNormalize
{
    private string iPrefix;
    private string iNumber;

    public TelPhoneNormalize(string PhonePrefix, string PhoneNumber)
    {
        iPrefix = NormalizePrefix(PhonePrefix);
        iNumber = NormalizePhoneNumber(PhoneNumber);
    }

    public bool PhoneIsValid
    {
        get { return ((string.IsNullOrEmpty(iPrefix) == false) && (string.IsNullOrEmpty(iNumber) == false)); }
    }

    public string PhonePrefix
    {
        get { return iPrefix; }
    }

    public string PhoneNumber
    {
        get { return iNumber; }
    }

    public override string ToString()
    {
        return iPrefix + iNumber;
    }

    public string ToString(string SplitChars)
    {
        return iPrefix + SplitChars + iNumber;
    }

    public bool Equals(TelPhoneNormalize obj)
    {
        return ((obj.PhonePrefix == iPrefix) && (obj.PhoneNumber == iNumber));
    }

    public static string NormalizePhoneNumber(string s)
    {
        // 規則: 開頭 0 濾掉
        // 需全數字
        string tmpStr = s;

        if (string.IsNullOrWhiteSpace(tmpStr) == false) {
            tmpStr = tmpStr.Trim();

            while (true) {
                if (tmpStr.Length >= 1) {
                    if (tmpStr.Substring(0, 1) == "0") {
                        tmpStr = tmpStr.Substring(1);
                    } else {
                        break;
                    }
                } else {
                    break;
                }
            }

            tmpStr = FilterNumber(tmpStr);
        }

        return tmpStr;
    }

    public static string NormalizePrefix(string s)
    {
        // 規則: 開頭 00, + 濾掉
        // 需全數字
        string tmpStr = s;

        if (string.IsNullOrWhiteSpace(tmpStr) == false) {
            tmpStr = tmpStr.Trim();

            if (tmpStr.Length >= 2) {
                if (tmpStr.Substring(0, 2) == "00") {
                    tmpStr = tmpStr.Substring(2);
                }
            }

            if (tmpStr.Length >= 1) {
                if (tmpStr.Substring(0, 1) == "+") {
                    tmpStr = tmpStr.Substring(1);
                }
            }

            tmpStr = FilterNumber(tmpStr);
        }

        return tmpStr;
    }

    private static string FilterNumber(string S)
    {
        string AvailString = "0123456789";
        string RetValue = string.Empty;

        foreach (char EachStr in S) {
            if (AvailString.IndexOf(EachStr) >= 0)
                RetValue += EachStr;
        }

        return RetValue;
    }

}
