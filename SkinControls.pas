unit SkinControls;

{$reference 'System.Windows.Forms.dll'}
{$reference 'System.Drawing.dll'}

uses
  System.Drawing,
  System.Windows.Forms;

type
  Editor = class(TextBox)
  private
    fWelcomeText: string;
    procedure SetWelcomeText(value: string);
    begin
      fWelcomeText := value;
      Text := value;
    end;
    procedure Editor_GotFocus(sender: Object; e: System.EventArgs);
    begin
      Text := String.Empty;
    end;
    procedure Editor_LostFocus(sender: Object; e: System.EventArgs);
    begin
      Text := fWelcomeText;
    end;
  public
    property WelcomeText: string read fWelcomeText write SetWelcomeText;
    constructor;
    begin
      BorderStyle := System.Windows.Forms.BorderStyle.None;
      self.GotFocus += Editor_GotFocus;
      self.LostFocus  += Editor_LostFocus;
    end;
  end;

  /// Кнопка
  PlayerButton = class(UserControl)
  private 
    state, states: integer;
    count: integer;
    imgWidth: integer;
    imgs: Image;
    ImgIndex: integer;
    isMouseDown := false;
    
    procedure SetState(i: integer);
    begin
      if not (i < states) then exit;
      var temp := state;
      state := i;
      if state <> temp then Refresh;
    end;
    
    procedure setImageIndex(i: integer);
    begin
      var temp := ImgIndex;
      ImgIndex := i;
      if ImgIndex <> temp then Refresh;
    end;
    
    procedure Down(sender: Object; e: MouseEventArgs);
    begin
      isMouseDown := true;
      ImageIndex := 2;
    end;
    
    procedure Up(sender: Object; e: MouseEventArgs);
    begin
      isMouseDown := false;
      ImageIndex := 1;
    end;
    
    procedure Move(sender: Object; e: MouseEventArgs);
    begin
      if isMouseDown then 
        ImageIndex := 2
      else 
        ImageIndex := 1;
    end;
    
    procedure Leave(sender: Object; e: System.EventArgs);
    begin
      isMouseDown := false;
      ImageIndex := 0;
    end;
    
    procedure PaintButton(sender: Object; e: PaintEventArgs);
    begin
      var g := e.Graphics;
      if ImageIndex >= Count then ImageIndex := count - 1;
      var srcRect: Rectangle := new System.Drawing.Rectangle(((ImageIndex * imgWidth + (state * count * imgWidth))), 0, imgWidth, imgs.Height);
      var destRect: Rectangle := new System.Drawing.Rectangle(0, 0, imgWidth, imgs.Height);
      g.DrawImage(imgs, destRect, srcRect, GraphicsUnit.Pixel);
    end;
  
  public 
    constructor(imgs: System.Drawing.Image; states: integer := 1; setCount: integer := 4);
    begin
      SetStyle(ControlStyles.ResizeRedraw, true);
      SetStyle(ControlStyles.AllPaintingInWmPaint, true);
      SetStyle(ControlStyles.DoubleBuffer, true);
    
      self.states := states;
      state := 0;
      count := setCount;
      imgWidth := imgs.Width div (setCount * states);
      self.imgs := imgs;
      ImageIndex := 0;
      
      self.Paint += PaintButton;
      
      MouseMove += Move;
      MouseLeave += Leave;
      MouseDown += Down;
      MouseUp += Up;
      ClientSize := new System.Drawing.Size(imgWidth, imgs.Height);
    end;
    
    property CurState: integer read state write SetState;
    property ImageIndex: integer read ImgIndex write setImageIndex;
  end;
  
  /// Скроллбар
  PlayerScrollbar = class(UserControl)
  private 
    _minimum := 0;
    _maximum := 100;
    _smallChange := 1;
    _largeChange := 10;
    _value := 0;
    
    
    
    clickPoint: integer;
    movingPoint: integer;
    _thumbDown := false;
    
    thumbImage: Image;
    
    ButtonDown, ButtonUp: PlayerButton; 
    
    btnUpImageHeight := 0;
    btnDownImageHeight := 0;
    
    progressTimer: Timer;
    /// Подсчет тактов
    progressTimerTickCount: integer;
    /// Через сколько тактов увеличить скорость прокрутки
    SpeedUpCount: integer; 
    DirectionUp: boolean; 
    
    /// Максимально допустимый интервал
    const MaxInterval = 10;
    
    procedure progressTimer_Tick(sender: Object; e: System.EventArgs);
    begin
      if DirectionUp then Value -= SmallChange else Value += SmallChange;
      if progressTimerTickCount >= SpeedUpCount then
        if progressTimer.Interval > MaxInterval then
        begin
          progressTimer.Interval := progressTimer.Interval div 2;
          progressTimerTickCount := 0;
          SpeedUpCount := SpeedUpCount * 2;
        end;
      progressTimerTickCount += 1;
      DoEvent;
    end;
    
    procedure EnableProgressTimer;
    begin
      progressTimer.Interval := 400;
      progressTimer.Enabled := True;
      progressTimerTickCount := 0;
      SpeedUpCount := 1;
    end;
    
    procedure ButtonUp_MouseDown(sender: Object; e: MouseEventArgs);
    begin
      DirectionUp := True;
      EnableProgressTimer;
    end;
    
    procedure ButtonDown_MouseDown(sender: Object; e: MouseEventArgs);
    begin
      DirectionUp := False;
      EnableProgressTimer;
    end;
    
    procedure ArrowButton_MouseUp(sender: Object; e: MouseEventArgs);
    begin
      progressTimer.Enabled := False;
    end;
    
    procedure DoEvent;
    begin
      if (ValueChanged <> nil) then
        ValueChanged(self, new System.EventArgs());
      if (Scroll <> nil) then
        Scroll(self, new System.EventArgs());
    end;
    
    procedure ButtonUp_Click(sender: Object; e: System.EventArgs);
    begin
      Value -= SmallChange;
      DoEvent;
    end;
    
    procedure ButtonDown_Click(sender: Object; e: System.EventArgs);
    begin
      Value += SmallChange;
      DoEvent;
    end;
    
    procedure SetMinimum(value: integer);
    begin
      _minimum := value;
      Invalidate;
    end;
    
    procedure SetMaximum(value: integer);
    begin
      _maximum := value;
      Invalidate;
    end;
    
    procedure SetSmallChange(value: integer);
    begin
      _smallChange := value;
      Invalidate;
    end;
    
    procedure SetLargeChange(value: integer);
    begin
      _largeChange := value;
      Invalidate;
    end;
    
    procedure SetValue(value: integer);
    begin
      if value > (Maximum - LargeChange) then
        value := Maximum - LargeChange;
      if value < Minimum then
        value := Minimum;
      _value := value;
      Invalidate;
    end;
    
    procedure SetButtonUpImg(img: Image);
    begin
      if ButtonUp <> nil then Controls.Remove(ButtonUp);
      ButtonUp := new PlayerButton(img);
      ButtonUp.MouseDown += ButtonUp_MouseDown;
      ButtonUp.MouseUp += ArrowButton_MouseUp;
      ButtonUp.Click += ButtonUp_Click;
      ButtonUp.Dock := DockStyle.Top;
      Controls.Add(ButtonUp);
      btnUpImageHeight := ButtonUp.Height;
      Invalidate;
    end;
    
    procedure SetButtonDownImg(img: Image);
    begin
      if ButtonDown <> nil then Controls.Remove(ButtonDown);
      ButtonDown := new PlayerButton(img);
      ButtonDown.Click += ButtonDown_Click;
      ButtonDown.MouseDown += ButtonDown_MouseDown;
      ButtonDown.MouseUp += ArrowButton_MouseUp;
      ButtonDown.Dock := DockStyle.Bottom;
      Controls.Add(ButtonDown);
      btnDownImageHeight := ButtonDown.Height;
      Invalidate;
    end;
    
    procedure SetThumb(img: Image);
    begin
      thumbImage := img;
      Invalidate;
    end;
    
    function GetThumbRect: Rectangle;
    begin
      
    
      var trackHeight := (self.Height - (btnUpImageHeight + btnDownImageHeight));
      var pixelRange := trackHeight - thumbImage.Height;
      var realRange := (Maximum - Minimum) - LargeChange;
      var perc := 0.0;
      if realRange <> 0 then
        perc := real(Value) / real(realRange);
        
      var thumbTop : integer; 
      if _thumbDown then 
      begin
        thumbTop := movingPoint;
        if thumbTop < btnDownImageHeight then thumbTop:= btnDownImageHeight else if thumbTop > pixelRange + btnUpImageHeight then thumbTop := pixelRange + btnUpImageHeight;
      end
      else
        thumbTop := round(perc * pixelRange) + btnDownImageHeight;
      
      
      Result := new Rectangle((Width div 2) - (thumbImage.Width div 2), thumbTop,
         thumbImage.Width, thumbImage.Height);
    end;
    
    procedure MoveThumb(y: integer);
    begin
      var trackHeight := (self.Height - (btnUpImageHeight + btnDownImageHeight));
      var pixelRange := trackHeight - thumbImage.Height;
      var realRange := (Maximum - Minimum) - LargeChange;
      var thumbTop := y - (btnUpImageHeight + clickPoint);
      var perc := thumbTop / pixelRange;
      Value := round(perc * realRange);
      Refresh;
    end;
    
    procedure PlayerScrollbar_Down(sender: Object; e: MouseEventArgs);
    begin
      var thumbRect := GetThumbRect;
      if thumbRect.Contains(e.Location) then
      begin
        clickPoint := (e.Y - thumbRect.Y);
        movingPoint := e.Y - clickPoint;
        _thumbDown := true;
      end;
    end;
    
    procedure PlayerScrollbar_Up(sender: Object; e: MouseEventArgs);
    begin
      _thumbDown := False;
      Refresh;
    end;
    
    procedure PlayerScrollbar_Move(sender: Object; e: MouseEventArgs);
    begin
      if _thumbDown then 
      begin
        MoveThumb(e.Y);
        movingPoint := e.Y - clickPoint;
        DoEvent;
      end;
    end;
    
    procedure PlayerScrollbar_Paint(sender: Object; e: PaintEventArgs);
    begin
      var realRange := (Maximum - Minimum) - LargeChange;
      if realRange > 0 then
          e.Graphics.DrawImage(thumbImage, GetThumbRect)// Мастер одной строчки
       else if Value <> 0 then 
       begin
         Value := 0;
         DoEvent; 
       end;
    end;
    
    procedure InitializeComponent;
    begin
      Paint += PlayerScrollbar_Paint;
      MouseDown += PlayerScrollbar_Down;
      MouseMove += PlayerScrollbar_Move;
      MouseUp += PlayerScrollbar_Up;
      
      progressTimer := new Timer;
      progressTimer.Tick += progressTimer_Tick;
    end;
  
  public 
    constructor(thumbImage: Image);
    begin
      SetStyle(ControlStyles.ResizeRedraw, true);
      SetStyle(ControlStyles.AllPaintingInWmPaint, true);
      SetStyle(ControlStyles.DoubleBuffer, true);
      
      self.thumbImage := thumbImage;
      InitializeComponent;
    end;
    
    constructor(thumbImage, btnUpImage, btnDownImage: Image);
    begin
      Create(thumbImage);
      self.ButtonUpImage := btnUpImage;
      self.ButtonDownImage := btnDownImage;
    end;
    
    property Minimum: integer read _minimum write SetMinimum;
    property Maximum: integer read _maximum write SetMaximum;
    
    property SmallChange: integer read _smallChange write SetSmallChange;
    property LargeChange: integer read _largeChange write SetLargeChange;
    
    property Value: integer read _value write SetValue;
    
    property Thumb: Image read thumbImage write SetThumb;
    property ButtonUpImage: Image write SetButtonUpImg;
    property ButtonDownImage: Image write SetButtonDownImg;
    
    public event Scroll: System.EventHandler;
    public event ValueChanged: System.EventHandler;
  end;
  
  /// Показывает время или другую информацию со шрифтом по скину
  PlayerTime = class(UserControl)
  private 
    CharWidth: integer;
    Skin: Image;
    ShowTime := True;
    
    function GetImageNumber(c: char): integer;
    begin
      result := 12; // пустота
      case ord(c) of 
        45: result := 11;
        48..57: result := ord(c) - 48;
        58: result := 10 ;
      end;
    end;
    
    procedure PlayerTime_Click(sender: Object; e: System.EventArgs);
    begin
      ShowTime := not ShowTime;
      Invalidate;
    end;
    
    procedure PlayerTime_Paint(sender: Object; e: PaintEventArgs);
    begin
      var g := e.Graphics;
      var s := Time;
      if not ShowTime then s := TimeLeft;
      for var i := 1 to s.Length do
        g.DrawImage(Skin, 
        new System.Drawing.Rectangle((i - 1) * CharWidth, 0, CharWidth, Height), 
        new System.Drawing.Rectangle(CharWidth * GetImageNumber(s[i]), 0, CharWidth, Height),
        GraphicsUnit.Pixel);
    end;
    
    procedure InitializeComponent;
    begin
      Paint += PlayerTime_Paint;
      Click += PlayerTime_Click;
    end;
  
  public 
    Time := ' 00:00';
    TimeLeft := '-00:00';
    constructor(Skin: Image);
    begin
      self.Skin := Skin;
      BackColor := Color.Transparent;
      SetStyle(ControlStyles.ResizeRedraw, true);
      SetStyle(ControlStyles.AllPaintingInWmPaint, true);
      SetStyle(ControlStyles.DoubleBuffer, true);
      InitializeComponent;
      CharWidth := self.Skin.Width div 13;
      
      Width := CharWidth * 7;
      Height := self.Skin.Height;
    end;
  end;
  
  /// Класс панелей в плеере
  PlayerPanel = class(UserControl)
  end;
  
  
  
  MouseAction = (maMove, maUp, maDown);
  /// Слайдер
  PlayerSlider = class(UserControl)  
  private 
    pos: real;
    background, thumb: Image;
    isMouseDown := false;
    
    imgAttributes: Imaging.ImageAttributes;
    
    isSeekBar := false;
    audiopos: real;
    
    procedure setPosition(r: real);
    begin
      if isMouseDown then 
      begin
        if isSeekBar then 
          audiopos := r;
      end else pos := r;
      Invalidate;
    end;
    
    function getPosition: real;
    begin
      if isMouseDown then 
      begin
        if isSeekBar then 
          result := audiopos;
      end else result := pos;
    end;
    
    procedure Down(sender: Object; e: MouseEventArgs);
    begin
      isMouseDown := true;
      var p: real := e.X / width;
      if p > 1 then p := 1 else if p < 0 then p := 0;
      if isSeekBar then audiopos := pos;
      p := ChangePosition(self, p, maDown);
      pos := p;
      Invalidate;
    end;
    
    procedure Up(sender: Object; e: MouseEventArgs);
    begin
      if isMouseDown then
      begin
        var p: real := e.X / width;
        if p > 1 then p := 1 else if p < 0 then p := 0;
        p := ChangePosition(self, p, maUp);
        pos := p;
        Invalidate; 
      end;
      isMouseDown := false;
    end;
    
    procedure Move(sender: Object; e: MouseEventArgs);
    begin
      if isMouseDown then
      begin
        var p: real := e.X / width;
        if p > 1 then p := 1 else if p < 0 then p := 0;
        p := ChangePosition(self, p, maMove);
        pos := p;
        Invalidate;
      end;
    end;
    
    procedure PaintSlider(sender: Object; e: PaintEventArgs);
    begin
      var g := e.Graphics;
      
      var srcRect: Rectangle := new System.Drawing.Rectangle(0, 0, background.Width, (background.Height div 2));
      var destRect: Rectangle := new System.Drawing.Rectangle(0, 0, background.Width, (background.Height div 2));
      g.DrawImage(background, destRect, srcRect, GraphicsUnit.Pixel);
      
      var p2 := pos;
      if isSeekBar and isMouseDown then  p2 := audiopos;
      
      var srcRect2: Rectangle := new System.Drawing.Rectangle(0, (background.Height div 2), round(p2 * width), (background.Height div 2));
      var destRect2: Rectangle := new System.Drawing.Rectangle(0, 0, round(p2 * width), (background.Height div 2));
      g.DrawImage(background, destRect2, srcRect2, GraphicsUnit.Pixel);
      
      var imgA := new Imaging.ImageAttributes();
      
      if isSeekBar and isMouseDown then 
      begin
        var srcRect4: Rectangle := new System.Drawing.Rectangle(0, 0, thumb.Width, thumb.Height);
        var destRect4: Rectangle := new System.Drawing.Rectangle(round((width - thumb.Width) * audiopos), 0, thumb.Width, thumb.Height);
        g.DrawImage(thumb, destRect4, srcRect4, GraphicsUnit.Pixel);
        imgA := imgAttributes;
      end;
      
      var srcRect3: Rectangle := new System.Drawing.Rectangle(0, 0, thumb.Width, thumb.Height);
      var destRect3: Rectangle := new System.Drawing.Rectangle(round((width - thumb.Width) * pos), 0, thumb.Width, thumb.Height);
      g.DrawImage(thumb, destRect3, srcRect3.X, srcRect3.Y, srcRect3.Width, srcRect3.Height, GraphicsUnit.Pixel, imgA, nil);
    end;
  
  public 
    constructor(background, thumb: System.Drawing.Image);
    type
      ArrOfDouble = array of single;
    begin
      SetStyle(ControlStyles.ResizeRedraw, true);
      SetStyle(ControlStyles.AllPaintingInWmPaint, true);
      SetStyle(ControlStyles.DoubleBuffer, true);
      self.BackColor := Color.Transparent;
      self.background := background;
      self.thumb := thumb;
      self.Paint += PaintSlider;
      self.MouseMove += Move;
      self.MouseDown += Down;
      self.MouseUp += Up;
      Size := new System.Drawing.Size(background.Width, background.Height div 2);
      
      var ptsArray := new ArrOfDouble[5]
      (new single[5](1, 0, 0, 0, 0),
       new single[5](0, 1, 0, 0, 0),
       new single[5](0, 0, 1, 0, 0),
       new single[5](0, 0, 0, 0.5, 0), 
       new single[5](0, 0, 0, 0, 1));
      var clrMatrix := new Imaging.ColorMatrix(ptsArray);
      imgAttributes := new Imaging.ImageAttributes();
      imgAttributes.SetColorMatrix(clrMatrix, Imaging.ColorMatrixFlag.Default,
        Imaging.ColorAdjustType.Bitmap);
      
    end;
    
    constructor(background, thumb: System.Drawing.Image; isSeekBar: boolean);
    begin
      Create(background, thumb);
      self.isSeekBar := isSeekBar;
    end;
    
    property Position: real read getPosition write setPosition;
    public event ChangePosition:  function(sender: PlayerSlider; r: real; ma: MouseAction): real;
  end;
  
  /// Спектрум
  PlayerSpectrum = class(UserControl)
  private 
    fBandCount := 27;
    peaks := new integer[128];
    limit := new integer[128];
    
    procedure SetBandCount(value: integer);
    begin
      fBandCount := value;
      Invalidate;
    end;
    
    procedure PlayerSpectrum_Paint(sender: Object; e: PaintEventArgs);
    begin
      var g := e.Graphics;
      var ColWidth := round(Width / BandCount); 
      for var i := 0 to BandCount - 1 do
      begin
        var YPos := Trunc(Abs(FFtData[i + 5]) * 500);
        if YPos > Height then YPos := Height;
        if YPos >= peaks[i] then peaks[i] := YPos
        else peaks[i] := peaks[i] - 1;
        
        if YPos >= limit[i] then limit[i] := YPos - 1
        else limit[i] := limit[i] - 3;
        
        if (Height - peaks[i]) > Height then
          peaks[i] := 0;
        if (Height - limit[i]) > Height then
          limit[i] := 0;
        
        g.DrawLine(new Pen(PeakColor), i * (ColWidth + 1), Height - peaks[i],
            i * (ColWidth + 1) + ColWidth - 1, Height - peaks[i]);
        
        g.FillRectangle(new SolidBrush(ColumnColor),
          i * (ColWidth + 1), Height - limit[i],
          ColWidth, Height);
      end;
    end;
    
    procedure InitializeComponent;
    begin
      Paint += PlayerSpectrum_Paint;
    end;
  public 
    FFTData := new Single[2048];
    PeakColor := Color.Yellow;
    ColumnColor := Color.White;
    
    property BandCount: integer read fBandCount write SetBandCount;
    constructor;
    begin
      SetStyle(ControlStyles.ResizeRedraw, true);
      SetStyle(ControlStyles.AllPaintingInWmPaint, true);
      SetStyle(ControlStyles.DoubleBuffer, true);
      InitializeComponent;
    end;
  end;
  
end.