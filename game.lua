-- title:   Mr Anderson's Addventure
-- author:  Zsolt Tasnadi
-- desc:    Life of a programmer in the Matrix
-- site:    http://teletype.hu
-- license: MIT License
-- version: 0.1
-- script:  lua

-- Game state
STATE_MENU = 0
STATE_GAME = 1
gameState = STATE_MENU

-- Menu properties
menuItems = {"Play", "Exit"}
selectedMenuItem = 1

function draw_top_bar(title)
  rect(0, 0, 240, 10, 0)
  print(title, 3, 2, 13)
end

function draw_menu()
  cls(13)
  draw_top_bar("Main Menu")
  for i, item in ipairs(menuItems) do
    local color = 14
    if i == selectedMenuItem then
      color = 6
    end
    print(item, 108, 70 + (i-1)*10, color)
  end
end

function update_menu()
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
      player.x = 120
      player.y = 128
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
screens = {
  { -- Screen 1
    name = "Home Screen",
    platforms = {
      {x = 80, y = 110, w = 40, h = 8},
      {x = 160, y = 90, w = 40, h = 8}
    }
  },
  { -- Screen 2
    name = "Second Screen",
    platforms = {
      {x = 30, y = 100, w = 50, h = 8},
      {x = 100, y = 80, w = 50, h = 8},
      {x = 170, y = 60, w = 50, h = 8}
    }
  },
  { -- Screen 3
    name = "Third Screen",
    platforms = {
      {x = 50, y = 110, w = 30, h = 8},
      {x = 100, y = 90, w = 30, h = 8},
      {x = 150, y = 70, w = 30, h = 8},
      {x = 200, y = 50, w = 30, h = 8}
    }
  }
}

currentScreen = 1

-- Player properties
player = {
  x = 120,
  y = 128,
  w = 8,
  h = 8,
  vx = 0,
  vy = 0,
  jumps = 0
}

-- Ground properties
ground = {
  x = 0,
  y = 136,
  w = 240,
  h = 8
}

-- Game constants
gravity = 0.5
jump_power = -5
move_speed = 1.5
max_jumps = 2

function game_update()
  -- Handle input
  if btn(2) then
    player.vx = -move_speed
  elseif btn(3) then
    player.vx = move_speed
  else
    player.vx = 0
  end

  if btnp(4) and player.jumps < max_jumps then
    player.vy = jump_power
    player.jumps = player.jumps + 1
  end

  -- Update player position
  player.x = player.x + player.vx
  player.y = player.y + player.vy

  -- Screen transition
  if player.x > 240 - player.w then
    if currentScreen < #screens then
      currentScreen = currentScreen + 1
      player.x = 0
    else
      player.x = 240 - player.w
    end
  elseif player.x < 0 then
    if currentScreen > 1 then
      currentScreen = currentScreen - 1
      player.x = 240 - player.w
    else
      player.x = 0
    end
  end

  -- Apply gravity
  player.vy = player.vy + gravity

  local currentPlatforms = screens[currentScreen].platforms
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

  -- Clear screen
  cls(13)

  draw_top_bar(screens[currentScreen].name)

  -- Draw platforms
  for i, p in ipairs(currentPlatforms) do
    rect(p.x, p.y, p.w, p.h, 14)
  end

  -- Draw ground
  rect(ground.x, ground.y, ground.w, ground.h, 14)

  -- Draw player
  rect(player.x, player.y, player.w, player.h, 6)
end

function TIC()
  if gameState == STATE_MENU then
    update_menu()
    draw_menu()
  elseif gameState == STATE_GAME then
    game_update()
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

