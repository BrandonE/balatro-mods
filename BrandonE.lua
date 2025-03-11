SMODS.Atlas {
  -- Key for code to find it with
  key = "ModdedVanilla",
  -- The name of the file, for the code to pull the atlas from
  path = "ModdedVanilla.png",
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
      "Copies the ability of the rightmost {C:attention}Joker{} and disables {C:attention}Joker{} to the right",
      "{C:inactive}By u/Spicy_burritos"
    }
  },

  unlocked = true,
  rarity = 2, -- Uncommon
  atlas = 'ModdedVanilla',
  pos = { x = 0, y = 0 },
  cost = 4,
  calculate = function(self, card, context)
    if context.before then
      for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card then
          local next_i = i + 1
          next_joker = G.jokers.cards[next_i]

          if next_joker then
            next_joker:set_debuff(true)
            card.ability["debuffed_card"] = next_joker
          end
        end
      end
    end

    if context.final_scoring_step then
      G.E_MANAGER:add_event(Event({
        blocking = false,
        no_delete = true,
        func = function()
          if card.ability["debuffed_card"] then
            card.ability["debuffed_card"]:set_debuff(false)
            return true
          end
        end
      }))
    end

    local last_joker = G.jokers.cards[#G.jokers.cards]

    if last_joker and last_joker ~= card then
      local last_joker_ret = last_joker:calculate_joker(context)

      if last_joker_ret then
        last_joker_ret.card = card
        return last_joker_ret
      end
    end
  end
}
