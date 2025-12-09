-- title:   Mr Anderson's Adventure
-- author:  Zsolt Tasnadi
-- desc:    Life of a programmer in the Vector
-- site:    http://teletype.hu
-- license: MIT License
-- version: 0.7
-- script:  lua

--------------------------------------------------------------------------------
-- Game Configuration
--------------------------------------------------------------------------------
local Config = {
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
  },
  timing = {
    splash_duration = 120 -- 2 seconds at 60fps
  }
}

--------------------------------------------------------------------------------
-- Game States
--------------------------------------------------------------------------------
local GAME_STATE_SPLASH = 0
local GAME_STATE_INTRO = 1
local GAME_STATE_MENU = 2
local GAME_STATE_GAME = 3
local GAME_STATE_DIALOG = 4
local GAME_STATE_INVENTORY = 5
local GAME_STATE_INVENTORY_ACTION = 6

--------------------------------------------------------------------------------
-- Modules
--------------------------------------------------------------------------------
local Splash = {}
local Intro = {}
local Menu = {}
local Game = {}
local UI = {}
local Input = {}
local Inventory = {}
local NpcActions = {}
local ItemActions = {}
local MenuActions = {}

--------------------------------------------------------------------------------
-- Game State
--------------------------------------------------------------------------------
local State = {
  game_state = GAME_STATE_SPLASH,
  inventory = {},
  intro = {
    y = Config.screen.height,
    speed = 0.5,
    text = "Mr. Anderson is an average\nprogrammer. His daily life\nrevolves around debugging,\npull requests, and end-of-sprint\nmeetings, all while secretly\ndreaming of being destined\nfor something more."
  },
  current_screen = 1,
  dialog_text = "",
  splash_timer = Config.timing.splash_duration,
  player = {
    x = Config.player.start_x,
    y = Config.player.start_y,
    w = Config.player.w,
    h = Config.player.h,
    vx = 0,
    vy = 0,
    jumps = 0,
    sprite_id = Config.player.sprite_id
  },
  ground = {
    x = 0,
    y = Config.screen.height,
    w = Config.screen.width,
    h = 8
  },
  menu_items = {},
  selected_menu_item = 1,
  selected_inventory_item = 1,
  dialog_menu_items = {},
  selected_dialog_menu_item = 1,
  active_entity = nil,
  -- Screen data
  screens = {
    { -- Screen 1
      name = "Screen 1",
      platforms = {
        {x = 80, y = 110, w = 40, h = 8},
        {x = 160, y = 90, w = 40, h = 8}
      },
      npcs = {
        {x = 180, y = 82, name = "Trinity", sprite_id = 2},
        {x = 90, y = 102, name = "Oracle", sprite_id = 3}
      },
      items = {
        {x = 100, y = 128, w=8, h=8, name = "Key", sprite_id = 4, desc = "A rusty old key. It might open something."}
      }
    },
    { -- Screen 2
      name = "Screen 2",
      platforms = {
        {x = 30, y = 100, w = 50, h = 8},
        {x = 100, y = 80, w = 50, h = 8},
        {x = 170, y = 60, w = 50, h = 8}
      },
      npcs = {
        {x = 120, y = 72, name = "Morpheus", sprite_id = 5},
        {x = 40, y = 92, name = "Tank", sprite_id = 6}
      },
      items = {
        {x = 180, y = 52, w=8, h=8, name = "Potion", sprite_id = 7, desc = "A glowing red potion. It looks potent."}
      }
    },
    { -- Screen 3
      name = "Screen 3",
      platforms = {
        {x = 50, y = 110, w = 30, h = 8},
        {x = 100, y = 90, w = 30, h = 8},
        {x = 150, y = 70, w = 30, h = 8},
        {x = 200, y = 50, w = 30, h = 8}
      },
      npcs = {
        {x = 210, y = 42, name = "Agent Smith", sprite_id = 8},
        {x = 160, y = 62, name = "Cypher", sprite_id = 9}
      },
      items = {}
    }
  }
}

