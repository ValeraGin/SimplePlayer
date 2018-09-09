unit RenameDlg;

{$reference 'System.Windows.Forms.dll'}
{$reference 'System.Drawing.dll'}

type
  RenameDialog = class(System.Windows.Forms.Form)
  private    
    cancel: System.Windows.Forms.Button;
    accept: System.Windows.Forms.Button;
    info: System.Windows.Forms.&Label;
    procedure InitializeComponent;
    begin
      cancel := new System.Windows.Forms.Button;
      accept := new System.Windows.Forms.Button;
      info := new System.Windows.Forms.&Label;
      input_ := new System.Windows.Forms.TextBox;
      SuspendLayout();

      cancel.DialogResult := System.Windows.Forms.DialogResult.Cancel;
      cancel.Location := new System.Drawing.Point(198, 51);
      cancel.Size := new System.Drawing.Size(76, 24);
      cancel.TabIndex := 1;
      cancel.Text := 'Отмена';

      accept.DialogResult := System.Windows.Forms.DialogResult.OK;
      accept.Location := new System.Drawing.Point(123, 51);
      accept.Size := new System.Drawing.Size(69, 24);
      accept.TabIndex := 0;
      accept.Text := 'Принять';

      info.AutoSize := true;
      info.Location := new System.Drawing.Point(12, 9);
      info.Size := new System.Drawing.Size(133, 13);
      info.TabIndex := 2;
      info.Text := 'Введите новое название';

      input_.Location := new System.Drawing.Point(12, 25);
      input_.Size := new System.Drawing.Size(262, 20);
      input_.TabIndex := 2;

      AutoScaleDimensions := new System.Drawing.SizeF(6, 13);
      AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
      ClientSize := new System.Drawing.Size(281, 83);
      Controls.Add(input_);
      Controls.Add(info);
      Controls.Add(accept);
      Controls.Add(cancel);
      FormBorderStyle := System.Windows.Forms.FormBorderStyle.FixedDialog;
      StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen;
      Text := 'Переименование';
      ResumeLayout(false);
      PerformLayout();
    end;
  
  public 
    input_: System.Windows.Forms.TextBox;
    constructor;
    begin
      InitializeComponent;
    end;
  end;

end. 