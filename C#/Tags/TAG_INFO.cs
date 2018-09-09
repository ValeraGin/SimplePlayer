namespace Tags
{
    using System;
    using System.Collections;
    using System.Drawing;
    using System.IO;
    using System.Runtime.InteropServices;
    using System.Text;

    public class TAG_INFO
    {
        public BASS_CHANNELINFO channelInfo;
        public string album;
        public string artist;
        public string comment;
        public string composer;
        public string copyright;
        public string encodedby;
        public string filename;
        public string genre;
        private ArrayList nativetags;
        private ArrayList pictures;
        public string publisher;
        public string title;
        public string track;
        public string year;

        public TAG_INFO()
        {
            this.title = string.Empty;
            this.artist = string.Empty;
            this.album = string.Empty;
            this.year = string.Empty;
            this.comment = string.Empty;
            this.genre = string.Empty;
            this.track = string.Empty;
            this.copyright = string.Empty;
            this.encodedby = string.Empty;
            this.composer = string.Empty;
            this.publisher = string.Empty;
            this.filename = string.Empty;
            this.pictures = new ArrayList();
            this.nativetags = new ArrayList();
        }

        public TAG_INFO(string FileName)
        {
            this.title = string.Empty;
            this.artist = string.Empty;
            this.album = string.Empty;
            this.year = string.Empty;
            this.comment = string.Empty;
            this.genre = string.Empty;
            this.track = string.Empty;
            this.copyright = string.Empty;
            this.encodedby = string.Empty;
            this.composer = string.Empty;
            this.publisher = string.Empty;
            this.filename = string.Empty;
            this.pictures = new ArrayList();
            this.nativetags = new ArrayList();
            this.filename = FileName;
            this.title = Path.GetFileName(FileName);
        }

        internal bool AddPicture(TagPicture tagPicture)
        {
            if (tagPicture == null)
            {
                return false;
            }
            bool flag = false;
            try
            {
                this.pictures.Add(tagPicture);
                flag = true;
            }
            catch
            {
            }
            return flag;
        }

        internal bool EvalTagEntry(string tagEntry)
        {
            string[] strArray2;
            int num;
            if (tagEntry == null)
            {
                return false;
            }
            bool flag = false;
            string s = string.Empty;
            string[] strArray = tagEntry.Split(new char[] { '=', ':' }, 2);
            if (strArray.Length == 2)
            {
                this.nativetags.Add(strArray[0].Trim() + "=" + strArray[1].Trim());
                switch (strArray[0].ToLower().Trim())
                {
                    case "IART":
                    case "tpe1":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.artist = s;
                            flag = true;
                        }
                        return flag;

                    case "trck":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.track = s;
                            flag = true;
                        }
                        return flag;

                    case "ICOP":
                    case "tcop":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.copyright = s;
                            flag = true;
                        }
                        return flag;

                    case "ISRF":
                    case "tool":
                    case "tenc":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.encodedby = s;
                            flag = true;
                        }
                        return flag;

                    case "INAM":
                    case "tit2":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.title = s;
                            flag = true;
                        }
                        return flag;

                    case "ICRD":
                    case "tyer":
                    case "tdrl":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.year = s;
                            flag = true;
                        }
                        return flag;

                    case "IGNR":
                    case "tcon":
                        s = strArray[1].Trim();
                        if (!(s != string.Empty))
                        {
                            return flag;
                        }
                        strArray2 = s.Split(new char[1]);
                        if ((strArray2 == null) || (strArray2.Length <= 0))
                        {
                            this.genre = s;
                            goto Label_07BC;
                        }
                        num = 0;
                        goto Label_0798;

                    case "ISRC":
                    case "tpub":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.publisher = s;
                            flag = true;
                        }
                        return flag;

                    case "ICMT":
                    case "tcom":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.comment = s;
                            flag = true;
                        }
                        return flag;

                    case "IPRD":
                    case "talb":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.album = s;
                            flag = true;
                        }
                        return flag;

                    case "title":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.title = s;
                            flag = true;
                        }
                        return flag;

                    case "streamtitle":
                    {
                        s = strArray[1].Trim(new char[] { '\'', '"' });
                        if (!(s != string.Empty))
                        {
                            return flag;
                        }
                        int index = s.IndexOf("-");
                        if ((index <= 0) || ((index + 1) >= s.Length))
                        {
                            this.title = s;
                        }
                        else
                        {
                            this.artist = s.Substring(0, index).Trim();
                            this.title = s.Substring(index + 1).Trim();
                        }
                        return true;
                    }
                    case "streamurl":
                        s = strArray[1].Trim(new char[] { '\'', '"' });
                        if (s != string.Empty)
                        {
                            this.comment = s;
                            flag = true;
                        }
                        return flag;

                    case "artist":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.artist = s;
                            flag = true;
                        }
                        return flag;

                    case "album":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.album = s;
                            flag = true;
                        }
                        return flag;

                    case "comment":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.comment = s;
                            flag = true;
                        }
                        return flag;

                    case "year":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.year = s;
                            flag = true;
                        }
                        return flag;

                    case "date":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.year = s;
                            flag = true;
                        }
                        return flag;

                    case "genre":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.genre = s;
                            flag = true;
                        }
                        return flag;

                    case "author":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.artist = s;
                            flag = true;
                        }
                        return flag;

                    case "description":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.comment = s;
                            flag = true;
                        }
                        return flag;

                    case "wm/albumtitle":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.album = s;
                            flag = true;
                        }
                        return flag;

                    case "wm/genre":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.genre = s;
                            flag = true;
                        }
                        return flag;

                    case "wm/year":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.year = s;
                            flag = true;
                        }
                        return flag;

                    case "copyright":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.copyright = s;
                            flag = true;
                        }
                        return flag;

                    case "publisher":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.publisher = s;
                            flag = true;
                        }
                        return flag;

                    case "wm/publisher":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.publisher = s;
                            flag = true;
                        }
                        return flag;

                    case "wm/encodedby":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.encodedby = s;
                            flag = true;
                        }
                        return flag;

                    case "encodedby":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.encodedby = s;
                            flag = true;
                        }
                        return flag;

                    case "wm/composer":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.composer = s;
                            flag = true;
                        }
                        return flag;

                    case "IENG":
                    case "composer":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.composer = s;
                            flag = true;
                        }
                        return flag;

                    case "writer":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.composer = s;
                            flag = true;
                        }
                        return flag;

                    case "tracknumber":
                    case "track":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.track = s;
                            flag = true;
                        }
                        return flag;

                    case "wm/tracknumber":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.track = s;
                            flag = true;
                        }
                        return flag;

                    case "icy-name":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.album = s;
                            flag = true;
                        }
                        return flag;

                    case "icy-genre":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.genre = s;
                            flag = true;
                        }
                        return flag;

                    case "icy-url":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.comment = s;
                            flag = true;
                        }
                        return flag;

                    case "icy-br":
                        s = strArray[1].Trim();
                        if (s != string.Empty)
                        {
                            this.year = s;
                            flag = true;
                        }
                        return flag;
                }
            }
            return flag;
        Label_0792:
            num++;
        Label_0798:
            if (num < strArray2.Length)
            {
                string str2 = strArray2[num].Trim();
                switch (str2)
                {
                    case "RX":
                    case "(RX)":
                        strArray2[num] = "Remix";
                        goto Label_0792;

                    case "CR":
                    case "(CR)":
                        strArray2[num] = "Cover";
                        goto Label_0792;
                }
                if ((str2.IndexOf('(') < str2.LastIndexOf(')')) && (str2.Length > 2))
                {
                    int num2 = str2.IndexOf('(');
                    int num3 = str2.LastIndexOf(')');
                    s = str2.Substring(num2 + 1, (num3 - num2) - 1);
                    try
                    {
                        strArray2[num] = Enum.GetName(typeof(ID3v1Genre), int.Parse(s));
                        if (strArray2[num] == null)
                        {
                            strArray2[num] = str2;
                        }
                    }
                    catch
                    {
                        strArray2[num] = str2;
                    }
                }
                else
                {
                    strArray2[num] = str2;
                    if (str2.Length < 4)
                    {
                        bool flag2 = true;
                        foreach (char ch in str2)
                        {
                            if (!char.IsNumber(ch))
                            {
                                flag2 = false;
                                break;
                            }
                        }
                        if (flag2)
                        {
                            try
                            {
                                strArray2[num] = Enum.GetName(typeof(ID3v1Genre), int.Parse(str2));
                                if (strArray2[num] == null)
                                {
                                    strArray2[num] = str2;
                                }
                            }
                            catch
                            {
                            }
                        }
                    }
                }
                goto Label_0792;
            }
            this.genre = string.Join(", ", strArray2);
        Label_07BC:
            return true;
        }

        public string NativeTag(string tagname)
        {
            if (tagname != null)
            {
                try
                {
                    foreach (string str2 in this.nativetags)
                    {
                        if (str2.StartsWith(tagname))
                        {
                            string[] strArray = str2.Split(new char[] { '=', ':' }, 2);
                            if (strArray.Length == 2)
                            {
                                return strArray[1].Trim();
                            }
                        }
                    }
                    return null;
                }
                catch
                {
                }
            }
            return null;
        }

        public string PictureGetDescription(int i)
        {
            if ((i >= 0) && (i <= (this.PictureCount - 1)))
            {
                try
                {
                    TagPicture picture = this.pictures[i] as TagPicture;
                    return picture.Description;
                }
                catch
                {
                }
            }
            return null;
        }

        public Image PictureGetImage(int i)
        {
            if ((i >= 0) && (i <= (this.PictureCount - 1)))
            {
                try
                {
                    TagPicture picture = this.pictures[i] as TagPicture;
                    return picture.PictureImage;
                }
                catch
                {
                }
            }
            return null;
        }

        public string PictureGetType(int i)
        {
            if ((i >= 0) && (i <= (this.PictureCount - 1)))
            {
                try
                {
                    TagPicture picture = this.pictures[i] as TagPicture;
                    return picture.PictureType.ToString();
                }
                catch
                {
                }
            }
            return null;
        }

        public override string ToString()
        {
            if ((this.artist == string.Empty) && (this.title != string.Empty))
            {
                return this.title;
            }
            if ((this.artist != string.Empty) && (this.title == string.Empty))
            {
                return this.artist;
            }
            if ((this.artist != string.Empty) && (this.title != string.Empty))
            {
                return string.Format("{0} - {1}", this.artist, this.title);
            }
            return this.filename;
        }

        public bool UpdateFromMETA(int data, bool utf8)
        {
            if (data == 0)
            {
                return false;
            }
            bool flag = false;
            if (data != 0)
            {
                string str = null;
                bool flag2 = true;
                int num = 0;
                UTF8Encoding encoding = new UTF8Encoding();
                while (flag2)
                {
                    if (utf8)
                    {
                        IntPtr ptr = new IntPtr(data + num);

						// find the first NULL byte as the strings are 0 terminated.
						int length = 0;
						unsafe 
						{
							IntPtr p = new IntPtr(ptr.ToInt32());
							byte c = *((byte*) p.ToPointer());

							while (c != 0) 
							{
								p = new IntPtr(p.ToInt32() + 1);
								c = *((byte*) p.ToPointer());
							}
							length = p.ToInt32() - ptr.ToInt32();
						}
						byte[] destination = new byte[length];

                        Marshal.Copy(ptr, destination, 0, length);
                        num += length + 1;
                        str = encoding.GetString(destination);
                    }
                    else
                    {
                        str = Marshal.PtrToStringAnsi(new IntPtr(data + num));
                        num += str.Length + 1;
                    }
                    if (str.Length != 0)
                    {
                        string[] strArray = str.Split(new char[] { ';' });
                        if (strArray.Length > 0)
                        {
                            foreach (string str2 in strArray)
                            {
                                flag |= this.EvalTagEntry(str2);
                            }
                        }
                        if (str.StartsWith("StreamTitle"))
                        {
                            flag2 = false;
                        }
                    }
                    else
                    {
                        flag2 = false;
                    }
                }
            }
            return flag;
        }

        public string[] NativeTags
        {
            get
            {
                return (string[]) this.nativetags.ToArray(typeof(string));
            }
        }

        public int PictureCount
        {
            get
            {
                return this.pictures.Count;
            }
        }
    }
}

