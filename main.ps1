#!/bin/sh

# check if base path are availabe if not create them
# from positional arguments
# or from the prompt
if((Test-Path Env:BACKUP_SOURCE) -and (Test-Path Env:BACKUP_DEST)) {
  $source = $Env:BACKUP_SOURCE
  $dest = $Env:BACKUP_DEST
  Write-Host "ENV variables available $Env:BACKUP_SOURCE"
} elseif ($args[0] -and $args[1]) {
  $source = $args[0]
  $dest = $args[1]
} else {
  Write-Host "Env variables required"
  $source = Read-Host -Prompt 'Provide source path of the folder.'
  $dest = Read-Host -Prompt 'Provide destination path for the zip file.'
}

# ---------------------------------------------
# check if log file is created if not create it
# get current number
$number_log_file = 'next_number.log'
$number_log_path = Join-Path -ChildPath $number_log_file -Path $dest

if (!(Test-Path $number_log_path))
{
   New-Item -path $dest -name $number_log_file -type "file" -value "1"
   Write-Host "Created new log file and text content added"
}
$current_number = Get-Content -Path $number_log_path
# ---------------------------------------------

if((Test-Path env:BACKUP_NUMBER)) {
  $backup_number = $Env:BACKUP_NUMBER
  Write-Host "backupnumber from variable"
} else {
  $backup_number = '10'
}
Write-Host "Number of backups is set to: ${backup_number}"


if ([int]$current_number -gt [int]$backup_number)
{
  Set-Content -path $number_log_path -value "1"
  Write-Host "Max backups has been reached. Overwriting oldest backup"
} else {
  $new_number = [int]$current_number + 1
  Set-Content -path $number_log_path -value $new_number
  Write-Host "Current backup number is: ${new_number}"
}

$final_destination = Join-Path -ChildPath $current_number -Path $dest

Compress-Archive -DestinationPath $final_destination -Force -Path $source -CompressionLevel Optimal
