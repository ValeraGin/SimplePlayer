using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Text;

namespace BassWrapper
{
    public enum BASSAttribute
    {
        BASS_ATTRIB_CPU = 7,
        BASS_ATTRIB_EAXMIX = 4,
        BASS_ATTRIB_FREQ = 1,
        BASS_ATTRIB_MIDI_CHANS = 0x12002,
        BASS_ATTRIB_MIDI_CPU = 0x12001,
        BASS_ATTRIB_MIDI_PPQN = 0x12000,
        BASS_ATTRIB_MIDI_TRACK_VOL = 0x12100,
        BASS_ATTRIB_MIDI_VOICES = 0x12003,
        BASS_ATTRIB_MUSIC_AMPLIFY = 0x100,
        BASS_ATTRIB_MUSIC_BPM = 0x103,
        BASS_ATTRIB_MUSIC_PANSEP = 0x101,
        BASS_ATTRIB_MUSIC_PSCALER = 0x102,
        BASS_ATTRIB_MUSIC_SPEED = 260,
        BASS_ATTRIB_MUSIC_VOL_CHAN = 0x200,
        BASS_ATTRIB_MUSIC_VOL_GLOBAL = 0x105,
        BASS_ATTRIB_MUSIC_VOL_INST = 0x300,
        BASS_ATTRIB_NOBUFFER = 5,
        BASS_ATTRIB_PAN = 3,
        BASS_ATTRIB_REVERSE_DIR = 0x11000,
        BASS_ATTRIB_TEMPO = 0x10000,
        BASS_ATTRIB_TEMPO_FREQ = 0x10002,
        BASS_ATTRIB_TEMPO_OPTION_AA_FILTER_LENGTH = 0x10011,
        BASS_ATTRIB_TEMPO_OPTION_OVERLAP_MS = 0x10015,
        BASS_ATTRIB_TEMPO_OPTION_PREVENT_CLICK = 0x10016,
        BASS_ATTRIB_TEMPO_OPTION_SEEKWINDOW_MS = 0x10014,
        BASS_ATTRIB_TEMPO_OPTION_SEQUENCE_MS = 0x10013,
        BASS_ATTRIB_TEMPO_OPTION_USE_AA_FILTER = 0x10010,
        BASS_ATTRIB_TEMPO_OPTION_USE_QUICKALGO = 0x10012,
        BASS_ATTRIB_TEMPO_PITCH = 0x10001,
        BASS_ATTRIB_VOL = 2
    }


