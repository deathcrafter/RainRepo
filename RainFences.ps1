<#
Summary: A script to create a customizable Fence for Rainmeter.
#>

param(
    $name = 'Fences',
    $rows = 3,
    $columns = 5,
    $folder = [Environment]::GetFolderPath('Desktop'),
    $title = 'MyFence',
    $skinsfolder = "$([System.Environment]::GetFolderPath('MyDocuments'))\Rainmeter\Skins"
)

function Test-Directory{
    param(
        [Parameter()]
        [string]
        $dir,
        $message = 'Please provide valid path:'
    )
    $correctdir = $dir
    if (-not [System.IO.Directory]::Exists($correctdir)){
        while (-not [System.IO.Directory]::Exists($correctdir)) {
            $correctdir = Read-Host $message
        }
    }

    return $correctdir
}

$folder = Test-Directory -dir $folder -message "Please provide correct shortcut folder:"

$skinsfolder = Test-Directory -dir $skinsfolder -message "Please provide correct skins folder:"

while ([System.IO.Directory]::Exists("$skinsFolder\$name")) {
    if ((Read-Host 'A skin with name $name already exists. Override? (Y/N)') -eq 'Y') {
        Remove-Item "$skinsfolder\$name" -Recurse -Force
    }else{
        $name = Read-Host Please provide a new name:
    }
}

# templates

$default = @"

[Rainmeter]
Update = 1000
AccurateText = 1
OnRefreshAction=[!UpdateMeasure *][!UpdateMeter *][!Update]

[Metadata]
Name = {name}
Author = death.crafter
Information = Created using Fences creator.
Version = 1.0.0
License = Creative Commons Attribution - Non - Commercial - Share Alike 4.0

[Variables]
FenceTitle = {title}
FenceFolder = {folder}
FenceRows = {rows}
FenceColumns = {columns}

LineItemWidth = 60
LineItemHeight = 56

LineXPadding = 10
LineYPadding = 10

LineBackgroundColor = 160,160,160,0

LineItemXPadding = 10
LineItemYPadding = 2

LineItemTextPadding = 3
LineItemTextFont = Segoe UI

LineItemImagePadding = 15
LineItemImageTopPadding = 3

HighlightOffColor = 200,200,200,0
HighLightOnColor = 200,200,200,200

"@

$base = @"

