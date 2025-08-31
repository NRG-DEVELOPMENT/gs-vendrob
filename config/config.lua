Config = {}

-- Framework Configuration
Config.Framework = 'qbcore' -- Options: 'qbcore', 'esx'  -- for QBX leave it as qbcore, it will work!!

-- Target System Configuration
Config.Target = 'ox' -- Options: 'qb', 'ox'
Config.TargetIcon = 'fa-solid fa-sack-dollar' -- Third-eye icon (FontAwesome icon)

-- Item Requirements
Config.RequiredItem = 'lockpick' -- Item needed to rob the vending machines

-- Notification Settings
Config.NotifyDuration = 7 -- Duration in seconds for notifications

-- Progress Bar Configuration
Config.ProgressBar = {
    Enabled = false, -- Set to true if you want a progress bar before minigame
    Type = "ox_progressbar", -- "ox_progressbar", "ox_progresscircle", "qb_progressbar"
    Options = {
        ["ox_progressbar"] = {
            duration = 20000,
            label = "Robbing vending machine...",
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
        },
        ["ox_progresscircle"] = {
            duration = 20000,
            label = "Robbing vending machine...",
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
        },
        ["qb_progressbar"] = {
            name = "rob_vending",
            duration = 20000,
            label = "Robbing vending machine...",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = 'missheistfbi3b_ig7',
                anim = 'lift_fibagent_loop',
            }
        },
    }
}

-- Minigame Configuration
Config.Minigame = {
    -- Choose which minigame to use:
    -- 'qb-lockpick' - Uses QB-Lockpick (circle minigame)
    -- 'ox-skillcheck' - Uses OX-Lib skillcheck
    -- 'ox-circle' - Uses OX-Lib circle minigame
    -- 'ox-bar' - Uses OX-Lib progress bar minigame
    -- 'ps-skillbar' - Uses PS-UI skillbar
    -- 'ps-circle' - Uses PS-UI circle minigame
    -- 'ps-scrambler' - Uses PS-UI scrambler (hacking) minigame
    Type = 'ox-skillcheck',
    
    Settings = {
        -- QB Lockpick Settings
        ['qb-lockpick'] = {
            Difficulty = 3, -- 1 = Easy, 5 = Hard
            Pins = 4,
            Time = 15, -- Seconds
            NumOfAttempts = 6
        },
        -- OX Skillcheck Settings
        ['ox-skillcheck'] = {
            Difficulty = 'medium', -- 'easy', 'medium', 'hard'
            SkillCheckCount = 3,
            Keys = {'w', 'a', 's', 'd'}
        },
        -- OX Circle Settings
        ['ox-circle'] = {
            Difficulty = 3, -- 1-10 (10 is hardest)
            Duration = 2000, -- milliseconds
        },
        -- OX Bar Settings
        ['ox-bar'] = {
            Duration = 5000, -- milliseconds
            Position = 'middle', -- 'left', 'middle', 'right'
            Width = 30, -- width of the success zone (percentage)
        },
        -- PS Skillbar Settings
        ['ps-skillbar'] = {
            Difficulty = 'medium', -- 'easy', 'medium', 'hard'
            SkillCheckCount = 3,
        },
        -- PS Circle Settings
        ['ps-circle'] = {
            Duration = 7, -- seconds
            Circles = 3,
            Success = 'medium' -- 'easy', 'medium', 'hard'
        },
        -- PS Scrambler Settings
        ['ps-scrambler'] = {
            Type = 'alphabet', -- 'alphabet', 'numeric', 'alphanumeric', 'greek', 'braille', 'runes'
            Duration = 30, -- seconds
            Length = 5, -- length of the code
        }
    }
}

-- Police Configuration
Config.RequirePolice = false -- Set to false to disable police requirement
Config.MinPolice = 1 -- Minimum number of police required for robbery
Config.AlertPolice = true -- Enable Police Alerts
Config.AlertPoliceOnCancel = true -- Enable Police Alerts even if robbery was cancelled
Config.PoliceAlertChance = 60 -- Percentage chance of alerting police (0-100)

