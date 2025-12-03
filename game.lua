-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua


-- Platforms properties
platforms = {
  {x = 80, y = 110, w = 40, h = 8},
  {x = 160, y = 90, w = 40, h = 8}
}

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

function TIC()
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

  -- Apply gravity
  player.vy = player.vy + gravity

  -- Collision detection with platforms
  for i, p in ipairs(platforms) do
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

  -- Draw platforms
  for i, p in ipairs(platforms) do
    rect(p.x, p.y, p.w, p.h, 14)
  end

  -- Draw ground
  rect(ground.x, ground.y, ground.w, ground.h, 14)

  -- Draw player
  rect(player.x, player.y, player.w, player.h, 6)

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

