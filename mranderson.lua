-- title:   Mr Anderson's Adventure
-- author:  Zsolt Tasnadi
-- desc:    Life of a programmer in the Vector
-- site:    https://github.com/rastasi/mranderson
-- license: MIT License
-- version: 0.9
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
    interaction_radius_npc = 12, -- New constant
    interaction_radius_item = 8   -- New constant
  },
  timing = {
    splash_duration = 120 -- 2 seconds at 60fps
  }
}

--------------------------------------------------------------------------------
-- Game Windows
--------------------------------------------------------------------------------
local WINDOW_SPLASH = 0
local WINDOW_INTRO = 1
local WINDOW_MENU = 2
local WINDOW_GAME = 3
local WINDOW_POPUP = 4
local WINDOW_INVENTORY = 5
local WINDOW_INVENTORY_ACTION = 6

--------------------------------------------------------------------------------
-- Modules
--------------------------------------------------------------------------------
-- Window Modules (in WINDOW order)
local SplashWindow = {}
local IntroWindow = {}
local MenuWindow = {}
local GameWindow = {}
local PopupWindow = {}    -- Manages popups for WINDOW_POPUP and WINDOW_INVENTORY_ACTION
local InventoryWindow = {} -- Used for WINDOW_INVENTORY

-- Other Modules
local UI = {}
local Input = {}
local NpcActions = {}
local ItemActions = {}
local MenuActions = {}
local Player = {}

--------------------------------------------------------------------------------
-- Game Window
--------------------------------------------------------------------------------
local Context = {
  active_window = WINDOW_SPLASH,
  inventory = {},
  intro = {
    y = Config.screen.height,
    speed = 0.5,
    text = "Mr. Anderson is an average\nprogrammer. His daily life\nrevolves around debugging,\npull requests, and end-of-sprint\nmeetings, all while secretly\ndreaming of being destined\nfor something more."
  },
  current_screen = 1,
  splash_timer = Config.timing.splash_duration,
  dialog = {
    text = "",
    menu_items = {},
    selected_menu_item = 1,
    active_entity = nil,
    showing_description = false,
    current_node_key = nil
  },
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
  -- Screen data
  screens = {
    { -- Screen 1
      name = "Screen 1",
      platforms = {
        {
          x = 80,
          y = 110,
          w = 40,
          h = 8
        },
        {
          x = 160,
          y = 90,
          w = 40,
          h = 8
        }
      },
      npcs = {
        {
          x = 180,
          y = 82,
          name = "Trinity",
          sprite_id = 2,
          dialog = {
            start = {
              text = "Hello, Neo.",
              options = {
                {label = "Who are you?", next_node = "who_are_you"},
                {label = "My name is not Neo.", next_node = "not_neo"},
                {label = "...", next_node = "silent"}
              }
            },
            who_are_you = {
              text = "I am Trinity. I've been looking for you.",
              options = {
                {label = "The famous hacker?", next_node = "famous_hacker"},
                {label = "Why me?", next_node = "why_me"}
              }
            },
            not_neo = {
              text = "I know. But you will be.",
              options = {
                {label = "What are you talking about?", next_node = "who_are_you"}
              }
            },
            silent = {
              text = "You're not much of a talker, are you?",
              options = {
                {label = "I guess not.", next_node = "dialog_end"}
              }
            },
            famous_hacker = {
                text = "The one and only.",
                options = {
                    {label = "Wow.", next_node = "dialog_end"}
                }
            },
            why_me = {
                text = "Morpheus believes you are The One.",
                options = {
                    {label = "The One?", next_node = "the_one"}
                }
            },
            the_one = {
                text = "The one who will save us all.",
                options = {
                    {label = "I'm just a programmer.", next_node = "dialog_end"}
                }
            },
            dialog_end = {
              text = "We'll talk later.",
              options = {} -- No options, ends conversation
            }
          }
        },
        {
          x = 90,
          y = 102,
          name = "Oracle",
          sprite_id = 3,
          dialog = {}
        }
      },
      items = {
        {
          x = 100,
          y = 128,
          w = 8,
          h = 8,
          name = "Key",
          sprite_id = 4,
          desc = "A rusty old key. It might open something."
        }
      }
    },
    { -- Screen 2
      name = "Screen 2",
      platforms = {
        {
          x = 30,
          y = 100,
          w = 50,
          h = 8
        },
        {
          x = 100,
          y = 80,
          w = 50,
          h = 8
        },
        {
          x = 170,
          y = 60,
          w = 50,
          h = 8
        }
      },
      npcs = {
        {
          x = 120,
          y = 72,
          name = "Morpheus",
          sprite_id = 5,
          dialog = {
            start = {
                text = "At last. Welcome, Neo. As you no doubt have guessed, I am Morpheus.",
                options = {
                    {label = "It's an honor to meet you.", next_node = "honor"},
                    {label = "You've been looking for me.", next_node = "looking_for_me"}
                }
            },
            honor = {
                text = "No, the honor is mine.",
                options = {
                    {label = "What is this place?", next_node = "what_is_this_place"}
                }
            },
            looking_for_me = {
                text = "I have. For some time.",
                options = {
                    {label = "What is this place?", next_node = "what_is_this_place"}
                }
            },
            what_is_this_place = {
                text = "This is the construct. It's our loading program. We can load anything from clothing, to equipment, weapons, training simulations. Anything we need.",
                options = {
                    {label = "Right.", next_node = "dialog_end"}
                }
            },
            dialog_end = {
                text = "I've been waiting for you, Neo. We have much to discuss.",
                options = {}
            }
          }
        },
        {
          x = 40,
          y = 92,
          name = "Tank",
          sprite_id = 6,
          dialog = {}
        }
      },
      items = {
        {
          x = 180,
          y = 52,
          w = 8,
          h = 8,
          name = "Potion",
          sprite_id = 7,
          desc = "A glowing red potion. It looks potent."
        }
      }
    },
    { -- Screen 3
      name = "Screen 3",
      platforms = {
        {
          x = 50,
          y = 110,
          w = 30,
          h = 8
        },
        {
          x = 100,
          y = 90,
          w = 30,
          h = 8
        },
        {
          x = 150,
          y = 70,
          w = 30,
          h = 8
        },
        {
          x = 200,
          y = 50,
          w = 30,
          h = 8
        }
      },
      npcs = {
        {
          x = 210,
          y = 42,
          name = "Agent Smith",
          sprite_id = 8,
          dialog = {}
        },
        {
          x = 160,
          y = 62,
          name = "Cypher",
          sprite_id = 9,
          dialog = {}
        }
      },
      items = {}
    }
  }
}