    [Flags]
    public enum BASSFlag
    {
        BASS_AAC_STEREO = 0x400000,
        BASS_AC3_DOWNMIX_2 = 0x200,
        BASS_AC3_DOWNMIX_4 = 0x400,
        BASS_AC3_DOWNMIX_DOLBY = 0x600,
        BASS_AC3_DYNAMIC_RANGE = 0x800,
        BASS_CD_SUBCHANNEL = 0x200,
        BASS_CD_SUBCHANNEL_NOHW = 0x400,
        BASS_DEFAULT = 0,
        BASS_MIXER_DOWNMIX = 0x400000,
        BASS_MIXER_MATRIX = 0x10000,
        BASS_SAMPLE_3D = 8,
        BASS_SAMPLE_8BITS = 1,
        BASS_SAMPLE_FLOAT = 0x100,
        BASS_SAMPLE_FX = 0x80,
        BASS_SAMPLE_LOOP = 4,
        BASS_SAMPLE_MONO = 2,
        BASS_SAMPLE_SOFTWARE = 0x10,
        BASS_SPEAKER_CENLFE = 0x3000000,
        BASS_SPEAKER_CENTER = 0x13000000,
        BASS_SPEAKER_FRONT = 0x1000000,
        BASS_SPEAKER_FRONTLEFT = 0x11000000,
        BASS_SPEAKER_FRONTRIGHT = 0x21000000,
        BASS_SPEAKER_LEFT = 0x10000000,
        BASS_SPEAKER_LFE = 0x23000000,
        BASS_SPEAKER_PAIR1 = 0x1000000,
        BASS_SPEAKER_PAIR10 = 0xa000000,
        BASS_SPEAKER_PAIR11 = 0xb000000,
        BASS_SPEAKER_PAIR12 = 0xc000000,
        BASS_SPEAKER_PAIR13 = 0xd000000,
        BASS_SPEAKER_PAIR14 = 0xe000000,
        BASS_SPEAKER_PAIR15 = 0xf000000,
        BASS_SPEAKER_PAIR2 = 0x2000000,
        BASS_SPEAKER_PAIR3 = 0x3000000,
        BASS_SPEAKER_PAIR4 = 0x4000000,
        BASS_SPEAKER_PAIR5 = 0x5000000,
        BASS_SPEAKER_PAIR6 = 0x6000000,
        BASS_SPEAKER_PAIR7 = 0x7000000,
        BASS_SPEAKER_PAIR8 = 0x8000000,
        BASS_SPEAKER_PAIR9 = 0x9000000,
        BASS_SPEAKER_REAR = 0x2000000,
        BASS_SPEAKER_REAR2 = 0x4000000,
        BASS_SPEAKER_REAR2LEFT = 0x14000000,
        BASS_SPEAKER_REAR2RIGHT = 0x24000000,
        BASS_SPEAKER_REARLEFT = 0x12000000,
        BASS_SPEAKER_REARRIGHT = 0x22000000,
        BASS_SPEAKER_RIGHT = 0x20000000,
        BASS_STREAM_AUTOFREE = 0x40000,
        BASS_STREAM_BLOCK = 0x100000,
        BASS_STREAM_DECODE = 0x200000,
        BASS_STREAM_PRESCAN = 0x20000,
        BASS_STREAM_RESTRATE = 0x80000,
        BASS_STREAM_STATUS = 0x800000,
        BASS_UNICODE = -2147483648,
        BASS_WINAMP_SYNC_BITRATE = 100,
        BASS_WV_STEREO = 0x400000
    }

    [Flags]
    public enum BASSInit
    {
        BASS_DEVICE_3D = 4,
        BASS_DEVICE_8BITS = 1,
        BASS_DEVICE_DEFAULT = 0,
        BASS_DEVICE_LATENCY = 0x100,
        BASS_DEVICE_MONO = 2,
        BASS_DEVICE_NOSPEAKER = 0x1000,
        BASS_DEVICE_SPEAKERS = 0x800
    }

    [Flags]
    public enum BASSData
    {
        BASS_DATA_AVAILABLE = 0,
        BASS_DATA_FFT_INDIVIDUAL = 0x10,
        BASS_DATA_FFT_NOWINDOW = 0x20,
        BASS_DATA_FFT_REMOVEDC = 0x40,
        BASS_DATA_FFT1024 = -2147483646,
        BASS_DATA_FFT16384 = -2147483642,
        BASS_DATA_FFT2048 = -2147483645,
        BASS_DATA_FFT256 = -2147483648,
        BASS_DATA_FFT4096 = -2147483644,
        BASS_DATA_FFT512 = -2147483647,
        BASS_DATA_FFT8192 = -2147483643,
        BASS_DATA_FLOAT = 0x40000000
    }
 


