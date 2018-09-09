const ConsoleCompilerABC = 'pabcnetc.exe';

procedure ShowHelp;
begin
  writeln(Format('program syntax: {0} {1}', ExtractFileName(GetEXEFileName), 'имя_файла_pas'));
  readln;
  Halt;
end;

begin
  if not (CommandLineArgs.Length > 0) then ShowHelp;
  var PABCDir := string(Microsoft.Win32.Registry.CurrentUser.OpenSubKey('Software\PascalABC.NET').GetValue('Install Directory'));
  if PABCDir <> nil then
  begin
      var startCompileTime := Milliseconds;
      var p := System.Diagnostics.Process.Start(System.IO.Path.Combine(PABCDir, ConsoleCompilerABC), '"'+CommandLineArgs[0]+'"');
      p.WaitForExit(100 *  1000);
      writeln('Компилирование длилось: ',(Milliseconds-startCompileTime) div 1000, 'сек');
      readln;
  end else raise new Exception('Не установлен PascalABC.NET');
end.