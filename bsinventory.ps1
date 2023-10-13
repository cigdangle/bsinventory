# Location of Beat Saber Song directories, assuming purchased with Steam in default location on C:
$CustomSongsPath = "C:\Program Files (x86)\Steam\steamapps\common\Beat Saber\Beat Saber_Data\CustomLevels\*info.dat"
# Output file & path to desktop
$outputFile = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop) + "\BeatSaberSongInventory.csv"

# Remove existing old output file
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

# Function as described, used to extract song title and artist from info.dat files
function ExtractFromInfoFile($startString, $endString, $importPath){

    #Get content from file
    $file = Get-Content $importPath

    #Regex pattern to compare two strings
    $pattern = "$startString(.*?)$endString"

    #Perform the opperation
    $result = [regex]::Match($file,$pattern).Groups[1].Value

    #Return result
    return $result

}

# Pull path for each info.dat file in path shown in $CustomSongsPath
$files = Get-ChildItem $CustomSongsPath -Recurse

"Title;Artist" >> $outputFile

# Extract title,song from each info.dat and write to file in $outputFile
foreach ($f in $files){
    $cleanUpData = (ExtractFromInfoFile -startString '"_songName":' -endString '",' -importPath $f) + ';' + (ExtractFromInfoFile -startString '"_songAuthorName":' -endString '",' -importPath $f)
    $cleanUpData = $cleanUpData -replace ' "' #Clean up Beat Sage Files
    $cleanUpData = $cleanUpData -replace '"' | Out-File $outputFile -Append #Clean up Beat Saber Files
}

