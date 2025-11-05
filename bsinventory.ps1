# Location of Beat Saber Custom Levels directory, assuming purchased with Steam in default location on C:
# Change the below value as needed. Set the directory to search and the output file path
$songDirectory = "C:\Program Files (x86)\Steam\steamapps\common\Beat Saber\Beat Saber_Data\CustomLevels"

# Define the output path for the Excel file.  Default exports to Desktop
$outputExcelFile = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop) + "\BeatSaberSongInventory.xlsx"

# If output file already exists, delete it in prepreation for a new one
if (Test-Path -Path $outputExcelFile) {
    Remove-Item -Path $outputExcelFile -Force
    Write-Host "File '$outputExcelFile' removed successfully."
}

# Define the data structure
$songDataCollection = @()

# Search for all info.dat files in the current directory and subdirectories
$infoFiles = Get-ChildItem -Path $songDirectory -Filter "info.dat" -Recurse -File

# Define patterns in info.dat file
$patternTitle = '"_songName": "(.*?)",'
$patternArtist = '"_songAuthorName": "(.*?)",'

# Process each info.dat file
foreach ($file in $infoFiles) {
    # Get the content of the file
    $content = Get-Content -Path $file.FullName

    # Extract the required data using simple string matching or regex
    $songTitle = ($content | Select-String -Pattern $patternTitle).Matches[0].Groups[1].Value.Trim()
    $songArtist = ($content | Select-String -Pattern $patternArtist).Matches[0].Groups[1].Value.Trim()

    # Create a custom object with the extracted data
    $songObject = [PSCustomObject]@{
        Artist = $songArtist
        Title = $songTitle
    }

    # Add the object to the collection
    $songDataCollection += $songObject
}

#Sort data by Artist
$sortedSongData = $songDataCollection | Sort-Object -Property Artist

# Export the collection to an formatted Excel file using the ImportExcel module
if ($songDataCollection) {
    Write-Host "Exporting data to $outputPath"
    $sortedSongData | Export-Excel -Path $outputExcelFile -WorksheetName "Song Information" -AutoSize -TableStyle:'Medium2'-Show
    Write-Host "Export complete."
} else {
    Write-Host "No data found to export."
}
