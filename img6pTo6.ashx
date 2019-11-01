<%@ WebHandler Language="C#" Class="img6pTo6" %>

using System;
using System.Web;
using System.IO;
using System.Drawing;


/// <summary> 
/// 显示请求图片的缩略图,以宽度100像素为最大单位 
/// </summary> 
public class img6pTo6 : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "image/jpeg";
        //获取到传递过来的img字符串,比如 
        //http://localhost:5002/img6pTo6.ashx?img=abacus8.jpg这种 
        string img = context.Request.Params["img"];
        if (string.IsNullOrWhiteSpace(img))
        {
            return;
        }
        string fileName = Guid.NewGuid().ToString() + ".jpg";
        string path = context.Server.MapPath("~/images/") + fileName;
        using (System.Net.WebClient wc = new System.Net.WebClient())
        {
            wc.Headers.Add("User-Agent", "Chrome");
            wc.DownloadFile(img, path);
        }
        //如果文件存在才会去读取,减少使用try,catch,提高程序性能 
        if (File.Exists(path))
        {
            //载入这个图片 
            Image big = Image.FromFile(path);
            //如果可以获取到文件,才会执行下面的代码 
            if (big != null)
            {
                //设定最大的宽度,可以修改来生成更小的缩略图 
                int newWidth = 750;
                //根据图片的宽高比来生成一个位图 
                Bitmap bitmap = new Bitmap(newWidth, newWidth * big.Height / big.Width);
                //根据图板来创建一个图画 
                Graphics g = Graphics.FromImage(bitmap);
                using (g)
                {
                    //将大图big画到自己定义的小图中bitmap 
                    g.DrawImage(big, 0, 0, bitmap.Width, bitmap.Height);
                    //直接将处理好的位图保存到响应输出流中,格式为jpeg! 
                    bitmap.Save(context.Response.OutputStream, System.Drawing.Imaging.ImageFormat.Jpeg);
                }
            }
            try
            {
                File.Delete(path);
            }
            catch { }
        }
        else
        {
            //否则就发送一个文件不存在的信息到浏览器 
            context.Response.ContentType = "text/html";
            context.Response.Write("文件不存在");
            //或者发送一个文件不存在的图片 
            //context.Response.WriteFile("todo此处修改为图片所在路径"); 
        }
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
} 
