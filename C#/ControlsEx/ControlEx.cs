using System;
using System.ComponentModel;
using System.Windows.Forms;

namespace ControlEx
{
    public class MyListBox : ListBox
    {
        private const int LB_ADDSTRING = 0x180;
        private const int LB_INSERTSTRING = 0x181;
        private const int LB_DELETESTRING = 0x182;
        private const int LB_RESETCONTENT = 0x184;

        protected override void WndProc(ref Message m)
        {
            if (m.Msg == LB_ADDSTRING ||
                    m.Msg == LB_INSERTSTRING ||
                    m.Msg == LB_DELETESTRING ||
                    m.Msg == LB_RESETCONTENT)
            {
                ItemsChanged(this, EventArgs.Empty);
            }
            base.WndProc(ref m);
        }

        private bool mShowScroll;
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                if (!mShowScroll) cp.Style &= ~0x200000;  // Turn off WS_VSCROLL
                return cp;
            }
        }

        [DefaultValue(false)]
        public bool ShowScrollbar
        {
            get { return mShowScroll; }
            set
            {
                if (value == mShowScroll) return;
                mShowScroll = value;
                if (this.Handle != IntPtr.Zero) RecreateHandle();
            }
        }
        public event EventHandler ItemsChanged = delegate { };
    }
}