    public enum BASSErrorCode
    {
        BASS_ERROR_ACM_CANCEL = 0x7d0,
        BASS_ERROR_ALREADY = 14,
        BASS_ERROR_BUFLOST = 4,
        BASS_ERROR_CDTRACK = 13,
        BASS_ERROR_CODE = 0x2c,
        BASS_ERROR_CREATE = 0x21,
        BASS_ERROR_DECODE = 0x26,
        BASS_ERROR_DEVICE = 0x17,
        BASS_ERROR_DRIVER = 3,
        BASS_ERROR_DX = 0x27,
        BASS_ERROR_EMPTY = 0x1f,
        BASS_ERROR_FILEFORM = 0x29,
        BASS_ERROR_FILEOPEN = 2,
        BASS_ERROR_FORMAT = 6,
        BASS_ERROR_FREQ = 0x19,
        BASS_ERROR_HANDLE = 5,
        BASS_ERROR_ILLPARAM = 20,
        BASS_ERROR_ILLTYPE = 0x13,
        BASS_ERROR_INIT = 8,
        BASS_ERROR_MEM = 1,
        BASS_ERROR_NO3D = 0x15,
        BASS_ERROR_NOCD = 12,
        BASS_ERROR_NOCHAN = 0x12,
        BASS_ERROR_NOEAX = 0x16,
        BASS_ERROR_NOFX = 0x22,
        BASS_ERROR_NOHW = 0x1d,
        BASS_ERROR_NONET = 0x20,
        BASS_ERROR_NOPAUSE = 0x10,
        BASS_ERROR_NOPLAY = 0x18,
        BASS_ERROR_NOTAUDIO = 0x11,
        BASS_ERROR_NOTAVAIL = 0x25,
        BASS_ERROR_NOTFILE = 0x1b,
        BASS_ERROR_PLAYING = 0x23,
        BASS_ERROR_POSITION = 7,
        BASS_ERROR_SPEAKER = 0x2a,
        BASS_ERROR_START = 9,
        BASS_ERROR_TIMEOUT = 40,
        BASS_ERROR_UNKNOWN = -1,
        BASS_ERROR_VERSION = 0x2b,
        BASS_ERROR_WMA_CODEC = 0x3eb,
        BASS_ERROR_WMA_DENIED = 0x3ea,
        BASS_ERROR_WMA_INDIVIDUAL = 0x3ec,
        BASS_ERROR_WMA_LICENSE = 0x3e8,
        BASS_ERROR_WMA_WM9 = 0x3e9,
        BASS_FX_ERROR_BPMINUSE = 0x66,
        BASS_FX_ERROR_NODECODE = 100,
        BASS_FX_ERROR_STEREO = 0x65,
        BASS_OK = 0,
        BASS_VST_ERROR_NOINPUTS = 0xbb8,
        BASS_VST_ERROR_NOOUTPUTS = 0xbb9,
        BASS_VST_ERROR_NOREALTIME = 0xbba
    }

    [Flags]
    public enum BASSChannelType
    {
        BASS_CTYPE_MUSIC_IT = 0x20004,
        BASS_CTYPE_MUSIC_MO3 = 0x100,
        BASS_CTYPE_MUSIC_MOD = 0x20000,
        BASS_CTYPE_MUSIC_MTM = 0x20001,
        BASS_CTYPE_MUSIC_S3M = 0x20002,
        BASS_CTYPE_MUSIC_XM = 0x20003,
        BASS_CTYPE_RECORD = 2,
        BASS_CTYPE_SAMPLE = 1,
        BASS_CTYPE_STREAM = 0x10000,
        BASS_CTYPE_STREAM_AAC = 0x10b00,
        BASS_CTYPE_STREAM_AC3 = 0x11000,
        BASS_CTYPE_STREAM_AIFF = 0x10006,
        BASS_CTYPE_STREAM_ALAC = 0x10e00,
        BASS_CTYPE_STREAM_APE = 0x10700,
        BASS_CTYPE_STREAM_CD = 0x10200,
        BASS_CTYPE_STREAM_FLAC = 0x10900,
        BASS_CTYPE_STREAM_MP1 = 0x10003,
        BASS_CTYPE_STREAM_MP2 = 0x10004,
        BASS_CTYPE_STREAM_MP3 = 0x10005,
        BASS_CTYPE_STREAM_MP4 = 0x10b01,
        BASS_CTYPE_STREAM_MPC = 0x10a00,
        BASS_CTYPE_STREAM_OFR = 0x10600,
        BASS_CTYPE_STREAM_OGG = 0x10002,
        BASS_CTYPE_STREAM_SPX = 0x10c00,
        BASS_CTYPE_STREAM_TTA = 0x10f00,
        BASS_CTYPE_STREAM_WAV = 0x40000,
        BASS_CTYPE_STREAM_WAV_FLOAT = 0x50003,
        BASS_CTYPE_STREAM_WAV_PCM = 0x50001,
        BASS_CTYPE_STREAM_WINAMP = 0x10400,
        BASS_CTYPE_STREAM_WMA = 0x10300,
        BASS_CTYPE_STREAM_WMA_MP3 = 0x10301,
        BASS_CTYPE_STREAM_WV = 0x10500,
        BASS_CTYPE_STREAM_WV_H = 0x10501,
        BASS_CTYPE_STREAM_WV_L = 0x10502,
        BASS_CTYPE_STREAM_WV_LH = 0x10503,
        BASS_CTYPE_UNKNOWN = 0
    }

