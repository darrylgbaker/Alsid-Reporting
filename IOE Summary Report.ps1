 
 
 
 
 
 
 param(
    [Parameter()]
        [string]
        $uri = "darrylslab.alsid.app",
         [string]
         $apikey = '82242af5-00ce-4941-bb22-b63b71b169f1'
   
 )

$token = @{'x-api-key'=$apikey}


 
 
 [array]$html = ""

$forests = Invoke-RestMethod -Uri ("https://" + $uri + "/api/infrastructures") -Method GET -Headers $token

$forests | %{
      

    
    [string]$forid = $_.id
    
    $_.name

   $domains =  Invoke-RestMethod -Uri ("https://" + $uri + "/api/infrastructures/$forid/directories") -Method GET -Headers $token
            $domains | %{
                    
                    [string]$dirid = $_.id
                    [string]$dirname = $_.name
                    $deviances = Invoke-RestMethod -Uri ("https://darrylslab.alsid.app/api/infrastructures/1/directories/1/deviances") -Method GET -Headers $token 
                    $checkers = Invoke-RestMethod -Uri "https://darrylslab.alsid.app/api/checkers" -Method GET -Headers $token    
                    $arraylist = New-Object -TypeName System.Collections.ArrayList
   
                            
                            $deviances |%{
                                 $num = $_.checkerid
                                 $date = $_.eventDate
                                 $resolved = $_.resolvedAt
                          [array]$attributes = $_.attributes
                         

                                 $checkname = $checkers | ?{$_.id -eq $num} | select name 
                                 $attribjoined = $attributes | foreach {$_ -join ","}
                                 $attribjoined = $attribjoined -join ","
                                 $attribjoined = $attribjoined -replace '@{name='
                                 $properties = @{
                                    IOE           = $checkname.name
                                    EventDate           = $date
                                    ResolvedAt     = $resolved
                                    DeviantObjects = $attribjoined -replace '}' 
                                    }
                                 $obj = New-Object PSObject -Property $properties
            
                                 $arraylist += $obj

                            }
            $devcount = $deviances.count
            $heading = $dirname + "___________________Current Deviance Count:" + $devcount
            $arraysort = $arraylist |sort IOE 
            $html = $arraysort | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$heading</h2>"
            $html = $html -replace "\<table\>",'<table cellpadding="15">'

         

             
          }

           
}

ConvertTo-Html -Title "IOE Report" -Body $html | Out-File c:\users\darryl\desktop\report.html 
c:\users\darryl\desktop\report.html 
            
