namespace Tags
{
    using System;
    using System.Collections;
    using System.IO;
    using System.Runtime.InteropServices;

    internal class WMFMetadataEditor
    {
        private IWMHeaderInfo3 HeaderInfo3 = null;

        public WMFMetadataEditor(IWMHeaderInfo3 headerInfo3)
        {
            this.HeaderInfo3 = headerInfo3;
        }

        public ArrayList GetAllPictures()
        {
            ArrayList list = null;
            ArrayList list2 = this.WMGetAllAttrib("WM/Picture");
            if ((list2 != null) && (list2.Count > 0))
            {
                list = new ArrayList(list2.Count);
                foreach (Tag tag in list2)
                {
                    TagPicture picture = this.GetPicture(tag);
                    if (picture != null)
                    {
                        list.Add(picture);
                    }
                }
            }
            return list;
        }

        private TagPicture GetPicture(Tag pTag)
        {
            TagPicture picture = null;
            string mimeType = "Unknown";
            TagPicture.PICTURE_TYPE unknown = TagPicture.PICTURE_TYPE.Unknown;
            string description = "";
            MemoryStream input = null;
            BinaryReader reader = null;
            if (pTag.Name == "WM/Picture")
            {
                try
                {
                    input = new MemoryStream((byte[]) pTag);
                    reader = new BinaryReader(input);
                    mimeType = Marshal.PtrToStringUni(new IntPtr(reader.ReadInt32()));
                    byte num = reader.ReadByte();
                    try
                    {
                        unknown = (TagPicture.PICTURE_TYPE) num;
                    }
                    catch
                    {
                        unknown = TagPicture.PICTURE_TYPE.Unknown;
                    }
                    description = Marshal.PtrToStringUni(new IntPtr(reader.ReadInt32()));
                    int length = reader.ReadInt32();
                    byte[] destination = new byte[length];
                    Marshal.Copy(new IntPtr(reader.ReadInt32()), destination, 0, length);
                    picture = new TagPicture(pTag.Index, mimeType, unknown, description, destination);
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
            return picture;
        }

        private ArrayList WMGetAllAttrib(string pAttribName)
        {
            ArrayList list = new ArrayList();
            try
            {
                if (!pAttribName.EndsWith("\0"))
                {
                    pAttribName = pAttribName + '\0';
                }
                ushort pwLangIndex = 0;
                ushort[] pwIndices = null;
                ushort pwCount = 0;
                this.HeaderInfo3.GetAttributeIndices(0, pAttribName, ref pwLangIndex, pwIndices, ref pwCount);
                ushort[] numArray2 = new ushort[pwCount];
                this.HeaderInfo3.GetAttributeIndices(0, pAttribName, ref pwLangIndex, numArray2, ref pwCount);
                if ((numArray2 == null) || (numArray2.Length <= 0))
                {
                    return list;
                }
                foreach (ushort num3 in numArray2)
                {
                    string pwszName = null;
                    object obj2 = null;
                    ushort pwNameLen = 0;
                    uint pdwDataLength = 0;
                    try
                    {
                        WMT_ATTR_DATATYPE wmt_attr_datatype;
                        this.HeaderInfo3.GetAttributeByIndexEx(0, num3, pwszName, ref pwNameLen, out wmt_attr_datatype, out pwLangIndex, IntPtr.Zero, ref pdwDataLength);
                        pwszName = new string('\0', pwNameLen);
                        switch (wmt_attr_datatype)
                        {
                            case WMT_ATTR_DATATYPE.WMT_TYPE_DWORD:
                            case WMT_ATTR_DATATYPE.WMT_TYPE_BOOL:
                                obj2 = 0;
                                break;

                            case WMT_ATTR_DATATYPE.WMT_TYPE_STRING:
                            case WMT_ATTR_DATATYPE.WMT_TYPE_BINARY:
                                obj2 = new byte[pdwDataLength];
                                break;

                            case WMT_ATTR_DATATYPE.WMT_TYPE_QWORD:
                                obj2 = (ulong) 0L;
                                break;

                            case WMT_ATTR_DATATYPE.WMT_TYPE_WORD:
                                obj2 = (ushort) 0;
                                break;

                            case WMT_ATTR_DATATYPE.WMT_TYPE_GUID:
                                obj2 = Guid.NewGuid();
                                break;

                            default:
                                throw new InvalidOperationException(string.Format("Not supported data type: {0}", wmt_attr_datatype.ToString()));
                        }
                        GCHandle handle = GCHandle.Alloc(obj2, GCHandleType.Pinned);
                        try
                        {
                            IntPtr pValue = handle.AddrOfPinnedObject();
                            this.HeaderInfo3.GetAttributeByIndexEx(0, num3, pwszName, ref pwNameLen, out wmt_attr_datatype, out pwLangIndex, pValue, ref pdwDataLength);
                            switch (wmt_attr_datatype)
                            {
                                case WMT_ATTR_DATATYPE.WMT_TYPE_STRING:
                                    obj2 = Marshal.PtrToStringUni(pValue);
                                    break;

                                case WMT_ATTR_DATATYPE.WMT_TYPE_BOOL:
                                    obj2 = ((uint) obj2) != 0;
                                    break;
                            }
                            list.Add(new Tag(num3, pwszName, wmt_attr_datatype, obj2));
                        }
                        finally
                        {
                            handle.Free();
                        }
                    }
                    catch
                    {
                    }
                }
            }
            catch
            {
            }
            return list;
        }

        private ushort[] WMGetAttribIndices(string pAttribName)
        {
            ushort[] pwIndices = null;
            try
            {
                if (!pAttribName.EndsWith("\0"))
                {
                    pAttribName = pAttribName + '\0';
                }
                ushort pwLangIndex = 0;
                ushort[] numArray2 = null;
                ushort pwCount = 0;
                this.HeaderInfo3.GetAttributeIndices(0, pAttribName, ref pwLangIndex, numArray2, ref pwCount);
                pwIndices = new ushort[pwCount];
                this.HeaderInfo3.GetAttributeIndices(0, pAttribName, ref pwLangIndex, pwIndices, ref pwCount);
            }
            catch
            {
                pwIndices = null;
            }
            return pwIndices;
        }
    }
}

