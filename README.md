# gs-meterrobbery

A comprehensive parking meter robbery script for FiveM servers, compatible with both QBCore and ESX frameworks.



## Features

- **Multi-Framework Support**: Works with both QBCore and ESX frameworks
- **Target System Integration**: Compatible with ox_target and qb-target
- **Advanced Minigame System**: Uses two sequential ox_lib minigames for a more challenging experience
- **Dispatch System**: Compatible with ps-dispatch and other dispatch systems
- **Highly Configurable**: Extensive configuration options for all aspects of the script
- **Realistic Animations**: Uses realistic animations for the robbery process
- **Reward System**: Configurable money and item rewards
- **Police Integration**: Configurable minimum police requirements with customizable police job names
- **Item Requirements**: Configurable required items with removal chance
- **Cooldown System**: Configurable cooldowns for individual meters or global player cooldowns



## Dependencies

- **Required**:
  - QBCore or ESX framework
  - ox_lib
  - ox_target or qb-target



## Installation

1. Extract the `gs-meterrobbery` folder to your server's resources directory
2. Add `ensure gs-meterrobbery` to your server.cfg file
3. Configure the script in the `config/config.lua` file
4. Restart your server

## Configuration

The script is highly configurable through the `config/config.lua` file. Here are the main configuration sections:

### Cooldown System

The script now includes a cooldown system for meter robberies. You can configure this in the `config.lua` file:

```lua
Config.Cooldown = {
    enabled = true,         -- Enable/disable cooldown system
    time = 300,             -- Cooldown time in seconds (e.g., 300 = 5 minutes)
    global = false,         -- If true, all meters share the same cooldown; if false, each meter has its own cooldown
    persistRestart = false, -- If true, cooldowns persist across server restarts (requires database integration)
}
```

- `enabled`: Set to `true` to enable the cooldown system, or `false` to disable it.
- `time`: The cooldown time in seconds. Default is 300 seconds (5 minutes).
- `global`: If set to `true`, players will have a global cooldown for all meters. If set to `false`, each meter will have its own cooldown.
- `persistRestart`: If set to `true`, cooldowns will persist across server restarts. This requires database integration (not implemented by default).

# Support

For support, please join our [Discord server](https://discord.gg/XpjBM53hMh)