    [Flags]
    public enum BASSMode
    {
        BASS_MIDI_DECAYSEEK = 0x4000,
        BASS_MIXER_NORAMPIN = 0x800000,
        BASS_MUSIC_POSRESET = 0x8000,
        BASS_MUSIC_POSRESETEX = 0x400000,
        BASS_POS_BYTES = 0,
        BASS_POS_DECODE = 0x10000000,
        BASS_POS_DECODETO = 0x20000000,
        BASS_POS_MIDI_TICK = 2,
        BASS_POS_MUSIC_ORDERS = 1
    }

    [Flags]
    public enum BASSSync
    {
        BASS_SYNC_CD_ERROR = 0x3e8,
        BASS_SYNC_CD_SPEED = 0x3ea,
        BASS_SYNC_DOWNLOAD = 7,
        BASS_SYNC_END = 2,
        BASS_SYNC_FREE = 8,
        BASS_SYNC_META = 4,
        BASS_SYNC_MIDI_CUE = 0x10001,
        BASS_SYNC_MIDI_EVENT = 0x10004,
        BASS_SYNC_MIDI_KEYSIG = 0x10007,
        BASS_SYNC_MIDI_LYRIC = 0x10002,
        BASS_SYNC_MIDI_MARKER = 0x10000,
        BASS_SYNC_MIDI_TEXT = 0x10003,
        BASS_SYNC_MIDI_TICK = 0x10005,
        BASS_SYNC_MIDI_TIMESIG = 0x10006,
        BASS_SYNC_MIXER_ENVELOPE = 0x10200,
        BASS_SYNC_MIXER_ENVELOPE_NODE = 0x10201,
        BASS_SYNC_MIXTIME = 0x40000000,
        BASS_SYNC_MUSICFX = 3,
        BASS_SYNC_MUSICINST = 1,
        BASS_SYNC_MUSICPOS = 10,
        BASS_SYNC_OGG_CHANGE = 12,
        BASS_SYNC_ONETIME = -2147483648,
        BASS_SYNC_POS = 0,
        BASS_SYNC_SETPOS = 11,
        BASS_SYNC_SLIDE = 5,
        BASS_SYNC_STALL = 6,
        BASS_SYNC_WMA_CHANGE = 0x10100,
        BASS_SYNC_WMA_META = 0x10101,
        BASS_WINAMP_SYNC_BITRATE = 100
    }

    [StructLayout(LayoutKind.Sequential)]
    public class BASS_PLUGINFORM
    {
        public int ctype;
        [MarshalAs(UnmanagedType.LPStr)]
        public string name;
        [MarshalAs(UnmanagedType.LPStr)]
        public string exts;
        public BASS_PLUGINFORM()
        {
            this.ctype = 0;
            this.name = string.Empty;
            this.exts = string.Empty;
        }

        public BASS_PLUGINFORM(string Name, string Extensions, int ChannelType)
        {
            this.ctype = 0;
            this.name = string.Empty;
            this.exts = string.Empty;
            this.ctype = ChannelType;
            this.name = Name;
            this.exts = Extensions;
        }

