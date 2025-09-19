# HubbersHelper

A powershell module that will hold Powershell functionality.

## Samples

### Get Huber information

```powershell
 get-hubber "rulasg"
```

### List population of hubbers by country

```powershell
 get-hubber | group country | Sort-Object count -Descending | select Count,Name
```

> Module generated with [TestingHelper Powershell Module](https://www.powershellgallery.com/packages/TestingHelper/)