--------------------------------------------------------------------------------
-- Inventory Module
--------------------------------------------------------------------------------
function InventoryWindow.draw()
  UI.draw_top_bar("Inventory")

  if #Context.inventory == 0 then
    print("Inventory is empty.", 70, 70, Config.colors.light_grey)
  else
    for i, item in ipairs(Context.inventory) do
			local color = Config.colors.light_grey
			if i == Context.selected_inventory_item then
				color = Config.colors.green
				print(">", 60, 20 + i * 10, color)
			end
      print(item.name, 70, 20 + i * 10, color)
    end
  end
end

function InventoryWindow.update()
  Context.selected_inventory_item = UI.update_menu(Context.inventory, Context.selected_inventory_item)

  if Input.menu_confirm() and #Context.inventory > 0 then
    local selected_item = Context.inventory[Context.selected_inventory_item]
    PopupWindow.show_menu_dialog(selected_item, {
      {label = "Use", action = ItemActions.use},
      {label = "Drop", action = ItemActions.drop},
      {label = "Look at", action = ItemActions.look_at},
      {label = "Go back", action = ItemActions.go_back_from_inventory_action}
    }, WINDOW_INVENTORY_ACTION)
  end

  if Input.menu_back() then
    GameWindow.set_state(WINDOW_GAME)
  end
end

--------------------------------------------------------------------------------
-- Menu Actions
--------------------------------------------------------------------------------
function MenuActions.play()
  -- Reset player state and screen for a new game
  Context.player.x = Config.player.start_x
  Context.player.y = Config.player.start_y
  Context.player.vx = 0
  Context.player.vy = 0
  Context.player.jumps = 0
  Context.current_screen = 1
  GameWindow.set_state(WINDOW_GAME)
end

function MenuActions.exit()
  exit()
end

-- Initialize menu items after actions are defined
Context.menu_items = {
  {label = "Play", action = MenuActions.play},
  {label = "Exit", action = MenuActions.exit}
}

--------------------------------------------------------------------------------
-- NPC Actions
--------------------------------------------------------------------------------
function NpcActions.talk_to()
  local npc = Context.dialog.active_entity
  if npc.dialog and npc.dialog.start then
    PopupWindow.set_dialog_node("start")
  else
    -- if no dialog, go back
    GameWindow.set_state(WINDOW_GAME)
  end
end
function NpcActions.fight() end
function NpcActions.go_back()
  GameWindow.set_state(WINDOW_GAME)
end

