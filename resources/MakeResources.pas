 #reference 'System.Windows.Forms.dll'
 
 uses System, System.Windows.Forms, System.Globalization, System.Resources, System.Diagnostics, System.IO;
 
 procedure MakeResource;
 begin
   var LanguageFiles := Directory.EnumerateFiles(io.Path.GetDirectoryName(GetEXEFileName), '*.lng');
   foreach fname:string in LanguageFiles do
   begin
     var rw := new ResourceWriter(string.Format('SimplePlayer.{0}.resources', Path.GetFileNameWithoutExtension(fname)));
     var streamReader := new StreamReader(fname);
     var lines := streamReader.ReadToEnd.Split(#10);
     streamReader.Close;
     foreach s: string in lines do
     begin
       var a := s.Split('=');
       rw.AddResource(a[0],a[1]);
     end;
     rw.Close;
   end;
 end;
 
 begin
  MakeResource;  
 end.