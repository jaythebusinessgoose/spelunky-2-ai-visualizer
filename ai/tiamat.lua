-- Tiamat cannot shoot while yelling and vice-versa. The yell is preferred if both attacks are possible at the same time.
-- Bomb yelling is triggered by having a paste bomb stuck to Tiamat's face, shoulder, or arm rest platforms, and has nothing to do with proximity. It uses the same cooldown timer as normal yells.
return Entity_AI:new({
    id = "tiamat",
    name = "Tiamat",
    ent_type = ENT_TYPE.MONS_TIAMAT,
    ranges = {
        { -- Shoot
            -- TODO: Is this shape based on Tiamat's position, or the level?
            shape = geometry.create_box_shape(-11, -6, 9, 10),
            is_active = function(ent)
                return ent.move_state == 0 and ent.attack_timer == 0
            end,
            label = "Shoot"
        },
        { -- Yell
            shape = geometry.create_circle_shape(2),
            is_active = function(ent)
                return ent.move_state == 0 and ent.damage_timer == 0
            end,
            label = "Yell"
        },
        { -- Yell hurtbox
            -- TODO: Yell only seems to do damage on its first frame within its entire hurtbox. The hurtbox stays active for a little while afterward, but only applies knockback.
            -- TODO: Haven't tested that hurtbox for paste bombs is the same as hurtbox for players.
            shape = geometry.create_box_shape(-4.4, -5.25, 4.6, 3.75),
            type = Entity_AI.RANGE_TYPE.HURTBOX,
            is_active = function(ent)
                return ent.move_state == 6
            end,
            label = "Yell hurtbox",
            label_position = LABEL_POSITION.BOTTOM
        }
    }
})
