-- title:   Mr Anderson's Adventure
-- author:  Zsolt Tasnadi
-- desc:    Life of a programmer in the Matrix
-- site:    http://teletype.hu
-- license: MIT License
-- version: 0.3
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
    npc = 8
  },
  player = {
    w = 8,
    h = 8,
    start_x = 120,
    start_y = 128,
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
local GAME_STATE_MENU = 1
local GAME_STATE_GAME = 2
local GAME_STATE_DIALOG = 3

--------------------------------------------------------------------------------
-- Modules
--------------------------------------------------------------------------------
local Splash = {}
local Menu = {}
local Game = {}
local UI = {}
local Input = {}

--------------------------------------------------------------------------------
-- Game State
--------------------------------------------------------------------------------
local State = {
  game_state = GAME_STATE_SPLASH,
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
    jumps = 0
  },
  ground = {
    x = 0,
    y = Config.screen.height,
    w = Config.screen.width,
    h = 8
  },
  menu_items = {"Play", "Exit"},
  selected_menu_item = 1,
  -- Screen data
  screens = {
    { -- Screen 1
      name = "Screen 1",
      platforms = {
        {x = 80, y = 110, w = 40, h = 8},
        {x = 160, y = 90, w = 40, h = 8}
      },
      npcs = {
        {x = 180, y = 82, name = "Trinity"},
        {x = 90, y = 102, name = "Oracle"}
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
        {x = 120, y = 72, name = "Morpheus"},
        {x = 40, y = 92, name = "Tank"}
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
        {x = 210, y = 42, name = "Agent Smith"},
        {x = 160, y = 62, name = "Cypher"}
      }
    }
  }
}

--------------------------------------------------------------------------------
-- Input Module
--------------------------------------------------------------------------------
function Input.up() return btnp(0) end
function Input.down() return btnp(1) end
function Input.left() return btn(2) end
function Input.right() return btn(3) end
function Input.action() return btnp(4) end
function Input.back() return btnp(5) end

--------------------------------------------------------------------------------
-- UI Module
--------------------------------------------------------------------------------
function UI.draw_top_bar(title)
  rect(0, 0, Config.screen.width, 10, Config.colors.black)
  print(title, 3, 2, Config.colors.light_grey)
end

function UI.draw_dialog()
  rect(40, 50, 160, 40, Config.colors.black)
  rectb(40, 50, 160, 40, Config.colors.dark_grey)
  print(State.dialog_text, 120 - #State.dialog_text * 2, 68, Config.colors.light_grey)
end

--------------------------------------------------------------------------------
-- Splash Module
--------------------------------------------------------------------------------
function Splash.draw()
  cls(Config.colors.black)
  print("Mr. Anderson's", 78, 60, Config.colors.light_grey)
  print("Addventure", 90, 70, Config.colors.light_grey)
end

function Splash.update()
  State.splash_timer = State.splash_timer - 1
  if State.splash_timer <= 0 then
    State.game_state = GAME_STATE_MENU
  end
end

--------------------------------------------------------------------------------
-- Menu Module
--------------------------------------------------------------------------------
function Menu.draw()
  cls(Config.colors.light_grey)
  UI.draw_top_bar("Main Menu")
  for i, item in ipairs(State.menu_items) do
    local color = Config.colors.dark_grey
    if i == State.selected_menu_item then
      color = Config.colors.green
    end
    print(item, 108, 70 + (i-1)*10, color)
  end
end

function Menu.update()
  if Input.up() then
    State.selected_menu_item = State.selected_menu_item - 1
    if State.selected_menu_item < 1 then
      State.selected_menu_item = #State.menu_items
    end
  elseif Input.down() then
    State.selected_menu_item = State.selected_menu_item + 1
    if State.selected_menu_item > #State.menu_items then
      State.selected_menu_item = 1
    end
  end

  if Input.action() or Input.back() then
    if State.selected_menu_item == 1 then -- Play
      -- Reset player state and screen for a new game
      State.player.x = Config.player.start_x
      State.player.y = Config.player.start_y
      State.player.vx = 0
      State.player.vy = 0
      State.player.jumps = 0
      State.current_screen = 1
      State.game_state = GAME_STATE_GAME
    elseif State.selected_menu_item == 2 then -- Exit
      exit()
    end
  end
end

--------------------------------------------------------------------------------
-- Game Module
--------------------------------------------------------------------------------
function Game.draw()
  local currentScreenData = State.screens[State.current_screen]
  
  cls(Config.colors.light_grey)
  UI.draw_top_bar(currentScreenData.name)

  -- Draw platforms
  for _, p in ipairs(currentScreenData.platforms) do
    rect(p.x, p.y, p.w, p.h, Config.colors.dark_grey)
  end
  
  -- Draw NPCs
  for _, npc in ipairs(currentScreenData.npcs) do
    rect(npc.x, npc.y, Config.player.w, Config.player.h, Config.colors.npc)
  end

  -- Draw ground
  rect(State.ground.x, State.ground.y, State.ground.w, State.ground.h, Config.colors.dark_grey)

  -- Draw player
  rect(State.player.x, State.player.y, State.player.w, State.player.h, Config.colors.green)
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

  if Input.action() and State.player.jumps < Config.physics.max_jumps then
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

  -- NPC interaction
  if Input.action() then
    for _, npc in ipairs(currentScreenData.npcs) do
      if math.abs(State.player.x - npc.x) < 12 and math.abs(State.player.y - npc.y) < 12 then
        State.dialog_text = npc.name
        State.game_state = GAME_STATE_DIALOG
      end
    end
  end
end

function Game.update_dialog()
  if Input.action() or Input.back() then
    State.game_state = GAME_STATE_GAME
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
}

function TIC()
  local handler = STATE_HANDLERS[State.game_state]
  if handler then
    handler()
  end
end


-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
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