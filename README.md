# Difficulty Adjustment System
Phoenix0001 suggested a plugin like this so Tak (Chaosxk) wrote a short one. Unfortunately, it wasn't properly checking for the amount of players on the server after every map transition. Lux then revised the code but the plugin still didn't work reliably. I then decided to revise his revision and made the "Difficulty Adjustment System" (D.A.S).

## License
Difficulty Adjustment System: a L4D/L4D2 SourceMod Plugin
Copyright (C) 2017 Alfred "Crasher_3637/Psyk0tik" Llagas

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

## About
Adjusts difficulty based on the number of alive human survivors on the server.

> The requirement for each difficulty can be set via convars. Difficulty is adjusted by constantly checking the alive human survivor count every second as soon as the round starts.

### What makes the Difficulty Adjustment System viable in Left 4 Dead/Left 4 Dead 2?
The plugin can adjust the intensity of gameplays depending on how many players are on the server. This can result in challenging and fun experiences for everyone.

### Requirements
Ammunition Variation was developed against SourceMod 1.8+.

### Installation
1. Delete files from old versions of the plugin.
2. Extract the folder inside the .zip file.
3. Place all the contents into their respective folders.
4. If prompted to replace or merge anything, click yes.
5. Load up the Difficulty Adjustment System.
  - Type ```sm_rcon sm plugins load difficulty_adjustment_system``` in console.
  - OR restart the server.
6. Customize Difficulty Adjustment System (Config file generated on first load).

### Uninstalling/Upgrading to Newer Versions
1. Delete difficulty_adjustment_system.smx from addons/sourcemod/plugins folder.
2. Delete difficulty_adjustment_system.sp from addons/sourcemod/scripting folder.
3. Delete difficulty_adjustment_system.cfg from cfg/sourcemod folder.
4. Follow the Installation guide above. (Only for upgrading to newer versions.)

### Disabling
1. Move difficulty_adjustment_system.smx to plugins/disabled folder.
2. Unload Difficulty Adjustment System.
  - Type ```sm_rcon sm plugins unload difficulty_adjustment_system``` in console.
  - OR restart the server.

## Configuration Variables (ConVars/CVars)
```
// Minimum players required for Advanced.
// -
// Default: "3"
das_advanceddifficulty "3"

// Announce the difficulty when it is changed?
// (0: OFF)
// (1: ON)
// -
// Default: "1"
das_announcedifficulty "1"

// Disable the plugin in these game modes.
// (Empty: None)
// (Not empty: Disabled in these game modes, separated by commas with no spaces.)
// -
// Default: "versus,realismversus,survival,scavenge"
das_disabledgamemodes "versus,realismversus,survival,scavenge"

// Minimum players required for Easy.
// -
// Default: "1"
das_easydifficulty "1"

// Enable the plugin in these game modes.
// (Empty: All)
// (Not empty: Enabled in these game modes, separated by commas with no spaces.)
// -
// Default: "coop,realism,mutation1,mutation12"
das_enabledgamemodes "coop,realism,mutation1,mutation12"

// Enable the Difficulty Adjustment System?
// (0: OFF)
// (1: ON)
// -
// Default: "1"
das_enableplugin "1"

// Minimum players required for Expert.
// -
// Default: "4"
das_expertdifficulty "4"

// Minimum players required for Normal.
// -
// Default: "2"
das_normaldifficulty "2"
```

## Questions You May Have
> If you have any questions that aren't addressed below, feel free to message me or post on this [thread](https://forums.alliedmods.net/showthread.php?t=303117).

1. How do I enable/disable the plugin in certain game modes?

You must specify the game modes in the das_enabledgamemodes and das_disabledgamemodes convars.

Here are some scenarios and their outcomes:

- Scenario 1
```
das_enabledgamemodes "" // The plugin is enabled in all game modes.
das_disabledgamemodes "coop" // The plugin is disabled in Campaign mode.

Outcome: The plugin works in every game mode except in Campaign mode.
```
- Scenario 2
```
das_enabledgamemodes "coop" // The plugin is enabled in only Campaign mode.
das_disabledgamemodes "" // The plugin is not disabled at all.

Outcome: The plugin works only in Campaign mode.
```
- Scenario 3
```
das_enabledgamemodes "coop,versus" // The plugin is enabled in only Campaign and Versus modes.
das_disabledgamemodes "coop" // The plugin is disabled in Campaign mode.

Outcome: The plugin works only in Versus mode.
```

2. When does the difficulty change?

- If the requirement for Easy is met or if the alive human survivor count is less than the requirements for Normal, it changes to Easy.
- If the requirement for Normal is met or if the alive human survivor count is less than the requirements for Advanced, it changes to Normal.
- If the requirement for Advanced is met or if the alive human survivor count is less than the requirement for Expert, it changes to Advanced.
- If the requirement for Expert is met or if the alive human survivor count is greater than the requirements for Expert, it changes to Expert.

## Credits

**Tak (Chaosxk)** - For the original code found [here](https://forums.alliedmods.net/showpost.php?p=2518197&postcount=4).

**Lux** - For revising the original code found [here](https://forums.alliedmods.net/showpost.php?p=2561468&postcount=9).

**phoenix0001** - For the idea, original post [here](https://forums.alliedmods.net/showthread.php?t=297009) and new post [here](https://forums.alliedmods.net/showthread.php?t=302919).

**Silvers (Silvershot)** - For the code that allows users to enable/disable the plugin in certain game modes.

**cravenge** - For the new code (3/28/2018).

**Visual77 and MasterMind420** - For helpful input.

**Mi.Cura** - For help in testing.

# Contact Me
If you wish to contact me for any questions, concerns, suggestions, or criticism, I can be found here:
- [AlliedModders Forum](https://forums.alliedmods.net/member.php?u=181166)
- [Steam](https://steamcommunity.com/profiles/76561198056665335)
- Psyk0tik#7757 on Discord

# 3rd-Party Revisions Notice
If you would like to share your own revisions of this plugin, please rename the files! I do not want to create confusion for end-users and it will avoid conflict and negative feedback on the official versions of my work. If you choose to keep the same file names for your revisions, it will cause users to assume that the official versions are the source of any problems your revisions may have. This is to protect you (the reviser) and me (the developer)! Thank you!

# Donate
- [Donate to SourceMod](https://www.sourcemod.net/donate.php)

Thank you very much! :)