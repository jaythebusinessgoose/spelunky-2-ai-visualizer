-- Held items appear to have no effect on range. Boomerang and torch (lit or unlit) are thrown, while a wooden shield and no held item (and probably anything else) causes them to charge.
return Entity_AI:new({
    id = "tiki_man",
    name = "Tiki man",
    ent_type = ENT_TYPE.MONS_TIKIMAN,
    targetting = false,
    ranges = {
        { -- Aggro/attack
            shape = geometry.create_box_shape(0, -0.4, 6, 0.4),
            flip_with_ent = true,
            is_blocked_by_solids = true,
            is_visible = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            is_active = function(ent)
                -- TODO
                return true
            end,
            -- TODO: Use "Attack" if the tikiman is going to throw a held object.
            label = "Aggro"
        }
    }
})