--------------------------------------------------------------------------------
-- Inventory Module
--------------------------------------------------------------------------------
function Inventory.draw()
  cls(Config.colors.dark_grey)
  UI.draw_top_bar("Inventory")

  if #State.inventory == 0 then
    print("Inventory is empty.", 70, 70, Config.colors.light_grey)
  else
    for i, item in ipairs(State.inventory) do
			local color = Config.colors.light_grey
			if i == State.selected_inventory_item then
				color = Config.colors.green
				print(">", 60, 20 + i * 10, color)
			end
      print(item.name, 70, 20 + i * 10, color)
    end
  end
end

function Inventory.update()
  State.selected_inventory_item = UI.update_menu(State.inventory, State.selected_inventory_item)

  if Input.action() and #State.inventory > 0 then
    local selected_item = State.inventory[State.selected_inventory_item]
    State.active_entity = selected_item
    State.dialog_text = ""
    State.game_state = GAME_STATE_INVENTORY_ACTION
    State.showing_description = false
    State.dialog_menu_items = {
      {label = "Use", action = ItemActions.use},
      {label = "Drop", action = ItemActions.drop},
      {label = "Look at", action = ItemActions.look_at},
      {label = "Go back", action = ItemActions.go_back_from_inventory_action}
    }
    State.selected_dialog_menu_item = 1
  end

  if Input.back() then
    State.game_state = GAME_STATE_GAME
  end
end

--------------------------------------------------------------------------------
-- Menu Actions
--------------------------------------------------------------------------------
function MenuActions.play()
  -- Reset player state and screen for a new game
  State.player.x = Config.player.start_x
  State.player.y = Config.player.start_y
  State.player.vx = 0
  State.player.vy = 0
  State.player.jumps = 0
  State.current_screen = 1
  State.game_state = GAME_STATE_GAME
end

function MenuActions.exit()
  exit()
end

-- Initialize menu items after actions are defined
State.menu_items = {
  {label = "Play", action = MenuActions.play},
  {label = "Exit", action = MenuActions.exit}
}

--------------------------------------------------------------------------------
-- NPC Actions
--------------------------------------------------------------------------------
function NpcActions.talk_to() end
function NpcActions.fight() end
function NpcActions.go_back()
  State.game_state = GAME_STATE_GAME
end

--------------------------------------------------------------------------------
-- Item Actions
--------------------------------------------------------------------------------
function ItemActions.use()
  print("Used item: " .. State.active_entity.name)
  State.game_state = GAME_STATE_INVENTORY
end
function ItemActions.look_at()
  State.dialog_text = State.active_entity.desc
  State.showing_description = true
end
function ItemActions.put_away()
  -- Add item to inventory
  table.insert(State.inventory, State.active_entity)

  -- Remove item from screen
  local currentScreenData = State.screens[State.current_screen]
  for i, item in ipairs(currentScreenData.items) do
    if item == State.active_entity then
      table.remove(currentScreenData.items, i)
      break
    end
  end

  -- Go back to game
  State.game_state = GAME_STATE_GAME
end
function ItemActions.go_back_from_item_dialog()
  State.game_state = GAME_STATE_GAME
end

function ItemActions.go_back_from_inventory_action()
	State.game_state = GAME_STATE_GAME
end

function ItemActions.drop()
  -- Remove item from inventory
  for i, item in ipairs(State.inventory) do
    if item == State.active_entity then
      table.remove(State.inventory, i)
      break
    end
  end

  -- Add item to screen
  local currentScreenData = State.screens[State.current_screen]
	State.active_entity.x = State.player.x
	State.active_entity.y = State.player.y
  table.insert(currentScreenData.items, State.active_entity)

  -- Go back to inventory
  State.game_state = GAME_STATE_INVENTORY
end


