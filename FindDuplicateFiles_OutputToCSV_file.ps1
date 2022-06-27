#Purpose: 
#The purpose of this script is to find duplicate files within a directory to assist with storage management. 

#Instructions: 
#Enter the folder directory that you would like to search for dupliates. Note that low level directories will take a long time to search through.

#Author
#Script by Steven McMahon. Created June 13, 2022. Last edited: June 27, 2022

############# Find Duplicate Files based on Hash Value ###############

#Subdues errors from being printed to the console. You need to set both of these to supress all errors from showing in the console.
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"

#Get the current username of the user running the script. This will be used to print the report to their specific desktop
$Username = $env:USERNAME
#Get Today's date. This will be added to the filename of the report and let the user know when the report was last run.
$date = get-date -UFormat "%d%m%Y"

#This block is printed to the console and is intended to let the 
Write-Host "This script is designed to help Administrators optimize storage space by locating multiple instances of duplicate files within a directory."
Write-Host "This script searches by the hash value of a file vs searching by filename. This way, even if a user has changed the name of a file it will be found by this script. This report will be saved as a CSV file on your Desktop"
Write-Host "`nPlease note that searching root directories can take a very long time (up to several hours), so please plan accordingly."
Write-Host "`nYou may see error messages. These are typically caused by file paths that are too long (The limit is 255 characters in total), or by files that are currently in use by users. Please ignore these errors, the script will continue to run" -ForegroundColor Red

#Get the filepath from the user that they would like to search. 
$filepath = Read-Host "`nEnter file path for searching duplicate files (e.g. C:\Temp, C:\)"

#The main body of the script. The Test-Path is used to determine if all elements of a path exist.
#If the path exists, the script will continue. If not, it will drop down to the else statement and inform the user that they have entered an invalid file path. 
If (Test-Path $filepath) {

#Print to console to let the user know that the script is running and may take some time to complete.
Write-Host 'Searching for duplicates ... Please wait ... This may take a while based on the size of the directory ...'

#Get all of the files within the filepath that was provided, get a hash of the file, and then group it together. Lasterly, if the count is greater than one, store that file in the report as a duplicate.  
$duplicates = Get-ChildItem $filepath -File -Recurse | 
Get-FileHash |
Group-Object -Property Hash |
Where-Object Count -GT 1

#If there are no duplicates found print that to console and then break from the script.  
If ($duplicates.count -lt 1){
Write-Host 'No duplicates found.'
Pause
Break 
}

#If there are duplicated found, generate a CSV file that stores the filepath and hash of the duplicate files 
else{
Write-Host "`nDuplicates found. Please see the report generated at C:\Users\$Username\Desktop\Duplicate_Files_Report_$date.csv "
$result = foreach ($d in $duplicates)
{
$d.Group | Select-Object -Property Path, Hash
}
#The script is currenlty saving the results to the desktop. If you would like to save it somewhere else change the file path here. 
$result | Export-Csv -path "C:\Users\$Username\Desktop\Duplicate_Files_Report_$date.csv" 
}

#Re-import the file that was just created. 
$FilesToCheck = Import-Csv -Path "C:\Users\$Username\Desktop\Duplicate_Files_Report_$date.csv" 

#For each file within the Duplicate File Report, Take that file path and then get the size of that file and print it to a CSV File on the Desktop. 
foreach($file in $FilesToCheck)
{
Get-ItemProperty -Path $FilesToCheck.Path -Name Name, Length | Export-Csv -path "C:\Users\$Username\Desktop\Duplicate_Files_by_Size_Report_$date.csv" #The script is currenlty saving the results to the desktop. If you would like to save it somewhere else change the file path here.
}

#Let the user know that the report is being generated 
Write-Host "Generating the duplicate file sizes now. Please do not close the console..."

#Let the user know where the report has been printed.
Write-Host "`nThe file size report can be found at: C:\Users\$Username\Desktop\Duplicate_Files_by_Size_Report_$date.csv"

#Puase so that the user can read the results.
Pause
}

#Used for error checking. If the folder that the user input in line 24 is not found, print that to the console and do not execute the main script 
else
{
Write-Warning
"Folder not found. Use full path to directory e.g. S:\documentation"
Pause
}