-- TODO: Unfinished
return Entity_AI:new({
    id = "ghost",
    name = "Ghost",
    ent_type = {
        ENT_TYPE.MONS_GHOST,
        ENT_TYPE.MONS_GHOST_MEDIUM_SAD,
        ENT_TYPE.MONS_GHOST_MEDIUM_HAPPY,
        ENT_TYPE.MONS_GHOST_SMALL_ANGRY,
        ENT_TYPE.MONS_GHOST_SMALL_SAD,
        ENT_TYPE.MONS_GHOST_SMALL_SURPRISED,
        ENT_TYPE.MONS_GHOST_SMALL_HAPPY
    },
    targetting = {
        id_field = "chased_target_uid"
    }
})
