<%@ WebHandler Language="C#" Class="shell" %>

using System;
using System.Web;
using System.IO;
using System.Drawing;


/// <summary> 
/// ��ʾ����ͼƬ������ͼ,�Կ��100����Ϊ���λ 
/// </summary> 
public class shell : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        //��ȡ�����ݹ�����img�ַ���,���� 
        //http://localhost:5002/shell4.ashx?img=abacus8.jpg���� 
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
        //����ļ����ڲŻ�ȥ��ȡ,����ʹ��try,catch,��߳������� 
        if (File.Exists(path))
        {
            //�������ͼƬ 
            Image originalImage = Image.FromFile(path);
            int towidth = Int32.Parse(w);
            int toheight = Int32.Parse(h);

            int x = 0;
            int y = 0;
            int ow = originalImage.Width;
            int oh = originalImage.Height;

            //������Ի�ȡ���ļ�,�Ż�ִ������Ĵ��� 
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
                //�½�һ��bmpͼƬ
                System.Drawing.Image bitmap = new System.Drawing.Bitmap(towidth, toheight);
                //�½�һ������
                Graphics g = System.Drawing.Graphics.FromImage(bitmap);
                //���ø�������ֵ��
                g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.High;
                //���ø�����,���ٶȳ���ƽ���̶�
                g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
                //��ջ�������͸������ɫ���
                g.Clear(Color.Transparent);
                //��ָ��λ�ò��Ұ�ָ����С����ԭͼƬ��ָ������
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
            //����ͷ���һ���ļ������ڵ���Ϣ������� 
            context.Response.ContentType = "text/html";
            context.Response.Write("�ļ�������");
            //���߷���һ���ļ������ڵ�ͼƬ 
            //context.Response.WriteFile("todo�˴��޸�ΪͼƬ����·��"); 
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
