function Test_SplitHubber{
            Reset-InvokeCommandMock
            Mock_Database
            $filePath = Get-MockFileFullPath -fileName "hubbers.json"
            $result = Import-HubbersList -Path $filePath

            $user = "user3"
            $manager = "user0"
            $reports = @("user6", "user12", "user9")

            $ref = Get-Hubber -Handle $user

    #Act -manager
    $result = $ref | split-hubber -Manager

    Assert-Count -Expected 1 -Presented $result
    Assert-AreEqual -Expected $manager -Presented $result.handle


    # Act - Reports
    $result = $ref | split-hubber -Reports

    Assert-Count -Expected $reports.Count -Presented $result
    $reports | foreach-object{
        Assert-Contains -Expected $_ -Presented $result.handle
    }

    # Act -Reports and Manager
    $result = $ref | split-hubber -Reports -Manager

    Assert-Count -Expected ($reports.Count + 1) -Presented $result
    Assert-Contains -Expected $manager -Presented $result.handle
    $reports | foreach-object{
        Assert-Contains -Expected $_ -Presented $result.handle
    }
}

function Test_SplitHubber_Unique{
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath

    # $manager = "user0"
    $user = "user3"
    $reports = @(
        [PSCustomObject]@{github_login="user6"}, 
        [PSCustomObject]@{github_login="user12"}, 
        [PSCustomObject]@{github_login="user9"}
    )

    # Act
    $result = $reports | split-hubber -Manager
    Assert-Count -Expected 1 -Presented $result
    Assert-AreEqual -Expected $user -Presented $result.handle
}