-- Dispatch Configuration
Config.Dispatch = {
    Enabled = false,
    System = 'ps', -- Options: 'ps', 'cd', 'custom'
    BlipDuration = 60, -- Seconds for the blip to remain on the map
    BlipSprite = 628,
    BlipColor = 1,
    BlipScale = 1.0,
}

-- Cooldown Configuration
Config.Cooldown = {
    -- Machine-specific cooldown
    MachineCooldown = 30.0, -- Minutes
    
    -- Player Cooldown
    EnablePlayerCooldown = false,
    PlayerCooldown = 10.0, -- Minutes
    
    -- Global Cooldown
    EnableGlobalCooldown = false,
    GlobalCooldown = 5.0, -- Minutes
}

-- Reward Configuration
Config.Rewards = {
    Enabled = true, -- Allow rewards on robbery success
    
    -- Mad-Loot Integration
    UseMadLoot = false,
    MadLootTableName = "vending_machine_loot",
    MadLootTableTiers = "all",
    MadLootTableUseGuaranteed = true,
    
    -- Cash Rewards
    Money = {
        Enabled = true,
        Chance = 100, -- Percentage chance to get money
        Min = 5,
        Max = 50,
        Type = 'cash' -- 'cash' or 'bank'
    },
    
    -- Common Item Rewards
    CommonItems = {
        Enabled = true,
        Chance = 50, -- Percentage chance to get common items
        Items = {
            {name = 'water', min = 1, max = 3, chance = 70},
            {name = 'sandwich', min = 1, max = 2, chance = 60},
            {name = 'cola', min = 1, max = 3, chance = 70},
            {name = 'chocolate', min = 1, max = 2, chance = 50},
            {name = 'chips', min = 1, max = 2, chance = 60},
            {name = 'bandage', min = 1, max = 5, chance = 40},
            {name = 'parachute', min = 1, max = 2, chance = 20},
        }
    },
    
    -- Rare Item Rewards
    RareItems = {
        Enabled = true,
        Chance = 25, -- Percentage chance to get rare items
        Items = {
            {name = 'lockpick', min = 1, max = 3, chance = 60},
            {name = 'phone', min = 1, max = 1, chance = 20},
            {name = 'radio', min = 1, max = 1, chance = 10},
        }
    }
}

-- Random Events Configuration
Config.RandomEvents = {
    OnSuccess = true, -- Allow random events on robbery success
    OnFail = true, -- Allow random events on robbery fail
    Chance = 30, -- Percentage chance for a random event to occur (0-100)
    
    -- Event Types
    Events = {
        Taze = {
            Enabled = true,
            Chance = 7.5, -- Percentage chance
            Duration = 5000, -- Duration in ms
        },
        BreakMachine = {
            Enabled = true,
            Chance = 15.0, -- Percentage chance
        },
        BlowUp = {
            Enabled = true,
            Chance = 5.0, -- Percentage chance
            DamageRadius = -1.0, -- Negative for no damage, positive for damage
        },
        -- TrapArm event removed as requested
        SecurityCamera = {
            Enabled = true,
            Chance = 15.0, -- Percentage chance
        },
        BonusReward = {
            Enabled = true,
            Chance = 10.0, -- Percentage chance
        },
        Nothing = {
            Enabled = true,
            Chance = 10.0, -- Percentage chance
        }
    }
}

-- Vending Machine Models
Config.VendingMachines = {
    -- Snack and Drink machines
    `prop_vend_snak_01`,
    `prop_vend_snak_01_tu`,
    `prop_vend_soda_01`,
    `prop_vend_soda_02`,
    `sf_prop_sf_vend_drink_01a`,
    `prop_vend_coffe_01`,
    `prop_vend_water_01`,
    `prop_vend_fags_01`,
    -- Add any other vending machine models you want to include
}

-- Debug Mode
Config.Debug = false