-- TODO: Determine behavior when head or hands are frozen.
return {
    Entity_AI:new({
        id = "osiris",
        name = "Osiris",
        ent_type = ENT_TYPE.MONS_OSIRIS_HEAD,
    }),
    Entity_AI:new({
        id = "osiris_hand",
        name = "Osiris hand",
        parent_id = "osiris",
        ent_type = ENT_TYPE.MONS_OSIRIS_HAND,
        ranges = {
            { -- Punch
                shape = geometry.create_box_shape(-0.88, -1000, 0.88, 0),
                post_transform_shape = function(ent, ctx, shape)
                    if ent.overlay then
                        local _, head_y = get_position(ent.overlay.uid)
                        return shape:clip_bottom(head_y - 4)
                    else
                        return shape
                    end
                end,
                is_visible = function(ent)
                    return ent.overlay and ent.overlay.state ~= CHAR_STATE.DYING
                end,
                is_active = function(ent)
                    return ent.state == 3 and ent.attack_cooldown_timer == 0 and ent.color.a == 1
                end,
                label = "Punch"
            }
        }
    })
}
