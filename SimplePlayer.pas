// �����: ValeraGin ICQ:583890030 E-Mail:valeragin@gmail.com ����:01.10.11

// ��������
// TODO: ������ �������� ���� �������, ����� ����.
// TODO: ������� ������� ����� ������� 
// TODO: ���� � �������� ���� ���������� ������� - ������������ �������� �����
// TODO: ���� �������� ������� ������� � ���������� � ��������� - ���������� '...' � �����.
// TODO: ������� ������������ �����
// TODO: ������� �����
// TODO: ���������� ������
// TODO: �������� ������������
// TODO: ���������(Tooltip)
// TODO: ����������� ������ � ����� (PrivateFontCollection)
// TODO: ������ �� ������� MyListBoxUnit.dll
// TODO: ������������� ��������� �� ���������
// TODO: ���� ����� ������(�������)


{$apptype windows}
//{$include 'AssemblyInfo.pas'}
{$mainresource 'resources\win32.res'}
{$reference 'Microsoft.VisualBasic.dll'}

uses
  Microsoft.VisualBasic.ApplicationServices,
  PlayerForm;

type
  /// ��� ������� ����� ����� ��������� �
  /// �������� ���������� ������ ����� ����������
  /// ����� ���� � ProcessParameters
  SingleApp = class(WindowsFormsApplicationBase)
    constructor;
    begin
      IsSingleInstance := true; 
      EnableVisualStyles := true;
      StartupNextInstance += SingleApp_StartupNextInstance;
      Startup += SingleApp_Startup;
    end;
    
    protected procedure OnCreateMainForm; override;
    begin
      MainForm := PlayerFrm;
    end;
    
    protected procedure SingleApp_Startup(sender: object; eventArgs: StartupEventArgs);
    begin
    end;
    
    
    protected procedure SingleApp_StartupNextInstance(sender: object; eventArgs: StartupNextInstanceEventArgs);
    begin
      var  args := new string[eventArgs.CommandLine.Count];
      eventArgs.CommandLine.CopyTo(args, 0);
      if args.Length > 1 then 
        MainForm.Invoke(Player(MainForm).ProcessParameters, args);
    end;
  end;


begin
  var App := new SingleApp;
  App.Run(System.Environment.GetCommandLineArgs);
end.