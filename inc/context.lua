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
    {
      -- Screen 1
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
    {
      -- Screen 2
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
                options = {} -- Ends conversation
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
    {
      -- Screen 3
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
