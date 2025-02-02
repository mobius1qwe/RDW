unit uRESTDW.DateUtils;
{< System level date/time utilities }

{$INCLUDE 'uRESTDW.inc'}

interface

{$IFDEF FPC}
Resourcestring
 SArgumentOutOfRange = 'Argument out of range';
{$ENDIF}

const
  { The minimum and maximum number of milliseconds since the Unix epoch that
    we can use to convert to and from a TDateTime value without loss in
    precision. Note that Delphi's TDateTime type can safely handle a larger
    range of milliseconds, but other languages may not. }
  MIN_MILLISECONDS_SINCE_EPOCH = -62135596800000;
  MAX_MILLISECONDS_SINCE_EPOCH = 253402300799999;

{ Converts a date/time value to a number of milliseconds since the Unix
  epoch.

  Parameters:
    AValue: the date/time value to convert.
    AInputIsUTC: whether AValue is in UTC format.

  Returns:
    The number of milliseconds since the Unix epoch. }
function goDateTimeToMillisecondsSinceEpoch(const AValue: TDateTime;
  const AInputIsUTC: Boolean): Int64;

{ Converts a number of milliseconds since the Unix epoch to a date/time value.

  Parameters:
    AValue: number of milliseconds since the Unix epoch.
    AReturnUTC: whether to return the corresponding date/time value in
      local time (False) or universal time (True).

  Returns:
    The date/time value.

  Raises:
    EArgumentOutOfRangeException if AValue cannot be accurately converted to
    a date/time value }
function goToDateTimeFromMillisecondsSinceEpoch(const AValue: Int64;
  const AReturnUTC: Boolean): TDateTime;

{ Converts a date/time value to a number of ticks that has passed since
  midnight, January 1, 0001 UTC.

  Parameters:
    AValue: the date/time value to convert.
    AInputIsUTC: whether AValue is in UTC format.

  Returns:
    The number of ticks.

  There are 10,000 ticks in a milliseconds (or 10 million ticks in a second). }
function goDateTimeToTicks(const AValue: TDateTime;
  const AInputIsUTC: Boolean): Int64;

{ Converts a number of ticks that has passed since midnight, January 1, 0001 UTC
  to a date/time value.

  Parameters:
    AValue: the number of ticks.
    AReturnUTC: whether to return the corresponding date/time value in
      local time (False) or universal time (True).

  Returns:
    The date/time value.

  There are 10,000 ticks in a milliseconds (or 10 million ticks in a second). }
function goDateTimeFromTicks(const AValue: Int64;
  const AReturnUTC: Boolean): TDateTime;

implementation

uses
 {$IFNDEF FPC}
  System.SysUtils,
  System.DateUtils,
  System.RTLConsts,
  System.TimeSpan
 {$ELSE}
  SysUtils,
  DateUtils,
  RTLConsts,
  uRESTDWTimespan
 {$ENDIF};

const
  UTC_MIDNIGHT_JAN_0001: TDateTime = -693593;

function goDateTimeToMillisecondsSinceEpoch(const AValue: TDateTime;
  const AInputIsUTC: Boolean): Int64;
var
  Date: TDateTime;
begin
  if AInputIsUTC then
    Date := AValue
  Else
   Begin
    {$IFNDEF FPC}
     Date := TTimeZone.Local.ToUniversalTime(AValue);
    {$ELSE}
     Date := LocalTimeToUniversal(AValue);
    {$ENDIF}
   End;
  Result := MilliSecondsBetween(UnixDateDelta, Date);
  if (Date < UnixDateDelta) then
     Result := -Result;
end;

function goToDateTimeFromMillisecondsSinceEpoch(
  const AValue: Int64; const AReturnUTC: Boolean): TDateTime;
begin
  if (AValue < MIN_MILLISECONDS_SINCE_EPOCH) or (AValue > MAX_MILLISECONDS_SINCE_EPOCH) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);

  if AReturnUTC then
    Result := IncMilliSecond(UnixDateDelta, AValue)
  Else
   Begin
   {$IFNDEF FPC}
    Result := TTimeZone.Local.ToLocalTime(IncMilliSecond(UnixDateDelta, AValue));
   {$ELSE}
    Result := UniversalTimeToLocal(IncMilliSecond(UnixDateDelta, AValue));
   {$ENDIF}
   End;
end;

function goDateTimeToTicks(const AValue: TDateTime;
  const AInputIsUTC: Boolean): Int64;
var
  Timespan: TTimeSpan;
begin
  if (AInputIsUTC) then
    Timespan := TTimespan.Subtract(AValue, UTC_MIDNIGHT_JAN_0001)
  else
   Timespan := TTimespan.Subtract({$IFNDEF FPC}
                                    TTimeZone.Local.ToUniversalTime(AValue)
                                   {$ELSE}
                                    LocalTimeToUniversal(AValue)
                                   {$ENDIF}
                                   , UTC_MIDNIGHT_JAN_0001);
  Result := Timespan.Ticks;
end;

function goDateTimeFromTicks(const AValue: Int64;
  const AReturnUTC: Boolean): TDateTime;
var
  Timespan: TTimeSpan;
begin
  Timespan := TTimeSpan.FromTicks(AValue);
  Result := UTC_MIDNIGHT_JAN_0001 + Timespan{$IFDEF FPC}.Ticks{$ENDIF};
  if (not AReturnUTC) then
    Result := {$IFNDEF FPC}
               TTimeZone.Local.ToLocalTime(Result)
              {$ELSE}
               UniversalTimeToLocal(Result)
              {$ENDIF};
end;

end.
