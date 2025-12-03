-- title:   Mr Anderson's Addventure
-- author:  Zsolt Tasnadi
-- desc:    Life of a programmer in the Matrix
-- site:    http://teletype.hu
-- license: MIT License
-- version: 0.1
-- script:  lua

-- Game constants
SCREEN_WIDTH = 240
SCREEN_HEIGHT = 136

-- Colors
COLOR_BLACK = 0
COLOR_LIGHT_GREY = 13
COLOR_DARK_GREY = 14
COLOR_GREEN = 6
COLOR_NPC = 8

-- Game state
STATE_SPLASH = 0
STATE_MENU = 1
STATE_GAME = 2
STATE_DIALOG = 3

-- Player constants
PLAYER_WIDTH = 8
PLAYER_HEIGHT = 8
PLAYER_START_X = 120
PLAYER_START_Y = 128

-- Ground constants
GROUND_X = 0
GROUND_Y = 136
GROUND_W = 240
GROUND_H = 8

-- Physics constants
GRAVITY = 0.5
JUMP_POWER = -5
MOVE_SPEED = 1.5
MAX_JUMPS = 2

-- Global variables (initialized)
local gameState = STATE_SPLASH
local currentScreen = 1
local dialog_text = ""
local splash_timer = 120 -- 2 seconds at 60fps

-- Player properties
local player = {
  x = PLAYER_START_X,
  y = PLAYER_START_Y,
  w = PLAYER_WIDTH,
  h = PLAYER_HEIGHT,
  vx = 0,
  vy = 0,
  jumps = 0
}

-- Ground properties
local ground = {
  x = GROUND_X,
  y = GROUND_Y,
  w = GROUND_W,
  h = GROUND_H
}

-- Menu properties
local menuItems = {"Play", "Exit"}
local selectedMenuItem = 1

local function draw_splash()
  cls(COLOR_BLACK)
  print("Mr. Anderson's", 78, 60, COLOR_LIGHT_GREY)
  print("Addventure", 90, 70, COLOR_LIGHT_GREY)
end

local function update_splash()
  splash_timer = splash_timer - 1
  if splash_timer <= 0 then
    gameState = STATE_MENU
  end
end

local function draw_top_bar(title)
  rect(0, 0, SCREEN_WIDTH, 10, COLOR_BLACK)
  print(title, 3, 2, COLOR_LIGHT_GREY)
end

local function draw_menu()
  cls(COLOR_LIGHT_GREY)
  draw_top_bar("Main Menu")
  for i, item in ipairs(menuItems) do
    local color = COLOR_DARK_GREY
    if i == selectedMenuItem then
      color = COLOR_GREEN
    end
    print(item, 108, 70 + (i-1)*10, color)
  end
end

local function update_menu()
  if btnp(0) then -- Up
    selectedMenuItem = selectedMenuItem - 1
    if selectedMenuItem < 1 then
      selectedMenuItem = #menuItems
    end
  elseif btnp(1) then -- Down
    selectedMenuItem = selectedMenuItem + 1
    if selectedMenuItem > #menuItems then
      selectedMenuItem = 1
    end
  end

  if btnp(4) or btnp(5) then -- A or B button
    if selectedMenuItem == 1 then -- Play
      -- Reset player state and screen for a new game
      player.x = PLAYER_START_X
      player.y = PLAYER_START_Y
      player.vx = 0
      player.vy = 0
      player.jumps = 0
      currentScreen = 1
      gameState = STATE_GAME
    elseif selectedMenuItem == 2 then -- Exit
      exit()
    end
  end
end

-- Screen data
local screens = {
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

local function game_update()
  -- Handle input
  if btn(2) then
    player.vx = -MOVE_SPEED
  elseif btn(3) then
    player.vx = MOVE_SPEED
  else
    player.vx = 0
  end

  if btnp(4) and player.jumps < MAX_JUMPS then
    player.vy = JUMP_POWER
    player.jumps = player.jumps + 1
  end

  -- Update player position
  player.x = player.x + player.vx
  player.y = player.y + player.vy

  -- Screen transition
  if player.x > SCREEN_WIDTH - player.w then
    if currentScreen < #screens then
      currentScreen = currentScreen + 1
      player.x = 0
    else
      player.x = SCREEN_WIDTH - player.w
    end
  elseif player.x < 0 then
    if currentScreen > 1 then
      currentScreen = currentScreen - 1
      player.x = SCREEN_WIDTH - player.w
    else
      player.x = 0
    end
  end

  -- Apply gravity
  player.vy = player.vy + GRAVITY

  local currentScreenData = screens[currentScreen]
  local currentPlatforms = currentScreenData.platforms
  -- Collision detection with platforms
  for i, p in ipairs(currentPlatforms) do
    if player.vy > 0 and player.y + player.h >= p.y and player.y + player.h <= p.y + p.h and player.x + player.w > p.x and player.x < p.x + p.w then
      player.y = p.y - player.h
      player.vy = 0
      player.jumps = 0
    end
  end

  -- Collision detection with ground
  if player.y + player.h > ground.y and player.x + player.w > ground.x and player.x < ground.x + ground.w then
    player.y = ground.y - player.h
    player.vy = 0
    player.jumps = 0
  end

  -- NPC interaction
  if btnp(4) then
    for i, npc in ipairs(currentScreenData.npcs) do
      if math.abs(player.x - npc.x) < 12 and math.abs(player.y - npc.y) < 12 then
        dialog_text = npc.name
        gameState = STATE_DIALOG
      end
    end
  end

  -- Clear screen
  cls(COLOR_LIGHT_GREY)

  draw_top_bar(currentScreenData.name)

  -- Draw platforms
  for i, p in ipairs(currentPlatforms) do
    rect(p.x, p.y, p.w, p.h, COLOR_DARK_GREY)
  end
  
  -- Draw NPCs
  for i, npc in ipairs(currentScreenData.npcs) do
    rect(npc.x, npc.y, PLAYER_WIDTH, PLAYER_HEIGHT, COLOR_NPC)
  end

  -- Draw ground
  rect(ground.x, ground.y, ground.w, ground.h, COLOR_DARK_GREY)

  -- Draw player
  rect(player.x, player.y, player.w, player.h, COLOR_GREEN)
end

local function draw_dialog()
  rect(40, 50, 160, 40, COLOR_BLACK)
  rectb(40, 50, 160, 40, COLOR_DARK_GREY)
  print(dialog_text, 120 - #dialog_text * 2, 68, COLOR_DARK_GREY)
end

local function update_dialog()
  if btnp(4) or btnp(5) then
    gameState = STATE_GAME
  end
end

function TIC()
  if gameState == STATE_SPLASH then
    update_splash()
    draw_splash()
  elseif gameState == STATE_MENU then
    update_menu()
    draw_menu()
  elseif gameState == STATE_GAME then
    game_update()
  elseif gameState == STATE_DIALOG then
    game_update() -- keep drawing the game state in the background
    draw_dialog()
    update_dialog()
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

