namespace Tags
{
    using System;

    internal class Tag
    {
        private WMT_ATTR_DATATYPE _dataType;
        private int _index;
        private string _name;
        private object _value;

        public Tag(int index, string name, WMT_ATTR_DATATYPE type, object val)
        {
            this._index = index;
            this._name = name.TrimEnd(new char[1]);
            this._dataType = type;
            switch (type)
            {
                case WMT_ATTR_DATATYPE.WMT_TYPE_DWORD:
                    this._value = Convert.ToUInt32(val);
                    return;

                case WMT_ATTR_DATATYPE.WMT_TYPE_STRING:
                    this._value = Convert.ToString(val).Trim();
                    return;

                case WMT_ATTR_DATATYPE.WMT_TYPE_BINARY:
                    this._value = (byte[]) val;
                    return;

                case WMT_ATTR_DATATYPE.WMT_TYPE_BOOL:
                    this._value = Convert.ToBoolean(val);
                    return;

                case WMT_ATTR_DATATYPE.WMT_TYPE_QWORD:
                    this._value = Convert.ToUInt64(val);
                    return;

                case WMT_ATTR_DATATYPE.WMT_TYPE_WORD:
                    this._value = Convert.ToUInt16(val);
                    return;

                case WMT_ATTR_DATATYPE.WMT_TYPE_GUID:
                    this._value = (Guid) val;
                    return;
            }
            throw new ArgumentException("Invalid data type", "type");
        }

        public static explicit operator byte[](Tag tag)
        {
            if (tag._dataType != WMT_ATTR_DATATYPE.WMT_TYPE_BINARY)
            {
                throw new InvalidCastException();
            }
            return (byte[]) tag._value;
        }

        public static explicit operator string(Tag tag)
        {
            if (tag._dataType != WMT_ATTR_DATATYPE.WMT_TYPE_STRING)
            {
                throw new InvalidCastException();
            }
            return (string) tag._value;
        }

        public static explicit operator bool(Tag tag)
        {
            if (tag._dataType != WMT_ATTR_DATATYPE.WMT_TYPE_BOOL)
            {
                throw new InvalidCastException();
            }
            return (bool) tag._value;
        }

        public static explicit operator Guid(Tag tag)
        {
            if (tag._dataType != WMT_ATTR_DATATYPE.WMT_TYPE_GUID)
            {
                throw new InvalidCastException();
            }
            return (Guid) tag._value;
        }

        public static explicit operator int(Tag tag)
        {
            return (int) ((ulong) tag);
        }

        public static explicit operator long(Tag tag)
        {
            return (long) ((ulong) tag);
        }

        public static explicit operator ushort(Tag tag)
        {
            return (ushort) ((ulong) tag);
        }

        public static explicit operator uint(Tag tag)
        {
            return (uint) ((ulong) tag);
        }

        public static explicit operator ulong(Tag tag)
        {
            switch (tag._dataType)
            {
                case WMT_ATTR_DATATYPE.WMT_TYPE_QWORD:
                case WMT_ATTR_DATATYPE.WMT_TYPE_WORD:
                case WMT_ATTR_DATATYPE.WMT_TYPE_DWORD:
                    return (ulong) tag._value;
            }
            throw new InvalidCastException();
        }

        public override string ToString()
        {
            return string.Format("{0,2}. {1}={2}", this._index, this._name.StartsWith("WM/") ? this._name.Substring(3) : this._name, this.ValueAsString);
        }

        public WMT_ATTR_DATATYPE DataType
        {
            get
            {
                return this._dataType;
            }
        }

        public int Index
        {
            get
            {
                return this._index;
            }
        }

        public string Name
        {
            get
            {
                return this._name;
            }
        }

        public object Value
        {
            get
            {
                return this._value;
            }
            set
            {
                switch (this._dataType)
                {
                    case WMT_ATTR_DATATYPE.WMT_TYPE_DWORD:
                        this._value = (uint) value;
                        return;

                    case WMT_ATTR_DATATYPE.WMT_TYPE_STRING:
                        this._value = (string) value;
                        return;

                    case WMT_ATTR_DATATYPE.WMT_TYPE_BINARY:
                        this._value = (byte[]) value;
                        return;

                    case WMT_ATTR_DATATYPE.WMT_TYPE_BOOL:
                        this._value = (bool) value;
                        return;

                    case WMT_ATTR_DATATYPE.WMT_TYPE_QWORD:
                        this._value = (ulong) value;
                        return;

                    case WMT_ATTR_DATATYPE.WMT_TYPE_WORD:
                        this._value = (ushort) value;
                        return;

                    case WMT_ATTR_DATATYPE.WMT_TYPE_GUID:
                        this._value = (Guid) value;
                        return;
                }
            }
        }

        public string ValueAsString
        {
            get
            {
                string str = string.Empty;
                switch (this._dataType)
                {
                    case WMT_ATTR_DATATYPE.WMT_TYPE_DWORD:
                    {
                        uint num = (uint) this._value;
                        return num.ToString();
                    }
                    case WMT_ATTR_DATATYPE.WMT_TYPE_STRING:
                        return (string) this._value;

                    case WMT_ATTR_DATATYPE.WMT_TYPE_BINARY:
                    {
                        int length = ((byte[]) this._value).Length;
                        return ("[" + length.ToString() + " bytes]");
                    }
                    case WMT_ATTR_DATATYPE.WMT_TYPE_BOOL:
                    {
                        bool flag = (bool) this._value;
                        return flag.ToString();
                    }
                    case WMT_ATTR_DATATYPE.WMT_TYPE_QWORD:
                    {
                        ulong num3 = (ulong) this._value;
                        return num3.ToString();
                    }
                    case WMT_ATTR_DATATYPE.WMT_TYPE_WORD:
                    {
                        ushort num2 = (ushort) this._value;
                        return num2.ToString();
                    }
                    case WMT_ATTR_DATATYPE.WMT_TYPE_GUID:
                    {
                        Guid guid = (Guid) this._value;
                        return guid.ToString();
                    }
                }
                return str;
            }
        }
    }
}

