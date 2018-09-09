unit AboutDlg;

{$reference 'System.Windows.Forms.dll'}
{$reference 'System.Drawing.dll'}

{$resource 'resources\aboutback.png'}

type
  AboutDialog = class(System.Windows.Forms.Form)
  private 
    panel1: System.Windows.Forms.Panel;
    label1: System.Windows.Forms.&Label;
    label3: System.Windows.Forms.&Label;
    label4: System.Windows.Forms.&Label;
    button1: System.Windows.Forms.Button;
    procedure InitializeComponent;
    begin
      self.panel1 := new System.Windows.Forms.Panel();
      self.label1 := new System.Windows.Forms.Label();
      self.label3 := new System.Windows.Forms.Label();
      self.label4 := new System.Windows.Forms.Label();
      self.button1 := new System.Windows.Forms.Button();
      self.panel1.SuspendLayout();
      self.SuspendLayout();

      self.panel1.Controls.Add(self.label1);
      self.panel1.BackgroundImage := new System.Drawing.Bitmap(GetResourceStream('aboutback.png'));
      self.panel1.Location := new System.Drawing.Point(1, -2);
      self.panel1.Size := new System.Drawing.Size(400, 150);

      self.label1.AutoSize := true;
      self.label1.BackColor := System.Drawing.Color.Transparent;
      self.label1.Font := new System.Drawing.Font('Microsoft Sans Serif', 9.75, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
      self.label1.Location := new System.Drawing.Point(21, 69);
      self.label1.Text := 'ver 1.00';

      self.label3.AutoSize := true;
      self.label3.Font := new System.Drawing.Font('Tahoma', 8.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
      self.label3.Location := new System.Drawing.Point(22, 164);
      self.label3.Text := 'ValeraGin, 2011. Все права защищены.';

      self.label4.AutoSize := true;
      self.label4.Font := new System.Drawing.Font('Tahoma', 8.25, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
      self.label4.Location := new System.Drawing.Point(22, 187);
      self.label4.Text := 'Аудиоплеер создан в системе программирования PascalABC.NET.';

      self.button1.DialogResult := System.Windows.Forms.DialogResult.OK;
      self.button1.Location := new System.Drawing.Point(309, 219);
      self.button1.TabIndex := 0;
      self.button1.Text := 'OK';
      self.button1.UseVisualStyleBackColor := true;

      self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
      self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
      self.ClientSize := new System.Drawing.Size(396, 254);
      self.Controls.Add(self.button1);
      self.Controls.Add(self.label4);
      self.Controls.Add(self.label3);
      self.Controls.Add(self.panel1);
      self.FormBorderStyle := System.Windows.Forms.FormBorderStyle.FixedDialog;
      self.StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen;
      self.Text := 'О аудиоплеере Simple Player';
      self.panel1.ResumeLayout(false);
      self.panel1.PerformLayout();
      self.ResumeLayout(false);
      self.PerformLayout();
    end;
  public 
    constructor;
    begin
      InitializeComponent;
    end;
  end;

end.