--------------------------------------------------------------------------------
-- Input Module
--------------------------------------------------------------------------------
function Input.up() return btnp(0) end
function Input.down() return btnp(1) end
function Input.left() return btn(2) end
function Input.right() return btn(3) end
function Input.jump() return btnp(4) end
function Input.action() return btnp(4) end
function Input.interact() return btnp(5) end -- B button
function Input.back() return btnp(5) end

--------------------------------------------------------------------------------
-- UI Module
--------------------------------------------------------------------------------
function UI.draw_top_bar(title)
  rect(0, 0, Config.screen.width, 10, Config.colors.dark_grey)
  print(title, 3, 2, Config.colors.green)
end

function UI.draw_dialog()
  rect(40, 40, 160, 80, Config.colors.black)
  rectb(40, 40, 160, 80, Config.colors.green)

  -- Display the entity's name as the dialog title
  print(State.active_entity.name, 120 - #State.active_entity.name * 2, 45, Config.colors.green)

  -- Display the dialog content (description for "look at", or initial name/dialog for others)
  local wrapped_lines = UI.word_wrap(State.dialog_text, 25) -- Max 25 chars per line
  local current_y = 55 -- Starting Y position for the first line of content
  for _, line in ipairs(wrapped_lines) do
    print(line, 50, current_y, Config.colors.light_grey)
    current_y = current_y + 8 -- Move to the next line (8 pixels for default font height + padding)
  end
  
  -- Adjust menu position based on the number of wrapped lines
  if not State.showing_description then
    UI.draw_menu(State.dialog_menu_items, State.selected_dialog_menu_item, 50, current_y + 2)
  else
    -- If description is showing, provide a "Go back" option automatically, or close dialog on action
    -- For now, let's just make it implicitly wait for Input.action() or Input.back() to close
    -- Or we can add a specific "Back" option here.
    -- Let's add a "Back" option for explicit return from description.
    print("[A] Go Back", 50, current_y + 10, Config.colors.green)
  end
end

function UI.draw_menu(items, selected_item, x, y)
  for i, item in ipairs(items) do
    local current_y = y + (i-1)*10
    if i == selected_item then
      print(">", x - 8, current_y, Config.colors.green)
    end
    print(item.label, x, current_y, Config.colors.green)
  end
end

function UI.update_menu(items, selected_item)
  if Input.up() then
    selected_item = selected_item - 1
    if selected_item < 1 then
      selected_item = #items
    end
  elseif Input.down() then
    selected_item = selected_item + 1
    if selected_item > #items then
      selected_item = 1
    end
  end
  return selected_item
end

function UI.word_wrap(text, max_chars_per_line)
    local lines = {}
    local current_line = ""
    local words = {}

    -- Split text into words, handling spaces and newlines
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end

    local i = 1
    while i <= #words do
        local word = words[i]
        -- Check if adding the word to the current line exceeds max_chars_per_line
        if #current_line == 0 then
            -- If the current line is empty, just add the word
            current_line = word
        elseif #current_line + 1 + #word <= max_chars_per_line then
            -- If the word fits, add it with a space
            current_line = current_line .. " " .. word
        else
            -- If it doesn't fit, start a new line
            table.insert(lines, current_line)
            current_line = word
        end
        i = i + 1
    end

    -- Add the last line if it's not empty
    if #current_line > 0 then
        table.insert(lines, current_line)
    end

    return lines
end

--------------------------------------------------------------------------------
-- Splash Module
--------------------------------------------------------------------------------
function Splash.draw()
  cls(Config.colors.dark_grey)
  print("Mr. Anderson's", 78, 60, Config.colors.green)
  print("Addventure", 90, 70, Config.colors.green)
end

function Splash.update()
  State.splash_timer = State.splash_timer - 1
  if State.splash_timer <= 0 or Input.action() then
    State.game_state = GAME_STATE_INTRO
  end
end

--------------------------------------------------------------------------------
-- Intro Module
--------------------------------------------------------------------------------
function Intro.draw()
  cls(Config.colors.dark_grey)
  local x = (Config.screen.width - 132) / 2 -- Centered text
  print(State.intro.text, x, State.intro.y, Config.colors.green)
end

function Intro.update()
  State.intro.y = State.intro.y - State.intro.speed

  -- Count lines in intro text to determine when scrolling is done
  local lines = 1
  for _ in string.gmatch(State.intro.text, "\n") do
    lines = lines + 1
  end

  -- When text is off-screen, go to menu
  if State.intro.y < -lines * 8 then
    State.game_state = GAME_STATE_MENU
  end

  -- Skip intro by pressing A
  if Input.action() then
    State.game_state = GAME_STATE_MENU
  end
end

--------------------------------------------------------------------------------
-- Menu Module
--------------------------------------------------------------------------------
function Menu.draw()
  cls(Config.colors.dark_grey)
  UI.draw_top_bar("Main Menu")
  UI.draw_menu(State.menu_items, State.selected_menu_item, 108, 70)
end

function Menu.update()
  State.selected_menu_item = UI.update_menu(State.menu_items, State.selected_menu_item)

  if Input.action() then
    local selected_item = State.menu_items[State.selected_menu_item]
    if selected_item and selected_item.action then
      selected_item.action()
    end
  end
end

--------------------------------------------------------------------------------
-- Game Module
--------------------------------------------------------------------------------
function Game.draw()
  local currentScreenData = State.screens[State.current_screen]
  
  cls(Config.colors.dark_grey)
  UI.draw_top_bar(currentScreenData.name)

  -- Draw platforms
  for _, p in ipairs(currentScreenData.platforms) do
    rect(p.x, p.y, p.w, p.h, Config.colors.green)
  end

  -- Draw items
  for _, item in ipairs(currentScreenData.items) do
    spr(item.sprite_id, item.x, item.y, 0)
  end
  
  -- Draw NPCs
  for _, npc in ipairs(currentScreenData.npcs) do
    spr(npc.sprite_id, npc.x, npc.y, 0)
  end

  -- Draw ground
  rect(State.ground.x, State.ground.y, State.ground.w, State.ground.h, Config.colors.dark_grey)

  -- Draw player
  spr(State.player.sprite_id, State.player.x, State.player.y, 0)
end

function Game.update()
  -- Handle input
  if Input.left() then
    State.player.vx = -Config.physics.move_speed
  elseif Input.right() then
    State.player.vx = Config.physics.move_speed
  else
    State.player.vx = 0
  end

  if Input.jump() and State.player.jumps < Config.physics.max_jumps then
    State.player.vy = Config.physics.jump_power
    State.player.jumps = State.player.jumps + 1
  end

  -- Update player position
  State.player.x = State.player.x + State.player.vx
  State.player.y = State.player.y + State.player.vy

  -- Screen transition
  if State.player.x > Config.screen.width - State.player.w then
    if State.current_screen < #State.screens then
      State.current_screen = State.current_screen + 1
      State.player.x = 0
    else
      State.player.x = Config.screen.width - State.player.w
    end
  elseif State.player.x < 0 then
    if State.current_screen > 1 then
      State.current_screen = State.current_screen - 1
      State.player.x = Config.screen.width - State.player.w
    else
      State.player.x = 0
    end
  end

  -- Apply gravity
  State.player.vy = State.player.vy + Config.physics.gravity

  local currentScreenData = State.screens[State.current_screen]
  -- Collision detection with platforms
  for _, p in ipairs(currentScreenData.platforms) do
    if State.player.vy > 0 and State.player.y + State.player.h >= p.y and State.player.y + State.player.h <= p.y + p.h and State.player.x + State.player.w > p.x and State.player.x < p.x + p.w then
      State.player.y = p.y - State.player.h
      State.player.vy = 0
      State.player.jumps = 0
    end
  end

  -- Collision detection with ground
  if State.player.y + State.player.h > State.ground.y then
    State.player.y = State.ground.y - State.player.h
    State.player.vy = 0
    State.player.jumps = 0
  end

  -- Entity interaction
  if Input.interact() then
    local interaction_found = false
    -- NPC interaction
    for _, npc in ipairs(currentScreenData.npcs) do
      if math.abs(State.player.x - npc.x) < 12 and math.abs(State.player.y - npc.y) < 12 then
        State.active_entity = npc
        State.dialog_text = ""
        State.game_state = GAME_STATE_DIALOG
        State.showing_description = false
        State.dialog_menu_items = {
          {label = "Talk to", action = NpcActions.talk_to},
          {label = "Fight", action = NpcActions.fight},
          {label = "Go back", action = NpcActions.go_back}
        }
        State.selected_dialog_menu_item = 1
        interaction_found = true
        break
      end
    end

    if not interaction_found then
      -- Item interaction
      for _, item in ipairs(currentScreenData.items) do
        if math.abs(State.player.x - item.x) < 8 and math.abs(State.player.y - item.y) < 8 then
          State.active_entity = item
          State.dialog_text = ""
          State.game_state = GAME_STATE_DIALOG
          State.showing_description = false
          State.dialog_menu_items = {
            {label = "Use", action = ItemActions.use},
            {label = "Look at", action = ItemActions.look_at},
            {label = "Put away", action = ItemActions.put_away},
            {label = "Go back", action = ItemActions.go_back_from_item_dialog}
          }
          State.selected_dialog_menu_item = 1
          interaction_found = true
          break
        end
      end
    end

    -- If no interaction happened, open inventory
    if not interaction_found then
      State.game_state = GAME_STATE_INVENTORY
    end
  end
end

function Game.update_dialog()
  if State.showing_description then
    if Input.action() or Input.back() then
      State.showing_description = false
      State.dialog_text = "" -- Clear the description text
      -- No need to change game_state, as it remains in GAME_STATE_DIALOG or GAME_STATE_INVENTORY_ACTION
    end
  else
    State.selected_dialog_menu_item = UI.update_menu(State.dialog_menu_items, State.selected_dialog_menu_item)

    if Input.action() then
      local selected_item = State.dialog_menu_items[State.selected_dialog_menu_item]
      if selected_item and selected_item.action then
        selected_item.action()
      end
    end
    
    if Input.back() then
      State.game_state = GAME_STATE_GAME
    end
  end
end

--------------------------------------------------------------------------------
-- Main Game Loop
--------------------------------------------------------------------------------
local STATE_HANDLERS = {
  [GAME_STATE_SPLASH] = function()
    Splash.update()
    Splash.draw()
  end,
  [GAME_STATE_INTRO] = function()
    Intro.update()
    Intro.draw()
  end,
  [GAME_STATE_MENU] = function()
    Menu.update()
    Menu.draw()
  end,
  [GAME_STATE_GAME] = function()
    Game.update()
    Game.draw()
  end,
  [GAME_STATE_DIALOG] = function()
    Game.draw() -- Draw game behind dialog
    UI.draw_dialog()
    Game.update_dialog()
  end,
  [GAME_STATE_INVENTORY] = function()
    Inventory.update()
    Inventory.draw()
  end,
  [GAME_STATE_INVENTORY_ACTION] = function()
    Inventory.draw() -- Draw inventory behind dialog
    UI.draw_dialog()
    Game.update_dialog()
  end,
}

function TIC()
  local handler = STATE_HANDLERS[State.game_state]
  if handler then
    handler()
  end
end


-- <TILES>
-- 000:4444444444444444444444444444444444444444444444444444444444444444
-- 001:1111111111111111111111111111111111111111111111111111111111111111
-- 002:5555555555555555555555555555555555555555555555555555555555555555
-- 003:6666666666666666666666666666666666666666666666666666666666666666
-- 004:7777777777777777777777777777777777777777777777777777777777777777
-- 005:8888888888888888888888888888888888888888888888888888888888888888
-- 006:9999999999999999999999999999999999999999999999999999999999999999
-- 007:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 008:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