        public BASS_PLUGINFORM(string Name, string Extensions, BASSChannelType ChannelType)
        {
            this.ctype = 0;
            this.name = string.Empty;
            this.exts = string.Empty;
            this.ctype = (int)ChannelType;
            this.name = Name;
            this.exts = Extensions;
        }

        public override string ToString()
        {
            return string.Format("{0}|{1}", this.name, this.exts);
        }

        public BASSChannelType ChannelType
        {
            get
            {
                try
                {
                    return (BASSChannelType)this.ctype;
                }
                catch
                {
                    return BASSChannelType.BASS_CTYPE_UNKNOWN;
                }
            }
        }
    }

    public class BASS_PLUGININFO
    {
        // Fields
        public int formatc;
        public BASS_PLUGINFORM[] formats;
        public int version;

        // Methods
        private BASS_PLUGININFO()
        {
            this.version = 0;
            this.formatc = 0;
            this.formats = null;
        }

        public BASS_PLUGININFO(IntPtr pluginInfoPtr)
        {
            this.version = 0;
            this.formatc = 0;
            this.formats = null;
            if (pluginInfoPtr != IntPtr.Zero)
            {
                bass_plugininfo _plugininfo = (bass_plugininfo)Marshal.PtrToStructure(pluginInfoPtr, typeof(bass_plugininfo));
                if (_plugininfo != null)
                {
                    this.version = _plugininfo.version;
                    this.formatc = _plugininfo.formatc;
                    this.formats = new BASS_PLUGINFORM[this.formatc];
                    this.ReadArrayStructure(this.formatc, _plugininfo.formats);
                }
            }
        }

        internal BASS_PLUGININFO(int Version, BASS_PLUGINFORM[] Formats)
        {
            this.version = 0;
            this.formatc = 0;
            this.formats = null;
            this.version = Version;
            this.formatc = Formats.Length;
            this.formats = Formats;
        }

        internal BASS_PLUGININFO(int ver, int count, IntPtr fPtr)
        {
            this.version = 0;
            this.formatc = 0;
            this.formats = null;
            this.version = ver;
            this.formatc = count;
            if (fPtr != IntPtr.Zero)
            {
                this.formats = new BASS_PLUGINFORM[count];
                this.ReadArrayStructure(this.formatc, fPtr);
            }
        }

        private void ReadArrayStructure(int count, IntPtr p)
        {
            for (int i = 0; i < count; i++)
            {
                this.formats[i] = (BASS_PLUGINFORM)Marshal.PtrToStructure(p, typeof(BASS_PLUGINFORM));
                p = new IntPtr(p.ToInt32() + Marshal.SizeOf(this.formats[i]));
            }
        }

