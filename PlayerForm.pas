unit PlayerForm;

{$resource 'resources\main.ico'}

{$reference 'System.Windows.Forms.dll'}
{$reference 'System.Drawing.dll'}
{$reference 'Microsoft.VisualBasic.dll'}
{$reference 'System.Data.dll'}
{$reference 'System.Xml.dll'}

{$reference 'BassWrapper.dll'}
{$reference 'Tags.dll'}

uses
  System,
  System.IO,
  System.Drawing,
  System.Windows.Forms,
  System.ComponentModel,
  System.Collections.Generic,
  Microsoft.VisualBasic.ApplicationServices,
  
  System.Data,
  System.Xml,
  System.Xml.Serialization,
  
  SkinManager,
  SkinControls,
  PlayerPlaylist,
  PlayerTabs,
  SettingsFormUnit,
  RenameDlg,
  AboutDlg,
  FSFormatProvider,
  
  BassWrapper,
  Tags;

const
  AppName = 'Simple Player';
  SupportedStreamExtensions = '*.mp3;*.ogg;*.wav;*.mp2;*.mp1;*.aiff;*.m2a;*.mpa;*.m1a;*.mpg;*.mpeg;*.aif;*.mp3pro;*.bwf;*.mus';
  SupportedStreamName = 'WAV/AIFF/MP3/MP2/MP1/OGG';


