return Entity_AI:new({
    id = "horned_lizard",
    name = "Horned lizard",
    ent_type = ENT_TYPE.MONS_HORNEDLIZARD,
    targetting = false,
    ranges = {
        { -- Attack
            shape = geometry.create_box_shape(0, -0.45, 6, 0.45),
            flip_with_ent = true,
            is_blocked_by_solids = true,
            is_visible = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            is_active = function(ent)
                -- TODO
                return true
            end,
            -- TODO: Change label if lizard is going to panic instead. Note that it seems to not panic if on a single tile.
            label = "Attack"
        }
    }
})
