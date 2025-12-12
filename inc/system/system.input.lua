-- Gamepad buttons
local INPUT_KEY_UP = 0
local INPUT_KEY_DOWN = 1
local INPUT_KEY_LEFT = 2
local INPUT_KEY_RIGHT = 3
local INPUT_KEY_A = 4 -- Z key
local INPUT_KEY_B = 5 -- X key
local INPUT_KEY_X = 6 -- A key
local INPUT_KEY_Y = 7 -- S key

-- Keyboard keys
-- TODO: Find correct key codes for SPACE and LCTRL
local INPUT_KEY_SPACE = 48
local INPUT_KEY_BACKSPACE = 51
local INPUT_KEY_ENTER = 50

function Input.up() return btnp(INPUT_KEY_UP) end
function Input.down() return btnp(INPUT_KEY_DOWN) end
function Input.left() return btn(INPUT_KEY_LEFT) end
function Input.right() return btn(INPUT_KEY_RIGHT) end
function Input.player_jump() return btnp(INPUT_KEY_A) or keyp(INPUT_KEY_SPACE) end
function Input.menu_confirm() return btnp(INPUT_KEY_A) or keyp(INPUT_KEY_ENTER) end
function Input.player_interact() return btnp(INPUT_KEY_B) or keyp(INPUT_KEY_ENTER) end -- B button
function Input.menu_back() return btnp(INPUT_KEY_Y) or keyp(INPUT_KEY_BACKSPACE) end
function Input.toggle_popup() return keyp(INPUT_KEY_ENTER) end