type
  PlaylistFile = class 
    public Name: string;
    public Cursor: integer;
    public Tracks: List<PlaylistItem>;
  end;
  
  Player = class(SkinForm)
  private 
    mainMenu := new System.Windows.Forms.ContextMenuStrip;
    addMenu := new System.Windows.Forms.ContextMenuStrip;
    
    delMenu := new System.Windows.Forms.ContextMenuStrip;
    miscMenu := new System.Windows.Forms.ContextMenuStrip;
    sortMenu := new System.Windows.Forms.ContextMenuStrip;
    quickplsmenu := new System.Windows.Forms.ContextMenuStrip;
    playlistManagerMenu := new System.Windows.Forms.ContextMenuStrip;
    
    tabMenu := new System.Windows.Forms.ContextMenuStrip;
    playlistMenu := new System.Windows.Forms.ContextMenuStrip;
    
    nextpls, replaypls, waitpls : ToolStripMenuItem;
    
    SettingsFrm := new SettingsForm;
    
    /// хендл текущего трека
    currentMusic: integer;
    currentFilename: string;
    currentVolume: single := 1;
    
    EndSyncDelegate: SYNCPROC  := nil;
    
    trackRepeat := false;
    shuffle := false;
    
    timer := new System.Timers.Timer(25);
    
    saveVolumeForMute: real;
    
    lastTextSearch: string;
    
    
    procedure SavePlaylist(filename, playlistName: string);
    begin
      &File.Delete(filename);
      
      var PlaylistF := new PlaylistFile;
      PlaylistF.Name := playlistName;
      PlaylistF.Cursor := Playlist.listBox_.PlayingIndex;
      if PlaylistF.Cursor = -1 then PlaylistF.Cursor := 0;
      PlaylistF.Tracks := new List<PlaylistItem>;
      foreach a: PlaylistItem in Playlist.listBox_.Items do
        PlaylistF.Tracks.Add(a);
      
      var ser := new XmlSerializer(typeof(PlaylistFile));
      var stream := &File.Create(filename);
      ser.Serialize(stream, PlaylistF);
      stream.Close;
    end;
    
    
    
    procedure LoadPlaylist(filename: string; opened: boolean);
    begin
      self.Playlist.listBox_.Items.Clear;
      self.Playlist.listBox_.RandomList.Clear;
      self.Playlist.listBox_.PlayingIndex := 0;
      var g := &File.Exists(filename);
      if g then
      begin
        try
          var ser := new XmlSerializer(typeof(PlaylistFile));
          var stream := &File.OpenRead(filename);
          var PlaylistF := ser.Deserialize(stream) as PlaylistFile;
          stream.Close;
          
          if not opened then
          begin
            self.Tabs.Tabs.Add(
              new TabInfo(PlaylistF.Name, filename));
            self.Tabs.ActiveTabIndex := self.Tabs.Tabs.Count - 1;
            self.Tabs.Invalidate;
          end;
          
          foreach a: PlayListItem in PlaylistF.Tracks do
            self.Playlist.listBox_.Items.Add(a);
          self.Playlist.listBox_.playingIndex := PlaylistF.Cursor;
          self.Playlist.scrollBar_.Value := self.Playlist.listBox_.TopIndex;
          self.RefreshCounters;
        except
        end;
      end;
    end;
    
    procedure OnTimer(sender: Object; e: System.Timers.ElapsedEventArgs);
    begin
      var g := new Single[2048];
      if Bass.BASS_ChannelIsActive(currentMusic) in [BASSActive.BASS_ACTIVE_PLAYING] then 
      begin
        self.SetSliderPos('seekbar', Bass.BASS_ChannelGetPosition(currentMusic)
          / Bass.BASS_ChannelGetLength(currentMusic));
        Bass.BASS_ChannelGetData(currentMusic, g, integer(BASSData.BASS_DATA_FFT2048));
        
        var Time := FixTimespan(Bass.BASS_ChannelBytes2Seconds(currentMusic, Bass.BASS_ChannelGetPosition(currentMusic)), 'mm:ss');
        
        var TimeLeft := FixTimespan(Bass.BASS_ChannelBytes2Seconds(currentMusic, Bass.BASS_ChannelGetLength(currentMusic)) 
          - Bass.BASS_ChannelBytes2Seconds(currentMusic, Bass.BASS_ChannelGetPosition(currentMusic)), 'mm:ss');
        SetPlayerTimeText('time', ' ' + Time, '-' + TimeLeft);
      end;
      Spectrum.FFTData := g;
      Spectrum.Invalidate;
    end;
    
    procedure About(sender: Object; e: System.EventArgs);
    begin
      (new AboutDialog).ShowDialog(self);
    end;
    
    procedure OpenFiles(sender: Object; e: System.EventArgs);
    begin
      AddClick;
    end;
    
    procedure OpenDir(sender: Object; e: System.EventArgs);
    begin
      var fd := new FolderBrowserDialog;
      fd.Description := 'Выберите папку с аудиофайлами';
      fd.ShowNewFolderButton := false;
      if fd.ShowDialog  = System.Windows.Forms.DialogResult.OK then 
      begin
        var filters := SupportedStreamExtensions.Split(';');
        var firstFile := false;
        foreach filter: string in filters do
        begin
          var files := Directory.GetFiles(fd.SelectedPath, filter);
          foreach fname: string in files do
          begin
            AddFile(fname);
            if firstFile then
            begin
              ItemClick(PlaylistItem(self.Playlist.listBox_.Items[self.Playlist.listBox_.Items.Count - 1]));
              firstFile := false;
            end;
          end;
        end;
        RefreshCounters;
      end;
    end;
    
    procedure Settings(sender: Object; e: System.EventArgs);
    begin
      SettingsFrm.ShowDialog(self);
    end;
    
    procedure Settings_Skins(sender: Object; e: System.EventArgs);
    begin
      SettingsFrm.ShowSkinPage;
      SettingsFrm.ShowDialog(self);
    end;
    
    procedure NewPlaylist(sender: Object; e: System.EventArgs);
    const
      newPlaylistName = 'pls{0}';
    begin
      var i := 0;
      var name: string;
      var ExistPlaylist := false;
      repeat
        i += 1;
        name := Format(newPlaylistName, i);
        ExistPlaylist := False;
        foreach tab: TabInfo in Tabs.Tabs do
          if tab.PlaylistFilename = Path.Combine(Application.UserAppDataPath, name + '.xml') then
            ExistPlaylist := True;
      until not &File.Exists(Path.Combine(Application.UserAppDataPath, name + '.xml')) and not ExistPlaylist;
      
      var tab := new TabInfo(Format(newPlaylistName, i), Path.Combine(Application.UserAppDataPath, name + '.xml'));
      Tabs.Tabs.Add(tab);
      Tabs.Invalidate;
    end;
    
    procedure ClosePlaylist(sender: Object; e: System.EventArgs);
    begin
      if Tabs.ActiveTabIndex > 0 then 
      begin
        ChangeTab(Tabs.ActiveTabIndex - 1);
        Tabs.Tabs.RemoveAt(Tabs.ActiveTabIndex + 1);
        Tabs.Invalidate;
      end
    end;
    
    
    procedure ClearPlaylist(sender: Object; e: System.EventArgs);
    begin
      self.Playlist.listBox_.Items.Clear;
      RefreshCounters;
    end;
    
    procedure RenamePlaylist(sender: Object; e: System.EventArgs);
    begin
      var RenameDialog_ := new RenameDialog;
      RenameDialog_.input_.Text := Tabs.Tabs[Tabs.ActiveTabIndex].TabName;
      if RenameDialog_.ShowDialog(self) = System.Windows.Forms.DialogResult.OK then 
        Tabs.Tabs[Tabs.ActiveTabIndex].TabName := RenameDialog_.input_.Text;
      Tabs.Invalidate;
    end;
    
    procedure SavePlaylist(sender: Object; e: System.EventArgs);
    begin
      SavePlaylist(self.Tabs.Tabs[self.Tabs.ActiveTabIndex].PlaylistFilename,
        self.Tabs.Tabs[self.Tabs.ActiveTabIndex].TabName);
    end;
    
    procedure OpenPlaylist(sender: Object; e: System.EventArgs);
    begin
      var od := new OpenFileDialog;
      od.DefaultExt := 'xml';
      od.Filter := 'Плейлисты (*.' + od.DefaultExt + ')|*.' + od.DefaultExt;
      if od.ShowDialog = System.Windows.Forms.DialogResult.OK then 
      begin
        SavePlaylist(self.Tabs.Tabs[self.Tabs.ActiveTabIndex].PlaylistFilename, 
           self.Tabs.Tabs[self.Tabs.ActiveTabIndex].TabName);
        LoadPlaylist(od.FileName, false);
      end;
    end;
    
    procedure SavePlaylistAs(sender: Object; e: System.EventArgs);
    begin
      var sd := new SaveFileDialog;
      sd.DefaultExt := 'xml';
      sd.Filter := 'Плейлисты (*.' + sd.DefaultExt + ')|*.' + sd.DefaultExt;
      if sd.ShowDialog = System.Windows.Forms.DialogResult.OK then 
      begin
        self.Tabs.Tabs[self.Tabs.ActiveTabIndex].PlaylistFilename := sd.FileName;
        SavePlaylist(self.Tabs.Tabs[self.Tabs.ActiveTabIndex].PlaylistFilename,
             self.Tabs.Tabs[self.Tabs.ActiveTabIndex].TabName);
      end;
    end;
    
    procedure DeleteFile(sender: Object; e: System.EventArgs);
    begin
      var selindex := self.Playlist.listBox_.SelectedIndex;
      if self.Playlist.listBox_.SelectedItem <> nil then 
        self.Playlist.listBox_.Items.Remove(self.Playlist.listBox_.SelectedItem);
      if selindex = self.Playlist.listBox_.Items.Count then 
        selindex -= 1;
      self.Playlist.listBox_.SelectedIndex := selindex;
    end;
    
    procedure DeleteFileFromHDD(sender: Object; e: System.EventArgs);
    begin
      var selindex := self.Playlist.listBox_.SelectedIndex;
      if self.Playlist.listBox_.SelectedItem <> nil then 
      begin
        var fname := (Playlist.listBox_.SelectedItem as PlayListItem).Filename;
        
        if (fname = currentFilename) then StopClick;
        &File.Delete(fname);
        if (fname = currentFilename) then NextClick;
        
        self.Playlist.listBox_.Items.Remove(self.Playlist.listBox_.SelectedItem);
      end;
      if selindex = self.Playlist.listBox_.Items.Count then 
        selindex -= 1;
      self.Playlist.listBox_.SelectedIndex := selindex;
    end;
    
    procedure DeleteNonexistentFiles(sender: Object; e: System.EventArgs);
    begin
      for var i := 0 to Playlist.listBox_.Items.Count - 1 do
        if not &File.Exists((Playlist.listBox_.Items[i] as PlayListItem).Filename) then Playlist.listBox_.Items.RemoveAt(i);
    end;
    
    procedure DeleteDuplicateFiles(sender: Object; e: System.EventArgs);
    begin
      var l := (Playlist.listBox_ as ListBox).Items;
      for var i := l.Count - 1 downto 0 do
      begin
        var ir := i;
        if not (i <= l.Count - 1) then continue;
        for var i2 := l.Count - 1 downto 0 do
        begin
          if not (i2 <= l.Count - 1) or (i2 = i) then continue;
          if (l[ir] as PlayListItem).Filename = (l[i2] as PlayListItem).Filename then
          begin
            l.RemoveAt(i2);
            ir -= 1;
          end;
        end;
      end;
    end;
    
    procedure FindNewFiles(sender: Object; e: System.EventArgs);
    begin
      // TODO: 
    end;
    
    procedure RescanTags(sender: Object; e: System.EventArgs);
    begin
      // TODO: 
    end;
    
    
    procedure Close(sender: Object; e: System.EventArgs);
    begin
      CloseClick;
    end;
    
    procedure DragDropFiles(sender: object; e: System.Windows.Forms.DragEventArgs);
    type
      ArrOfString = array of string;
    begin
      var a :=  ArrOfString(e.Data.GetData(DataFormats.FileDrop, false));
      foreach s: string in a do AddFile(s);
      RefreshCounters;
    end;
    
    procedure DragEnterFiles(sender: object; e: System.Windows.Forms.DragEventArgs);
    begin
      if (e.Data.GetDataPresent(DataFormats.FileDrop)) then
        e.Effect := DragDropEffects.All
      else
        e.Effect := DragDropEffects.None;
    end;
    
    procedure AddFile(fname: string);
    begin
      var tagInfo := new TAG_INFO;
      var stream := Bass.BASS_StreamCreateFile(false, fname, 0, 0, BASSFlag.BASS_STREAM_DECODE or BASSFlag.BASS_UNICODE);
      BassTags.BASS_TAG_GetFromFile(stream, tagInfo);
      var duration := Bass.BASS_ChannelBytes2Seconds(stream, Bass.BASS_ChannelGetLength(stream));
      var bitrate := round((Bass.BASS_StreamGetFilePosition(stream, BASSStreamFilePosition.BASS_FILEPOS_END)) 
                                          / (125.0 * duration));
      self.Playlist.listBox_.Items.Add(
        new PlaylistItem(fname, tagInfo.artist, tagInfo.title, bitrate, tagInfo.channelInfo.freq,  duration, (new FileInfo(fname)).Length)
      );
      Application.DoEvents;
    end;
    
    procedure PlayerChangeState;
    begin
      if (Bass.BASS_ChannelIsActive(currentMusic) in [BASSActive.BASS_ACTIVE_PLAYING]) then
      begin
        self.ChangeImageState('playpause', 1);
        self.ChangeImageState('playermode', 1);
        // timer.Start;
      end
      else 
      begin
        if (Bass.BASS_ChannelIsActive(currentMusic) in [BASSActive.BASS_ACTIVE_PAUSED])
          then 
          self.ChangeImageState('playermode', 2)
        else  
          self.ChangeImageState('playermode', 0);
        
        self.ChangeImageState('playpause', 0);
        
        // timer.Stop;
      end;
    end;
    
    procedure MainMenuClick;
    begin
      mainMenu.Show(Control.MousePosition);
    end;
    
    procedure OptionsClick;
    begin
      SettingsFrm.ShowDialog(self);
    end;
    
    procedure UtiitiesClick;
    begin
      SettingsFrm.ShowSkinPage;
      SettingsFrm.ShowDialog(self);
    end;
    
    procedure PlayClick;
    begin
      if not (Bass.BASS_ChannelIsActive(currentMusic) in [BASSActive.BASS_ACTIVE_PLAYING]) then
      begin
        if currentMusic = 0 then InitStream(currentFilename);
        Bass.BASS_ChannelPlay(currentMusic, false);
        PlayerChangeState;
      end;
      
    end;
    
    
    procedure InitStream(Filename: string);
    begin
      currentMusic := Bass.BASS_StreamCreateFile(false, Filename,
        0, 0, BASSFlag.BASS_UNICODE);   
      currentFilename := Filename;
      Bass.BASS_ChannelSetSync(currentMusic, BASSSync.BASS_SYNC_END or BASSSync.BASS_SYNC_MIXTIME, 
          0, EndSyncDelegate, IntPtr.Zero);
      Bass.BASS_ChannelSetAttribute(currentMusic, BassAttribute.BASS_ATTRIB_VOL, currentVolume);
    end;
    
    procedure PlayPauseClick;
    begin
      if Bass.BASS_ChannelIsActive(currentMusic) in [BASSActive.BASS_ACTIVE_PLAYING] then
      begin
        Bass.BASS_ChannelPause(currentMusic);
      end
      else 
      begin
        if currentMusic = 0 then InitStream(currentFilename);
        Bass.BASS_ChannelPlay(currentMusic, false);
      end;
      PlayerChangeState;
    end;
    
    procedure StopClick;
    begin
      if (currentMusic <> 0) and (Bass.BASS_ChannelIsActive(currentMusic) in [BASSActive.BASS_ACTIVE_PAUSED, BASSActive.BASS_ACTIVE_PLAYING]) then 
      begin
        Bass.BASS_StreamFree(currentMusic);
        currentMusic := 0;
        PlayerChangeState;
      end;     
    end;
    
    procedure PauseClick;
    begin
      if Bass.BASS_ChannelIsActive(currentMusic) in [BASSActive.BASS_ACTIVE_PLAYING] then 
      begin
        Bass.BASS_ChannelPause(currentMusic);
        PlayerChangeState;
      end;       
    end;
    
    procedure NextClick;
    begin
      if not shuffle then
      begin
        if self.Playlist.listBox_.Items.Count > 0 then 
        begin
          if self.Playlist.listBox_.PlayingIndex = self.Playlist.listBox_.Items.Count - 1 then
            ItemClick(PlaylistItem(self.Playlist.listBox_.Items[0]))
          else 
            ItemClick(PlaylistItem(self.Playlist.listBox_.Items[self.Playlist.listBox_.PlayingIndex + 1]));
        end;
      end
      else 
      begin
        if self.Playlist.listBox_.RandomList.Count > 0 then 
        begin
          var r := self.Playlist.listBox_.RandomList.IndexOf(PlaylistItem(self.Playlist.listBox_.Items[self.Playlist.listBox_.PlayingIndex]));
          if r = self.Playlist.listBox_.RandomList.Count - 1 then
            ItemClick(PlaylistItem(self.Playlist.listBox_.RandomList[0]))
          else ItemClick(PlaylistItem(self.Playlist.listBox_.RandomList[r + 1]));
        end;
      end;
    end;
    
    procedure PrevClick;
    begin
      if self.Playlist.listBox_.Items.Count > 0 then 
      begin
        if self.Playlist.listBox_.PlayingIndex = 0 then
          ItemClick(PlaylistItem(self.Playlist.listBox_.Items[self.Playlist.listBox_.Items.Count - 1]))
        else ItemClick(PlaylistItem(self.Playlist.listBox_.Items[self.Playlist.listBox_.PlayingIndex - 1]));
      end;
    end;
    
    procedure MinimizeClick;
    begin
      WindowState := FormWindowState.Minimized;
    end;
    
    procedure StayOnTopClick;
    begin
      TopMost := not TopMost;
      if TopMost then self.ChangeImageState('stayontop', 1) 
      else self.ChangeImageState('stayontop', 0);
    end;
    
    procedure CloseClick;
    begin
      SavePlaylist(self.Tabs.Tabs[self.Tabs.ActiveTabIndex].PlaylistFilename, 
        self.Tabs.Tabs[self.Tabs.ActiveTabIndex].TabName);
      SaveSettings;  
      (self as Form).Close;
    end;
    
    procedure AddMenuClick;
    begin
      AddMenu.Show(Control.MousePosition);
    end;
    
    
    
    
    procedure RefreshCounters;
    begin
      var tPlayTime: real;
      var tCount: integer;
      var tSize: Int64;
      foreach a: PlayListItem in self.Playlist.listBox_.Items do
      begin
        tPlayTime += a.Duration;
        tSize += a.FileSize;
        tCount += 1;
      end;
      SetText('playlistduration', PlayListItem.FixTimespan(tPlayTime, 'HH:mm:ss'));
      SetText('trackscount', tCount.ToString);
      SetText('sizeofplaylist', String.Format(new FileSizeFormatProvider, '{0:fs1}', tSize));
    end;
    
    procedure AddClick;
    begin
      var sd := new OpenFileDialog;
      sd.Multiselect := True;
      sd.Filter := 'Аудио файлы (' + SupportedStreamExtensions + ')|' + SupportedStreamExtensions;
      if sd.ShowDialog = System.Windows.Forms.DialogResult.OK then
      begin
        var firstFile := true;
        foreach fname: string in sd.FileNames do
        begin
          AddFile(fname);
          if firstFile then
          begin
            ItemClick(PlaylistItem(self.Playlist.listBox_.Items[self.Playlist.listBox_.Items.Count - 1]));
            firstFile := false;
          end;
        end;
        RefreshCounters;
      end;
    end;
    
    procedure MuteClick;
    begin
      if saveVolumeForMute <> 0 then 
      begin
        Bass.BASS_ChannelSetAttribute(currentMusic, BassAttribute.BASS_ATTRIB_VOL, saveVolumeForMute);
        currentVolume := saveVolumeForMute;
        saveVolumeForMute := 0;
        self.ChangeImageState('mute', 0);
      end
      else
      begin
        saveVolumeForMute := currentVolume;
        Bass.BASS_ChannelSetAttribute(currentMusic, BassAttribute.BASS_ATTRIB_VOL, 0);
        currentVolume := 0;  
        self.ChangeImageState('mute', 1);
      end;
      self.SetSliderPos('volumebar', currentVolume);
    end;
    
    procedure  DeleteMenuClick;
    begin
      DelMenu.Show(Control.MousePosition);
    end;
    
    procedure  SortMenuClick;
    begin
      SortMenu.Show(Control.MousePosition);
    end;
    
    
    procedure PlaylistManagerClick;
    begin
      PlaylistManagerMenu.Show(Control.MousePosition);
    end;
    
    procedure QuickPlaylistMenuClick;
    begin
      QuickPlsMenu.Show(Control.MousePosition);
    end;
    
    
    procedure  MiscMenuClick;
    begin
      MiscMenu.Show(Control.MousePosition);
    end;
    
    procedure PlaylistClick;
    begin
      self.PlaylistForm.Visible := not self.PlaylistForm.Visible;
    end;
    
    procedure JumpPlaylist(sender: Object; e: System.EventArgs);
    begin
      nextpls.Checked := True;
      replaypls.Checked := False;
      waitpls.Checked := False;
    end;

    procedure ReplayPlaylist(sender: Object; e: System.EventArgs);
    begin
      nextpls.Checked := False;
      replaypls.Checked := True;
      waitpls.Checked := False;
    end;
    
    procedure WaitPlaylist(sender: Object; e: System.EventArgs);
    begin
      nextpls.Checked := False;
      replaypls.Checked := False;
      waitpls.Checked := True;
    end;
    
    procedure TrackRepeatClick;
    begin
      trackRepeat := not trackRepeat;
      if trackRepeat then 
        self.ChangeImageState('trackRepeat', 1)
      else
        self.ChangeImageState('trackRepeat', 0)
    end;
    
    procedure ShuffleClick;
    begin
      shuffle := not shuffle;
      if shuffle then 
      begin
        self.ChangeImageState('shuffle', 1);
        self.Playlist.listBox_.CreateRandomList;
      end
      else
        self.ChangeImageState('shuffle', 0)
    end;

    
    
    procedure SortBy(Comp: IComparer<PlaylistItem>; Reverse: boolean := false; Shuffle: boolean := false);
    begin
      var SelectedItem := Playlist.listBox_.SelectedItem;
      var a := new List<PlaylistItem>;
      foreach  lbItem: PlaylistItem in Playlist.listBox_.Items do
        a.Add(lbItem);
      if Comp <> nil then a.Sort(Comp);
      if Reverse then
      begin
        //!!! a.Reverse not working 
        var newList := new List<PlaylistItem>;
        for var i := a.Count - 1 downto 0 do newList.Add(a[i]);
        a := newList;
      end;
      if Shuffle then 
      begin
        var r := new System.Random();  
        var n := a.Count;  
        while (n > 1) do
        begin
          n -= 1;  
          var k := r.Next(n + 1);  
          var value := a[k];  
          a[k] := a[n];  
          a[n] := value;  
        end;  
      end;
      Playlist.listBox_.Items.Clear;
      foreach item: PlaylistItem in a do 
        Playlist.listBox_.Items.Add(item);
      Playlist.listBox_.SelectedItem := SelectedItem;
    end;
    
    procedure SelectAll(sender: Object; e: System.EventArgs);
    begin
      for var i := 0 to Playlist.listBox_.Items.Count - 1 do
        Playlist.listBox_.SetSelected(i, true);
    end;
    
    procedure UnSelectAll(sender: Object; e: System.EventArgs);
    begin
      for var i := 0 to Playlist.listBox_.Items.Count - 1 do
        Playlist.listBox_.SetSelected(i, false);
    end;
    
    procedure SortByTitle(sender: Object; e: System.EventArgs);
    begin
      SortBy(new PlaylistTitleComparer);
    end;
    
    procedure SortByDir(sender: Object; e: System.EventArgs);
    begin
      SortBy(new PlaylistDirectoryComparer);
    end;
    
    procedure SortByLength(sender: Object; e: System.EventArgs);
    begin
      SortBy(new PlaylistLengthComparer);
    end;
    
    procedure SortByArtist(sender: Object; e: System.EventArgs);
    begin
      SortBy(new PlaylistArtistComparer);
    end;
    
    procedure ReverseClick(sender: Object; e: System.EventArgs);
    begin
      SortBy(nil, true);
    end;
    
    procedure ShuffleClick(sender: Object; e: System.EventArgs);
    begin
      SortBy(nil, true, true);
    end;
    
    
    
    procedure Search(text: string; StartIndex: integer := 0);
    begin
      lastTextSearch := text;
      for var i := StartIndex to Playlist.listBox_.Items.Count - 1 do
      begin
        if ((Playlist.listBox_.Items[i] as PlayListItem).ListBoxData.Title.IndexOf(text) <> -1) or ((Playlist.listBox_.Items[i] as PlayListItem).ListBoxData.SubTitle.IndexOf(text) <> -1) then
        begin
          Playlist.listBox_.SelectedItem := Playlist.listBox_.Items[i];
          exit;
        end;
      end;
      
      if StartIndex <> 0 then for var i := 0 to StartIndex do
        begin
          if ((Playlist.listBox_.Items[i] as PlayListItem).ListBoxData.Title.IndexOf(text) <> -1) or ((Playlist.listBox_.Items[i] as PlayListItem).ListBoxData.SubTitle.IndexOf(text) <> -1) then
          begin
            Playlist.listBox_.SelectedItem := Playlist.listBox_.Items[i];
            exit;
          end;
        end;
      
    end;
    
    procedure QuickSearch_TextChanged(text: string);
    begin
      Search(text);
    end;
    
    procedure QuickSearchClick;
    begin
      Search(lastTextSearch, Playlist.listBox_.SelectedIndex + 1);
    end;
    
    procedure PrevPlaylistClick;
    begin
      if PlaylistTabs_.ActiveTabIndex = 0 then
        ChangeTab(PlaylistTabs_.Tabs.Count - 1)
      else 
        ChangeTab(PlaylistTabs_.ActiveTabIndex - 1);
    end;
    
    procedure NextPlaylistClick;
    begin
      if PlaylistTabs_.ActiveTabIndex = PlaylistTabs_.Tabs.Count - 1 then
        ChangeTab(0)
      else 
        ChangeTab(PlaylistTabs_.ActiveTabIndex + 1);
    end;
    
    
    
    
    function BalanceChange(value: real; ma: MouseAction): real;
    begin
      result := value;
      if (0.4 < value) and (value < 0.6) then result := 0.5;
      var balance := (result * 2) - 1;
      Bass.BASS_ChannelSetAttribute(
        currentMusic,
        BASSAttribute.BASS_ATTRIB_PAN,
        balance
      );
      var s: string;
      if balance = 0 then s := 'L = R' else
      if balance > 0 then s := Format('R +{0:00}%', round(balance * 100)) 
      else s := Format('L +{0:00}%', round(-balance * 100));
      self.SetRunningText('runstring', Format('Баланс [{0}]', s), true, 2000);
    end;
    
    function VolumeChange(volume: real; ma: MouseAction): real;
    begin
      result := volume;
      Bass.BASS_ChannelSetAttribute(currentMusic, BassAttribute.BASS_ATTRIB_VOL, volume);
      currentVolume := volume;
      if volume = 0 then
      begin
        saveVolumeForMute := 0.8;
        self.ChangeImageState('mute', 1);
      end
      else
        self.ChangeImageState('mute', 0);
      self.SetRunningText('runstring', Format('Громкость [{0}%]', Round(volume * 100).ToString), true, 2000);
    end;
    
    
    
    
    function FixTimespan(seconds: double; format: string): string;
    begin
      Result := DateTime.Today.AddSeconds(seconds).ToString(format);
    end;
    
    function ChangePos(pos: real; ma: MouseAction): real;
    begin
      result := pos;
      if (Bass.BASS_ChannelIsActive(currentMusic) in [BASSActive.BASS_ACTIVE_PLAYING]) then 
      begin
        if (ma = maUp) then
        begin
          if pos = 1 then
            NextClick
          else
            Bass.BASS_ChannelSetPosition(currentMusic, round(Bass.BASS_ChannelGetLength(currentMusic) * pos))
        end;
        
        var Time := FixTimespan(Bass.BASS_ChannelBytes2Seconds(currentMusic, Bass.BASS_ChannelGetLength(currentMusic)) * pos, 'mm:ss');
        var TimeLeft := FixTimespan(Bass.BASS_ChannelBytes2Seconds(currentMusic, Bass.BASS_ChannelGetLength(currentMusic)) - (Bass.BASS_ChannelBytes2Seconds(currentMusic, Bass.BASS_ChannelGetLength(currentMusic)) * pos), 'mm:ss');
        
        self.SetRunningText('runstring', 
           Format('Позиция [{0}(-{1})/{2}]', 
            Time,
            TimeLeft,
            FixTimespan(Bass.BASS_ChannelBytes2Seconds(currentMusic, Bass.BASS_ChannelGetLength(currentMusic)), 'mm:ss')
         ), true, 2000
        );
        
      end;
    end;
    
    procedure ChangeTab(Tab: integer);
    begin
      self.Playlist.listBox_.PlayingIndex := 0;
      SavePlaylist(self.Tabs.Tabs[self.Tabs.ActiveTabIndex].PlaylistFilename, 
      self.Tabs.Tabs[self.Tabs.ActiveTabIndex].TabName);
      self.Playlist.listBox_.Items.Clear;
      LoadPlaylist(self.Tabs.Tabs[Tab].PlaylistFilename, true);
      Tabs.ActiveTabIndex := Tab;
      Tabs.Invalidate;
    end;
    
    
    
    procedure GetTags(handle: integer; var tagInfo: Tags.TAG_INFO);
    begin
      Tags.BassTags.BASS_TAG_GetFromFile(handle, tagInfo);
    end;
    
    procedure ItemClick(Item: PlaylistItem; EndSyncCall: boolean);
    begin
      InitStream(Item.Filename);
      
      
      
      if item.Title = '' then 
        self.SetText('title', Path.GetFileName(Item.Filename))
      else 
        self.SetText('title', item.Title);
      self.SetText('artist', item.Artist);
      
      
      
      
      
      self.SetRunningText('runstring', String.Format(
             '.:: {0} :: {1} - {2} :: {3} :: {4} kHz, {5} kbps, {6}  ::. ',
             Path.GetExtension(item.Filename).Remove(0, 1).ToUpper,
             item.Artist,
             item.Title,
             FixTimespan(item.Duration, 'mm:ss'),
             (item.Frequency div 1000).ToString,
             item.Bitrate.ToString, 
             String.Format(new FileSizeFormatProvider, '{0:fs1}', item.FileSize)
             ));
      
      self.SetPlayerTimeText('brinfo', item.Bitrate.ToString,  item.Bitrate.ToString);
      self.SetPlayerTimeText('srinfo', (item.Frequency div 1000).ToString, (item.Frequency div 1000).ToString); 
      
      self.Playlist.listBox_.PlayingIndex := self.Playlist.listBox_.Items.IndexOf(Item);
      PlayClick;
    end;
    
    procedure ItemClick(Item: PlaylistItem);
    begin
      StopClick;
      ItemClick(Item, true);
    end;
    
    public procedure ProcessParameters(args: array of string);
    begin
      if (args.Length > 1) and (&File.Exists(args[1])) then 
      begin
        AddFile(args[1]);
        ItemClick(PlaylistItem(self.Playlist.listBox_.Items[self.Playlist.listBox_.Items.Count - 1]));  
      end
      else if self.Playlist.listBox_.Items.Count > 0 then
        self.ItemClick(self.Playlist.listBox_.Items[self.Playlist_.listbox_.PlayingIndex] as PlayListItem);
      RefreshCounters;
    end;
    
    
    
    
    procedure EndSyncInvoke;
    begin
      if not trackRepeat then 
      begin
        if not shuffle then
        begin
          if self.Playlist.listBox_.Items.Count > 0 then 
          begin
            if self.Playlist.listBox_.PlayingIndex = self.Playlist.listBox_.Items.Count - 1 then
              ItemClick(PlaylistItem(self.Playlist.listBox_.Items[0]), true)
            else ItemClick(PlaylistItem(self.Playlist.listBox_.Items[self.Playlist.listBox_.PlayingIndex + 1]), true);
          end;
        end
        else 
        begin
          if self.Playlist.listBox_.RandomList.Count > 0 then 
          begin
            var r := self.Playlist.listBox_.RandomList.IndexOf(PlaylistItem(self.Playlist.listBox_.Items[self.Playlist.listBox_.PlayingIndex]));
            if r = self.Playlist.listBox_.RandomList.Count - 1 then
              ItemClick(PlaylistItem(self.Playlist.listBox_.RandomList[0]), true)
            else ItemClick(PlaylistItem(self.Playlist.listBox_.RandomList[r + 1]), true);
          end;
        end;
      end else ItemClick(PlaylistItem(self.Playlist.listBox_.Items[self.Playlist.listBox_.PlayingIndex]), true);
    end;
    
    procedure EndSync(handle, channel, data: integer; user: IntPtr);
    begin
      Invoke(EndSyncInvoke);
    end;
  
  
  public 
    procedure LoadSettings;
    begin
      var SettingsFile := Path.Combine(Application.UserAppDataPath, 'settings.xml');
      if &File.Exists(SettingsFile) then
      begin
        var doc := new XmlDocument();
        doc.Load(SettingsFile);
        var root := doc['settings'];
        
        var PlaylistNode := root['playlists'];
        
        foreach a: XmlNode in PlaylistNode.ChildNodes do
        begin
          var tab := new TabInfo(a.Attributes.GetNamedItem('name').InnerText,
          a.Attributes.GetNamedItem('filename').InnerText);
          Tabs.Tabs.Add(tab);
        end;
        Tabs.ActiveTabIndex := Convert.ToInt32(PlaylistNode.Attributes.GetNamedItem('current').InnerText);
        LoadPlaylist(Tabs.Tabs[Tabs.ActiveTabIndex].PlaylistFilename, true); 
      end;
    end;
    
   
    procedure SaveSettings;
    begin
      &File.Delete(Path.Combine(Application.UserAppDataPath, 'settings.xml'));
      
      var doc := new XmlDocument();
      var root := doc.CreateElement('settings');
      
      var curskin := doc.CreateElement('currentskin');
      curskin.InnerText := SettingsFrm.CurrentSkinConfigFile;
      root.AppendChild(curskin);
      
      var PlaylistNode := doc.CreateElement('playlists');
      PlaylistNode.SetAttribute('current', Tabs.ActiveTabIndex.ToString);
      foreach a: TabInfo in Tabs.Tabs do 
      begin
        var pls := doc.CreateElement('playlist');
        pls.SetAttribute('name', a.TabName);
        pls.SetAttribute('filename', a.PlaylistFilename);
        PlaylistNode.AppendChild(pls);
      end;
      root.AppendChild(PlaylistNode);
      doc.AppendChild(root);
      doc.Save(Path.Combine(Application.UserAppDataPath, 'settings.xml'));
      SavePlaylist(self.Tabs.Tabs[self.Tabs.ActiveTabIndex].PlaylistFilename, 
           self.Tabs.Tabs[self.Tabs.ActiveTabIndex].TabName);
    end;
    
    procedure KDown(sender: Object; e: KeyEventArgs);
    begin
      if (sender as ListBox).Items.Count > 0 then
      begin
        if e.KeyCode = Keys.Delete then
        begin
          DeleteFile(nil, nil);
        end;
      end;
    end;
    
    
    constructor;
    begin
      LoadSkin(self.SettingsFrm.CurrentSkinConfigFile);
      LoadSettings;
      
      
      //inherited Create(Path.Combine(Application.StartupPath, 'skins', 'Minimal', 'skin.xml'));
      //inherited Create(Path.Combine(Application.StartupPath, 'skins', 'iSkin', 'skin.xml'));
      
      if not Bass.BASS_Init(-1, 44100, 0, Handle, nil)  then 
        raise(new Exception('Bass Init error!'));
      
      
      
      
      Icon := new System.Drawing.Icon(GetResourceStream('main.ico'));
      
      System.IO.Directory.CreateDirectory(Application.UserAppDataPath);
      
      EndSyncDelegate := EndSync;
      
      self.ClickEvents['close'] := CloseClick;
      self.ClickEvents['minimize'] := MinimizeClick;
      self.ClickEvents['playpause'] := PlayPauseClick;
      self.ClickEvents['stop'] := StopClick;
      self.ClickEvents['next'] := NextClick;
      self.ClickEvents['prev'] := PrevClick;
      self.ClickEvents['mute'] := MuteClick;
      self.ClickEvents['playlist'] := PlaylistClick;
      self.ClickEvents['trackRepeat'] := TrackRepeatClick;
      self.ClickEvents['shuffle'] := ShuffleClick;
      self.ClickEvents['mainmenu'] := MainMenuClick;
      self.ClickEvents['options'] := OptionsClick;
      self.ClickEvents['utilities'] := UtiitiesClick;
      
      self.SliderPosEvents['seekbar'] := ChangePos;
      self.SliderPosEvents['volumebar'] := VolumeChange;
      self.SliderPosEvents['balancebar'] := BalanceChange;
      self.ClickEvents['stayontop'] := StayOnTopClick;
      
      self.ClickEvents['quicksearch'] := QuickSearchClick;
      
      
      self.ClickEvents['addmenu'] := AddMenuClick;
      self.ClickEvents['deletemenu'] := DeleteMenuClick;
      self.ClickEvents['sortmenu'] := SortMenuClick;
      self.ClickEvents['miscmenu'] := MiscMenuClick;  
      
      self.ClickEvents['quickplaylistoptions'] := QuickPlaylistMenuClick; 
      self.ClickEvents['playlistmanager'] := PlaylistManagerClick; 
      
      self.ClickEvents['prevplaylist'] := PrevPlaylistClick;
      self.ClickEvents['nextplaylist'] := NextPlaylistClick;  
      
      self.ClickEvents['open'] := AddClick;
      
      self.Tabs.ChangeTab += ChangeTab;
      
      if trackRepeat then 
        self.ChangeImageState('trackRepeat', 1)
      else
        self.ChangeImageState('trackRepeat', 0);
      
      
      mainMenu.Items.Add(new ToolStripMenuItem('О программе', nil, About));
      mainMenu.Items.Add(new ToolStripSeparator);
      mainMenu.Items.Add(new ToolStripMenuItem('Открыть файлы', nil, OpenFiles));
      mainMenu.Items.Add(new ToolStripMenuItem('Открыть папку', nil, OpenDir));
      mainMenu.Items.Add(new ToolStripSeparator);
      mainMenu.Items.Add(new ToolStripMenuItem('Настройки', nil, Settings));
      mainMenu.Items.Add(new ToolStripMenuItem('Скины', nil, Settings_Skins));
      mainMenu.Items.Add(new ToolStripSeparator);
      mainMenu.Items.Add(new ToolStripMenuItem('Выход', nil, Close));
      
      tabMenu.Items.Add(new ToolStripMenuItem('Новый плейлист', nil, NewPlaylist));
      tabMenu.Items.Add(new ToolStripMenuItem('Закрыть плейлист', nil, ClosePlaylist));
      tabMenu.Items.Add(new ToolStripMenuItem('Переименовать плейлист', nil, RenamePlaylist));
      tabMenu.Items.Add(new ToolStripMenuItem('Очистить плейлист', nil, ClearPlaylist));
      tabMenu.Items.Add(new ToolStripMenuItem('Сохранить плейлист как...', nil, SavePlaylistAs));  
      
      addMenu.Items.Add(new ToolStripMenuItem('Файлы', nil, OpenFiles));
      addMenu.Items.Add(new ToolStripMenuItem('Папку', nil, OpenDir)); 
      addMenu.Items.Add(new ToolStripMenuItem('Плейлист', nil, OpenPlaylist)); 
      
      
      delMenu.Items.Add(new ToolStripMenuItem('Удалить выбранный файлы', nil, DeleteFile));
      delMenu.Items.Add(new ToolStripMenuItem('Удалить выбранный файл с диска', nil, DeleteFileFromHDD));
      delMenu.Items.Add(new ToolStripMenuItem('Удалить несуществующие файлы', nil, DeleteNonexistentFiles));
      delMenu.Items.Add(new ToolStripMenuItem('Удалить повторяющиеся файлы', nil, DeleteDuplicateFiles));
      delMenu.Items.Add(new ToolStripSeparator);
      delMenu.Items.Add(new ToolStripMenuItem('Удалить все файлы', nil, ClearPlaylist));
      
      //  miscMenu.Items.Add(new ToolStripMenuItem('Выбрать все файлы', nil, SelectAll));
      //  miscMenu.Items.Add(new ToolStripMenuItem('Убрать выделение', nil, UnSelectAll));
      miscMenu.Items.Add(new ToolStripMenuItem('Поиск новых файлов', nil, FindNewFiles));
      miscMenu.Items.Add(new ToolStripMenuItem('Пересканировать теги', nil, RescanTags));
      
      sortMenu.Items.Add(new ToolStripMenuItem('Сортировка по заголовку', nil, SortByTitle));
      sortMenu.Items.Add(new ToolStripMenuItem('Сортировка по папкам', nil, SortByDir));
      sortMenu.Items.Add(new ToolStripMenuItem('Сортировка по длительности', nil, SortByLength));
      sortMenu.Items.Add(new ToolStripMenuItem('Сортировка по исполнителю', nil, SortByArtist));
      sortMenu.Items.Add(new ToolStripSeparator);
      sortMenu.Items.Add(new ToolStripMenuItem('Инвертировать', nil, ReverseClick));
      sortMenu.Items.Add(new ToolStripMenuItem('Перемешать', nil, ShuffleClick));
      
      
      nextpls := new ToolStripMenuItem('Перейти на следущий плейлист', nil, JumpPlaylist);
      replaypls := new ToolStripMenuItem('Повторить плейлист', nil, ReplayPlaylist);
      
      replaypls.Checked := True;
      
      waitpls := new ToolStripMenuItem('Перейти в режим ожидания', nil, WaitPlaylist);
      
      
      quickplsmenu.Items.Add(nextpls);
      quickplsmenu.Items.Add(replaypls);
      quickplsmenu.Items.Add(waitpls);
      
      playlistManagerMenu.Items.Add(new ToolStripMenuItem('Новый плейлист', nil, NewPlaylist));
      playlistManagerMenu.Items.Add(new ToolStripMenuItem('Закрыть плейлист', nil, ClosePlaylist));
      playlistManagerMenu.Items.Add(new ToolStripSeparator);
      playlistManagerMenu.Items.Add(new ToolStripMenuItem('Открыть папку', nil, OpenDir));
      playlistManagerMenu.Items.Add(new ToolStripSeparator);
      playlistManagerMenu.Items.Add(new ToolStripMenuItem('Открыть плейлист', nil, OpenPlaylist));
      playlistManagerMenu.Items.Add(new ToolStripMenuItem('Сохранить плейлист', nil, SavePlaylist));
      playlistManagerMenu.Items.Add(new ToolStripMenuItem('Переименовать плейлист', nil, RenamePlaylist));
      playlistManagerMenu.Items.Add(new ToolStripSeparator);  
      playlistManagerMenu.Items.Add(new ToolStripMenuItem('Очистить плейлист', nil, ClearPlaylist));
      
      
         //  playlistMenu.Items.Add(new ToolStripMenuItem('Воспроизвести', nil, nil));
          // playlistMenu.Items.Add(new ToolStripMenuItem('Удалить', nil, nil));
      
      (Playlist_ as Control).ContextMenuStrip := playlistMenu;
      (PlaylistTabs_ as Control).ContextMenuStrip := tabMenu;
      
      Application.DoEvents;
      self.Playlist.listBox_.ItemClick += ItemClick;
      self.Playlist.listBox_.KeyDown += KDown;
      
      
      
      
      var DefPlsFilename := Path.Combine(Application.UserAppDataPath, 'default_pls.xml');
      if (Tabs.Tabs.Count = 0) then 
      begin
        Tabs.Tabs.Add(new TabInfo('Default', DefPlsFilename));
        if &File.Exists(DefPlsFilename) then
          LoadPlaylist(DefPlsFilename, true)
      end;
      
      
      self.AllowDrop := True;
      self.DragDrop += DragDropFiles;
      self.DragEnter += DragEnterFiles;
      foreach f: Form in self.OwnedForms do 
      begin
        f.AllowDrop := True;
        f.DragDrop += DragDropFiles;
        f.DragEnter += DragEnterFiles;
      end;
      
      
      timer.Elapsed += OnTimer;
      timer.Start;
      
      self.SetSliderPos('balancebar', 0.5);
      self.SetSliderPos('volumebar', currentVolume); 
      
      self.SetEditorText('quicksearch', 'Быстрый поиск'); 
      self.SliderTextChangedEvents['quicksearch'] := QuickSearch_TextChanged;
      
      // Запуск плеера
      ProcessParameters(Environment.GetCommandLineArgs);        
    end;
  end;
  
  BassPlayerState = (stopped, playing, paused);
  BassPlayer = class
  private 
    fFilename: string;
    stream: integer;
    fVolume: single;
    saveMuteVolume: single;
    fLength: integer;
    EndSyncDelegate: SYNCPROC  := nil;
    
    function GetPosition: single;
    begin
      
    end;
    
    procedure SetPosition(value: single);
    begin
      ;;;
    end;
    
    procedure SetVolume(value: single);
    begin
      fVolume := value;
      Bass.BASS_ChannelSetAttribute(stream, BassAttribute.BASS_ATTRIB_VOL, fVolume);
    end;
    
    function GetState: BassPlayerState;
    begin
      //case Bass.BASS_ChannelIsActive(stream) 
    end;
    
    procedure SetState(value: BassPlayerState);
    begin
      { if value <> State then 
      case value of 
      stopped: 
      playing:
      paused:
      end;}
    end;
  
  public 
    procedure LoadMusic(Filename: string);
    begin
      stream := Bass.BASS_StreamCreateFile(false, Filename,
        0, 0, BASSFlag.BASS_UNICODE);   
      Bass.BASS_ChannelSetSync(stream, BASSSync.BASS_SYNC_END or BASSSync.BASS_SYNC_MIXTIME, 
          0, EndSyncDelegate, IntPtr.Zero);
    end;
    
    constructor;
    begin
      if not Bass.BASS_Init(-1, 44100, 0, IntPtr.Zero, nil)  then 
        raise(new Exception('Bass Init error!'));
      volume := 1;
    end;
    
    function GetFFTData(): array of Single;
    begin
      
    end;
    
    property Filename: string read fFilename write LoadMusic;
    property Volume: single read fVolume write SetVolume;
    property Position: single read GetPosition write SetPosition;
    property Length: integer read fLength;
    property State: BassPlayerState read GetState write SetState;
    public event OnTrackEnd: System.EventHandler;
  end;


var
  PlayerFrm: Player;

begin
  PlayerFrm := new Player;
end.