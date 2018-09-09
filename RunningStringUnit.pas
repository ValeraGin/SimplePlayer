unit RunningStringUnit;

{$reference 'System.Windows.Forms.dll'}
{$reference 'System.Drawing.dll'}

uses
  System,
  System.Drawing,
  System.Windows.Forms;

type
  RunningString = class(Panel)  
  private 
    skin: Image;
    font: System.Drawing.Font;
    color: System.Drawing.Color;
    
    /// промежуток между концом и началом
    indent := 15;
    text: string;
    textwidth: integer;
    gWidth: integer;
    moveTimer: Timer;
    pos: integer;
    
    infoTimer: Timer;
    infoText: string;
    
    isMouseDown := false;
    PosXDown: integer;
    TextPosDown: integer;
    
    procedure setText(value: string);
    begin
      text := value;
      textwidth := Graphics.FromHwnd(self.Handle).MeasureString(text, font).ToSize.Width;
      gWidth := textwidth;
      if textwidth < self.Width then
        gWidth := self.Width;
      pos := 0;
      Invalidate;
      moveTimer.Enabled := True;
    end;
    
    procedure infoTimer_Tick(sender: Object; e: System.EventArgs);
    begin
      infoTimer.Enabled := False;
      setText(text);
      moveTimer.Enabled := True;
    end;
    
    procedure moveTimer_Tick(sender: Object; e: System.EventArgs);
    begin
      if not isMouseDown then 
      begin
        pos += 1;
        if pos >= gWidth + indent
          then pos := 0;
        Invalidate;
      end;
    end;
    
    procedure RunningString_Paint(sender: Object; e: PaintEventArgs);
    begin
      var g := e.Graphics;
      var srcRect := new System.Drawing.Rectangle(0, 0, skin.Width, skin.Height div 2);
      var srcRect2 := new System.Drawing.Rectangle(0, skin.Height div 2, skin.Width, skin.Height div 2);
      var destRect := new System.Drawing.Rectangle(0, 0, skin.Width, skin.Height div 2);
      g.DrawImage(skin, destRect, srcRect, GraphicsUnit.Pixel);
      if moveTimer.Enabled then
      begin
        var textDestRect := new System.Drawing.Rectangle(-pos, 0, textwidth + 1, Height);
        g.DrawString(text, font, new SolidBrush(color), textDestRect, new StringFormat(StringFormatFlags.NoWrap));
        var textDestRect2 := new System.Drawing.Rectangle(-pos + indent + gWidth, 0, textwidth + 1, Height);
        g.DrawString(text, font, new SolidBrush(color), textDestRect2, new StringFormat(StringFormatFlags.NoWrap));
      end
      else if infoTimer.Enabled then
      begin
        var infotextwidth := g.MeasureString(infotext, font).ToSize.Width;
        var textDestRect := new System.Drawing.Rectangle((width div 2) - (infotextwidth div 2), 0, infotextwidth + 1, Height);
        g.DrawString(infoText, font, new SolidBrush(color), textDestRect, new StringFormat(StringFormatFlags.NoWrap));
      end;
      g.DrawImage(skin, destRect, srcRect2, GraphicsUnit.Pixel);
    end;
    
    procedure RunningString_MouseDown(sender: Object; e: MouseEventArgs);
    begin
      isMouseDown := true;
      PosXDown := e.X;
      TextPosDown := pos;
    end;
    
    procedure RunningString_MouseMove(sender: Object; e: MouseEventArgs);
    begin
      if isMouseDown then
      begin
        pos := PosXDown - e.X + TextPosDown;
        if pos >= gWidth + indent
          then pos := (pos mod (gWidth + indent));
        if pos < 0
          then pos := (pos mod (gWidth + indent))+(gWidth + indent);
        Invalidate;
      end;
    end;
    
    procedure RunningString_MouseUp(sender: Object; e: MouseEventArgs);
    begin
      isMouseDown := false;
    end;
  
  public 
    constructor(skin: Image; font: System.Drawing.Font; color: System.Drawing.Color);
    begin
      SetStyle(ControlStyles.OptimizedDoubleBuffer 
        or ControlStyles.ResizeRedraw
        or ControlStyles.Selectable  
        or ControlStyles.AllPaintingInWmPaint
        or ControlStyles.UserPaint, true);
        
      Size := new System.Drawing.Size(skin.Width, skin.Height div 2);

      self.skin := skin;
      self.font := font;
      self.color := color;
      
      moveTimer := new Timer;
      moveTimer.Interval := 20;  // Важно: интервал таймера
      moveTimer.Tick += moveTimer_Tick;
      
      infoTimer := new Timer;
      infoTimer.Tick += infoTimer_Tick;
      
      self.Paint += RunningString_Paint;
      
      self.MouseMove += RunningString_MouseMove;
      self.MouseDown += RunningString_MouseDown;
      self.MouseUp += RunningString_MouseUp;
    end;
    
    property RunText: string write setText read text;
    procedure ShowInfoText(infoText: string; duration: integer);
    begin
      moveTimer.Enabled := False;
      self.infoText := infoText;
      infoTimer.Interval := duration;
      infoTimer.Start;
      Invalidate;
    end;
  end;

end.