--------------------------------------------------------------------------------
-- Item Actions
--------------------------------------------------------------------------------
function ItemActions.use()
  print("Used item: " .. Context.dialog.active_entity.name)
  GameWindow.set_state(WINDOW_INVENTORY)
end
function ItemActions.look_at()
  PopupWindow.show_description_dialog(Context.dialog.active_entity, Context.dialog.active_entity.desc)
end
function ItemActions.put_away()
  -- Add item to inventory
  table.insert(Context.inventory, Context.dialog.active_entity)

  -- Remove item from screen
  local currentScreenData = Context.screens[Context.current_screen]
  for i, item in ipairs(currentScreenData.items) do
    if item == Context.dialog.active_entity then
      table.remove(currentScreenData.items, i)
      break
    end
  end

  -- Go back to game
  GameWindow.set_state(WINDOW_GAME)
end
function ItemActions.go_back_from_item_dialog()
  GameWindow.set_state(WINDOW_GAME)
end

function ItemActions.go_back_from_inventory_action()
	GameWindow.set_state(WINDOW_GAME)
end

function ItemActions.drop()
  -- Remove item from inventory
  for i, item in ipairs(Context.inventory) do
    if item == Context.dialog.active_entity then
      table.remove(Context.inventory, i)
      break
    end
  end

  -- Add item to screen
  local currentScreenData = Context.screens[Context.current_screen]
	Context.dialog.active_entity.x = Context.player.x
	Context.dialog.active_entity.y = Context.player.y
  table.insert(currentScreenData.items, Context.dialog.active_entity)

  -- Go back to inventory
  GameWindow.set_state(WINDOW_INVENTORY)
end


--------------------------------------------------------------------------------
-- Input Module
--------------------------------------------------------------------------------
function Input.up() return btnp(0) end
function Input.down() return btnp(1) end
function Input.left() return btn(2) end
function Input.right() return btn(3) end
function Input.player_jump() return btnp(4) end
function Input.menu_confirm() return btnp(4) end
function Input.player_interact() return btnp(5) end -- B button
function Input.menu_back() return btnp(5) end

--------------------------------------------------------------------------------
-- UI Module
--------------------------------------------------------------------------------
function UI.draw_top_bar(title)
  rect(0, 0, Config.screen.width, 10, Config.colors.dark_grey)
  print(title, 3, 2, Config.colors.green)
end

function UI.draw_dialog()
  PopupWindow.draw()
end

