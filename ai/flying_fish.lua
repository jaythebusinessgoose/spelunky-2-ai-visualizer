-- TODO: How does the targetting work?
return Entity_AI:new({
    id = "flying_fish",
    name = "Flying fish",
    ent_type = ENT_TYPE.MONS_FISH,
    ranges = {
        { -- Rise
            -- TODO: Ceiling will reduce the height of the rise shape. Getting close may cause a rise even when there is a low ceiling.
            shape = geometry.create_box_shape(-10, 0, 10, 4),
            is_active = function(ent)
                return ent.state == 3 and ent.move_state == 0 and ent.target_selection_timer == 0
            end,
            label = "Rise"
        },
        { -- Attack
            shape = geometry.create_box_shape(-1000, -1000, 1000, 0),
            is_visible = function(ent)
                return ent.move_state == 2
            end,
            label = "Attack",
            label_position = LABEL_POSITION.TOP
        }
    }
})
