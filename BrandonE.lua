SMODS.Atlas {
  -- Key for code to find it with
  key = "BrandonE",
  -- The name of the file, for the code to pull the atlas from
  path = "BrandonE.png", -- Original file sourced from https://github.com/Steamodded/examples/tree/master/Mods/ExampleJokersMod/assets
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}

SMODS.Joker {
  key = 'dunce',
  loc_txt = {
    name = 'Dunce',
    text = {
      "Copies the ability of the",
      "rightmost {C:attention}Joker{} and",
      "disables {C:attention}Joker{} to the right",
      "{C:inactive}By u/Spicy_burritos"
    }
  },

  unlocked = true,
  discovered = true,
  rarity = 3, -- Rare
  atlas = 'BrandonE',
  pos = { x = 1, y = 0 },
  cost = 10,
  calculate = function(self, card, context)
    if context.before then
      for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card then
          local next_i = i + 1
          next_joker = G.jokers.cards[next_i]

          if next_joker then
            next_joker:set_debuff(true)
            card.ability.debuffed_card = next_joker
          end
        end
      end
    end

    if context.final_scoring_step then
      G.E_MANAGER:add_event(Event({
        func = function()
          if card.ability.debuffed_card then
            card.ability.debuffed_card:set_debuff(false)
          end

          return true
        end
      }))
    end

    local last_joker = G.jokers.cards[#G.jokers.cards]

    if last_joker and last_joker ~= card then
      return SMODS.blueprint_effect(card, last_joker, context)
    end
  end
}

SMODS.Joker {
  key = 'hot_streak',
  loc_txt = {
    name = 'Hot Streak',
    text = {
      "This Joker gains {C:mult}X#2#{} Mult",
      "per consecutive hand played",
      "that sets the score on fire",
      "{C:inactive}(Currently {C:mult}X#1#{})",
      "{C:inactive}By u/Sample_text_here1337"
    }
  },

  config = { extra = { x_mult = 1, x_mult_gain = 0.4 } },
  unlocked = true,
  discovered = true,
  rarity = 3, -- Rare
  atlas = 'BrandonE',
  pos = { x = 0, y = 0 },
  cost = 10,
  loc_vars = function(self, info_queue, card)
  return { vars = { card.ability.extra.x_mult, card.ability.extra.x_mult_gain } }
  end,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.x_mult > 1 then
      return {
        Xmult_mod = card.ability.extra.x_mult,
        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.x_mult } }
      }
    end

    if context.final_scoring_step then
      G.E_MANAGER:add_event(Event({
        func = function()
          card.ability.current_hand_chips = G.GAME.current_round.current_hand.chips
          card.ability.current_hand_mult = G.GAME.current_round.current_hand.mult

          return true
        end
      }))
    end

    if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint and card.ability.current_hand_chips and card.ability.current_hand_mult then
      local chips = card.ability.current_hand_chips
      local mult = card.ability.current_hand_mult
      local required_score = G.ARGS.score_intensity.required_score

      if G.GAME.selected_back:get_name() == "Plasma Deck" then
        local total = chips + mult
        chips = math.floor(total / 2)
        mult = math.floor(total / 2)
      end

      local score = chips * mult

      if score >= required_score and required_score > 0 then
        card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
        return { message = "Upgraded!" }
      elseif card.ability.extra.x_mult > 1 then
        card.ability.extra.x_mult = 1
        return { message = localize('k_reset') }
      end
    end
  end
}

SMODS.Joker {
  key = 'shift_lead',
  loc_txt = {
    name = 'Shift Lead',
    text = {
      "{X:mult,C:white} X#1# {} Mult Before {C:attention}9AM{},",
      "After {C:attention}5PM{}, Or From {C:attention}12-1PM{}",
      "{X:mult,C:white} X#2# {} Mult Otherwise"
    }
  },

  config = { extra = { x_mult = 1.5, x_mult_work = 0 } },
  unlocked = true,
  discovered = true,
  rarity = 2, -- Rare
  atlas = 'BrandonE',
  pos = { x = 0, y = 0 },
  cost = 5,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.x_mult, card.ability.extra.x_mult_work } }
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      local current_time = os.date("*t", os.time())
      local current_hour = current_time.hour

      if current_hour >= 9 and current_hour < 17 and current_hour ~= 12 then
        return {
          Xmult_mod = card.ability.extra.x_mult_work,
          message = "Get To Work!"
        }
      else
        return {
          Xmult_mod = card.ability.extra.x_mult,
          message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.x_mult } }
        }
      end
    end
  end
}
