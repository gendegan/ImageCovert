<%@ WebHandler Language="C#" Class="shell" %>

using System;
using System.Web;
using System.IO;
using System.Drawing;


/// <summary> 
/// 显示请求图片的缩略图,以宽度100像素为最大单位 
/// </summary> 
public class shell : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        //获取到传递过来的img字符串,比如 
        //http://localhost:5002/shell4.ashx?img=abacus8.jpg这种 
        string img = context.Request.Params["img"];
        string h = context.Request.Params["h"];
        string w = context.Request.Params["w"];
        if (string.IsNullOrWhiteSpace(img))
        {
            return;
        }
        string fileName = "";
        System.Drawing.Imaging.ImageFormat objImageFormat = System.Drawing.Imaging.ImageFormat.Jpeg;
        if (img.Contains(".png"))
        {
            objImageFormat = System.Drawing.Imaging.ImageFormat.Png;
            context.Response.ContentType = "image/png";
            fileName = Guid.NewGuid().ToString() + ".png";
        }
        else
        {
            fileName = Guid.NewGuid().ToString() + ".jpg";
            context.Response.ContentType = "image/jpeg";
        }
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
            Image originalImage = Image.FromFile(path);
            int towidth = Int32.Parse(w);
            int toheight = Int32.Parse(h);

            int x = 0;
            int y = 0;
            int ow = originalImage.Width;
            int oh = originalImage.Height;

            //如果可以获取到文件,才会执行下面的代码 
            if (originalImage != null)
            {
                if ((double)originalImage.Width / (double)originalImage.Height > (double)towidth / (double)toheight)
                {
                    oh = originalImage.Height;
                    ow = originalImage.Height * towidth / toheight;
                    y = 0;
                    x = (originalImage.Width - ow) / 2;
                }
                else
                {
                    ow = originalImage.Width;
                    oh = originalImage.Width * toheight / towidth;
                    x = 0;
                    y = (originalImage.Height - oh) / 2;
                }
                //新建一个bmp图片
                System.Drawing.Image bitmap = new System.Drawing.Bitmap(towidth, toheight);
                //新建一个画板
                Graphics g = System.Drawing.Graphics.FromImage(bitmap);
                //设置高质量插值法
                g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.High;
                //设置高质量,低速度呈现平滑程度
                g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
                //清空画布并以透明背景色填充
                g.Clear(Color.Transparent);
                //在指定位置并且按指定大小绘制原图片的指定部分
                g.DrawImage(originalImage, new Rectangle(0, 0, towidth, toheight),
                    new Rectangle(x, y, ow, oh),
                    GraphicsUnit.Pixel);
                bitmap.Save(context.Response.OutputStream, objImageFormat);
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
