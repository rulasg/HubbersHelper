# How to use HubberHelper

## Sync the Hubber List from TheHub
```powershell
Sync-HubbersList
```

## Search a hubber by Name or handle

```powershell
Search-Hubber Raúl
sbb rulas
```

## Search hubbers by title and name

```powershell
Search-Hubber -Title "Engineer" -Name "Raúl"
```

## How a hubber

```powershell
Show-Hubber rulasg
sbb rulasg | shbb
```

## How to show hubber's manager

```powershell
shbb rulasg -Manager
```
## Show hubbers tree

```powershell
Show-HubberTree rulasg
```

## Show hubbers organization

```powershell
Show-HubberOrg helaili
```

## Show the connection betwen two hubbers

```powershell
Show-HubberConnection rulasg bas
```
