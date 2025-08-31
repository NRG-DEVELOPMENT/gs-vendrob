# GS-VendRob

## Advanced Vending Machine Robbery Script for FiveM

GS-VendRob is a high-quality vending machine robbery script for FiveM with compatibility for QBCore, QBX, and ESX frameworks. This script allows players to rob vending machines throughout the city using third-eye targeting systems.


## Features

- **Multi-Framework Support**: Compatible with QBCore, QBX, and ESX frameworks
- **Target System Integration**: Works with both QB-Target and OX-Target
- **Minigame Options**: Choose between QB, OX, and PS minigames
- **Dispatch Integration**: Built-in support for PS-Dispatch, CD-Dispatch, and custom dispatch systems
- **Random Events**: Chance-based events like electric shocks, alarms, and tool breakage
- **Configurable Rewards**: Customize money and item rewards
- **Police Requirements**: Set minimum police requirements for robberies
- **Cooldown System**: Both global and per-machine cooldowns
- **Item Requirements**: Require specific items to perform robberies

## Installation

1. Download the latest release from the [GitHub repository](https://github.com/yourusername/gs-vendrob/releases)
2. Extract the `gs-vendrob` folder to your server's resources directory
3. Add `ensure gs-vendrob` to your server.cfg
4. Configure the script in the `config/config.lua` file
5. Restart your server

## Configuration

The script is highly configurable through the `config/config.lua` file. Here are the main configuration options:

### Framework Configuration

```lua
-- Framework Configuration
Config.Framework = 'qbcore' -- Options: 'qbcore', 'qbx', 'esx'

-- Target System Configuration
Config.Target = 'qb' -- Options: 'qb', 'ox'
```

### Minigame Configuration

```lua
-- Minigame Configuration
Config.Minigame = {
    Type = 'qb', -- Options: 'qb', 'ox', 'ps'
    Settings = {
        -- QB Lockpick Settings
        QB = {
            Difficulty = 3, -- 1 = Easy, 5 = Hard
            Pins = 4,
            Time = 15, -- Seconds
        },
        -- OX Skillbar Settings
        OX = {
            Difficulty = 'medium', -- 'easy', 'medium', 'hard'
            SkillCheckCount = 3,
        },
        -- PS Skillbar Settings
        PS = {
            Difficulty = 'medium', -- 'easy', 'medium', 'hard'
            SkillCheckCount = 3,
        }
    }
}
```

### Item Requirements

```lua
-- Item Requirements
Config.RequiredItem = {
    Name = 'lockpick', -- Item name in your inventory system
    RemoveOnUse = true, -- Whether to remove the item after use
    RemoveOnFail = false, -- Whether to remove the item if the player fails
}
```

### Police Configuration

```lua
-- Police Configuration
Config.RequirePolice = true -- Set to false to disable police requirement
Config.MinPolice = 2 -- Minimum number of police required for robbery
```

### Dispatch Configuration

```lua
-- Dispatch Configuration
Config.Dispatch = {
    Enabled = true,
    System = 'ps', -- Options: 'ps', 'cd', 'custom'
    BlipDuration = 60, -- Seconds for the blip to remain on the map
    BlipSprite = 628,
    BlipColor = 1,
    BlipScale = 1.0,
    AlertChance = 75, -- Percentage chance of alerting police (0-100)
}
```

### Reward Configuration

```lua
-- Reward Configuration
Config.Rewards = {
    Money = {
        Min = 100,
        Max = 500,
        Type = 'cash' -- 'cash' or 'bank'
    },
    Items = {
        Enabled = true,
        Chance = 50, -- Percentage chance to get items (0-100)
        PossibleItems = {
            {name = 'water', min = 1, max = 3, chance = 70},
            {name = 'sandwich', min = 1, max = 2, chance = 60},
            {name = 'cola', min = 1, max = 3, chance = 70},
            {name = 'chocolate', min = 1, max = 2, chance = 50},
            {name = 'chips', min = 1, max = 2, chance = 60},
        }
    }
}
```

### Random Events Configuration

```lua
-- Random Events Configuration
Config.RandomEvents = {
    Enabled = true,
    Chance = 30, -- Percentage chance for a random event to occur (0-100)
    Events = {
        {
            name = 'taze',
            label = 'Electric Shock',
            chance = 40, -- Relative chance within events
            duration = 5000, -- Duration in ms
            animation = 'electrocuted',
        },
        {
            name = 'alarm',
            label = 'Loud Alarm',
            chance = 30,
        },
        {
            name = 'break_tool',
            label = 'Tool Breaks',
            chance = 20,
        },
        {
            name = 'nothing',
            label = 'Nothing Happens',
            chance = 10,
        }
    }
}
```

### Cooldown Configuration

```lua
-- Cooldown Configuration
Config.Cooldown = {
    Global = 300, -- Global cooldown in seconds (5 minutes)
    Individual = 600, -- Individual machine cooldown in seconds (10 minutes)
}
```

### Vending Machine Models

```lua
-- Vending Machine Models
Config.VendingMachines = {
    -- Snack machines
    `prop_vend_snak_01`,
    `prop_vend_snak_01_tu`,
    `prop_vend_soda_01`,
    `prop_vend_soda_02`,
    `prop_vend_coffe_01`,
    `prop_vend_water_01`,
    -- Add any other vending machine models you want to include
}
```

## Dependencies

- QBCore, QBX, or ESX framework
- QB-Target or OX-Target
- One of the following minigame scripts:
  - QB-Lockpick
  - OX-Lib
  - PS-UI

## Optional Dependencies

- PS-Dispatch
- CD-Dispatch

## Adding New Vending Machine Models

To add new vending machine models to the robbery system, simply add the model hash to the `Config.VendingMachines` table in the config.lua file:

```lua
Config.VendingMachines = {
    `prop_vend_snak_01`,
    `prop_vend_snak_01_tu`,
    `prop_vend_soda_01`,
    `prop_vend_soda_02`,
    `prop_vend_coffe_01`,
    `prop_vend_water_01`,
    `your_new_model_hash_here`,
}
```
