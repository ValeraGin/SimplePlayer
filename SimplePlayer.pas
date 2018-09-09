// Автор: ValeraGin ICQ:583890030 E-Mail:valeragin@gmail.com Дата:01.10.11

// Основное
// TODO: Кнопки плейлист таба активны, когда надо.
// TODO: Плавный переход между песнями 
// TODO: Если в название есть чужеродные символы - использовать название файла
// TODO: Если название слишком длинное и обрезается в плейлисте - дописывать '...' в конец.
// TODO: Фоновое сканирование тегов
// TODO: Быстрый поиск
// TODO: Ассоциации файлов
// TODO: Интернет радиостанции
// TODO: Подсказки(Tooltip)
// TODO: Собственные шрифты в скине (PrivateFontCollection)
// TODO: Убрать из проекта MyListBoxUnit.dll
// TODO: Перетакивание элементов на плейлисте
// TODO: Скин одним файлом(архивом)


{$apptype windows}
//{$include 'AssemblyInfo.pas'}
{$mainresource 'resources\win32.res'}
{$reference 'Microsoft.VisualBasic.dll'}

uses
  Microsoft.VisualBasic.ApplicationServices,
  PlayerForm;

type
  /// Для запуска одной копии программы и
  /// передача параметров других копий запущенных
  /// после этой в ProcessParameters
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