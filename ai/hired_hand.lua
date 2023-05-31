-- TODO: Ai class has a lot of unknown variables that probably control things I'd be interested in.
-- TODO: Ranged weapon usage
-- TODO: Item/enemy seeking
return Entity_AI:new({
    id = "hired_hand",
    name = "Hired hand & eggplant child",
    ent_type = { ENT_TYPE.CHAR_HIREDHAND, ENT_TYPE.CHAR_EGGPLANT_CHILD },
    targetting = {
        id_field = { "ai", "target_uid" }
    },
    ranges = {
        { -- Adopt (asleep)
            -- TODO: Actual range seems to be around 1.99662, possibly due to rounding errors.
            -- TODO: Eggplant child seems to have a "same room" requirement. What about normal HHs? Only in back layer?
            shape = geometry.create_circle_shape(2),
            is_visible = function(ent)
                return ent.ai and ent.ai.state == 0 and ent.linked_companion_parent == -1
            end,
            label = "Adopt"
        },
        { -- Adopt (awake)
            -- TODO: Distance not precisely tested, but probably has same rounding errors as asleep range.
            -- TODO: Does this range have a "same room" requirement? Maybe only in back layer?
            shape = geometry.create_circle_shape(4),
            is_visible = function(ent)
                return ent.ai and ent.ai.state == 1 and ent.linked_companion_parent == -1
            end,
            label = "Adopt"
        }
    }
})
