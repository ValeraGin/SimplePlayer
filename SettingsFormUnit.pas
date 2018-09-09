unit SettingsFormUnit;

{$reference 'System.Windows.Forms.dll'}
{$reference 'System.Drawing.dll'}
{$reference 'System.Xml.dll'}

{$resource 'resources\settings.ico'}
{$resource 'resources\settingsCaptionPanel.BackgroundImage.png'}

interface

uses
  System.Windows.Forms,
  System.Drawing,
  System.IO,
  System.Xml;

type
  Helper = class
    class function GetDefSkinConfigFile: string;
    begin
      Result := Path.Combine(Application.StartupPath, 'skins\iSkin\skin.xml');
    end;
  end;
  
  SkinItem = class
    Author, Name, Details, ConfigFile: string;
    PreviewImage: Image;
  end;
  
  SkinsListBox = class(ListBox)  
  private 
    ActiveSkinIndex: integer;
    SkinNameFont := new System.Drawing.Font('Tahoma', 8.25, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point);
    AuthorFont := new System.Drawing.Font('Tahoma', 8.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
    DetailsFont := new System.Drawing.Font('Tahoma', 8.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
    procedure PaintItem(sender: Object; e: DrawItemEventArgs);
    begin
      var g := e.Graphics;
      if e.Index = -1 then exit;
      e.DrawBackground;
      e.DrawFocusRectangle;
      var item := Items[e.Index] as SkinItem;
      var br := new SolidBrush(Forecolor);
      if (e.State and DrawItemState.Selected) = DrawItemState.Selected  then br := new SolidBrush(SystemColors.HighlightText);
      g.DrawImage(item.PreviewImage, e.Bounds.Left + 12, e.Bounds.Top + 15);
      g.DrawString(item.Name, SkinNameFont, br, e.Bounds.Left + 150, e.Bounds.Top + 15);
      g.DrawString(item.Author, AuthorFont, br, e.Bounds.Left + 150, e.Bounds.Top + 30);
      g.DrawString(item.Details, DetailsFont, br, e.Bounds.Left + 150, e.Bounds.Top + 45);
    end;
  
  public 
    procedure LoadSkins;
    begin
      Items.Clear;
      var SkinDirs := Directory.GetDirectories(Path.Combine(Application.StartupPath, 'skins'));
      foreach s: string in SkinDirs do 
      begin
        var SkinConfigFile := Path.Combine(s, 'skin.xml');
        if &File.Exists(SkinConfigFile) then 
        begin
          var XMLSkinConfig := new XmlDocument;
          XMLSkinConfig.Load(SkinConfigFile);
          var root := XMLSkinConfig['skin'];
          var SkinInfo := root['skininfo'];
          var fi := new SkinItem; 
          fi.ConfigFile := SkinConfigFile;
          fi.Author := SkinInfo['author'].InnerText;
          fi.Name := SkinInfo['name'].InnerText;
          fi.Details := SkinInfo['details'].InnerText;
          fi.PreviewImage := Image.FromFile(Path.Combine(s, 'preview.png'));
          
          if Helper.GetDefSkinConfigFile = SkinConfigFile then
            self.SelectedIndex := Items.Add(fi)
          else Items.Add(fi);
        end;
      end;
      Invalidate;
    end;
    
    
    constructor;
    begin
      SetStyle(ControlStyles.ResizeRedraw, true);
      SetStyle(ControlStyles.AllPaintingInWmPaint, true);
      SetStyle(ControlStyles.DoubleBuffer, true);
      self.DrawMode := System.Windows.Forms.DrawMode.OwnerDrawFixed;
      self.ItemHeight := 120;
      self.DrawItem += PaintItem;
      self.LoadSkins;
      self.SelectedIndex := 1;
    end;
  end;
  
  
  SettingsForm = class(System.Windows.Forms.Form)
  private 
    tabControl1: System.Windows.Forms.TabControl;
    PlayPage: System.Windows.Forms.TabPage;
    PlaylistPage: System.Windows.Forms.TabPage;
    PlayerPage: System.Windows.Forms.TabPage;
    PluginPage: System.Windows.Forms.TabPage;
    InterfacePage: System.Windows.Forms.TabPage;
    AssociationPage: System.Windows.Forms.TabPage;
    CoverPage: System.Windows.Forms.TabPage;
    LanguagePage: System.Windows.Forms.TabPage;
    CoverListBox: SkinsListBox;
    SettingsCaption_Panel: System.Windows.Forms.Panel;
    ByDefault_Btn: System.Windows.Forms.Button;
    Aplly_Btn: System.Windows.Forms.Button;
    Cancel_Btn: System.Windows.Forms.Button;
    OK_Btn: System.Windows.Forms.Button;
    SettingsCaption_Label: System.Windows.Forms.Label;
    treeView1: System.Windows.Forms.TreeView;
    
    PlayNode := new System.Windows.Forms.TreeNode('Воспроизведение');
    PlaylistNode := new System.Windows.Forms.TreeNode('Плейлист');
    AssociationSubNode := new System.Windows.Forms.TreeNode('Ассоциация файлов');
    PlayerNode := new System.Windows.Forms.TreeNode('Плеер', 
    new System.Windows.Forms.TreeNode[1](AssociationSubNode));
    PluginNode := new System.Windows.Forms.TreeNode('Плагины');
    CoverSubNode := new System.Windows.Forms.TreeNode('Обложки');
    LanguageSubNode := new System.Windows.Forms.TreeNode('Язык интрфейса');
    InterfaceNode := new System.Windows.Forms.TreeNode('Интерфейс', 
    new System.Windows.Forms.TreeNode[2](CoverSubNode, LanguageSubNode));
    
    
    procedure treeView1_AfterSelect(sender: object; e: System.Windows.Forms.TreeViewEventArgs);
    begin
      self.SettingsCaption_Label.Text := e.Node.Text;
      if e.Node = PlayNode then tabControl1.SelectedTab := PlayPage 
      else if e.Node = PlaylistNode then tabControl1.SelectedTab := PlaylistPage
      else if e.Node = PlayerNode then tabControl1.SelectedTab := PlayerPage
      else if e.Node = PluginNode then tabControl1.SelectedTab := PluginPage
      else if e.Node = InterfaceNode then tabControl1.SelectedTab := InterfacePage
      else if e.Node = AssociationSubNode then tabControl1.SelectedTab := AssociationPage
      else if e.Node = CoverSubNode then tabControl1.SelectedTab := CoverPage
      else if e.Node = LanguageSubNode then tabControl1.SelectedTab := LanguagePage;      
    end;
    
    procedure panel1_Paint(sender: object; e: System.Windows.Forms.PaintEventArgs);
    begin
      e.Graphics.DrawRectangle(new System.Drawing.Pen(System.Drawing.SystemColors.ButtonShadow), 0, 0,
      (sender as System.Windows.Forms.Control).Bounds.Width - 1, (sender as System.Windows.Forms.Control).Bounds.Height - 1);
    end;
    
    procedure Apply_Click(sender: object; e: System.EventArgs);
    
    procedure Cancel_Click(sender: object; e: System.EventArgs);
    begin
      LoadSettings;
    end;
    
    procedure OK_Click(sender: object; e: System.EventArgs);
    begin
      Apply_Click(self.Aplly_Btn, System.EventArgs.Empty);
      Close;
    end;
    
    
    procedure InitializeComponent;
    begin
      self.tabControl1 := new System.Windows.Forms.TabControl;
      self.PlayPage := new System.Windows.Forms.TabPage;
      self.PlaylistPage := new System.Windows.Forms.TabPage;
      self.PlayerPage := new System.Windows.Forms.TabPage;
      self.PluginPage := new System.Windows.Forms.TabPage;
      self.InterfacePage := new System.Windows.Forms.TabPage;
      self.AssociationPage := new System.Windows.Forms.TabPage;
      self.CoverPage := new System.Windows.Forms.TabPage;
      self.LanguagePage := new System.Windows.Forms.TabPage;  
      self.CoverListBox := new SkinsListBox;
      
      self.SettingsCaption_Panel := new System.Windows.Forms.Panel;
      self.SettingsCaption_Label := new System.Windows.Forms.Label;
      self.ByDefault_Btn := new System.Windows.Forms.Button;
      self.Aplly_Btn := new System.Windows.Forms.Button;
      self.Cancel_Btn := new System.Windows.Forms.Button;
      self.OK_Btn := new System.Windows.Forms.Button;
      self.treeView1 := new System.Windows.Forms.TreeView();
      self.tabControl1.SuspendLayout;
      self.SettingsCaption_Panel.SuspendLayout;
      self.SuspendLayout;
      // 
      // tabControl1
      // 
      self.tabControl1.Appearance := System.Windows.Forms.TabAppearance.Buttons;
      self.tabControl1.Controls.Add(self.PlayPage);
      self.tabControl1.Controls.Add(self.PlaylistPage);
      self.tabControl1.Controls.Add(self.PlayerPage);
      self.tabControl1.Controls.Add(self.PluginPage);
      self.tabControl1.Controls.Add(self.InterfacePage);   
      self.tabControl1.Controls.Add(self.AssociationPage);
      self.tabControl1.Controls.Add(self.CoverPage);
      self.tabControl1.Controls.Add(self.LanguagePage);       
      self.tabControl1.ItemSize := new System.Drawing.Size(0, 1);
      self.tabControl1.Location := new System.Drawing.Point(195, 36);
      self.tabControl1.SelectedIndex := 0;
      self.tabControl1.Size := new System.Drawing.Size(415, 377);
      self.tabControl1.SizeMode := System.Windows.Forms.TabSizeMode.Fixed;
      self.tabControl1.TabIndex := 3;
      // 
      // PlayPage
      // 
      self.PlayPage.BackColor := System.Drawing.SystemColors.Control;
      self.PlayPage.ForeColor := System.Drawing.SystemColors.ControlText;
      self.PlayPage.Location := new System.Drawing.Point(4, 5);
      self.PlayPage.Padding := new System.Windows.Forms.Padding(3);
      self.PlayPage.Size := new System.Drawing.Size(407, 368);
      self.PlayPage.TabIndex := 1;
      self.PlayPage.Paint += self.panel1_Paint;
      // 
      // PlaylistPage
      // 
      self.PlaylistPage.BackColor := System.Drawing.SystemColors.Control;
      self.PlaylistPage.Location := new System.Drawing.Point(4, 5);
      self.PlaylistPage.Padding := new System.Windows.Forms.Padding(3);
      self.PlaylistPage.Size := new System.Drawing.Size(407, 368);
      self.PlaylistPage.TabIndex := 2;
      self.PlaylistPage.UseVisualStyleBackColor := true;
      self.PlaylistPage.Paint += self.panel1_Paint;
      // 
      // PlayerPage
      // 
      self.PlayerPage.Location := new System.Drawing.Point(4, 5);
      self.PlayerPage.Padding := new System.Windows.Forms.Padding(3);
      self.PlayerPage.Size := new System.Drawing.Size(407, 368);
      self.PlayerPage.TabIndex := 3;
      self.PlayerPage.UseVisualStyleBackColor := true;
      self.PlayerPage.Paint += self.panel1_Paint;
      // 
      // PluginPage
      // 
      self.PluginPage.Location := new System.Drawing.Point(4, 5);
      self.PluginPage.Padding := new System.Windows.Forms.Padding(3);
      self.PluginPage.Size := new System.Drawing.Size(407, 368);
      self.PluginPage.TabIndex := 4;
      self.PluginPage.UseVisualStyleBackColor := true;
      self.PluginPage.Paint += self.panel1_Paint;
      // 
      // InterfacePage
      // 
      self.InterfacePage.Location := new System.Drawing.Point(4, 5);
      self.InterfacePage.Padding := new System.Windows.Forms.Padding(3);
      self.InterfacePage.Size := new System.Drawing.Size(407, 368);
      self.InterfacePage.TabIndex := 5;
      self.InterfacePage.UseVisualStyleBackColor := true;
      self.InterfacePage.Paint += self.panel1_Paint;
      // 
      // AssociationPage
      // 
      self.AssociationPage.Location := new System.Drawing.Point(4, 5);
      self.AssociationPage.Padding := new System.Windows.Forms.Padding(3);
      self.AssociationPage.Size := new System.Drawing.Size(407, 368);
      self.AssociationPage.TabIndex := 6;
      self.AssociationPage.UseVisualStyleBackColor := true;
      self.AssociationPage.Paint += self.panel1_Paint;
      // 
      // CoverPage
      // 
      self.CoverListBox.FormattingEnabled := true;
      //   self.CoverListBox.Dock := DockStyle.Fill;
      self.CoverListBox.Size := new System.Drawing.Size(403, 363);
      self.CoverListBox.TabIndex := 0;
      
      self.CoverPage.Controls.Add(CoverListBox); 
      self.CoverPage.Location := new System.Drawing.Point(4, 5);
      self.CoverPage.Padding := new System.Windows.Forms.Padding(3);
      self.CoverPage.Size := new System.Drawing.Size(407, 368);
      self.CoverPage.TabIndex := 4;
      self.CoverPage.UseVisualStyleBackColor := true;
      self.CoverPage.Paint += self.panel1_Paint;
      // 
      // LanguagePage
      // 
      self.LanguagePage.Location := new System.Drawing.Point(4, 5);
      self.LanguagePage.Padding := new System.Windows.Forms.Padding(3);
      self.LanguagePage.Size := new System.Drawing.Size(407, 368);
      self.LanguagePage.TabIndex := 5;
      self.LanguagePage.UseVisualStyleBackColor := true;
      self.LanguagePage.Paint += self.panel1_Paint;
      // 
      // SettingsCaption_Panel
      // 
      self.SettingsCaption_Panel.BackColor := System.Drawing.SystemColors.Control;
      self.SettingsCaption_Panel.BackgroundImage := System.Drawing.Image.FromStream(GetResourceStream('settingsCaptionPanel.BackgroundImage.png'));
      self.SettingsCaption_Panel.Controls.Add(self.SettingsCaption_Label);
      self.SettingsCaption_Panel.Location := new System.Drawing.Point(199, 8);
      self.SettingsCaption_Panel.Size := new System.Drawing.Size(407, 22);
      self.SettingsCaption_Panel.TabIndex := 4;
      self.SettingsCaption_Panel.Paint += self.panel1_Paint;
      // 
      // SettingsCaption_Label
      // 
      self.SettingsCaption_Label.BackColor := System.Drawing.Color.Transparent;
      self.SettingsCaption_Label.Font := new System.Drawing.Font('Tahoma', 9.75, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
      self.SettingsCaption_Label.Location := new System.Drawing.Point(1, 1);
      self.SettingsCaption_Label.Size := new System.Drawing.Size(405, 21);
      self.SettingsCaption_Label.TabIndex := 0;
      self.SettingsCaption_Label.Text := 'Воспроизведение';
      self.SettingsCaption_Label.TextAlign := System.Drawing.ContentAlignment.MiddleCenter;
      // 
      // ByDefault_Btn
      // 
      self.ByDefault_Btn.Font := new System.Drawing.Font('Tahoma', 9.75, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
      self.ByDefault_Btn.Location := new System.Drawing.Point(6, 416);
      self.ByDefault_Btn.Size := new System.Drawing.Size(137, 25);
      self.ByDefault_Btn.TabIndex := 6;
      self.ByDefault_Btn.Text := 'По умолчанию';
      self.ByDefault_Btn.UseVisualStyleBackColor := true;
      // 
      // Aplly_Btn
      // 
      self.Aplly_Btn.Font := new System.Drawing.Font('Tahoma', 9.75, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
      self.Aplly_Btn.Location := new System.Drawing.Point(510, 416);
      self.Aplly_Btn.Size := new System.Drawing.Size(97, 25);
      self.Aplly_Btn.TabIndex := 7;
      self.Aplly_Btn.Text := 'Применить';
      self.Aplly_Btn.UseVisualStyleBackColor := true;
      self.Aplly_Btn.Click += self.Apply_Click;
      // 
      // Cancel_Btn
      // 
      self.Cancel_Btn.Font := new System.Drawing.Font('Tahoma', 9.75, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
      self.Cancel_Btn.Location := new System.Drawing.Point(406, 416);
      self.Cancel_Btn.Size := new System.Drawing.Size(97, 25);
      self.Cancel_Btn.TabIndex := 8;
      self.Cancel_Btn.Text := 'Отмена';
      self.Cancel_Btn.UseVisualStyleBackColor := true;
      self.Cancel_Btn.Click += self.Cancel_Click;
      // 
      // OK_Btn
      // 
      self.OK_Btn.Font := new System.Drawing.Font('Tahoma', 9.75, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
      self.OK_Btn.Location := new System.Drawing.Point(302, 416);
      self.OK_Btn.Size := new System.Drawing.Size(97, 25);
      self.OK_Btn.TabIndex := 9;
      self.OK_Btn.Text := 'OK';
      self.OK_Btn.UseVisualStyleBackColor := true;
      self.OK_Btn.Click += self.OK_Click;
      // 
      // treeView1
      // 
      self.treeView1.Location := new System.Drawing.Point(6, 9);
      self.treeView1.Nodes.AddRange( new System.Windows.Forms.TreeNode[5](
        PlayNode,
        PlaylistNode,
        PlayerNode,
        PluginNode,
        InterfaceNode));
      self.treeView1.Size := new System.Drawing.Size(187, 400);
      self.treeView1.TabIndex := 10;
      self.treeView1.AfterSelect += self.treeView1_AfterSelect;
      // 
      // SettingsForm
      // 
      self.Icon := new System.Drawing.Icon(GetResourceStream('settings.ico'));
      self.AutoScaleDimensions := new System.Drawing.SizeF(6, 13);
      self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
      self.ClientSize := new System.Drawing.Size(610, 444);
      self.Controls.Add(self.treeView1);
      self.Controls.Add(self.OK_Btn);
      self.Controls.Add(self.Cancel_Btn);
      self.Controls.Add(self.Aplly_Btn);
      self.Controls.Add(self.ByDefault_Btn);
      self.Controls.Add(self.SettingsCaption_Panel);
      self.Controls.Add(self.tabControl1);
      self.FormBorderStyle := System.Windows.Forms.FormBorderStyle.FixedSingle;
      self.MaximizeBox := false;
      self.Name := 'SettingsForm';
      self.StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen;
      self.Text := 'Настройки';
      self.tabControl1.ResumeLayout(false);
      self.SettingsCaption_Panel.ResumeLayout(false);
      self.ResumeLayout(false);
      self.PerformLayout;
    end;
    
    function GetCurrentSkinConfigFile: string;
    begin
      if CoverListBox.SelectedIndex <> -1 then
      begin
        result := (CoverListBox.SelectedItem as SkinItem).ConfigFile
      end 
      else 
        result := Helper.GetDefSkinConfigFile;
    end;
  
  public 
    procedure ShowSkinPage;
    begin
      self.treeView1.SelectedNode := CoverSubNode;
    end;
    
    procedure LoadSettings;
    begin
      var SettingsFile := Path.Combine(Application.UserAppDataPath, 'settings.xml');
      
      if not &File.Exists(SettingsFile) then
      begin
        var selItem2: object;
        foreach a: SkinItem in self.CoverListBox.Items do 
        begin
          if a.ConfigFile = Helper.GetDefSkinConfigFile then
            selItem2 := a;
        end;
        if selItem2 <> nil then self.CoverListBox.SelectedItem := selItem2;
        exit;
      end;
      
      var doc := new XmlDocument();
      doc.Load(SettingsFile);
      var root := doc['settings'];
      
      var selItem: object;
      foreach a: SkinItem in self.CoverListBox.Items do 
      begin
        if a.ConfigFile = root['currentskin'].InnerText then
          selItem := a;
      end;
      if selItem <> nil then self.CoverListBox.SelectedItem := selItem
      else 
      begin
        var selItem2: object;
        foreach a: SkinItem in self.CoverListBox.Items do 
        begin
          if a.ConfigFile = Helper.GetDefSkinConfigFile then
            selItem2 := a;
        end;
        if selItem2 <> nil then self.CoverListBox.SelectedItem := selItem2
      end;
      
      self.CoverListBox.ActiveSkinIndex := self.CoverListBox.SelectedIndex;
    end;
    
    constructor;
    begin
      self.InitializeComponent;
      self.LoadSettings;
    end;
    
    property CurrentSkinConfigFile: string read GetCurrentSkinConfigFile;
  end;

implementation

uses
  PlayerForm;

procedure SettingsForm.Apply_Click(sender: object; e: System.EventArgs);
begin
  if CoverListBox.ActiveSkinIndex <> CoverListBox.SelectedIndex then 
    if MessageBox.Show('Для измения скина необходимо перезагрузить плеер. Перезапустить приложение ?', 'Применение настроек.', MessageBoxButtons.YesNo) =
        System.Windows.Forms.DialogResult.Yes then
    begin
      PlayerFrm.SaveSettings;
      Application.Restart;
    end;
end;

end.