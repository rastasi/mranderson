local DEFAULT_CONFIG = {
  screen = {
    width = 240,
    height = 136
  },
  colors = {
    black = 0,
    light_grey = 13,
    dark_grey = 14,
    green = 6,
    npc = 8,
    item = 12 -- yellow
  },
  player = {
    w = 8,
    h = 8,
    start_x = 120,
    start_y = 128,
    sprite_id = 1
  },
  physics = {
    gravity = 0.5,
    jump_power = -5,
    move_speed = 1.5,
    max_jumps = 2,
    interaction_radius_npc = 12,
    interaction_radius_item = 8
  },
  timing = {
    splash_duration = 120
  }
}

local Config = {
  -- Copy default values initially
  screen = DEFAULT_CONFIG.screen,
  colors = DEFAULT_CONFIG.colors,
  player = DEFAULT_CONFIG.player,
  physics = DEFAULT_CONFIG.physics,
  timing = DEFAULT_CONFIG.timing,
}

local CONFIG_SAVE_BANK = 7
local CONFIG_SAVE_ADDRESS_MOVE_SPEED = 0
local CONFIG_SAVE_ADDRESS_MAX_JUMPS = 1
local CONFIG_MAGIC_VALUE_ADDRESS = 2
local CONFIG_MAGIC_VALUE = 0xDE -- A magic number to check if config is saved

function Config.save()
  -- Save physics settings
  mset(Config.physics.move_speed * 10, CONFIG_SAVE_ADDRESS_MOVE_SPEED, CONFIG_SAVE_BANK)
  mset(Config.physics.max_jumps, CONFIG_SAVE_ADDRESS_MAX_JUMPS, CONFIG_SAVE_BANK)
  mset(CONFIG_MAGIC_VALUE, CONFIG_MAGIC_VALUE_ADDRESS, CONFIG_SAVE_BANK) -- Mark as saved
end

function Config.load()
  -- Check if config has been saved before using a magic value
  if mget(CONFIG_MAGIC_VALUE_ADDRESS, CONFIG_SAVE_BANK) == CONFIG_MAGIC_VALUE then
    Config.physics.move_speed = mget(CONFIG_SAVE_ADDRESS_MOVE_SPEED, CONFIG_SAVE_BANK) / 10
    Config.physics.max_jumps = mget(CONFIG_SAVE_ADDRESS_MAX_JUMPS, CONFIG_SAVE_BANK)
  else
    Config.restore_defaults()
  end
end

function Config.restore_defaults()
  Config.physics.move_speed = DEFAULT_CONFIG.physics.move_speed
  Config.physics.max_jumps = DEFAULT_CONFIG.physics.max_jumps
  -- Any other configurable items should be reset here
end

-- Load configuration on startup
Config.load()
