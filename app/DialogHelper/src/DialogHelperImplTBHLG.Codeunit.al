codeunit 81501 "Dialog Helper Impl TBHLG"
{
    Access = Internal;

    var
        EndTime: DateTime;
        LastUpdate: DateTime;
        StartTime: DateTime;
        Window: Dialog;
        ProgressBarPlaceHolder: Label '#20###############################################';
        ElapsedTimeTxt: Label '\\Elapsed time :.................. #21#############';
        EstimatedTimeLeftTxt: Label '\Estimated time left :...... #22#############';
        EstimatedEndTimeTxt: label '\Estimated end time :..... #23#############';

        MinutesTxt: Label 'Minutes';
        SecondsTxt: Label 'Seconds';

    procedure OpenWindow(DialogString: text; ShowEstimatedEndTime: Boolean)
    var
        WindowString: Text;
    begin
        if not IsGuiAllowed() then
            exit;

        StartTime := 0DT;
        WindowString := DialogString;
        if WindowString = '' then
            WindowString := ProgressBarPlaceHolder
        else
            WindowString := WindowString + '\\' + ProgressBarPlaceHolder;

        if ShowEstimatedEndTime then begin
            WindowString := WindowString + ElapsedTimeTxt + EstimatedTimeLeftTxt + EstimatedEndTimeTxt;
            StartTime := CurrentDateTime;
        end;

        Window.open(WindowString);
        LastUpdate := CreateDateTime(19000101D, 100000T);
    end;

    procedure UpdateWindow(Counter: Integer; NoOfRecords: Integer);
    var
        ProgressBar: Codeunit "Progress Bar TBHLG";
        EndTime: DateTime;
        CurrDuration: Duration;
        EstimatedDuration: Duration;

    begin
        if CurrentDateTime < LastUpdate + 1000 then
            exit;

        if Counter = 0 then
            exit;

        Window.Update(20, ProgressBar.ProgressBar(Counter, NoOfRecords));
        LastUpdate := CurrentDateTime;

        if StartTime = 0DT then
            exit;

        CurrDuration := CurrentDateTime - StartTime;
        EstimatedDuration := ROUND((CurrentDateTime - StartTime) * 100 / (Counter / NoOfRecords * 100), 100);
        EndTime := StartTime + EstimatedDuration;
        Window.Update(21, FormatDuration(CurrDuration));

        IF CurrDuration <= 2000 then
            exit;

        Window.Update(22, FormatDuration(EstimatedDuration - CurrDuration));
        Window.Update(23, Format(EndTime, 0, '<Hours24>:<Minutes,2>:<Seconds,2>'));

    end;

    procedure UpdateWindow(FieldNo: Integer; Value: Text);
    begin
        if not IsGuiAllowed then
            exit;

        Window.Update(FieldNo, Value);
    end;

    procedure UpdateWindow(FieldNo: Integer; Value: Text; Counter: Integer; NoOfRecords: Integer);
    begin
        if not IsGuiAllowed then
            exit;

        UpdateWindow(FieldNo, Value);
        UpdateWindow(Counter, NoOfRecords);
    end;

    local procedure FormatDuration(NewDuration: Duration): Text;
    VAR
        Minutes: Integer;
        Seconds: Integer;
    begin
        NewDuration := Round(NewDuration / 1000, 1);
        Minutes := Round(NewDuration / 60, 1, '<');
        Seconds := NewDuration - (Minutes * 60);
        IF Minutes > 0 then
            exit(StrSubstNo('%1 %2 %3 %4', Minutes, MinutesTxt, Seconds, SecondsTxt))
        ELSE
            exit(StrSubstNo('%1 %2', Seconds, SecondsTxt));
    END;

    local procedure IsGuiAllowed() GuiIsAllowed: Boolean
    var
        Handled: Boolean;
    begin
        OnBeforeGuiAllowed(GuiIsAllowed, Handled);
        if Handled then
            exit;
        exit(GuiAllowed());
    end;

    /// <summary>
    /// Raises an event to be able to change the return of IsGuiAllowed function. Used for testing.
    /// </summary>
    [InternalEvent(false)]
    procedure OnBeforeGuiAllowed(var Result: Boolean; var Handled: Boolean)
    begin
    end;
}
