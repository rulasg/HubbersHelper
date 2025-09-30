function Test_Gethubber{

    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Load-HubbersList -Path $filePath

    $user = "user3"
    $manager = "user0"

    $result = Get-Hubber -Handle $user

    Assert-AreEqual -Expected $user -Presented $result.github_login
    Assert-AreEqual -Expected $manager -Presented $result.manager.github_login

}