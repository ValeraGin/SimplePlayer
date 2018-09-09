namespace Tags
{
    using System;
    using System.Drawing;
    using System.Drawing.Imaging;
    using System.IO;
    using System.Runtime.InteropServices;

    internal class TagPicture
    {
        public int AttributeIndex;
        public byte[] Data;
        public string Description;
        public string MIMEType;
        public PICTURE_TYPE PictureType;

        public TagPicture(Tag pTag)
        {
            this.Data = null;
            this.AttributeIndex = -1;
            this.AttributeIndex = pTag.Index;
            this.MIMEType = "Unknown";
            this.PictureType = PICTURE_TYPE.Unknown;
            this.Description = "";
            MemoryStream input = null;
            BinaryReader reader = null;
            if (pTag.Name == "WM/Picture")
            {
                try
                {
                    input = new MemoryStream((byte[]) pTag);
                    reader = new BinaryReader(input);
                    this.MIMEType = Marshal.PtrToStringUni(new IntPtr(reader.ReadInt32()));
                    byte num = reader.ReadByte();
                    try
                    {
                        this.PictureType = (PICTURE_TYPE) num;
                    }
                    catch
                    {
                        this.PictureType = PICTURE_TYPE.Unknown;
                    }
                    this.Description = Marshal.PtrToStringUni(new IntPtr(reader.ReadInt32()));
                    int length = reader.ReadInt32();
                    this.Data = new byte[length];
                    Marshal.Copy(new IntPtr(reader.ReadInt32()), this.Data, 0, length);
                }
                catch
                {
                }
                finally
                {
                    if (reader != null)
                    {
                        reader.Close();
                    }
                    if (input != null)
                    {
                        input.Close();
                    }
                }
            }
        }

        public TagPicture(int attribIndex, string mimeType, PICTURE_TYPE pictureType, string description, byte[] data)
        {
            this.Data = null;
            this.AttributeIndex = -1;
            this.AttributeIndex = attribIndex;
            this.MIMEType = mimeType;
            this.PictureType = pictureType;
            this.Description = description;
            this.Data = data;
        }

        public static string GetMimeTypeFromImage(Image pImage)
        {
            ImageFormat rawFormat = pImage.RawFormat;
            if (rawFormat.Guid != ImageFormat.Jpeg.Guid)
            {
                if (rawFormat.Guid == ImageFormat.Gif.Guid)
                {
                    return "image/gif";
                }
                if (rawFormat.Guid == ImageFormat.MemoryBmp.Guid)
                {
                    return "image/bmp";
                }
                if (rawFormat.Guid == ImageFormat.Bmp.Guid)
                {
                    return "image/bmp";
                }
                if (rawFormat.Guid == ImageFormat.Png.Guid)
                {
                    return "image/png";
                }
                if (rawFormat.Guid == ImageFormat.Icon.Guid)
                {
                    return "image/x-icon";
                }
                if (rawFormat.Guid == ImageFormat.Tiff.Guid)
                {
                    return "image/tiff";
                }
                if (rawFormat.Guid == ImageFormat.Emf.Guid)
                {
                    return "image/x-emf";
                }
                if (rawFormat.Guid == ImageFormat.Wmf.Guid)
                {
                    return "image/x-wmf";
                }
            }
            return "image/jpeg";
        }

        public override string ToString()
        {
            return string.Format("{0} [{1}, {2}]", this.Description, this.PictureType, this.MIMEType);
        }

        public Image PictureImage
        {
            get
            {
                try
                {
                    ImageConverter converter = new ImageConverter();
                    return (converter.ConvertFrom(this.Data) as Image);
                }
                catch
                {
                    return null;
                }
            }
        }

        public enum PICTURE_TYPE : byte
        {
            Artists = 8,
            BackAlbumCover = 4,
            BandLogo = 0x13,
            ColoredFish = 0x11,
            Composer = 11,
            Conductor = 9,
            FrontAlbumCover = 3,
            Icon32 = 1,
            Illustration = 0x12,
            LeadArtist = 7,
            LeafletPage = 5,
            Location = 13,
            Media = 6,
            Orchestra = 10,
            OtherIcon = 2,
            Performance = 15,
            PublisherLogo = 20,
            RecordingSession = 14,
            Unknown = 0,
            VideoCapture = 0x10,
            Writer = 12
        }
    }
}

