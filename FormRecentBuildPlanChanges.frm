VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} FormRecentBuildPlanChanges 
   Caption         =   "FormRecentBuildPlanChanges"
   ClientHeight    =   5640
   ClientLeft      =   45
   ClientTop       =   375
   ClientWidth     =   4545
   OleObjectBlob   =   "FormRecentBuildPlanChanges.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "FormRecentBuildPlanChanges"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' FORREST SOFTWARE
' Copyright (c) 2016 Mateusz Forrest Milewski
'
' Permission is hereby granted, free of charge,
' to any person obtaining a copy of this software and associated documentation files (the "Software"),
' to deal in the Software without restriction, including without limitation the rights to
' use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
' and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
'
' The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
'
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
' INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
' IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
' WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Private walidator As Validator


Private Sub BtnClear_Click()
    
    With Me
        .TextBoxCmnt = ""
        .TextBoxNoOfVeh = 0
        .TextBoxReleased = ""
        .TextBoxTBW = ""
    End With
End Sub

Private Sub BtnCopy_Click()

    ' pubic sub from global foo module
    copyOneItemFromDifferentRecord CStr(Me.name)
End Sub

' DTPICKERS!
' ------------------------------------------------------------------------------------------------------------------
' ------------------------------------------------------------------------------------------------------------------
'Private Sub ComboBoxPLT_Change()
'    Me.TextBoxPlt = CStr(Me.ComboBoxPLT.Value)
'End Sub
'
'Private Sub DTPicker1_Change()
'    Me.TextBoxCW = SIXP.GlobalFooModule.parse_from_date_to_yyyycw(CDate(Me.DTPicker1.Value))
'End Sub


Private Sub BtnGoBack_Click()
    Hide
    run_FormMain Me.LabelTitle
End Sub

Private Sub BtnSubmit_Click()

    Set walidator = New Validator
    With walidator
        .dodajDoKolekcji Me.TextBoxNoOfVeh, .pStr_checkIfNumber
        .dodajDoKolekcji Me.TextBoxTBW, .pStr_checkIfYYYYCW
        .dodajDoKolekcji Me.TextBoxReleased, .pStr_checkIfYYYYCW
        
        .run
    End With
    
    
    If walidator.pass Then
    
        
        SIXP.GlobalFooModule.gotoThisWorkbookMainA1
        
        ' text na guziki
        ' Global Const G_BTN_TEXT_ADD = "Dodaj"
        ' Global Const G_BTN_TEXT_EDIT = "Edytuj"
        'Hide
        inner_calc
        
        ' run_FormMain Me.LabelTitle
        
        If Me.BtnSubmit.Caption = SIXP.G_BTN_TEXT_ADD Then
            Me.BtnSubmit.Caption = SIXP.G_BTN_TEXT_EDIT
        End If
    Else
        MsgBox "Validation failed!"
    End If
End Sub


Private Sub change_col_G_in_MAIN_worksheet(ByRef r As Range)
    
    ' tutaj sekcja, gdy dane juz zostaly dodane do arkusza order releases
    ' teraz nalezy odpowiednio o tym poinformowac arkusz glowny
    ' -----------------------------------------------------------------------
    ' -----------------------------------------------------------------------
    
        ' szukamy teraz w main
        ' ===================================================
        Dim rr As Range
        Set rr = ThisWorkbook.Sheets(SIXP.G_main_sh_nm).Cells(1, 1)
        Do
            If CStr(Trim(r) & ", " & Trim(r.Offset(0, 1)) & ", " & Trim(r.Offset(0, 2)) & ", " & Trim(CStr(r.Offset(0, 3)))) = _
                CStr(Trim(rr) & ", " & Trim(rr.Offset(0, 1)) & ", " & Trim(rr.Offset(0, 2)) & ", " & Trim(CStr(rr.Offset(0, 3)))) Then
                    ' jest to samo w order release status sheet oraz to samo w main sheet
                    ' --------------------------------------------------------------------
                    ''
                    '
                    rr.Offset(0, SIXP.e_main_last_update_on_recent_build_plan_changes - 1) = Trim(CStr(rr.Offset(0, 3)))
                    '
                    ''
                    ' --------------------------------------------------------------------
                    Exit Do
            End If
            Set rr = rr.Offset(1, 0)
        Loop Until Trim(rr) = ""
        
        
        ' ===================================================
    
    
    
    
    ' -----------------------------------------------------------------------
    ' -----------------------------------------------------------------------
End Sub