        public override string ToString()
        {
            return string.Format("{0}, {1}", this.version, this.formatc);
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    public class bass_plugininfo
    {
        public int version = 0;
        public int formatc = 0;
        public IntPtr formats = IntPtr.Zero;
    }

    [StructLayout(LayoutKind.Sequential)]
    public class BASS_INFO
    {
        public int flags = 0;
        public int hwsize = 0;
        public int hwfree = 0;
        public int freesam = 0;
        public int free3d = 0;
        public int minrate = 0;
        public int maxrate = 0;
        [MarshalAs(UnmanagedType.Bool)]
        public bool eax = false;
        public int minbuf = 500;
        public int dsver = 0;
        public int latency = 0;
        public int initflags = 0;
        public int speakers = 0;
        [MarshalAs(UnmanagedType.LPStr)]
        public string driver = string.Empty;
        public int freq = 0;
        public override string ToString()
        {
            return string.Format("Driver={0}, Speakers={1}, MinRate={2}, MaxRate={3}, DX={4}, EAX={5}", new object[] { this.driver, this.speakers, this.minrate, this.maxrate, this.dsver, this.eax });
        }

        public bool SupportsContinuousRate
        {
            get
            {
                return ((this.flags & 0x10) != 0);
            }
        }
        public bool SupportsDirectSound
        {
            get
            {
                return ((this.flags & 0x20) == 0);
            }
        }
        public bool IsCertified
        {
            get
            {
                return ((this.flags & 0x40) != 0);
            }
        }
        public bool SupportsMonoSamples
        {
            get
            {
                return ((this.flags & 0x100) != 0);
            }
        }
        public bool SupportsStereoSamples
        {
            get
            {
                return ((this.flags & 0x200) != 0);
            }
        }
        public bool Supports8BitSamples
        {
            get
            {
                return ((this.flags & 0x400) != 0);
            }
        }
        public bool Supports16BitSamples
        {
            get
            {
                return ((this.flags & 0x800) != 0);
            }
        }
    }

    public enum BASSStreamFilePosition
    {
        BASS_FILEPOS_BUFFER = 5,
        BASS_FILEPOS_CONNECTED = 4,
        BASS_FILEPOS_CURRENT = 0,
        BASS_FILEPOS_DOWNLOAD = 1,
        BASS_FILEPOS_END = 2,
        BASS_FILEPOS_START = 3,
        BASS_FILEPOS_WMA_BUFFER = 0x3e8
    }


    public enum BASSActive
    {
        BASS_ACTIVE_STOPPED,
        BASS_ACTIVE_PLAYING,
        BASS_ACTIVE_STALLED,
        BASS_ACTIVE_PAUSED
    }

    public delegate void SYNCPROC(int handle, int channel, int data, IntPtr user);

    public class Bass
    {

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_PluginFree(int handle);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern int BASS_PluginLoad(string file, int flags);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_Init(int device, int freq, int flags, IntPtr win, [MarshalAs(UnmanagedType.AsAny)] object clsid);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_Free();

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_Stop();

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern int BASS_StreamCreateFile(bool mem, [MarshalAs(UnmanagedType.LPWStr)] string file, System.Int64 offset, System.Int64 length, BASSFlag flags);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_ChannelPlay(int handle, [MarshalAs(UnmanagedType.Bool)] bool restart);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_ChannelPause(int handle);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_ChannelStop(int handle);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_StreamFree(int handle);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern int BASS_ErrorGetCode();

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern int BASS_GetVersion();

        [DllImport("bass.dll", EntryPoint = "BASS_PluginGetInfo", CharSet = CharSet.Auto)]
        private static extern bass_plugininfo BASS_PluginGetInfoStruct(int handle);

        public static BASS_PLUGININFO BASS_PluginGetInfo(int handle)
        {
            if (handle != 0)
            {
                bass_plugininfo _plugininfo = BASS_PluginGetInfoStruct(handle);
                if (_plugininfo != null)
                {
                    return new BASS_PLUGININFO(_plugininfo.version, _plugininfo.formatc, _plugininfo.formats);
                }
                return null;
            }
            return new BASS_PLUGININFO(BASS_GetVersion(), new BASS_PLUGINFORM[] { new BASS_PLUGINFORM("WAVE Audio", "*.wav", BASSChannelType.BASS_CTYPE_STREAM_WAV), new BASS_PLUGINFORM("Ogg Vorbis", "*.ogg", BASSChannelType.BASS_CTYPE_STREAM_OGG), new BASS_PLUGINFORM("MPEG layer 1", "*.mp1", BASSChannelType.BASS_CTYPE_STREAM_MP1), new BASS_PLUGINFORM("MPEG layer 2", "*.mp2", BASSChannelType.BASS_CTYPE_STREAM_MP2), new BASS_PLUGINFORM("MPEG layer 3", "*.mp3", BASSChannelType.BASS_CTYPE_STREAM_MP3), new BASS_PLUGINFORM("Audio IFF", "*.aif", BASSChannelType.BASS_CTYPE_STREAM_AIFF) });
        }

        public static string BASSAddOnGetPluginFileFilter(IList plugins, string allFormatName)
        {
            return BASSAddOnGetPluginFileFilter(plugins, allFormatName, true);
        }

        public static string[] BASSAddOnGetPluginFileExt(IList plugins, bool includeBASS)
        {
            ArrayList extensions = new ArrayList();
            if (includeBASS)
            {
                foreach (BASS_PLUGINFORM bass_pluginform in BASS_PluginGetInfo(0).formats)
                {
                    extensions.Add(bass_pluginform.exts);
                }
            }
            if (plugins != null)
            {
                foreach (int num in plugins)
                {
                    foreach (BASS_PLUGINFORM bass_pluginform in BASS_PluginGetInfo(num).formats)
                    {
                        extensions.Add(bass_pluginform.exts);
                    }
                }
            }
            return (string[])extensions.ToArray(typeof(string));
        }

        public static string BASSAddOnGetPluginFileFilter(IList plugins, string allFormatName, bool includeBASS)
        {
            string name = string.Empty;
            string exts = string.Empty;
            StringBuilder builder = new StringBuilder();
            StringBuilder builder2 = new StringBuilder();
            if (includeBASS)
            {
                foreach (BASS_PLUGINFORM bass_pluginform in BASS_PluginGetInfo(0).formats)
                {
                    name = bass_pluginform.name;
                    exts = bass_pluginform.exts;
                    builder.Append("|" + name + "|" + exts);
                    builder2.Append(";" + exts);
                }
            }
            if (plugins != null)
            {
                foreach (int num in plugins)
                {
                    foreach (BASS_PLUGINFORM bass_pluginform2 in BASS_PluginGetInfo(num).formats)
                    {
                        name = bass_pluginform2.name;
                        exts = bass_pluginform2.exts;
                        builder.Append("|" + name + "|" + exts);
                        builder2.Append(";" + exts);
                    }
                }
            }
            if ((allFormatName != string.Empty) && (allFormatName != null))
            {
                builder.Insert(0, allFormatName + "|" + builder2.ToString() + "|");
            }
            if (builder[0] == '|')
            {
                builder.Remove(0, 1);
            }
            return builder.ToString();
        }
        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern int BASS_ChannelSetSync(int handle, BASSSync type, long param, SYNCPROC proc, IntPtr user);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_GetInfo([In, Out] BASS_INFO info);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern long BASS_ChannelSeconds2Bytes(int handle, double pos);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern double BASS_ChannelBytes2Seconds(int handle, long pos);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern BASSActive BASS_ChannelIsActive(int handle);


        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern long BASS_ChannelGetPosition(int handle, BASSMode mode);
        public static long BASS_ChannelGetPosition(int handle)
        {
            return BASS_ChannelGetPosition(handle, BASSMode.BASS_POS_BYTES);
        }

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_ChannelSetPosition(int handle, long pos, BASSMode mode);
        public static bool BASS_ChannelSetPosition(int handle, long pos)
        {
            return BASS_ChannelSetPosition(handle, pos, BASSMode.BASS_POS_BYTES);
        }

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern long BASS_ChannelGetLength(int handle, BASSMode mode);
        public static long BASS_ChannelGetLength(int handle)
        {
            return BASS_ChannelGetLength(handle, BASSMode.BASS_POS_BYTES);
        }

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern long BASS_StreamGetFilePosition(int handle, BASSStreamFilePosition mode);
   
        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_ChannelGetAttribute(int handle, BASSAttribute attrib, ref float value);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern bool BASS_ChannelSetAttribute(int handle, BASSAttribute attrib, float value);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern int BASS_ChannelGetData(int handle, [In, Out] byte[] buffer, int length);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern int BASS_ChannelGetData(int handle, [In, Out] short[] buffer, int length);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern int BASS_ChannelGetData(int handle, [In, Out] int[] buffer, int length);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern int BASS_ChannelGetData(int handle, IntPtr buffer, int length);

        [DllImport("bass.dll", CharSet = CharSet.Auto)]
        public static extern int BASS_ChannelGetData(int handle, [In, Out] float[] buffer, int length);


    }
}
