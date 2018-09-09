unit FSFormatProvider;

uses
  System;

type
  /// Специальный форматер для вывода размеров файлов (10 КB, 1,5 MB, etc).
  /// http://www.rsdn.ru/forum/src/2238601.1.aspx
  FileSizeFormatProvider = class(IFormatProvider, ICustomFormatter)
    public function GetFormat(formatType: &Type): object;
    begin
      if (typeof(ICustomFormatter).IsAssignableFrom(formatType)) then
        result := self;
    end;
    
    private const fileSizeFormat = 'fs';
    private letters := new string[6]('B', 'KB', 'MB', 'GB', 'TB', 'PB' );
    public function Format(format: string; arg: object; formatProvider: IFormatProvider): string;
    begin
      if (format = nil) or not format.StartsWith(fileSizeFormat) then 
      begin
        result := string.Format(format, arg, formatProvider);
      end 
      else 
      begin
        var size: Decimal;
        try
          size := Convert.ToDecimal(arg);
        except
          on InvalidCastException do
          begin
            result := string.Format(format, arg, formatProvider);
            exit;
          end;
        end;
        var i: byte := 0;
        while ((size >= 1024) and (i < letters.Length - 1)) do
        begin
          i += 1;
          size := size / 1024;
        end;
        var precision := format.Substring(2);
        if String.IsNullOrEmpty(precision) then  precision := '2';
        result := String.Format('{0:N' + precision + '} {1}', size, letters[i]);
      end;
    end;
    
    private function defaultFormat(format: string; arg: object; formatProvider: IFormatProvider): string;
    begin
      var formattableArg := (arg as IFormattable);
      if formattableArg <> nil then
        result := formattableArg.ToString(format, formatProvider)
      else
        result := arg.ToString();
    end;
  end;
  

end. 