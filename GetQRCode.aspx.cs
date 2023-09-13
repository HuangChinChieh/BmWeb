using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class GetQRCode : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    public static byte[] GenerateQRCode_URL(string URL, int PointPixel, bool EmbedLogo = true)
    {
        QRCoder.PayloadGenerator.Url p;
        QRCoder.QRCodeGenerator qCodeGen = new QRCoder.QRCodeGenerator();
        QRCoder.QRCodeData qData;
        QRCoder.QRCode qCode;
        System.Drawing.Bitmap b;
        System.IO.MemoryStream stm = new System.IO.MemoryStream();
        byte[] RetValue;
        int logoDestWidth;
        int logoDestHeight;


        // H: 30% 可遺失
        //p = new QRCoder.PayloadGenerator.Url(URL);
        //qData = qCodeGen.CreateQrCode(p, QRCoder.QRCodeGenerator.ECCLevel.H);
        qData = qCodeGen.CreateQrCode(URL, QRCoder.QRCodeGenerator.ECCLevel.H);
        qCode = new QRCoder.QRCode(qData);

        b = qCode.GetGraphic(PointPixel);

        //if (EmbedLogo)
        //{
        //    System.Drawing.Graphics g;

        //    logoDestWidth = Convert.ToInt32(b.Width * 0.20);  // 設定 20%, 保留一些誤差空間
        //    logoDestHeight = Convert.ToInt32(b.Height * 0.20);

        //    g = System.Drawing.Graphics.FromImage(b);
        //    g.DrawImage(eWinLogoImg,
        //                new System.Drawing.Rectangle(Convert.ToInt32((b.Width - logoDestWidth) / 2), Convert.ToInt32((b.Height - logoDestHeight) / 2), logoDestWidth, logoDestHeight),
        //                0, 0, eWinLogoImg.Width, eWinLogoImg.Height,
        //                System.Drawing.GraphicsUnit.Pixel);
        //    g.Dispose();
        //    g = null;
        //}

        b.Save(stm, System.Drawing.Imaging.ImageFormat.Png);
        b.Dispose();
        b = null;

        RetValue = (byte[])Array.CreateInstance(typeof(byte), stm.Length);
        stm.Position = 0;
        stm.Read(RetValue, 0, RetValue.Length);
        stm.Close();
        stm.Dispose();
        stm = null;

        qCode.Dispose();
        qCode = null;

        qData.Dispose();
        qData = null;

        qCodeGen.Dispose();
        qCodeGen = null;

        return RetValue;
    }
}