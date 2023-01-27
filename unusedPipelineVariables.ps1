$pathToOutputFile=".\Outfile.json"

#az login --allow-no-subscriptions
$token = az account get-access-token --query '{token:accessToken}' --output json | ConvertFrom-Json

$pipelines = az pipelines list --org https://dev.azure.com/MJQ-LEG --project GESTE --query '[].{name:name}' --output json | ConvertFrom-Json

$headers = @{
    'Accept' = 'application/json'
    'Content-Type' ='application/json'
    'Authorization' = "Bearer $($token.token)"
}

$resultObject = New-Object -TypeName psobject

foreach ($json in $pipelines)
{
    $pipelineName = $json.name

    
    $variables = az pipelines variable list --pipeline-name $pipelineName --project GESTE --output json | ConvertFrom-Json 

        foreach ($variable in $variables.PSObject.Properties) 
        {
            $variableName = $variable.Name
            $Body = @{
                'searchText' = "$($variableName)"
                '$top' = '10'
            }
            
            $Parameters = @{
                Method = 'POST'
                Uri =  'https://almsearch.dev.azure.com/MJQ-LEG/GESTE/_apis/search/codesearchresults?api-version=7.0'
                Body = ($Body | ConvertTo-Json) 
                Headers = $headers 
            }
            
            $response = Invoke-RestMethod @Parameters
            $results = $response.results
            foreach ($result in $results) 
            {
                $result | Add-Member -Type NoteProperty -Name 'resultsCount' -Value $response.count
                $result | Add-Member -Type NoteProperty -Name 'variableName' -Value $variable
                $result | ConvertTo-Json | Add-Content $pathToOutputFile 
                Add-Content $pathToOutputFile ","
            }
            

        }
    $resultObject | Add-Member -Type NoteProperty -Name $pipelineName -Value ????
}
Add-Content $pathToOutputFile "]"
Write-Output "Analyse termine"

function Get-ResultFormated {
    param (
        $rawResult
    )
    return 
}