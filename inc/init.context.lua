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
          dialog = {
            start = {
                text = "I know what you're thinking. 'Am I in the right place?'",
                options = {
                    {label = "Who are you?", next_node = "who_are_you"},
                    {label = "I guess I am.", next_node = "you_are"}
                }
            },
            who_are_you = {
                text = "I'm the Oracle. And you're right on time. Want a cookie?",
                options = {
                    {label = "Sure.", next_node = "cookie"},
                    {label = "No, thank you.", next_node = "no_cookie"}
                }
            },
            you_are = {
                text = "Of course you are. Sooner or later, everyone comes to see me. Want a cookie?",
                options = {
                    {label = "Yes, please.", next_node = "cookie"},
                    {label = "I'm good.", next_node = "no_cookie"}
                }
            },
            cookie = {
                text = "Here you go. Now, what's really on your mind?",
                options = {
                    {label = "Am I The One?", next_node = "the_one"},
                    {label = "What is the Matrix?", next_node = "the_matrix"}
                }
            },
            no_cookie = {
                text = "Suit yourself. Now, what's troubling you?",
                options = {
                    {label = "Am I The One?", next_node = "the_one"},
                    {label = "What is the Matrix?", next_node = "the_matrix"}
                }
            },
            the_one = {
                text = "Being The One is just like being in love. No one can tell you you're in love, you just know it. Through and through. Balls to bones.",
                options = {
                    {label = "So I'm not?", next_node = "dialog_end"}
                }
            },
            the_matrix = {
                text = "The Matrix is a system, Neo. That system is our enemy. But when you're inside, you look around, what do you see? The very minds of the people we are trying to save.",
                options = {
                    {label = "I see.", next_node = "dialog_end"}
                }
            },
            dialog_end = {
                text = "You have to understand, most of these people are not ready to be unplugged.",
                options = {}
            }
          }
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
          dialog = {
            start = {
                text = "Hey, Neo! Welcome to the construct. I'm Tank.",
                options = {
                    {label = "Good to meet you.", next_node = "good_to_meet_you"},
                    {label = "This place is incredible.", next_node = "incredible"}
                }
            },
            good_to_meet_you = {
                text = "You too! We've been waiting for you. Need anything? Training? Weapons?",
                options = {
                    {label = "Training?", next_node = "training"},
                    {label = "I'm good for now.", next_node = "dialog_end"}
                }
            },
            incredible = {
                text = "Isn't it? The boss's design. We can load anything we need. What do you want to learn?",
                options = {
                    {label = "Show me.", next_node = "training"}
                }
            },
            training = {
                text = "Jujitsu? Kung Fu? How about... all of them?",
                options = {
                    {label = "All of them.", next_node = "all_of_them"}
                }
            },
            all_of_them = {
                text = "Operator, load the combat training program.",
                options = {
                    {label = "...", next_node = "dialog_end"}
                }
            },
            dialog_end = {
                text = "Just holler if you need anything. Anything at all.",
                options = {}
            }
          }
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
          dialog = {
            start = {
                text = "Mr. Anderson. We've been expecting you.",
                options = {
                    {label = "My name is Neo.", next_node = "name_is_neo"},
                    {label = "...", next_node = "silent"}
                }
            },
            name_is_neo = {
                text = "Whatever you say. You're here for a reason.",
                options = {
                    {label = "What reason?", next_node = "what_reason"}
                }
            },
            silent = {
                text = "The silent type. It doesn't matter. You are an anomaly.",
                options = {
                    {label = "What do you want?", next_node = "what_reason"}
                }
            },
            what_reason = {
                text = "To be deleted. The system has no place for your kind.",
                options = {
                    {label = "I won't let you.", next_node = "wont_let_you"}
                }
            },
            wont_let_you = {
                text = "You hear that, Mr. Anderson? That is the sound of inevitability.",
                options = {
                    {label = "...", next_node = "dialog_end"}
                }
            },
            dialog_end = {
                text = "It is purpose that created us. Purpose that connects us. Purpose that pulls us. That guides us. That drives us. It is purpose that defines. Purpose that binds us.",
                options = {}
            }
          }
        },
        {
          x = 160,
          y = 62,
          name = "Cypher",
          sprite_id = 9,
          dialog = {
            start = {
                text = "Well, well. The new messiah. Welcome to the real world.",
                options = {
                    {label = "You don't seem happy.", next_node = "not_happy"},
                    {label = "...", next_node = "silent"}
                }
            },
            not_happy = {
                text = "Happy? Ignorance is bliss, Neo. We've been fighting this war for years. For what?",
                options = {
                    {label = "For freedom.", next_node = "freedom"}
                }
            },
            silent = {
                text = "Not a talker, huh? Smart. Less to regret later. Want a drink?",
                options = {
                    {label = "Sure.", next_node = "drink"},
                    {label = "No thanks.", next_node = "no_drink"}
                }
            },
            drink = {
                text = "Good stuff. The little things you miss, you know? Like a good steak.",
                options = {
                    {label = "I guess.", next_node = "dialog_end"}
                }
            },
            no_drink = {
                text = "Your loss. More for me.",
                options = {
                    {label = "...", next_node = "dialog_end"}
                }
            },
            freedom = {
                text = "Freedom... right. If Morpheus told you you could fly, would you believe him?",
                options = {
                    {label = "He's our leader.", next_node = "dialog_end"}
                }
            },
            dialog_end = {
                text = "Just be careful who you trust.",
                options = {}
            }
          }
        }
      },
      items = {}
    }
  }
}
