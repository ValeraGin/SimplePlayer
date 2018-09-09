unit SkinManager;

{$reference 'System.Windows.Forms.dll'}
{$reference 'System.Drawing.dll'}
{$reference 'System.Data.dll'}
{$reference 'System.Xml.dll'}

uses
  System,
  System.IO,
  System.Xml,
  System.Data,
  System.Drawing,
  System.Windows.Forms,
  System.Collections.Generic,
  
  PlayerPlaylist,
  SkinControls,
  RunningStringUnit,
  PlayerTabs;

/// Перемешивание элементов списка алгоритмом Фишера-Ятеса 
/// http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
procedure ShuffleList<T>(list: IList<T>);
begin
  var r := new System.Random();  
  var n := list.Count;  
  while (n > 1) do
  begin
    n -= 1;  
    var k := r.Next(n + 1);  
    var value := list[k];  
    list[k] := list[n];  
    list[n] := value;  
  end;  
end;

procedure AddToDict<T>(dict: Dictionary<string, List<T>>; id: string; obj: T);
begin
  if dict.ContainsKey(id) then 
    dict[id].Add(obj)
      else
  begin
    var newList := new List<T>; newList.Add(obj);
    dict.Add(id, newList);
  end;
end;

type
  StickyForm = class(Form)
    class StickyGap := 20;
    class StickyForms: List<StickyForm>;
  private 
  public 
    MainForm: boolean;
    // for non MainForm
    StickyOwner: StickyForm;
    // for MainForm
    StickedForms := new List<StickyForm>;
    
    procedure AddStickedForm(f: StickyForm);
    begin
      if MainForm and not StickedForms.Contains(f) then 
      begin
        f.StickyOwner := self;
        StickedForms.Add(f);
      end;
    end;
    
    procedure DeleteStickedForm(f: StickyForm);
    begin
      if MainForm and StickedForms.Contains(f) then 
      begin
        f.StickyOwner := nil;
        StickedForms.Remove(f);
      end;
    end;
    
    constructor;
    begin
      inherited Create;
      if StickyForm.StickyForms = nil then StickyForm.StickyForms := new List<StickyForm>;
      StickyForm.StickyForms.Add(self);
    end;
  end;
  
  TabInfo = class
  public 
    TabName: string;
    PlaylistFilename: string;
    constructor(TabName, PlaylistFilename: string);
    begin
      self.TabName := TabName;
      self.PlaylistFilename := PlaylistFilename;
    end;
  end;
  
  
  
  
  
  
  ClickProc = procedure();
  ChangePosFunc = function(percent: real; ma: MouseAction): real;
  ChangeTextProc = procedure(text: string);
  
  SkinForm = class(StickyForm) 
  private 
    HorizontalAlignmentTC := System.ComponentModel.TypeDescriptor.GetConverter(typeof(HorizontalAlignment));
    FontTC := System.ComponentModel.TypeDescriptor.GetConverter(typeof(System.Drawing.Font));
    SizeTC := System.ComponentModel.TypeDescriptor.GetConverter(typeof(System.Drawing.Size));
    DockStyleTC := System.ComponentModel.TypeDescriptor.GetConverter(typeof(DockStyle));
    ColorTC := System.ComponentModel.TypeDescriptor.GetConverter(typeof(System.Drawing.Color));
    PointTC := System.ComponentModel.TypeDescriptor.GetConverter(typeof(Point));
    RectTC := System.ComponentModel.TypeDescriptor.GetConverter(typeof(Rectangle));
    
    
    DisplaysText: Dictionary<string, List<&Label>>;
    Sliders: Dictionary<string, List<PlayerSlider>>;
    Buttons: Dictionary<string, List<PlayerButton>>;
    RunStrings: Dictionary<string, List<RunningString>>;
    PlayerTimes: Dictionary<string, List<PlayerTime>>;
    Editors: Dictionary<string, List<Editor>>;
    
    
    mouseOffset: Point;
    isMouseDown := false;
    
    DockStartSize: System.Drawing.Size;
    
    
    procedure DockDown(sender: Object; e: MouseEventArgs);
    begin
      if e.Button = System.Windows.Forms.MouseButtons.Left then 
      begin
        mouseOffset := Control.MousePosition;
        DockStartSize := self.Playlist_.Size;
        isMouseDown := true;
      end;
    end;
    
    procedure DockUp(sender: Object; e: MouseEventArgs);
    begin
      if isMouseDown then 
      begin
        isMouseDown := false;
      end;
    end;
    
    procedure DockMove(sender: Object; e: MouseEventArgs);
    begin
      if isMouseDown then 
      begin
        self.Playlist_.Parent.MinimumSize := new System.Drawing.Size(DockStartSize.Width, DockStartSize.Height + Control.MousePosition.Y - mouseOffset.Y);
      end;
    end;
    
    procedure Down(sender: Object; e: MouseEventArgs);
    begin
      if e.Button = System.Windows.Forms.MouseButtons.Left then 
      begin
        var c := (sender as control);
        while not (c is Form) do c := c.Parent;
        var f := c as Form;
        var sp := Control.MousePosition;
        mouseOffset := new Point(-(sp.X - f.Location.X), -(sp.Y - f.Location.Y));
        isMouseDown := true;
      end;
    end;
    
    procedure Up(sender: Object; e: MouseEventArgs);
    begin
      if (e.Button = System.Windows.Forms.MouseButtons.Left) and isMouseDown then
      begin
        var c := (sender as control);
        while not (c is Form) do c := c.Parent;
        var f := c as StickyForm;
        var formOffset: Point;
        var formRect := f.Bounds;
        var mousePos := Control.MousePosition;
        mousePos.Offset(mouseOffset);
        formRect.Location := mousePos;
        
        formOffset.X := StickyGap + 1;
        formOffset.Y := StickyGap + 1;
        
        foreach fForm: StickyForm in StickyForm.StickyForms do
        begin
          if (fForm <> f) and not f.StickedForms.Contains(fForm) then
          begin
            if MoveStick(formRect, fForm.Bounds, formOffset, true) then 
            begin
              
              if fForm.MainForm then fForm.AddStickedForm(f);
              if f.MainForm then f.AddStickedForm(fForm);
            end 
            else
            if f.StickyOwner = fForm then
            begin
              fForm.DeleteStickedForm(f);
            end;
          end;
        end;
      end;
      isMouseDown := false;
    end;
    
    function MoveStick(formRect: Rectangle; toRect: Rectangle; var formOffsetPoint: Point; bInsideStick: boolean): boolean;
    begin
      var x := false;
      var y := false;
      if ((formRect.Bottom >= (toRect.Top - StickyGap)) and (formRect.Top <= (toRect.Bottom + StickyGap))) then
      begin
        x  := true;
        if (bInsideStick) then
        begin
          if Math.Abs(formRect.Left - toRect.Right) <= Math.Abs(formOffsetPoint.X) then
            formOffsetPoint.X := (toRect.Right - formRect.Left);
          if (Math.Abs(((formRect.Left + formRect.Width) - toRect.Left)) <= Math.Abs(formOffsetPoint.X)) then
            formOffsetPoint.X := ((toRect.Left - formRect.Width) - formRect.Left)
        end;
        if (Math.Abs((formRect.Left - toRect.Left)) <= Math.Abs(formOffsetPoint.X)) then
          formOffsetPoint.X := (toRect.Left - formRect.Left);
        if (Math.Abs((((formRect.Left + formRect.Width) - toRect.Left) - toRect.Width)) <= Math.Abs(formOffsetPoint.X)) then
          formOffsetPoint.X := (((toRect.Left + toRect.Width) - formRect.Width) - formRect.Left)
      end;
      if ((formRect.Right >= (toRect.Left - StickyGap)) and (formRect.Left <= (toRect.Right + StickyGap))) then
      begin
        y := true;
        if (bInsideStick) then
        begin
          if ((Math.Abs((formRect.Top - toRect.Bottom)) <= Math.Abs(formOffsetPoint.Y)) and bInsideStick) then
            formOffsetPoint.Y := (toRect.Bottom - formRect.Top);
          if ((Math.Abs(((formRect.Top + formRect.Height) - toRect.Top)) <= Math.Abs(formOffsetPoint.Y)) and bInsideStick) then
            formOffsetPoint.Y := ((toRect.Top - formRect.Height) - formRect.Top)
        end;
        if (Math.Abs((formRect.Top - toRect.Top)) <= Math.Abs(formOffsetPoint.Y)) then
          formOffsetPoint.Y := (toRect.Top - formRect.Top);
        if (Math.Abs((((formRect.Top + formRect.Height) - toRect.Top) - toRect.Height)) <= Math.Abs(formOffsetPoint.Y)) then
          formOffsetPoint.Y := (((toRect.Top + toRect.Height) - formRect.Height) - formRect.Top)
      end;
      Result := x and y;
    end;
    
    
    procedure Move(sender: Object; e: MouseEventArgs);
    begin
      if (e.Button = System.Windows.Forms.MouseButtons.Left) and isMouseDown then
      begin
        var c := (sender as control);
        while not (c is Form) do c := c.Parent;
        var f := c as StickyForm;
        var formOffset: Point;
        var formRect := f.Bounds;
        var mousePos := Control.MousePosition;
        mousePos.Offset(mouseOffset);
        formRect.Location := mousePos;
        
        formOffset.X := StickyGap + 1;
        formOffset.Y := StickyGap + 1;
        
        var UnionBounds := formRect;
        {  if f.MainForm then
            foreach fForm: StickyForm in f.StickedForms do
            begin
              var bounds := fForm.Bounds;
              bounds.Location.X += formRect.Location.X - bounds.Location.X;
              bounds.Location.Y += formRect.Location.Y - bounds.Location.Y;
              UnionBounds := Rectangle.Union(UnionBounds, bounds);
            end;}
        
        
        MoveStick(UnionBounds, Screen.FromPoint(Control.MousePosition).WorkingArea, formOffset, false);
        
        foreach fForm: StickyForm in StickyForm.StickyForms do
        begin
          if (fForm <> f) and not f.StickedForms.Contains(fForm) then
          begin
            MoveStick(UnionBounds, fForm.Bounds, formOffset, true);
          end;
        end;
        
        if formOffset.X = (StickyGap + 1) then
          formOffset.X := 0;
        if formOffset.Y = (StickyGap + 1) then
          formOffset.Y := 0;
        
        formRect.Offset(formOffset);
        
        if f.MainForm then
          foreach fForm: StickyForm in f.StickedForms do
          begin
            fForm.Location := new System.Drawing.Point(fForm.Left + formRect.Left - f.Bounds.Left, fForm.Top + formRect.Top - f.Bounds.Top);
          end;
        
        f.Bounds := formRect;
      end;
    end;
    
    procedure Shown(sender: Object; e: System.EventArgs);
    begin
      foreach f: Form in self.OwnedForms do
      begin
        var loc := f.Location;
        loc.Offset(self.Location);
        f.Show;
        f.Location := loc;
      end;
    end;
    
    procedure BtnClick(sender: Object; e: System.EventArgs);
    begin
      var action := ((Sender as PlayerButton).Tag as XmlAttributeCollection).GetNamedItem('id').InnerText;
      if ClickEvents.ContainsKey(action) then 
        ClickEvents[action]();
    end;
    
    function SliderChangePos(sender: PlayerSlider; percentage: real; ma: MouseAction): real;
    begin
      if SliderPosEvents.ContainsKey(Sender.Name) then 
        result := SliderPosEvents[Sender.Name](percentage, ma);
    end;
    
    procedure EditorTextChange(sender: Object; e: System.EventArgs);
    begin
      if SliderTextChangedEvents.ContainsKey((Sender as Editor).Name) then
        if ((Sender as Editor).Text <> (Sender as Editor).WelcomeText) and ((Sender as Editor).Text <> string.Empty) then
          SliderTextChangedEvents[(Sender as Editor).Name]((Sender as Editor).Text);
    end;
  
  protected 
    PlaylistTabs_: PlaylistTabs;
    PlaylistForm_: Form;
    Spectrum: PlayerSpectrum;
    Playlist_: PlaylistBox;
    SkinDirectoryPath: string;
  public 
    
    ClickEvents := new Dictionary<string, ClickProc>;
    SliderPosEvents := new Dictionary<string, ChangePosFunc>;
    SliderTextChangedEvents := new Dictionary<string, ChangeTextProc>;
    
    property PlaylistForm: Form read PlaylistForm_;
    property Playlist: PlaylistBox read Playlist_;
    property Tabs: PlaylistTabs read PlaylistTabs_;
    
    
    procedure ChangeImageState(id: string; state: integer);
    begin
      if Buttons.ContainsKey(id) then
        foreach b: PlayerButton in Buttons[id] do
          b.CurState := state;
    end;
    
    procedure SetText(display, text: string);
    begin
      if DisplaysText.ContainsKey(display) then
        foreach l: &Label in DisplaysText[display] do
          l.Text := text;
    end;
    
    procedure SetEditorText(id, text: string);
    begin
      if Editors.ContainsKey(id) then
        foreach tb: Editor in Editors[id] do
          tb.WelcomeText := text;
    end;
    
    procedure SetPlayerTimeText(id, Time, TimeLeft: string);
    begin
      if PlayerTimes.ContainsKey(id) then
        foreach a: PlayerTime in PlayerTimes[id] do
        begin
          a.Time := Time;
          a.TimeLeft := TimeLeft;
          a.Invalidate;
        end;
    end;
    
    procedure SetRunningText(display, text: string; isInfoText: boolean := false; InfoDuration: integer := 1000);
    begin
      if RunStrings.ContainsKey(display) then
        foreach a: RunningString in RunStrings[display] do
        begin
          if not isInfoText then 
            a.RunText := text
          else
            a.ShowInfoText(text, InfoDuration);
        end;
    end;
    
    procedure SetSliderPos(name: string; position: real);
    begin
      if Sliders.ContainsKey(name) then
        foreach Slider: PlayerSlider in Sliders[name] do
          Slider.Position := position;
    end;
    
    procedure ProcessingXML(Nodes: XMLNodeList; CParent: Control);
    begin
      foreach a: XmlNode in Nodes do 
      begin
        var id := a.Attributes.GetNamedItem('id').InnerText;
        var NewControl: Control;
        
        if a.Name = 'editor' then
        begin
          var tBox := new Editor;
          tBox.TextAlign := HorizontalAlignment(HorizontalAlignmentTC.ConvertFromString(a.Attributes.GetNamedItem('textalign').InnerText));
          tBox.Bounds := Rectangle(RectTC.ConvertFromString(a.Attributes.GetNamedItem('bounds').InnerText));
          tBox.Font := System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('font').InnerText));
          tBox.ForeColor := Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('forecolor').InnerText));
          tBox.TextChanged += EditorTextChange;
          AddToDict(Editors, id, tBox);
          NewControl := tBox;
        end
        else if a.Name = 'panel' then
        begin
          var pnl := new PlayerPanel;
          pnl.AutoSize := True;
          pnl.AutoSizeMode := System.Windows.Forms.AutoSizeMode.GrowAndShrink;
          
          pnl.Dock := DockStyle(DockStyleTC.ConvertFromString(a.Attributes.GetNamedItem('dock').InnerText));
          if (id = 'bottombarpanel') then 
          begin
            pnl.Cursor := Cursors.SizeNS;
            pnl.MouseMove += DockMove;
            pnl.MouseDown += DockDown;
            pnl.MouseUp += DockUp;
          end
          else
          begin
            pnl.MouseMove += Move;
            pnl.MouseDown += Down;
            pnl.MouseUp += Up;
          end;
          var skin := a.Attributes.GetNamedItem('skin');
          if skin <> nil then 
          begin
            pnl.BackgroundImage := System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, skin.InnerText));
            pnl.MinimumSize := pnl.BackgroundImage.Size;
          end;
          var minsize := a.Attributes.GetNamedItem('minsize');
          if minsize <> nil then 
          begin
            pnl.MinimumSize := System.Drawing.Size(SizeTC.ConvertFromString(minsize.InnerText));
          end;
          var maxsize := a.Attributes.GetNamedItem('maxsize');
          if maxsize <> nil then 
          begin
            pnl.MaximumSize := System.Drawing.Size(SizeTC.ConvertFromString(maxsize.InnerText));
          end;
          ProcessingXML(a.ChildNodes, pnl);
          NewControl := pnl;
        end
        else if a.Name = 'button' then
        begin
          var btn := new PlayerButton(System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, a.Attributes.GetNamedItem('image').InnerText)),
          StrToInt(a.Attributes.GetNamedItem('imgstates').InnerText),
          StrToInt(a.Attributes.GetNamedItem('count').InnerText));
          btn.Location :=  new System.Drawing.Point(StrToInt(a.Attributes.GetNamedItem('x').InnerText), StrToInt(a.Attributes.GetNamedItem('y').InnerText));
          btn.Click += BtnClick;
          btn.Cursor := Cursors.Hand;
          AddToDict(Buttons, id, btn);
          NewControl := btn;
        end 
        else
        if a.Name = 'text' then
        begin
          var textLabel := new &Label;
          textLabel.BackColor := Color.Transparent;
          textLabel.MouseMove += Move;
          textLabel.MouseDown += Down;
          textLabel.MouseUp += Up;
          textLabel.Font := System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('font').InnerText));
          textLabel.ForeColor := Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('color').InnerText));
          textLabel.SetBounds(StrToInt(a.Attributes.GetNamedItem('x').InnerText), StrToInt(a.Attributes.GetNamedItem('y').InnerText)
             , StrToInt(a.Attributes.GetNamedItem('w').InnerText), StrToInt(a.Attributes.GetNamedItem('h').InnerText));
          
          AddToDict(DisplaysText, id, textLabel);
          NewControl := textLabel;
        end
        else if a.Name = 'slider' then
        begin
          var isSeekBar := False;
          if a.Attributes.GetNamedItem('isseekbar').InnerText.ToLower = 'true' then
            isSeekBar := True;
          
          {var isHorizontal := False;
          if a.Attributes.GetNamedItem('ishorizontal').InnerText.ToLower = 'true' then
            ishorizontal := true;  }
          
          var slider := new PlayerSlider(System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, a.Attributes.GetNamedItem('background').InnerText)),
          System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, a.Attributes.GetNamedItem('thumb').InnerText)), isSeekBar);
          slider.ChangePosition += SliderChangePos;
          slider.Cursor := Cursors.Hand;
          slider.Location :=  new System.Drawing.Point(StrToInt(a.Attributes.GetNamedItem('x').InnerText), 
             StrToInt(a.Attributes.GetNamedItem('y').InnerText));
          
          AddToDict(Sliders, id, slider);
          
          NewControl := slider;
          
        end
        else if a.Name = 'playlist' then
        begin
          if Playlist_ <> nil then raise new Exception('Playlist must be 1');
          Playlist_ := new PlaylistBox(
              System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, a.Attributes.GetNamedItem('playlistScrollbarSkin').InnerText)),
              System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, a.Attributes.GetNamedItem('playlistScrollbarThumbSkin').InnerText)),
              
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('backcolor').InnerText)),
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('selectedcolor').InnerText)),
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('playingcolor').InnerText)),
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('playingselectedcolor').InnerText)),
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('focuscolor').InnerText)),
              
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('itemnormallinecolor').InnerText)),
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('itemplayinglinecolor').InnerText)),
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('itemselectedlinecolor').InnerText)),
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('itemplayingselectedlinecolor').InnerText)),
              
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('itemnormalline2color').InnerText)),
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('itemplayingline2color').InnerText)),
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('itemselectedline2color').InnerText)),
              Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('itemplayingselectedline2color').InnerText)),
              
              
              System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('itemnormallinefont').InnerText)),
              System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('itemnormalline2font').InnerText)),
              
              System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('itemplayinglinefont').InnerText)),
              System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('itemplayingline2font').InnerText)),
              
              System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('itemselectedlinefont').InnerText)),
              System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('itemselectedline2font').InnerText)),
              
              System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('itemplayingselectedlinefont').InnerText)),
              System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('itemplayingselectedline2font').InnerText))
          );
          
          Playlist_.Dock := DockStyle.Fill;
          Playlist_.SetBounds(
              StrToInt(a.Attributes.GetNamedItem('x').InnerText),
              StrToInt(a.Attributes.GetNamedItem('y').InnerText),
              StrToInt(a.Attributes.GetNamedItem('w').InnerText),
              StrToInt(a.Attributes.GetNamedItem('h').InnerText)
          );
          
          
          var playlistScrollbarButtonDown := a.Attributes.GetNamedItem('playlistScrollbarButtonDown');
          if playlistScrollbarButtonDown <> nil then 
            Playlist_.scrollBar_.ButtonDownImage := System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, playlistScrollbarButtonDown.InnerText));
          
          var playlistScrollbarButtonUp := a.Attributes.GetNamedItem('playlistScrollbarButtonUp');
          if playlistScrollbarButtonUp <> nil then 
            Playlist_.scrollBar_.ButtonUpImage := System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, playlistScrollbarButtonUp.InnerText));
          
          NewControl := Playlist;
        end
        else if a.Name = 'playlisttabs' then
        begin
          if PlaylistTabs_ <> nil then raise new Exception('playlisttabs must be 1');
          
          var tabsContainer_ := new TabsContainer(
          System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('tabnormaltextfont').InnerText)),
          System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('tabplayingtextfont').InnerText)),
          System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('tabactivetextfont').InnerText)),
          System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('tabactiveplayingtextfont').InnerText)),
          
          Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('tabnormaltextcolor').InnerText)),
          Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('tabplayingtextcolor').InnerText)),
          Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('tabactivetextcolor').InnerText)),
          Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('tabactiveplayingtextcolor').InnerText)),
          
          System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, a.Attributes.GetNamedItem('tabsskin').InnerText)),
          System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, a.Attributes.GetNamedItem('tabprev').InnerText)),
          System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, a.Attributes.GetNamedItem('tabnext').InnerText))
            );
          
          tabsContainer_.SetBounds(  
          StrToInt(a.Attributes.GetNamedItem('x').InnerText),
          StrToInt(a.Attributes.GetNamedItem('y').InnerText),
          StrToInt(a.Attributes.GetNamedItem('w').InnerText),
          StrToInt(a.Attributes.GetNamedItem('h').InnerText)
          );
          
          PlaylistTabs_ := tabsContainer_.Tabs;
          
          NewControl := tabsContainer_;
        end
        else if a.Name = 'runstring' then
        begin
          var runString_ := new RunningString(
          System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath, a.Attributes.GetNamedItem('skin').InnerText)),
          System.Drawing.Font(FontTC.ConvertFromString(a.Attributes.GetNamedItem('font').InnerText)),
          Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('color').InnerText))
          );
          runString_.Location := new System.Drawing.Point(
           StrToInt(a.Attributes.GetNamedItem('x').InnerText),
           StrToInt(a.Attributes.GetNamedItem('y').InnerText)
          );
          
          runString_.Cursor := Cursors.Hand;
          
          runString_.RunText := 'Simple Player';
          
          AddToDict(RunStrings, id, runString_);
          NewControl := runString_;
        end
        else if a.Name = 'spectrum' then
        begin
          if Spectrum <> nil then raise new Exception('Spectrum must be 1');
          Spectrum := new PlayerSpectrum;
          Spectrum.MouseMove += Move;
          Spectrum.MouseDown += Down;
          Spectrum.MouseUp += Up;
          Spectrum.Location :=  new System.Drawing.Point(StrToInt(a.Attributes.GetNamedItem('x').InnerText), 
             StrToInt(a.Attributes.GetNamedItem('y').InnerText));
          Spectrum.BackgroundImage := System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath,
           a.Attributes.GetNamedItem('background').InnerText));
          
          Spectrum.ColumnColor := Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('columncolor').InnerText));
          Spectrum.PeakColor := Color(ColorTC.ConvertFromString(a.Attributes.GetNamedItem('peakcolor').InnerText));
          Spectrum.Size :=  Spectrum.BackgroundImage.Size;
          NewControl := Spectrum;
        end
        else if a.Name = 'time' then
        begin
          var time := new PlayerTime(System.Drawing.Image.FromFile(Path.Combine(SkinDirectoryPath,
           a.Attributes.GetNamedItem('skin').InnerText)));
          time.Cursor := Cursors.Hand;
          time.MouseMove += Move;
          time.MouseDown += Down;
          time.MouseUp += Up;
          time.Location :=  new System.Drawing.Point(StrToInt(a.Attributes.GetNamedItem('x').InnerText), 
             StrToInt(a.Attributes.GetNamedItem('y').InnerText));
          
          AddToDict(PlayerTimes, id, time);   
          NewControl :=  time;  
        end;
        
        if NewControl <> nil then 
        begin
          NewControl.Tag := a.Attributes;
          NewControl.Name := id;
          CParent.Controls.Add(NewControl);
        end;
      end;
    end;
    
    
    constructor(SkinConfigFile: string);
    begin
      inherited Create; 
      LoadSkin(SkinConfigFile);
    end;
    
    procedure LoadSkin(SkinConfigFile: string);
    begin
      DisplaysText := new Dictionary<string, List<&Label>>;
      Sliders := new Dictionary<string, List<PlayerSlider>>;
      Buttons := new Dictionary<string, List<PlayerButton>>;
      RunStrings := new Dictionary<string, List<RunningString>>;
      PlayerTimes := new Dictionary<string, List<PlayerTime>>;
      Editors := new Dictionary<string, List<Editor>>;
      
      
      SkinDirectoryPath := Path.GetDirectoryName(SkinConfigFile);
      var XMLSkinConfig := new XmlDataDocument;
      XMLSkinConfig.Load(SkinConfigFile);
      var Root := XMLSkinConfig.LastChild;
      var SkinInfo := Root['skininfo'];
      var main := Root['main'];
      
      foreach FormElement: XmlNode in main.ChildNodes do 
      begin
        var NewForm: StickyForm;
        if FormElement.Name = 'form' then
        begin
          NewForm := self;
          NewForm.MainForm := true;
          NewForm.VisibleChanged += Shown;
          NewForm.StartPosition := FormStartPosition.CenterScreen;
        end
        else 
        begin
          NewForm := new StickyForm;
          self.AddStickedForm(NewForm);
          NewForm.Owner := self;
        end;
        
        if FormElement.Name = 'playlistform' then 
        begin
          PlaylistForm_ := NewForm;
          PlaylistForm_.ShowInTaskbar := False;
          NewForm.Location := new System.Drawing.Point(self.Left, self.Top + self.Height);
        end;
        
        NewForm.FormBorderStyle := System.Windows.Forms.FormBorderStyle.None;
        NewForm.MaximizeBox := False;
        
        NewForm.MouseMove += Move;
        NewForm.MouseDown += Down;
        NewForm.MouseUp += Up;
        
        NewForm.text := FormElement.Attributes.GetNamedItem('caption').InnerText;
        
        NewForm.AutoSizeMode := System.Windows.Forms.AutoSizeMode.GrowAndShrink;
        NewForm.AutoSize := True;
        
        var bimage := FormElement.Attributes.GetNamedItem('backgroundimage');
        if bimage <> nil then 
        begin
          NewForm.BackgroundImage := System.Drawing.Bitmap.FromFile(Path.Combine(SkinDirectoryPath, bimage.InnerText));
          NewForm.Size := NewForm.BackgroundImage.Size;
          NewForm.MinimumSize := NewForm.BackgroundImage.Size;
        end;
        
        
        NewForm.BackColor := Color.Thistle;
        NewForm.TransparencyKey := Color.Thistle;
        
        
        
        NewForm.SuspendLayout;
        ProcessingXML(FormElement.ChildNodes, NewForm);
        NewForm.ResumeLayout;
      end;
    end;
  
  
  end;

end.