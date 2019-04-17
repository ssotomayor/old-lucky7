window.App = window.App or {}
window.App.Helpers = window.App.Helpers or {}
window.App.Helpers.Queue = window.App.Helpers.Queue or {}

App.Helpers.Queue =

  defaultChainTimeout: 600

  customTimeouts:
    burned_card_1: 300
    burned_card_2: 300
    burned_card_3: 600
    spin: 4200
    spinRoulette: 2600
    scores: 0
    
    vp_player_card_1: 300
    vp_player_card_2: 300
    vp_player_card_3: 300
    vp_player_card_4: 300
    vp_player_card_5: 300
    vp_score: 1
    vp_game_result: 1

    bc_player_card_1: 500
    bc_player_score_1: 100
    
    bc_banker_card_1: 500
    bc_banker_score_1: 100
    
    bc_player_card_2: 500
    bc_player_score_2: 100

    bc_banker_card_2: 500
    bc_banker_score_2: 100
    
    bc_player_card_3: 500
    bc_player_score_3: 100

    bc_banker_card_3: 500
    bc_banker_score_3: 100

  execute: (callbacks)->
    nextCallbackTime = 0
    for callbackName, callback of callbacks
      setTimeout callback, nextCallbackTime
      nextCallbackTime += @customTimeouts[callbackName] or @defaultChainTimeout