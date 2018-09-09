namespace Tags
{
    using System;
    using System.Runtime.InteropServices;

    [StructLayout(LayoutKind.Sequential)]
    public class BASS_CHANNELINFO
    {
        public int freq = 0;
        public int chans = 0;
        public int flags = 0;
        public int ctype = 0;
        public int origres = 0;
        public int plugin = 0;
        public override string ToString()
        {
            string name = "unknown";
            try
            {
                name = Enum.GetName(typeof(BASSChannelType), this.ctype);
            }
            catch
            {
            }
            return string.Format("Type={0}, Frequency={1}, Channels={2}, OrigResolution={3}", new object[] { name, this.freq, this.chans, this.origres });
        }
    }
}

