window.App = window.App or {}
window.App.Helpers = window.App.Helpers or {}
window.App.Helpers.Casino = window.App.Helpers.Casino or {}
window.App.Helpers.Casino.VideoPoker = window.App.Helpers.Casino.VideoPoker or {}

App.Helpers.Casino.VideoPoker =

  GAME_TYPES:
    "jacks-or-better": [
      {"id" : "jacks-or-better",    "name": "Jacks or better",    "multiplier": "1"},
      {"id" : "two-pair",           "name": "Two pair",           "multiplier": "2"},
      {"id" : "three-of-a-kind",    "name": "Three of a kind",    "multiplier": "3"},
      {"id" : "straight",           "name": "Straight",           "multiplier": "4"},
      {"id" : "flush",              "name": "Flush",              "multiplier": "6"},
      {"id" : "full-house",         "name": "Full house",         "multiplier": "9"},
      {"id" : "four-of-a-kind",     "name": "Four of a kind",     "multiplier": "25"},
      {"id" : "straight-flush",     "name": "Straight flush",     "multiplier": "50"},
      {"id" : "royal-flush",        "name": "Royal flush",        "multiplier": "800"},
    ]    
    "tens-or-better": [
      {"id" : "tens-or-better",     "name": "Tens or better",    "multiplier": "1"},
      {"id" : "two-pair",           "name": "Two pair",           "multiplier": "2"},
      {"id" : "three-of-a-kind",    "name": "Three of a kind",    "multiplier": "3"},
      {"id" : "straight",           "name": "Straight",           "multiplier": "4"},
      {"id" : "flush",              "name": "Flush",              "multiplier": "5"},
      {"id" : "full-house",         "name": "Full house",         "multiplier": "6"},
      {"id" : "four-of-a-kind",     "name": "Four of a kind",     "multiplier": "25"},
      {"id" : "straight-flush",     "name": "Straight flush",     "multiplier": "50"},
      {"id" : "royal-flush",        "name": "Royal flush",        "multiplier": "800"},
    ]
    "bonus-poker": [
      {"id" : "jacks-or-better",    "name": "Jacks or better",    "multiplier": "1"},
      {"id" : "two-pair",           "name": "Two pair",           "multiplier": "2"},
      {"id" : "three-of-a-kind",    "name": "Three of a kind",    "multiplier": "3"},
      {"id" : "straight",           "name": "Straight",           "multiplier": "4"},
      {"id" : "flush",              "name": "Flush",              "multiplier": "5"},
      {"id" : "full-house",         "name": "Full house",         "multiplier": "8"},
      {"id" : "four-5-k",           "name": "Four 5-K",           "multiplier": "25"},
      {"id" : "four-2-4",           "name": "Four 2-4",           "multiplier": "40"},
      {"id" : "four-aces",          "name": "Four aces",          "multiplier": "80"},
      {"id" : "straight-flush",     "name": "Straight flush",     "multiplier": "50"},
      {"id" : "royal-flush",        "name": "Royal flush",        "multiplier": "800"},
    ]
    "double-bonus": [
      {"id" : "jacks-or-better",    "name": "Jacks or better",    "multiplier": "1"},
      {"id" : "two-pair",           "name": "Two pair",           "multiplier": "1"},
      {"id" : "three-of-a-kind",    "name": "Three of a kind",    "multiplier": "3"},
      {"id" : "straight",           "name": "Straight",           "multiplier": "5"},
      {"id" : "flush",              "name": "Flush",              "multiplier": "7"},
      {"id" : "full-house",         "name": "Full house",         "multiplier": "10"},
      {"id" : "four-5-k",           "name": "Four 5-K",           "multiplier": "45"},
      {"id" : "four-2-4",           "name": "Four 2-4",           "multiplier": "80"},
      {"id" : "four-aces",          "name": "Four aces",          "multiplier": "160"},
      {"id" : "straight-flush",     "name": "Straight flush",     "multiplier": "50"},
      {"id" : "royal-flush",        "name": "Royal flush",        "multiplier": "800"},
    ]
    "double-double-bonus": [
      {"id" : "jacks-or-better",    "name": "Jacks or better",    "multiplier": "1"},
      {"id" : "two-pair",           "name": "Two pair",           "multiplier": "1"},
      {"id" : "three-of-a-kind",    "name": "Three of a kind",    "multiplier": "3"},
      {"id" : "straight",           "name": "Straight",           "multiplier": "4"},
      {"id" : "flush",              "name": "Flush",              "multiplier": "6"},
      {"id" : "full-house",         "name": "Full house",         "multiplier": "9"},
      {"id" : "four-5-k",           "name": "Four 5-K",           "multiplier": "50"},
      {"id" : "four-2-4-with-5-k",  "name": "Four 2-4 with 5-k",  "multiplier": "80"},
      {"id" : "four-2-4-with-a-4",  "name": "Four 2-4 with a-4",  "multiplier": "160"},
      {"id" : "four-aces-with-5-k", "name": "Four aces with 5-k", "multiplier": "160"},
      {"id" : "four-aces-with-2-4", "name": "Four aces with 2-4", "multiplier": "400"},
      {"id" : "straight-flush",     "name": "Straight flush",     "multiplier": "55"},
      {"id" : "royal-flush",        "name": "Royal flush",        "multiplier": "800"},
    ]
  
  getReturnToPlayer: ()->
    @RETURN_TO_PLAYER
