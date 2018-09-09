namespace Tags
{
    using System;
    using System.IO;
    using System.Runtime.InteropServices;
    using System.Text;

    internal class ID3v2Reader
    {
        private byte[] buffer;
        private byte DefaultMajorVersion = 3;
        private byte DefaultMinorVersion = 0;
        private string frameId;
        private object frameValue;
        private int lastTagPos;
        private byte majorVersion;
        private byte minorVersion;
        private int offset = 0;
        private Stream stream;

        public ID3v2Reader(IntPtr pID3v2)
        {
            if (Marshal.PtrToStringAnsi(pID3v2, 3) == "ID3")
            {
                this.offset += 3;
                this.majorVersion = Marshal.ReadByte(pID3v2, this.offset);
                this.offset++;
                this.minorVersion = Marshal.ReadByte(pID3v2, this.offset);
                this.offset++;
                byte num = Marshal.ReadByte(pID3v2, this.offset);
                this.offset++;
                int num2 = this.ReadInt28(pID3v2, this.offset);
                this.offset += 4;
                bool flag = (num & 0x40) > 0;
                int num3 = 0;
                if (flag)
                {
                    num3 = this.ReadInt32(pID3v2, this.offset);
                }
                this.buffer = new byte[num2 + 10];
                Marshal.Copy(pID3v2, this.buffer, 0, num2 + 10);
                this.stream = new MemoryStream(this.buffer);
                this.stream.Position = 10 + num3;
                int num4 = num2 + 10;
                this.lastTagPos = num4 - 10;
            }
            else
            {
                this.majorVersion = this.DefaultMajorVersion;
                this.minorVersion = this.DefaultMinorVersion;
                this.stream = null;
            }
            this.frameId = null;
            this.frameValue = null;
        }

        public void Close()
        {
            if (this.stream != null)
            {
                this.stream.Close();
            }
        }

        private Encoding GetFrameEncoding(byte frameEncoding)
        {
            switch (frameEncoding)
            {
                case 1:
                    return Encoding.Unicode;

                case 2:
                    return Encoding.BigEndianUnicode;

                case 3:
                    return Encoding.UTF8;
            }
            return Encoding.Default;
        }

        public string GetKey()
        {
            if (this.frameId == null)
            {
                throw new Exception("You gotta call Read first.");
            }
            return this.frameId;
        }

        public TagPicture GetPicture(byte[] frameValue, int index)
        {
            if (frameValue == null)
            {
                return null;
            }
            TagPicture picture = null;
            byte[] destinationArray = null;
            try
            {
                TagPicture.PICTURE_TYPE unknown;
                Encoding frameEncoding = this.GetFrameEncoding(frameValue[0]);
                int offset = 1;
                string mimeType = this.ReadTextZero(frameValue, ref offset);
                offset++;
                byte num2 = frameValue[offset];
                try
                {
                    unknown = (TagPicture.PICTURE_TYPE) num2;
                }
                catch
                {
                    unknown = TagPicture.PICTURE_TYPE.Unknown;
                }
                offset++;
                string description = this.ReadTextZero(frameValue, ref offset, frameEncoding);
                offset++;
                int length = frameValue.Length - offset;
                destinationArray = new byte[length];
                Array.Copy(frameValue, offset, destinationArray, 0, length);
                picture = new TagPicture(index, mimeType, unknown, description, destinationArray);
            }
            catch
            {
            }
            return picture;
        }

        public object GetValue()
        {
            if (this.frameId == null)
            {
                throw new Exception("You gotta call Read first.");
            }
            return this.frameValue;
        }

        public bool Read()
        {
            this.frameId = null;
            this.frameValue = null;
            if (this.stream == null)
            {
                return false;
            }
            if (this.stream.Position > this.lastTagPos)
            {
                return false;
            }
            this.frameId = this.ReadFrameId();
            int frameLength = this.ReadFrameLength();
            if (frameLength == 0)
            {
                return false;
            }
            this.ReadFrameFlags();
            this.frameValue = this.ReadFrameValue(frameLength);
            return true;
        }

        private short ReadFrameFlags()
        {
            int num = this.stream.ReadByte();
            int num2 = this.stream.ReadByte();
            return (short) ((num << 8) | num2);
        }

        private string ReadFrameId()
        {
            byte[] buffer = new byte[4];
            this.stream.Read(buffer, 0, 4);
            return Encoding.ASCII.GetString(buffer, 0, 4);
        }

        private int ReadFrameLength()
        {
            if (this.majorVersion == 4)
            {
                return this.ReadInt28();
            }
            if (this.majorVersion != 3)
            {
                throw new Exception("Don't know how to deal with this version.");
            }
            return this.ReadInt32();
        }

        private object ReadFrameValue(int frameLength)
        {
            byte[] buffer = new byte[frameLength];
            this.stream.Read(buffer, 0, frameLength);
            if (this.frameId[0] != 'T')
            {
                return buffer;
            }
            Encoding frameEncoding = this.GetFrameEncoding(buffer[0]);
            int index = 1;
            if ((buffer[0] == 1) && (frameLength > 3))
            {
                if ((buffer[1] == 0xfe) && (buffer[2] == 0xff))
                {
                    frameEncoding = Encoding.BigEndianUnicode;
                }
                else if ((buffer[1] == 0xff) && (buffer[2] == 0xfe))
                {
                    frameEncoding = Encoding.Unicode;
                }
            }
            return frameEncoding.GetString(buffer, index, frameLength - index).TrimEnd('\0');
        }

        private int ReadInt28()
        {
            byte[] buffer = new byte[4];
            this.stream.Read(buffer, 0, 4);
            if ((((buffer[0] & 0x80) != 0) || ((buffer[1] & 0x80) != 0)) || (((buffer[2] & 0x80) != 0) || ((buffer[3] & 0x80) != 0)))
            {
                throw new Exception("Found invalid syncsafe integer");
            }
            return ((((buffer[0] << 0x15) | (buffer[1] << 14)) | (buffer[2] << 7)) | buffer[3]);
        }

        private int ReadInt28(IntPtr p, int offset)
        {
            byte[] buffer = new byte[] { Marshal.ReadByte(p, offset), Marshal.ReadByte(p, offset + 1), Marshal.ReadByte(p, offset + 2), Marshal.ReadByte(p, offset + 3) };
            if ((((buffer[0] & 0x80) != 0) || ((buffer[1] & 0x80) != 0)) || (((buffer[2] & 0x80) != 0) || ((buffer[3] & 0x80) != 0)))
            {
                throw new Exception("Found invalid syncsafe integer");
            }
            return ((((buffer[0] << 0x15) | (buffer[1] << 14)) | (buffer[2] << 7)) | buffer[3]);
        }

        private int ReadInt32()
        {
            byte[] buffer = new byte[4];
            this.stream.Read(buffer, 0, 4);
            return ((((buffer[0] << 0x18) | (buffer[1] << 0x10)) | (buffer[2] << 8)) | buffer[3]);
        }

        private int ReadInt32(IntPtr p, int offset)
        {
            byte[] buffer = new byte[] { Marshal.ReadByte(p, offset), Marshal.ReadByte(p, offset + 1), Marshal.ReadByte(p, offset + 2), Marshal.ReadByte(p, offset + 3) };
            return ((((buffer[0] << 0x18) | (buffer[1] << 0x10)) | (buffer[2] << 8)) | buffer[3]);
        }

        private string ReadMagic(IntPtr p)
        {
            byte[] buffer = new byte[3];
            this.stream.Read(buffer, 0, 3);
            return Encoding.ASCII.GetString(buffer, 0, 3);
        }

        private string ReadTextZero(byte[] frameValue, ref int offset)
        {
            StringBuilder builder = new StringBuilder();
            try
            {
                char ch;
                while ((ch = (char) frameValue[offset]) != '\0')
                {
                    builder.Append(ch);
                    offset++;
                }
            }
            catch
            {
            }
            return builder.ToString();
        }

        private string ReadTextZero(byte[] frameValue, ref int offset, Encoding encoding)
        {
            string str = string.Empty;
            try
            {
                if (frameValue[0] == 1)
                {
                    if ((frameValue[offset] == 0xfe) && (frameValue[offset + 1] == 0xff))
                    {
                        encoding = Encoding.BigEndianUnicode;
                    }
                    else if ((frameValue[offset] == 0xff) && (frameValue[offset + 1] == 0xfe))
                    {
                        encoding = Encoding.Unicode;
                    }
                }
                int num = 1;
                if ((frameValue[0] == 1) || (frameValue[0] == 2))
                {
                    num = 2;
                }
                int index = offset;
                while (true)
                {
                    while (num == 1)
                    {
                        if (frameValue[index] == 0)
                        {
                            goto Label_008A;
                        }
                        index++;
                    }
                    if (num == 2)
                    {
                        if ((frameValue[index] == 0) && (frameValue[index + 1] == 0))
                        {
                            index++;
                            break;
                        }
                        index++;
                    }
                }
            Label_008A:
                str = encoding.GetString(frameValue, offset, ((index - offset) + 1) - num);
                offset = index;
            }
            catch
            {
            }
            return str;
        }

        public byte MajorVersion
        {
            get
            {
                return this.majorVersion;
            }
        }

        public byte MinorVersion
        {
            get
            {
                return this.minorVersion;
            }
        }
    }
}

