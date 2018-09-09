namespace Tags
{
    using System;
    using System.Collections;
    using System.Runtime.InteropServices;

    public class BassTags
    {
        [DllImport(@"bass.dll", CharSet = CharSet.Auto)]
        private static extern bool BASS_ChannelGetInfo(int handle, [In, Out] BASS_CHANNELINFO info);

        [DllImport(@"basswma.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr BASS_WMA_GetWMObject(int handle);

        [DllImport(@"bass.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr BASS_ChannelGetTags(int handle, int tags);

        [DllImport(@"bass.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr BASS_ChannelGetTags(int handle, BASSTag tags);

        private BassTags()
        {
        }

        public static bool BASS_TAG_GetFromFile(int stream, TAG_INFO tags)
        {
            if ((stream == 0) || (tags == null))
            {
                return false;
            }
            bool flag = false;
            tags.channelInfo = new BASS_CHANNELINFO();
            if (BASS_ChannelGetInfo(stream, tags.channelInfo))
            {
                BASSTag tagType = BASSTag.BASS_TAG_UNKNOWN;
                IntPtr p = BASS_TAG_GetIntPtr(stream, tags.channelInfo, out tagType);
                if (p != IntPtr.Zero)
                {
                    switch (tagType)
                    {
                        case BASSTag.BASS_TAG_ID3:
                            return ReadID3v1(p, tags);

                        case BASSTag.BASS_TAG_ID3V2:
                            return ReadID3v2(p, tags);

                        case BASSTag.BASS_TAG_OGG:
                            return tags.UpdateFromMETA(p.ToInt32(), true);

                        case BASSTag.BASS_TAG_HTTP:
                        case BASSTag.BASS_TAG_ICY:
                        case BASSTag.BASS_TAG_META:
                            return flag;

                        case BASSTag.BASS_TAG_APE:
                            return tags.UpdateFromMETA(p.ToInt32(), false);

                        case BASSTag.BASS_TAG_MP4:
                            return tags.UpdateFromMETA(p.ToInt32(), false);

                        case BASSTag.BASS_TAG_WMA:
                            flag = tags.UpdateFromMETA(p.ToInt32(), true);
                            try
                            {
                                IntPtr pUnk = BASS_WMA_GetWMObject(stream);
                                if (!(pUnk != IntPtr.Zero))
                                {
                                    return flag;
                                }
                                IWMHeaderInfo3 objectForIUnknown = (IWMHeaderInfo3)Marshal.GetObjectForIUnknown(pUnk);
                                ArrayList allPictures = new WMFMetadataEditor(objectForIUnknown).GetAllPictures();
                                if (allPictures != null)
                                {
                                    foreach (TagPicture picture in allPictures)
                                    {
                                        tags.AddPicture(picture);
                                    }
                                }
                                objectForIUnknown = null;
                                GC.Collect();
                            }
                            catch
                            {
                            }
                            return flag;

                        case BASSTag.BASS_TAG_RIFF_INFO:
                            return tags.UpdateFromMETA(p.ToInt32(), false);

                        case BASSTag.BASS_TAG_MUSIC_NAME:
                            tags.title = BASS_ChannelGetMusicName(stream);
                            tags.artist = BASS_ChannelGetMusicMessage(stream);
                            return true;
                    }
                }
            }
            return flag;
        }

        private static string BASS_ChannelGetMusicMessage(int handle)
        {
            IntPtr ptr = BASS_ChannelGetTags(handle, BASSTag.BASS_TAG_MUSIC_MESSAGE);
            if (ptr != IntPtr.Zero)
            {
                return Marshal.PtrToStringAnsi(ptr);
            }
            return null;
        }

        private static string BASS_ChannelGetMusicName(int handle)
        {
            IntPtr ptr = BASS_ChannelGetTags(handle, BASSTag.BASS_TAG_MUSIC_NAME);
            if (ptr != IntPtr.Zero)
            {
                return Marshal.PtrToStringAnsi(ptr);
            }
            return null;
        }

        public static bool BASS_TAG_GetFromURL(int stream, TAG_INFO tags)
        {
            if ((stream == 0) || (tags == null))
            {
                return false;
            }
            bool flag = false;
            IntPtr ptr = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_ICY);
            if (ptr == IntPtr.Zero)
            {
                ptr = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_HTTP);
            }
            if (ptr != IntPtr.Zero)
            {
                flag = tags.UpdateFromMETA(ptr.ToInt32(), false);
            }
            ptr = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_META);
            if (ptr == IntPtr.Zero)
            {
                ptr = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_OGG);
            }
            if (ptr == IntPtr.Zero)
            {
                ptr = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_APE);
            }
            if (ptr == IntPtr.Zero)
            {
                ptr = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_WMA);
            }
            if (ptr != IntPtr.Zero)
            {
                flag = tags.UpdateFromMETA(ptr.ToInt32(), false);
            }
            return flag;
        }

        public static IntPtr BASS_TAG_GetIntPtr(int stream, BASS_CHANNELINFO info, out BASSTag tagType)
        {
            IntPtr zero = IntPtr.Zero;
            tagType = BASSTag.BASS_TAG_UNKNOWN;
            if ((stream == 0) || (info == null))
            {
                return zero;
            }
            int ctype = info.ctype;
            if ((ctype & (int)BASSChannelType.BASS_CTYPE_STREAM_WAV) > 0)
            {
                ctype = (int)BASSChannelType.BASS_CTYPE_STREAM_WAV;
            }
            BASSChannelType type = (BASSChannelType)ctype;
            switch (type)
            {
                case BASSChannelType.BASS_CTYPE_STREAM_WMA:
                case BASSChannelType.BASS_CTYPE_STREAM_WMA_MP3:
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_WMA);
                    tagType = BASSTag.BASS_TAG_WMA;
                    return zero;

                case BASSChannelType.BASS_CTYPE_STREAM_WINAMP:
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_ID3V2);
                    if (!(zero == IntPtr.Zero))
                    {
                        tagType = BASSTag.BASS_TAG_ID3V2;
                        return zero;
                    }
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_APE);
                    if (!(zero == IntPtr.Zero))
                    {
                        tagType = BASSTag.BASS_TAG_APE;
                        return zero;
                    }
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_OGG);
                    if (zero == IntPtr.Zero)
                    {
                        zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_ID3);
                        if (zero != IntPtr.Zero)
                        {
                            tagType = BASSTag.BASS_TAG_ID3;
                        }
                        return zero;
                    }
                    tagType = BASSTag.BASS_TAG_OGG;
                    return zero;

                case BASSChannelType.BASS_CTYPE_STREAM_OGG:
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_OGG);
                    if (!(zero == IntPtr.Zero))
                    {
                        tagType = BASSTag.BASS_TAG_OGG;
                        return zero;
                    }
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_APE);
                    tagType = BASSTag.BASS_TAG_APE;
                    return zero;

                case BASSChannelType.BASS_CTYPE_STREAM_MP1:
                case BASSChannelType.BASS_CTYPE_STREAM_MP2:
                case BASSChannelType.BASS_CTYPE_STREAM_MP3:
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_ID3V2);
                    if (!(zero == IntPtr.Zero))
                    {
                        tagType = BASSTag.BASS_TAG_ID3V2;
                        return zero;
                    }
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_ID3);
                    tagType = BASSTag.BASS_TAG_ID3;
                    return zero;

                case BASSChannelType.BASS_CTYPE_STREAM_AIFF:
                case BASSChannelType.BASS_CTYPE_STREAM_WAV_PCM:
                case BASSChannelType.BASS_CTYPE_STREAM_WAV_FLOAT:
                case BASSChannelType.BASS_CTYPE_STREAM_WAV:
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_RIFF_INFO);
                    if (zero != IntPtr.Zero)
                    {
                        tagType = BASSTag.BASS_TAG_RIFF_INFO;
                    }
                    return zero;

                case BASSChannelType.BASS_CTYPE_MUSIC_MO3:
                case BASSChannelType.BASS_CTYPE_MUSIC_MOD:
                case BASSChannelType.BASS_CTYPE_MUSIC_MTM:
                case BASSChannelType.BASS_CTYPE_MUSIC_S3M:
                case BASSChannelType.BASS_CTYPE_MUSIC_XM:
                case BASSChannelType.BASS_CTYPE_MUSIC_IT:
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_MUSIC_NAME);
                    if (zero != IntPtr.Zero)
                    {
                        tagType = BASSTag.BASS_TAG_MUSIC_NAME;
                    }
                    return zero;

                case BASSChannelType.BASS_CTYPE_STREAM_WV:
                case BASSChannelType.BASS_CTYPE_STREAM_WV_H:
                case BASSChannelType.BASS_CTYPE_STREAM_WV_L:
                case BASSChannelType.BASS_CTYPE_STREAM_WV_LH:
                case BASSChannelType.BASS_CTYPE_STREAM_OFR:
                case BASSChannelType.BASS_CTYPE_STREAM_APE:
                case BASSChannelType.BASS_CTYPE_STREAM_FLAC:
                case BASSChannelType.BASS_CTYPE_STREAM_SPX:
                case BASSChannelType.BASS_CTYPE_STREAM_MPC:
                case BASSChannelType.BASS_CTYPE_STREAM_TTA:
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_APE);
                    if (zero == IntPtr.Zero)
                    {
                        zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_OGG);
                        if (zero == IntPtr.Zero)
                        {
                            zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_ID3V2);
                            if (zero == IntPtr.Zero)
                            {
                                zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_ID3);
                                if (zero != IntPtr.Zero)
                                {
                                    tagType = BASSTag.BASS_TAG_ID3;
                                }
                                return zero;
                            }
                            tagType = BASSTag.BASS_TAG_ID3V2;
                            return zero;
                        }
                        tagType = BASSTag.BASS_TAG_OGG;
                        return zero;
                    }
                    tagType = BASSTag.BASS_TAG_APE;
                    return zero;

                case BASSChannelType.BASS_CTYPE_STREAM_ALAC:
                case BASSChannelType.BASS_CTYPE_STREAM_AAC:
                case BASSChannelType.BASS_CTYPE_STREAM_MP4:
                    zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_MP4);
                    if (zero == IntPtr.Zero)
                    {
                        zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_ID3V2);
                        if (zero == IntPtr.Zero)
                        {
                            zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_APE);
                            if (zero == IntPtr.Zero)
                            {
                                zero = BASS_ChannelGetTags(stream, BASSTag.BASS_TAG_OGG);
                                if (zero != IntPtr.Zero)
                                {
                                    tagType = BASSTag.BASS_TAG_OGG;
                                }
                                return zero;
                            }
                            tagType = BASSTag.BASS_TAG_APE;
                            return zero;
                        }
                        tagType = BASSTag.BASS_TAG_ID3V2;
                        return zero;
                    }
                    tagType = BASSTag.BASS_TAG_MP4;
                    return zero;
            }
            return IntPtr.Zero;
        }


        private static bool ReadID3v1(IntPtr p, TAG_INFO tags)
        {
            if ((p == IntPtr.Zero) || (tags == null))
            {
                return false;
            }

            if (Marshal.PtrToStringAnsi(p, 3) != "TAG")
            {
                return false;
            }
            p = new IntPtr(p.ToInt32() + 3);

            tags.title = Marshal.PtrToStringAuto(p).TrimEnd(new char[1]);
            int index = tags.title.IndexOf('\0');
            if (index > 0)
            {
                tags.title = tags.title.Substring(0, index);
            }
            p = new IntPtr(p.ToInt32() + 30);
            tags.artist = Marshal.PtrToStringAnsi(p, 30).TrimEnd(new char[1]);
            index = tags.artist.IndexOf('\0');
            if (index > 0)
            {
                tags.artist = tags.artist.Substring(0, index);
            }
            p = new IntPtr(p.ToInt32() + 30);
            tags.album = Marshal.PtrToStringAnsi(p, 30).TrimEnd(new char[1]);
            index = tags.album.IndexOf('\0');
            if (index > 0)
            {
                tags.album = tags.album.Substring(0, index);
            }
            p = new IntPtr(p.ToInt32() + 30);
            tags.year = Marshal.PtrToStringAnsi(p, 4).TrimEnd(new char[1]);
            index = tags.year.IndexOf('\0');
            if (index > 0)
            {
                tags.year = tags.year.Substring(0, index);
            }
            p = new IntPtr(p.ToInt32() + 4);
            tags.comment = Marshal.PtrToStringAnsi(p, 30).TrimEnd(new char[1]);
            index = tags.comment.IndexOf('\0');
            if (index > 0)
            {
                tags.comment = tags.comment.Substring(0, index);
            }
            p = new IntPtr(p.ToInt32() + 30);
            int num2 = Marshal.ReadByte(p);
            try
            {
                tags.genre = Enum.GetName(typeof(ID3v1Genre), num2);
            }
            catch
            {
                tags.genre = ID3v1Genre.Unknown.ToString();
            }
            return true;
        }

        private static bool ReadID3v2(IntPtr p, TAG_INFO tags)
        {
            if ((p == IntPtr.Zero) || (tags == null))
            {
                return false;
            }
            try
            {
                ID3v2Reader reader = new ID3v2Reader(p);
                while (reader.Read())
                {
                    string key = reader.GetKey();
                    object obj2 = reader.GetValue();
                    if (obj2 is string)
                    {
                        tags.EvalTagEntry(string.Format("{0}={1}", key, obj2));
                    }
                    else if ((key == "APIC") && (obj2 is byte[]))
                    {
                        TagPicture tagPicture = reader.GetPicture(obj2 as byte[], tags.PictureCount);
                        if (tagPicture != null)
                        {
                            tags.AddPicture(tagPicture);
                        }
                    }
                }
                reader.Close();
            }
            catch
            {
                return false;
            }
            return true;
        }
    }
}

