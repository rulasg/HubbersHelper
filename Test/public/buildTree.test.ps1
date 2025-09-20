function Test_Build-Tree{
    
    $hubbers,$tree = Build-Tree

    Assert-AreEqual -Expected ashtom -Presented $hubbers.rulasg.manager.manager.manager.manager.github_login

    # total employeed
    Assert-Count -Expected 4410 -Presented $hubbers
    Assert-AreEqual -Expected 4410 -Presented $tree.totalEmployees

}