function PopupWindow.draw()
  rect(40, 40, 160, 80, Config.colors.black)
  rectb(40, 40, 160, 80, Config.colors.green)

  -- Display the entity's name as the dialog title
  if Context.dialog.active_entity and Context.dialog.active_entity.name then
    print(Context.dialog.active_entity.name, 120 - #Context.dialog.active_entity.name * 2, 45, Config.colors.green)
  end

  -- Display the dialog content (description for "look at", or initial name/dialog for others)
  local wrapped_lines = UI.word_wrap(Context.dialog.text, 25) -- Max 25 chars per line
  local current_y = 55 -- Starting Y position for the first line of content
  for _, line in ipairs(wrapped_lines) do
    print(line, 50, current_y, Config.colors.light_grey)
    current_y = current_y + 8 -- Move to the next line (8 pixels for default font height + padding)
  end
  
  -- Adjust menu position based on the number of wrapped lines
  if not Context.dialog.showing_description then
    UI.draw_menu(Context.dialog.menu_items, Context.dialog.selected_menu_item, 50, current_y + 2)
  else
    -- If description is showing, provide a "Go back" option automatically, or close dialog on action
    -- For now, let's just make it implicitly wait for Input.menu_confirm() or Input.menu_back() to close
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
    if text == nil then return {""} end
    local lines = {}
    
    for input_line in (text .. "\n"):gmatch("(.-)\n") do
        local current_line = ""
        local words_in_line = 0
        for word in input_line:gmatch("%S+") do
            words_in_line = words_in_line + 1
            if #current_line == 0 then
                current_line = word
            elseif #current_line + #word + 1 <= max_chars_per_line then
                current_line = current_line .. " " .. word
            else
                table.insert(lines, current_line)
                current_line = word
            end
        end
        
        if words_in_line > 0 then
            table.insert(lines, current_line)
        else
            table.insert(lines, "")
        end
    end
    
    if #lines == 0 then
        return {""}
    end
    
    return lines
end

--------------------------------------------------------------------------------
-- Splash Module
--------------------------------------------------------------------------------
function SplashWindow.draw()
  print("Mr. Anderson's", 78, 60, Config.colors.green)
  print("Addventure", 90, 70, Config.colors.green)
end

function SplashWindow.update()
  Context.splash_timer = Context.splash_timer - 1
  if Context.splash_timer <= 0 or Input.menu_confirm() then
    GameWindow.set_state(WINDOW_INTRO)
  end
end

--------------------------------------------------------------------------------
-- Intro Module
--------------------------------------------------------------------------------
function IntroWindow.draw()
  local x = (Config.screen.width - 132) / 2 -- Centered text
  print(Context.intro.text, x, Context.intro.y, Config.colors.green)
end

function IntroWindow.update()
  Context.intro.y = Context.intro.y - Context.intro.speed

  -- Count lines in intro text to determine when scrolling is done
  local lines = 1
  for _ in string.gmatch(Context.intro.text, "\n") do
    lines = lines + 1
  end

  -- When text is off-screen, go to menu
  if Context.intro.y < -lines * 8 then
    GameWindow.set_state(WINDOW_MENU)
  end

  -- Skip intro by pressing A
  if Input.menu_confirm() then
    GameWindow.set_state(WINDOW_MENU)
  end
end

--------------------------------------------------------------------------------
-- Menu Module
--------------------------------------------------------------------------------
function MenuWindow.draw()
  UI.draw_top_bar("Main Menu")
  UI.draw_menu(Context.menu_items, Context.selected_menu_item, 108, 70)
end

function MenuWindow.update()
  Context.selected_menu_item = UI.update_menu(Context.menu_items, Context.selected_menu_item)

  if Input.menu_confirm() then
    local selected_item = Context.menu_items[Context.selected_menu_item]
    if selected_item and selected_item.action then
      selected_item.action()
    end
  end
end

--------------------------------------------------------------------------------
-- Game Module
--------------------------------------------------------------------------------
function GameWindow.draw()
  local currentScreenData = Context.screens[Context.current_screen]

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
  rect(Context.ground.x, Context.ground.y, Context.ground.w, Context.ground.h, Config.colors.dark_grey)

  -- Draw player
  Player.draw()
end

function Player.draw()
  spr(Context.player.sprite_id, Context.player.x, Context.player.y, 0)
end

function Player.update()
  -- Handle input
  if Input.left() then
    Context.player.vx = -Config.physics.move_speed
  elseif Input.right() then
    Context.player.vx = Config.physics.move_speed
  else
    Context.player.vx = 0
  end

  if Input.player_jump() and Context.player.jumps < Config.physics.max_jumps then
    Context.player.vy = Config.physics.jump_power
    Context.player.jumps = Context.player.jumps + 1
  end

  -- Update player position
  Context.player.x = Context.player.x + Context.player.vx
  Context.player.y = Context.player.y + Context.player.vy

  -- Screen transition
  if Context.player.x > Config.screen.width - Context.player.w then
    if Context.current_screen < #Context.screens then
      Context.current_screen = Context.current_screen + 1
      Context.player.x = 0
    else
      Context.player.x = Config.screen.width - Context.player.w
    end
  elseif Context.player.x < 0 then
    if Context.current_screen > 1 then
      Context.current_screen = Context.current_screen - 1
      Context.player.x = Config.screen.width - Context.player.w
    else
      Context.player.x = 0
    end
  end

  -- Apply gravity
  Context.player.vy = Context.player.vy + Config.physics.gravity

  local currentScreenData = Context.screens[Context.current_screen]
  -- Collision detection with platforms
  for _, p in ipairs(currentScreenData.platforms) do
    if Context.player.vy > 0 and Context.player.y + Context.player.h >= p.y and Context.player.y + Context.player.h <= p.y + p.h and Context.player.x + Context.player.w > p.x and Context.player.x < p.x + p.w then
      Context.player.y = p.y - Context.player.h
      Context.player.vy = 0
      Context.player.jumps = 0
    end
  end

  -- Collision detection with ground
  if Context.player.y + Context.player.h > Context.ground.y then
    Context.player.y = Context.ground.y - Context.player.h
    Context.player.vy = 0
    Context.player.jumps = 0
  end

  -- Entity interaction
  if Input.player_interact() then
    local interaction_found = false
    -- NPC interaction
    for _, npc in ipairs(currentScreenData.npcs) do
      if math.abs(Context.player.x - npc.x) < Config.physics.interaction_radius_npc and math.abs(Context.player.y - npc.y) < Config.physics.interaction_radius_npc then
        PopupWindow.show_menu_dialog(npc, {
          {label = "Talk to", action = NpcActions.talk_to},
          {label = "Fight", action = NpcActions.fight},
          {label = "Go back", action = NpcActions.go_back}
        }, WINDOW_POPUP)
        interaction_found = true
        break
      end
    end

    if not interaction_found then
      -- Item interaction
      for _, item in ipairs(currentScreenData.items) do
        if math.abs(Context.player.x - item.x) < Config.physics.interaction_radius_item and math.abs(Context.player.y - item.y) < Config.physics.interaction_radius_item then
          PopupWindow.show_menu_dialog(item, {
            {label = "Use", action = ItemActions.use},
            {label = "Look at", action = ItemActions.look_at},
            {label = "Put away", action = ItemActions.put_away},
            {label = "Go back", action = ItemActions.go_back_from_item_dialog}
          }, WINDOW_POPUP)
          interaction_found = true
          break
        end
      end
    end

    -- If no interaction happened, open inventory
    if not interaction_found then
      GameWindow.set_state(WINDOW_INVENTORY)
    end
  end
end

function GameWindow.update()
  Player.update() -- Call the encapsulated player update logic
end

function GameWindow.set_state(new_state)
  Context.active_window = new_state
  -- Add any state-specific initialization/cleanup here later if needed
end

function PopupWindow.set_dialog_node(node_key)
  local npc = Context.dialog.active_entity
  local node = npc.dialog[node_key]

  if not node then
    GameWindow.set_state(WINDOW_GAME)
    return
  end

  Context.dialog.current_node_key = node_key
  Context.dialog.text = node.text

  local menu_items = {}
  if node.options then
    for _, option in ipairs(node.options) do
      table.insert(menu_items, {
        label = option.label,
        action = function()
          PopupWindow.set_dialog_node(option.next_node)
        end
      })
    end
  end

  -- if no options, it's the end of this branch.
  if #menu_items == 0 then
      table.insert(menu_items, {
          label = "Go back",
          action = function() GameWindow.set_state(WINDOW_GAME) end
      })
  end

  Context.dialog.menu_items = menu_items
  Context.dialog.selected_menu_item = 1
  Context.dialog.showing_description = false
  GameWindow.set_state(WINDOW_POPUP)
end

function PopupWindow.update()
  if Context.dialog.showing_description then
    if Input.menu_confirm() or Input.menu_back() then
      Context.dialog.showing_description = false
      Context.dialog.text = "" -- Clear the description text
      -- No need to change active_window, as it remains in WINDOW_POPUP or WINDOW_INVENTORY_ACTION
    end
  else
    Context.dialog.selected_menu_item = UI.update_menu(Context.dialog.menu_items, Context.dialog.selected_menu_item)

    if Input.menu_confirm() then
      local selected_item = Context.dialog.menu_items[Context.dialog.selected_menu_item]
      if selected_item and selected_item.action then
        selected_item.action()
      end
    end
    
    if Input.menu_back() then
      GameWindow.set_state(WINDOW_GAME)
    end
  end
end

function PopupWindow.show_menu_dialog(entity, menu_items, dialog_active_window)
  Context.dialog.active_entity = entity
  Context.dialog.text = "" -- Initial dialog text is empty, name is title
  GameWindow.set_state(dialog_active_window or WINDOW_POPUP)
  Context.dialog.showing_description = false
  Context.dialog.menu_items = menu_items
  Context.dialog.selected_menu_item = 1
end

function PopupWindow.show_description_dialog(entity, description_text)
  Context.dialog.active_entity = entity
  Context.dialog.text = description_text
  GameWindow.set_state(WINDOW_POPUP)
  Context.dialog.showing_description = true
  -- No menu items needed for description dialog
end

--------------------------------------------------------------------------------
-- Main Game Loop
--------------------------------------------------------------------------------
local STATE_HANDLERS = {
  [WINDOW_SPLASH] = function()
    SplashWindow.update()
    SplashWindow.draw()
  end,
  [WINDOW_INTRO] = function()
    IntroWindow.update()
    IntroWindow.draw()
  end,
  [WINDOW_MENU] = function()
    MenuWindow.update()
    MenuWindow.draw()
  end,
  [WINDOW_GAME] = function()
    GameWindow.update()
    GameWindow.draw()
  end,
  [WINDOW_POPUP] = function()
    GameWindow.draw() -- Draw game behind dialog
    PopupWindow.update()
    PopupWindow.draw()
  end,
  [WINDOW_INVENTORY] = function()
    InventoryWindow.update()
    InventoryWindow.draw()
  end,
  [WINDOW_INVENTORY_ACTION] = function()
    InventoryWindow.draw() -- Draw inventory behind dialog
    PopupWindow.draw()
    PopupWindow.update()
  end,
}

function TIC()
  cls(Config.colors.black)
  local handler = STATE_HANDLERS[Context.active_window]
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
