unit PlayerTabs;

{$reference 'System.Windows.Forms.dll'}
{$reference 'System.Drawing.dll'}

uses
  System.Drawing,
  System.Windows.Forms,
  System.Collections.Generic,
  
  SkinControls;

type
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
  
  PlaylistTabs = class(UserControl)
  protected 
    tabnormaltextfont,  
    tabplayingtextfont,   
    tabactivetextfont,
    tabactiveplayingtextfont: System.Drawing.Font;
    
    tabnormaltextcolor,
    tabplayingtextcolor,
    tabactivetextcolor,
    tabactiveplayingtextcolor: Color;
    
    
    tabsskin: System.Drawing.Image;
    
    fActiveTabIndex := 0;
    PlayingTabIndex_ := 0;
    fTabs := new List<TabInfo>;
    
    mouseOffset: Point;
    isMouseDown := false;
    
    fTopTab := 0;
    
    procedure SetTopTab(value: integer);
    begin
      if fTopTab = value then exit;
      fTopTab := value;
      self.Invalidate;
    end;
    
    procedure DownEvent(sender: Object; e: MouseEventArgs);
    begin
      for var i := fTopTab  to fTabs.Count - 1 do 
      begin
        var destRect := new System.Drawing.Rectangle((i - fTopTab) * self.tabsskin.Width, 0, self.tabsskin.Width, (self.tabsskin.Height div 2));
        if destrect.Contains(e.Location) then
        begin
          if i = fActiveTabIndex then exit;
          if ChangeTab <> nil then ChangeTab(i);
          exit;
        end;
      end;
      
      if e.Button = System.Windows.Forms.MouseButtons.Left then 
      begin
        isMouseDown := true;
        var ec := new MouseEventArgs(e.Button, e.Clicks, e.Location.X + self.Left, e.Location.Y + self.Top, e.Delta); 
        self.Parent.OnMouseDown(ec);
      end;
    end;
    
    procedure MoveEvent(sender: Object; e: MouseEventArgs);
    begin
      self.Cursor := Cursors.Default;
      for var i := fTopTab  to fTabs.Count - 1 do 
      begin
        if i = self.fActiveTabIndex then continue;
        var destRect := new System.Drawing.Rectangle((i - fTopTab) * self.tabsskin.Width, 0, self.tabsskin.Width, (self.tabsskin.Height div 2));
        if destrect.Contains(e.Location) then
        begin
          self.Cursor := Cursors.Hand;
          exit;
        end;
      end;
      
      if isMouseDown and (e.Button = System.Windows.Forms.MouseButtons.Left) then 
      begin
        var ec := new MouseEventArgs(e.Button, e.Clicks, e.Location.X + self.Left, e.Location.Y + self.Top, e.Delta); 
        self.Parent.OnMouseMove(ec);
      end;
    end;
    
    procedure UpEvent(sender: Object; e: MouseEventArgs);
    begin
      if isMouseDown then 
      begin
        var ec := new MouseEventArgs(e.Button, e.Clicks, e.Location.X + self.Left, e.Location.Y + self.Top, e.Delta); 
        self.Parent.OnMouseUp(ec);
      end;
      isMouseDown := false;
    end;
    
    
    procedure PaintEvent(sender: Object; e: PaintEventArgs);
    begin
      var g := e.Graphics;
      for var i := fTopTab to fTabs.Count - 1 do 
      begin
        var font := tabnormaltextfont;
        var color := tabnormaltextcolor;
        if i = PlayingTabIndex_ then 
        begin
          font := tabplayingtextfont;
          color := tabplayingtextcolor;
        end;
        var state := 0;
        if i = fActiveTabIndex then
        begin
          state := 1;
          if i = PlayingTabIndex_ then
          begin
            font := tabactiveplayingtextfont;
            color := tabactiveplayingtextcolor; 
          end
          else
          begin
            font := tabactiveplayingtextfont;
            color := tabactiveplayingtextcolor;
          end;
        end;
        var srcRect := new System.Drawing.Rectangle(0, state * (self.tabsskin.Height div 2), self.tabsskin.Width, (self.tabsskin.Height div 2));
        var destRect := new System.Drawing.Rectangle((i - fTopTab) * self.tabsskin.Width, 0, self.tabsskin.Width, (self.tabsskin.Height div 2));
        g.DrawImage(tabsskin, destRect, srcRect, GraphicsUnit.Pixel);
        var size := g.MeasureString(fTabs[i].TabName, font).ToSize;
        
        if size.Width < destRect.Width then 
          destRect.X := destRect.X + (destRect.Width div 2) - (size.Width div 2)
        else 
          destRect.X += 1;
        
        if size.Height < destRect.Height then 
          destRect.Y := destRect.Y + (destRect.Height div 2) - (size.Height div 2)
        else 
          destRect.Y += 1;
        
        
        g.DrawString(fTabs[i].TabName, font, new SolidBrush(color),  destRect, new StringFormat(StringFormatFlags.NoWrap));
      end;
    end;
  
  public 
    constructor(
        tabnormaltextfont,  
        tabplayingtextfont,   
        tabactivetextfont,
        tabactiveplayingtextfont: System.Drawing.Font;
        
        tabnormaltextcolor,
        tabplayingtextcolor,
        tabactivetextcolor,
        tabactiveplayingtextcolor: Color;
        
        tabsskin: System.Drawing.Image);
    begin
      self.tabsskin := tabsskin;
      
      self.tabnormaltextfont := tabnormaltextfont;  
      self.tabplayingtextfont := tabplayingtextfont;    
      self.tabactivetextfont := tabactivetextfont; 
      self.tabactiveplayingtextfont := tabactiveplayingtextfont; 
      
      self.tabnormaltextcolor := tabnormaltextcolor; 
      self.tabplayingtextcolor := tabplayingtextcolor; 
      self.tabactivetextcolor := tabactivetextcolor; 
      self.tabactiveplayingtextcolor := tabactiveplayingtextcolor;
      
      self.BackColor := Color.Transparent;
      
      self.Paint += PaintEvent;
      self.MouseDown += DownEvent;
      self.MouseMove += MoveEvent;
      self.MouseUp += UpEvent;
    end;
    
    
    property TopTab: integer read fTopTab write setTopTab;
    property Tabs: List<TabInfo> read fTabs write fTabs;
    property ActiveTabIndex: integer read fActiveTabIndex write fActiveTabIndex;
    public event ChangeTab: procedure(TabIndex: integer);
  end;
  
  TabsContainer = class(UserControl)
  private 
    procedure PrevClick(sender: Object; e: System.EventArgs);
    begin
      if tabs.TopTab = 0 then exit;
      tabs.TopTab -= 1;
    end;
    
    procedure NextClick(sender: Object; e: System.EventArgs);
    begin
      if tabs.TopTab = tabs.Tabs.Count - 1 then exit;
      tabs.TopTab += 1;
    end;
  public 
    Tabs: PlaylistTabs;
    nextButton, prevButton: PlayerButton;
    constructor(
        tabnormaltextfont,  
        tabplayingtextfont,   
        tabactivetextfont,
        tabactiveplayingtextfont: System.Drawing.Font;
        
        tabnormaltextcolor,
        tabplayingtextcolor,
        tabactivetextcolor,
        tabactiveplayingtextcolor: Color;
        
        tabsskin, tabprevb, tabnextb: System.Drawing.Image);
    begin
      
      self.BackColor := Color.Transparent;
      
      prevButton := new PlayerButton(tabprevb);  
      prevButton.Click += PrevClick;
      prevButton.Dock := DockStyle.Right;
      
      nextButton := new PlayerButton(tabnextb);
      nextButton.Click += NextClick;
      nextButton.Dock := DockStyle.Right;
      
      tabs := new PlaylistTabs(
        tabnormaltextfont,  
        tabplayingtextfont,   
        tabactivetextfont,
        tabactiveplayingtextfont,
        tabnormaltextcolor,
        tabplayingtextcolor,
        tabactivetextcolor,
        tabactiveplayingtextcolor,
        tabsskin);
      tabs.Dock := DockStyle.Fill;
      
      self.Controls.Add(tabs);
      self.Controls.Add(prevButton);
      self.Controls.Add(nextButton);
    end;
  end;
  
end.