Private Sub inner_calc()


    'Public Enum E_RECENT_BP_CH
    '    e_recent_bp_ch_no_of_veh = 5
    '    e_recent_bp_ch_tbw
    '    e_recent_bp_ch_order_release_ch
    '    e_recent_bp_ch_comment
    'End Enum


    Dim r As Range
    
    If Me.BtnSubmit.Caption = SIXP.G_BTN_TEXT_ADD Then
    
        ' no to szukamy pierwszego wolnego pola i wsadzamy
        ' ===================================================
        Set r = ThisWorkbook.Sheets(SIXP.G_recent_build_plan_changes_sh_nm).Cells(1, 1)
        Do
            Set r = r.Offset(1, 0)
        Loop Until Trim(r) = ""
        
        Dim arr As Variant
        arr = Split(CStr(Me.LabelTitle), ",")
        For x = 0 To 3
            r.Offset(0, x) = Trim(arr(x))
        Next x
        
        
        give_data_to_ranges r
        change_col_G_in_MAIN_worksheet r
        
        ' tutaj raczej bledu wychwytywac nie bedziemy - chodzi o zwyczajne (z pewnoscia)
        ' dodanie info na sam koniec tabeli
        
        
        
        ' ===================================================
    
    ElseIf Me.BtnSubmit.Caption = SIXP.G_BTN_TEXT_EDIT Then
    
    
        ' szukamy jeszcze raz
        ' ===================================================
        Set r = ThisWorkbook.Sheets(SIXP.G_recent_build_plan_changes_sh_nm).Cells(1, 1)
        Do
            If CStr(Me.LabelTitle.Caption) = _
                CStr(Trim(r) & ", " & Trim(r.Offset(0, 1)) & ", " & Trim(r.Offset(0, 2)) & ", " & Trim(r.Offset(0, 3))) Then
            
                    give_data_to_ranges r
                    change_col_G_in_MAIN_worksheet r
                    Exit Do
            End If
            Set r = r.Offset(1, 0)
        Loop Until Trim(r) = ""
        
        
        ' ===================================================
    Else
        MsgBox "fatal error on submitting!"
        End
    End If
End Sub

Private Sub give_data_to_ranges(ByRef r As Range)

    'Public Enum E_RECENT_BP_CH
    '    e_recent_bp_ch_no_of_veh = 5
    '    e_recent_bp_ch_tbw
    '    e_recent_bp_ch_order_release_ch
    '    e_recent_bp_ch_comment
    'End Enum

    r.Parent.Cells(r.Row, SIXP.e_recent_bp_ch_no_of_veh) = CStr(Me.TextBoxNoOfVeh)
    r.Parent.Cells(r.Row, SIXP.e_recent_bp_ch_tbw) = CStr(Me.TextBoxTBW)
    r.Parent.Cells(r.Row, SIXP.e_recent_bp_ch_order_release_ch) = CStr(Me.TextBoxReleased)
    r.Parent.Cells(r.Row, SIXP.e_recent_bp_ch_comment) = CStr(Me.TextBoxCmnt)
End Sub

Private Sub DTPickerTBW_Change()
    Me.TextBoxTBW = CStr(SIXP.GlobalFooModule.parse_from_date_to_yyyycw(CDate(Me.DTPickerTBW.Value)))
End Sub

Private Sub DTPickerReleased_Change()
    Me.TextBoxReleased = CStr(SIXP.GlobalFooModule.parse_from_date_to_yyyycw(CDate(Me.DTPickerReleased)))
End Sub

' ------------------------------------------------------------------------------------------------------------------
' ------------------------------------------------------------------------------------------------------------------





' textboxes with qtyies
' ------------------------------------------------------------------------------------------------------------------
' ------------------------------------------------------------------------------------------------------------------

Private Sub NoOfVehLess_Click()
    If IsNumeric(Me.TextBoxNoOfVeh) Then
        If CLng(Me.TextBoxNoOfVeh) > 0 Then
            tmp = CLng(Me.TextBoxNoOfVeh)
            tmp = tmp - 1
            Me.TextBoxNoOfVeh = CStr(tmp)
        End If
    End If
End Sub

Private Sub NoOfVehMore_Click()
    If IsNumeric(Me.TextBoxNoOfVeh) Then
        tmp = CLng(Me.TextBoxNoOfVeh)
        tmp = tmp + 1
        Me.TextBoxNoOfVeh = CStr(tmp)
    End If
End Sub
' ------------------------------------------------------------------------------------------------------------------
' ------------------------------------------------------------------------------------------------------------------
