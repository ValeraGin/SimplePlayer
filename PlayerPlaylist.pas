unit PlayerPlaylist;

{$reference 'System.Windows.Forms.dll'}
{$reference 'System.Drawing.dll'}
{$reference 'System.Data.dll'}
{$reference 'System.Xml.dll'}

{$reference 'ControlsEx.dll'}


uses
  System,
  System.Runtime.Serialization,
  System.Collections.Generic,
  System.Data,
  System.Xml,
  System.IO,
  System.Drawing,
  System.Windows.Forms, 
  
  FSFormatProvider,
  SkinControls;

type
  
  
  LBoxData = class
  public 
    Title, SubTitle, Time: string;
    Rating: integer;
  end;
  
  
  // TODO: свойства сделать readonly
  PlaylistItem = class
  private 
    fFileName: string;
    fArtist: string;
    fTitle: string;
    fBitrate: integer;
    fDuration: real;
    fFrequency: integer;
    fFileSize: Int64;
    fRating: integer;
    fListBoxData: LBoxData;
  public 
    // Пришлось добавить set'еры для того, чтобы они сериализовались 
    public property FileName: string read fFileName write fFileName;
    public property Artist: string read fArtist write fArtist;
    public property Title: string read fTitle write fTitle;
    public property Bitrate: integer read fBitrate write fBitrate;
    public property Duration: real read fDuration write fDuration;
    public property Frequency: integer read  fFrequency write fFrequency;
    public property FileSize: Int64 read fFilesize write fFilesize;
    public property Rating: integer read fRating write fRating;
    public property ListBoxData: LBoxData read fListBoxData write fListBoxData;
    constructor(FileName: string; Artist: string; Title: string; Bitrate: integer; Frequency: integer; Duration: real; FileSize: Int64; Rating: integer := 0);
    begin
      fFileName := FileName;
      fArtist := Artist;
      fTitle := Title;
      fBitrate := Bitrate;
      fFrequency := Frequency;
      fDuration := Duration;
      fFileSize := FileSize;
      fRating := Rating;
      
      fListBoxData := new LBoxData;
      fListBoxData.Rating := 0;
      
      if fArtist <> string.Empty then 
        fListBoxData.Title := Format('{0} - {1}', fArtist, fTitle)
      else 
        fListBoxData.Title := Path.GetFileNameWithoutExtension(fFileName);
      
      fListBoxData.SubTitle := Format('{0} :: {1} kHz, {2} kbps {3}',
            Path.GetExtension(fFilename).Remove(0, 1).ToUpper,
            (fFrequency div 1000).ToString,
            fBitrate.ToString,
            String.Format(new FileSizeFormatProvider, '{0:fs1}', fFileSize)
            );
      
      fListBoxData.Time := PlaylistItem.FixTimespan(fDuration, 'mm:ss');
    end;
    
    class function FixTimespan(seconds: double; format: string): string;
    begin
      Result := (new DateTime(0)).AddSeconds(seconds).ToString(format);
    end;
  end;
  
  

  
   
  
  PlaylistManager = class 
  private 
    fListControl: ListControl;
    fCurrentPlaylist: integer;
    fPlaylists := new List<System.ComponentModel.BindingList<PlaylistItem>>;
    CManager: CurrencyManager;
    procedure SetCurrentPlaylist(value: integer);
    begin
      fCurrentPlaylist := value;
      fListControl.DataSource := fPlaylists[fCurrentPlaylist];
     // ((CurrencyManager)sideListBox1.BindingContext[_sideList]).Refresh();
    end;
  public 
    property Playlists: List<System.ComponentModel.BindingList<PlaylistItem>> read fPlaylists;
    property CurrentPlaylist: integer read fCurrentPlaylist write SetCurrentPlaylist;
    constructor(lc: ListControl);
    begin
      fListControl := lc;
    end;
  end;
  
  
  
  PlaylistLengthComparer = class(IComparer<PlaylistItem>)
    public function Compare(x, y: PlaylistItem): integer;
    begin
      result := x.Duration.CompareTo(y.Duration);
    end;
  end;
  
  PlaylistArtistComparer = class(IComparer<PlaylistItem>)
    public function Compare(x, y: PlaylistItem): integer;
    begin
      result := x.Artist.CompareTo(y.Artist);
    end;
  end;
  
  PlaylistDirectoryComparer = class(IComparer<PlaylistItem>)
    public function Compare(x, y: PlaylistItem): integer;
    begin
      result := x.FileName.CompareTo(y.FileName);
    end;
  end;
  
  PlaylistTitleComparer = class(IComparer<PlaylistItem>)
    public function Compare(x, y: PlaylistItem): integer;
    begin
      result := x.Title.CompareTo(y.Title);
    end;
  end;
  
  Playlist_ListBox = class(ControlEx.MyListBox)  
  private 
    randomList_ := new List<PlaylistItem>;
    
    playingIndex_ := 0;
    playingItem_ := new PlaylistItem;
    // backcolor стандартный 
    selectedcolor, playingcolor, playingselectedcolor, focuscolor: color;
    
    itemnormallinefont, itemnormalline2font: System.Drawing.Font;
    itemplayinglinefont, itemplayingline2font: System.Drawing.Font;
    itemselectedlinefont, itemselectedline2font: System.Drawing.Font;
    itemplayingselectedlinefont, itemplayingselectedline2font: System.Drawing.Font;
    
    itemnormallinecolor, itemplayinglinecolor, itemselectedlinecolor, itemplayingselectedlinecolor: Color;
    itemnormalline2color, itemplayingline2color, itemselectedline2color, itemplayingselectedline2color: Color;
    
    focusPen, focusPenInvert: Pen;
    focusPenColor: Color;
    function GetFocusPen(backColor, focusColor: Color;  odds: boolean): Pen;
    begin
      if ((focusPen = nil) or ((focusPenColor.GetBrightness() 
     	<= 0.5) and (backColor.GetBrightness() <= 0.5)) 
     	or not focusPenColor.Equals(backColor)) then
      begin
        if (focusPen <> nil) then
        begin
          focusPen.Dispose();
          focusPen := nil;
          focusPenInvert.Dispose();
          focusPenInvert := nil;
        end;
        
        focusPenColor := backColor;
        var bitmap := new Bitmap(2, 2);
        var color := System.Drawing.Color.Transparent;
        var color2 := focusColor;
        if (backColor.GetBrightness() <= 0.5) then
        begin
          color := color2;
          color2 := System.Drawing.Color.FromArgb(backColor.A, 255 - backColor.R, 255 - backColor.G, 255 - backColor.B); 
        end
      		else
        begin
          if (backColor = System.Drawing.Color.Transparent) then
          begin
            color := System.Drawing.Color.White;
          end;
        end;
        bitmap.SetPixel(1, 0, color2);
        bitmap.SetPixel(0, 1, color2);
        bitmap.SetPixel(0, 0, color);
        bitmap.SetPixel(1, 1, color);
        var brush := new TextureBrush(bitmap);
        focusPen := new Pen(brush, 1);
        brush.Dispose();
        bitmap.SetPixel(1, 0, color);
        bitmap.SetPixel(0, 1, color);
        bitmap.SetPixel(0, 0, color2);
        bitmap.SetPixel(1, 1, color2);
        brush := new TextureBrush(bitmap);
        focusPenInvert := new Pen(brush, 1);
        brush.Dispose();
        bitmap.Dispose();
      end;
      if not odds then
      begin
        result := focusPenInvert;
      end;
      result := focusPen;
    end;
    
    procedure PaintItem(sender: Object; e: DrawItemEventArgs);
    begin
      if e.Index = -1 then exit;
      
      var item := (self.Items[e.Index] as PlaylistItem);
      var g := e.Graphics;
      
      var ItemsBounds := e.Bounds; 
      ItemsBounds.Width -= 5; 
      
      var BC := BackColor;
      if ((e.state and DrawItemState.Selected) = DrawItemState.Selected) and (e.Index = self.PlayingIndex) then
        BC := playingselectedcolor
      else if (e.state and DrawItemState.Selected) = DrawItemState.Selected then
        BC := selectedcolor
      else if e.Index = self.PlayingIndex then
        BC := playingcolor;
      
      var brush := new SolidBrush(BC);
      g.FillRectangle(brush, ItemsBounds);
      brush.Dispose();
      
      var fontline1 := self.itemnormallinefont;
      var fontline2 := self.itemnormalline2font;
      var colorline1 := self.itemnormallinecolor;
      var colorline2 := self.itemnormalline2color;
      
      if (e.state and DrawItemState.Selected) = DrawItemState.Selected then
      begin
        var rect := ItemsBounds; rect.Width -= 1; rect.Height -= 1;
        g.DrawRectangle(GetFocusPen(self.BackColor, self.focuscolor, (ItemsBounds.X + ItemsBounds.Y) / 2 = 1), rect);
        fontline1 := self.itemselectedlinefont;
        fontline2 := self.itemselectedline2font;
        colorline1 := self.itemselectedlinecolor;
        colorline2 := self.itemselectedline2color;
      end;
      
      if e.Index = self.PlayingIndex then 
      begin
        fontline1 := self.itemplayinglinefont;
        fontline2 := self.itemplayingline2font;
        colorline1 := self.itemplayinglinecolor;
        colorline2 := self.itemplayingline2color;
      end;
      
      if (e.Index = self.PlayingIndex) and ((e.state and DrawItemState.Selected) = DrawItemState.Selected) then 
      begin
        fontline1 := self.itemplayingselectedlinefont;
        fontline2 := self.itemplayingselectedline2font;
        colorline1 := self.itemplayingselectedlinecolor;
        colorline2 := self.itemplayingselectedline2color;
      end;
      
      
      var format := new StringFormat(StringFormatFlags.NoWrap);
      
      var timesize := g.MeasureString(item.fListBoxData.Time, fontline1).ToSize;
      
      g.DrawString( string.Format('{0}. {1}', (e.Index + 1).ToString, item.fListBoxData.Title),
        fontline1,
        new SolidBrush(colorline1),
        new Rectangle(ItemsBounds.Left, ItemsBounds.Top, ItemsBounds.Width - timesize.Width, ItemsBounds.Height - 15), format);
      
      g.DrawString(item.fListBoxData.SubTitle, fontline2, new SolidBrush(colorline2), ItemsBounds.Left, ItemsBounds.Top + 15, format);
      
      g.DrawString(item.fListBoxData.Time, fontline1, new SolidBrush(colorline1), ItemsBounds.Width - timesize.Width, ItemsBounds.Top, format);
    end;
    
    procedure Measure(sender: Object; e: MeasureItemEventArgs);
    begin
      e.ItemHeight := 32;
    end;
    
    procedure MClick(sender: Object; e: System.EventArgs);
    begin
      if ItemClick <> nil then 
      begin
        var sel := (self.SelectedItem as PlaylistItem);
        if sel <> nil then
        begin
          ItemClick(sel);
        end;
      end;
    end;
    
    procedure KDown(sender: Object; e: KeyEventArgs);
    begin
      if ItemClick <> nil then 
      begin
        if Items.Count > 0 then
        begin
          if e.KeyCode = Keys.Enter then
          begin
            var sel := (self.SelectedItem as PlaylistItem);
            if sel <> nil then 
            begin
              ItemClick(sel);
            end;
          end;
        end;
      end;
    end;
    
    function IsItemVisible(i: integer): boolean;
    begin
      result := false;
      var theFirst := IndexFromPoint(new Point(0, 0));
      var theLast := IndexFromPoint(new Point(Width - 1, Height - 1));
      if theLast = -1 then
        theLast := Items.Count - 1;
      if (i >= theFirst) and (i < theLast) then
        result := true;
    end;
    
    procedure set_PlayingIndex(i: integer);
    begin
      if (self as ListBox).Items.Count = 0 then exit;
      if (playingIndex_ >= 0) then 
        Invalidate(GetItemRectangle(playingIndex_));
      playingIndex_ := i;
      if i > -1 then
        playingItem_ := PlaylistItem(Items[i]);
      if not IsItemVisible(i) then 
        self.TopIndex := i;
      if (playingIndex_ >= 0) then    
        Invalidate(GetItemRectangle(playingIndex_));
    end;
    
    procedure ListBox_ItemsChanged(sender: object; e: System.EventArgs);
    begin
      playingIndex_ := Items.IndexOf(playingItem_);
    end;
  
  public 
    property RandomList: List<PlaylistItem> read randomList_;
    
    constructor(
    backcolor, selectedcolor, playingcolor, playingselectedcolor, focuscolor, 
    itemnormallinecolor, itemplayinglinecolor, itemselectedlinecolor, itemplayingselectedlinecolor,
    itemnormalline2color, itemplayingline2color, itemselectedline2color, itemplayingselectedline2color: color;
    
    itemnormallinefont, itemnormalline2font,
    itemplayinglinefont, itemplayingline2font,
    itemselectedlinefont, itemselectedline2font,
    itemplayingselectedlinefont, itemplayingselectedline2font: System.Drawing.Font);
    
    begin
      SetStyle(ControlStyles.ResizeRedraw, true);
      SetStyle(ControlStyles.AllPaintingInWmPaint, true);
      SetStyle(ControlStyles.DoubleBuffer, true);
      
      self.BackColor := backcolor;
      self.SelectedColor := selectedcolor; self.ForeColor := selectedcolor;
      self.playingcolor := playingcolor;
      self.playingselectedcolor := playingselectedcolor;
      self.focusColor := focuscolor;
      
      self.itemnormallinecolor := itemnormallinecolor;
      self.itemplayinglinecolor := itemplayinglinecolor;
      self.itemselectedlinecolor := itemselectedlinecolor;
      self.itemplayingselectedlinecolor := itemplayingselectedlinecolor;
      
      self.itemnormalline2color := itemnormalline2color;
      self.itemplayingline2color := itemplayingline2color;
      self.itemselectedline2color := itemselectedline2color;
      self.itemplayingselectedline2color := itemplayingselectedline2color;
      
      self.itemnormallinefont := itemnormallinefont;
      self.itemnormalline2font := itemnormalline2font;
      self.itemplayinglinefont := itemplayinglinefont;
      self.itemplayingline2font := itemplayingline2font;
      self.itemselectedlinefont := itemselectedlinefont;
      self.itemselectedline2font := itemselectedline2font;
      self.itemplayingselectedlinefont := itemplayingselectedlinefont;
      self.itemplayingselectedline2font := itemplayingselectedline2font;
      
      self.BorderStyle := System.Windows.Forms.BorderStyle.None;
      self.ScrollAlwaysVisible := false;
      
      self.ItemsChanged += ListBox_ItemsChanged;
      
      self.DrawMode := System.Windows.Forms.DrawMode.OwnerDrawVariable;
      self.DrawItem += PaintItem;
      self.MeasureItem += Measure;
      
      self.KeyDown += KDown;
      self.DoubleClick += MClick;
    end;
    
    procedure CreateRandomList;
    begin
      foreach item: PlaylistItem in self.Items do
        randomList_.Add(item);
      
      Randomize(DateTime.Now.Millisecond);
      for var i := 0 to randomList_.Count - 1 do
      begin
        var randomNumber := PABCSystem.Random(randomList_.Count - 1);
        var t := randomList_[i];
        randomList_[i] := randomList_[randomNumber];
        randomList_[randomNumber] := t;
      end;  
    end;
    
    property PlayingIndex: integer read playingIndex_ write set_PlayingIndex;
    
    public event ItemClick: procedure(Item: PlaylistItem);
  end;
  
  
  PlaylistBox = class(Panel)
  private 
    procedure scrollBar_Scroll(sender: object; e: EventArgs);
    begin
      listBox_.TopIndex := scrollBar_.Value;
    end;
    
    procedure listBox_MouseWheel(sender: object; e: MouseEventArgs);
    begin
      scrollBar_.Value -=  e.Delta div 120;
      listBox_.TopIndex := scrollBar_.Value
    end;
    
    procedure listBox_SelectedIndexChanged(sender: object; e: System.EventArgs);
    begin
      scrollBar_.Value := listBox_.TopIndex;
    end;
    
    procedure ListBoxItemsChanged(sender: object; e: System.EventArgs);
    begin
      if listBox_.Items.Count = 0 then exit;
      scrollBar_.Minimum := 0;
      scrollBar_.Maximum := listBox_.Items.Count;
      scrollBar_.SmallChange := 1;
      scrollBar_.LargeChange := listBox_.Height div 32;
      scrollBar_.Value := listBox_.TopIndex;
    end;
  
  
  public 
    listBox_: Playlist_ListBox;
    scrollBar_: PlayerScrollbar;
    
    constructor(
      playlistScrollbarSkin, playlistScrollbarThumbSkin: Image;
      
      backcolor, selectedcolor, playingcolor, playingselectedcolor, focuscolor, 
      itemnormallinecolor, itemplayinglinecolor, itemselectedlinecolor, itemplayingselectedlinecolor,
      itemnormalline2color, itemplayingline2color, itemselectedline2color, itemplayingselectedline2color: color;
      
      itemnormallinefont, itemnormalline2font,
      itemplayinglinefont, itemplayingline2font,
      itemselectedlinefont, itemselectedline2font,
      itemplayingselectedlinefont, itemplayingselectedline2font: System.Drawing.Font);
    begin
      inherited Create;
      
      listBox_ := new Playlist_ListBox(
      backcolor, selectedcolor, playingcolor, playingselectedcolor, focuscolor, 
      itemnormallinecolor, itemplayinglinecolor, itemselectedlinecolor, itemplayingselectedlinecolor,
      itemnormalline2color, itemplayingline2color, itemselectedline2color, itemplayingselectedline2color,
      itemnormallinefont, itemnormalline2font,
      itemplayinglinefont, itemplayingline2font,
      itemselectedlinefont, itemselectedline2font,
      itemplayingselectedlinefont, itemplayingselectedline2font);
      listBox_.Dock := DockStyle.Fill;
      
      listBox_.MouseWheel += listBox_MouseWheel;
      listBox_.SelectedIndexChanged += listBox_SelectedIndexChanged;
      listBox_.Parent := self;
      
      listBox_.ItemsChanged += ListBoxItemsChanged;
      
      scrollBar_ := new PlayerScrollbar(playlistScrollbarThumbSkin);
      scrollBar_.Dock := DockStyle.Right;
      scrollBar_.BackgroundImage := playlistScrollbarSkin;
      scrollBar_.Width := playlistScrollbarSkin.Width;
      scrollBar_.Scroll += scrollBar_Scroll;
      scrollBar_.MouseWheel += listBox_MouseWheel;
      scrollBar_.Parent := self;
      
      Self.SizeChanged += ListBoxItemsChanged;
    end;
  end;


end.