<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetQRCode.aspx.cs" Inherits="GetQRCode" %>
<%
    string QRCodeContent;
    byte[] QRCodeArray = null;
    string QRCodeDataURI = "";
    bool AllowShow = false;
    int DownloadImg = 0;

    if (Request["Download"] == "1")
        DownloadImg = 1;
    else if (Request["Download"] == "2")
        DownloadImg = 2;

    QRCodeContent = Request["QRCode"];
    if (string.IsNullOrEmpty(QRCodeContent) == false)
    {
        QRCodeArray = GenerateQRCode_URL(QRCodeContent, 5);
        if (QRCodeArray != null)
        {
            QRCodeDataURI = "data:image/png;base64," + Convert.ToBase64String(QRCodeArray);
            AllowShow = true;
        }
    }

    if (QRCodeArray != null)
    {
        if (DownloadImg == 1)
        {
            Response.Clear();
            Response.AddHeader("Content-Disposition", "attachment;filename=QRCode.png");
            Response.AddHeader("Content-Length", QRCodeArray.Length.ToString());
            Response.AddHeader("Content-Transfer-Encoding", "binary");
            Response.ContentType = "application/octet-stream";
            Response.BinaryWrite(QRCodeArray);
            Response.Flush();
            Response.End();
        }
        else if (DownloadImg == 2)
        {
            Response.Clear();
            Response.AddHeader("Content-Length", QRCodeArray.Length.ToString());
            Response.AddHeader("Content-Transfer-Encoding", "binary");
            Response.ContentType = "image/png";
            Response.BinaryWrite(QRCodeArray);
            Response.Flush();
            Response.End();
        }
    }
%>
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="Content-Language" content="zh-cn">
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="pragma" content="no-cache" />
</head>
<body style="width: 100%; padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px">
    <% if (AllowShow) { %>
        <img src="<%=QRCodeDataURI %>">
    <% } %>
</body>
</html>