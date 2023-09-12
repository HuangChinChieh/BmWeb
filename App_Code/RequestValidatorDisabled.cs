using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Util;

/// <summary>
/// RequestValidatorDisabled 的摘要描述
/// </summary>
public class RequestValidatorDisabled : System.Web.Util.RequestValidator
{
    protected override bool IsValidRequestString(HttpContext context, string value, RequestValidationSource requestValidationSource, string collectionKey, out int validationFailureIndex)
    {
        validationFailureIndex = -1;
        return true;
    }
}