[Background]
Meter = Shape
Shape = Rectangle 0,0,(2*#LineXPadding# + (#LineItemWidth# + #LineItemXPadding#)*#FenceColumns# + #LineItemXPadding#),(40 + #LineYPadding# + ((#LineItemHeight# + 2*#LineItemYPadding#) + #LineYPadding#)*#FenceRows#),5 | StrokeWidth 0 | FillColor 30,30,30,190

[Name]
Meter = String
Text = #FenceTitle#
X = ([Background:W]/2)
Y = 20r
FontFace = Segoe UI
FontSize = 16
FontWeight = 500
FontColor = FFFFFF
AntiAlias = 1
StringAlign = CenterCenter
DynamicVariables=1

[Separator]
Meter = Shape
Y = 38
Shape = Line 0,0,(2*#LineXPadding# + (#LineItemWidth# + #LineItemXPadding#)*#FenceColumns# + #LineItemXPadding#),0 | StrokeWidth 2 | StrokeColor 200,200,200

[LineItemBackStyle]
X = (#LineItemXPadding# - (#LineItemWidth# - 2*#LineItemTextPadding# - #LineItemWidth#/2))R
Y = #LineItemYPadding#
Shape = Rectangle 0,0,#LineItemWidth#,#LineItemHeight#,4 | StrokeWidth 0 | Extend MyStyle
DynamicVariables=1
MouseOverAction = [!SetOption #CURRENTSECTION# MyStyle "FillColor #HighlightOnColor#"][!UpdateMeter #CURRENTSECTION#][!Redraw]
MouseLeaveAction = [!SetOption #CURRENTSECTION# MyStyle "FillColor #HighlightOffColor#"][!UpdateMeter #CURRENTSECTION#][!Redraw]

[LineItemIconStyle]
X = #LineItemImagePadding#r
Y = #LineItemImageTopPadding#r
H = (#LineItemWidth# - 2*#LineItemImagePadding#)
W = (#LineItemWidth# - 2*#LineItemImagePadding#)
DynamicVariables=1

[LineItemTextStyle]
X = ((#LineItemWidth# - 2*#LineItemImagePadding#)/2)r
Y = ((#LineItemHeight# - (#LineItemWidth# - 2*#LineItemImagePadding#) - #LineItemImageTopPadding#)/2)R
W = (#LineItemWidth# - 2*#LineItemTextPadding#)
H = (#LineItemHeight# - (#LineItemWidth# - 2*#LineItemImagePadding#) - #LineItemImageTopPadding#)
FontFace = #LineItemTextFont#
SolidColor=0,0,0,1
FontWeight = 300
FontSize = 8
FontColor = FFFFFF
AntiAlias = 1
StringAlign = CenterCenter
ClipString = 2
DynamicVariables = 1

[Parent]
Measure = Plugin
Plugin = FileView
Path = #FenceFolder#
ShowFolders = 0
ShowDotDot = 0
HideExtensions = 1
Count = (#FenceRows#*#FenceColumns#)
UpdateDivider = 4
OnUpdateAction=[!CommandMeasure Parent Update][!UpdateMeasure Count]

[Count]
Measure = Plugin
Plugin = FileView
Path = [Parent]
Type = FileCount
OnChangeAction = [!UpdateMeasure *][!UpdateMeter *][!Update]

"@

$line = @"

[Line{num}Container]
Meter = Shape
X = 10
Y = 10R
Shape = Rectangle 0,0,((#LineItemWidth# + #LineItemXPadding#)*#FenceColumns# + #LineItemXPadding#),(#LineItemHeight# + #LineItemYPadding#*2),4 | StrokeWidth 0 | FillColor 0,0,0
Hidden = ([Count] < {num}*#FenceColumns# + 1)
DynamicVariables=1

[Line{num}Back]
Meter = Shape
Shape = Rectangle 0,0,((#LineItemWidth# + #LineItemXPadding#)*#FenceColumns# + #LineItemXPadding#),(#LineItemHeight# + #LineItemYPadding#*2),4 | StrokeWidth 0 | FillColor #LineBackgroundColor#
Container = Line{num}Container

[Line{num}Start]
Meter = String
X = (#LineItemWidth# - 2*#LineItemTextPadding# - #LineItemWidth#/2)
Container = Line{num}Container

"@

$item = @"

[Line{num}Item{index}Back]
Meter = Shape
MyStyle = FillColor #HighlightOffColor#
MeterStyle = LineItemBackStyle
Container = Line{num}Container
Hidden = ([Count] < {num}*#FenceColumns# + {index})

[Line{num}Item{index}Icon]
Meter = Image
MeasureName = m#CURRENTSECTION#
MeterStyle = LineItemIconStyle
Container = Line{num}Container
Hidden = ([Count] < {num}*#FenceColumns# + {index})
LeftMouseDoubleClickAction=[!CommandMeasure m#CURRENTSECTION# Open]

[Line{num}Item{index}Text]
Meter = String
MeasureName = m#CURRENTSECTION#
MeterStyle = LineItemTextStyle
Container = Line{num}Container
Hidden = ([Count] < {num}*#FenceColumns# + {index})
LeftMouseDoubleClickAction=[!CommandMeasure m#CURRENTSECTION# Open]

"@

$fileview = @"

[mLine{num}Item{index}Icon]
Measure = Plugin
Plugin = FileView
Path = [Parent]
Type = Icon
IconPath = #@#Icons\Line{num}Item{index}.png
Index=({num}*#FenceColumns# + {index})

[mLine{num}Item{index}Text]
Measure = Plugin
Plugin = FileView
Path = [Parent]
Type = FileName
Index=({num}*#FenceColumns# + {index})

"@

$separator = ";=========================::{section}::=========================="

$finalSkin += $separator -replace '\{section\}', 'DEFAULT'

$default = $default -replace '\{name\}', $name
$default = $default -replace '\{title\}', $title
$default = $default -replace '\{folder\}', $folder
$default = $default -replace '\{rows\}', $rows
$default = $default -replace '\{columns\}', $columns

$finalSkin += $default

$finalSkin += $separator -replace '\{section\}', 'BASE'

$finalSkin += $base

for ($i = 0; $i -lt $rows; $i++) {
    $finalSkin += $separator -replace '\{section\}', "LINE $i"

    $finalSkin += $line -replace '\{num\}', $i
    
    for ($j = 1; $j -le $columns; $j++){
        $finalSkin += ($fileview -replace '\{num\}', $i) -replace '\{index\}', $j
        $finalSkin += ($item -replace '\{num\}', $i) -replace '\{index\}', $j
    }

}

New-Item -Path $skinsfolder -Name $name -ItemType Directory | Out-Null
New-Item -Path "$skinsfolder\$name" -Name '@Resources' -ItemType Directory | Out-Null
New-Item -Path "$skinsfolder\$name\@Resources" -Name Icons -ItemType Directory | Out-Null

$finalSkin | Out-File -FilePath "$skinsfolder\$name\$name.ini" -Encoding unicode

try {
    $process = (Get-Process Rainmeter).Path
    Start-Process $process -ArgumentList '[!RefreshApp]'
    Start-Sleep -Milliseconds 200
    Start-Process $process -ArgumentList "$('[!ActivateConfig "' + $name + '"]')"
} catch {}
