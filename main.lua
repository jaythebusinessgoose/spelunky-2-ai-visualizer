meta.name = "AI Visualizer"
meta.version = "0.0.0"
meta.description = "Adds an overlay showing entity AI ranges and targetting information."
meta.author = "Cosine"

local ai_common = require("ai/common")
Entity_AI = require("ai/entity_ai")
geometry = require("geometry")
local drawing = require("drawing")
LABEL_POSITION = drawing.Draw_Item.LABEL_POSITION
local persistence = require("persistence")

local ENTITY_AI_MODULES = {
    "ammit",
    "anubis",
    "anubis_2",
    "axolotl",
    "bat",
    "bee",
    "beg",
    "bodyguard",
    "butterfly",
    "cat_mummy",
    "caveman",
    "celestial_jelly",
    "crab",
    "crocman",
    "drone",
    "egg_sac",
    "eggplant_king",
    "firefly",
    "fish",
    "flying_fish",
    "frog",
    "ghist_shopkeeper",
    "ghost",
    "giant_spider",
    "golden_monkey",
    "goliath_frog",
    "great_humphead",
    "grub",
    "hang_spider",
    "hermit_crab",
    "hired_hand",
    "horned_lizard",
    "hundun",
    "imp",
    "jiangshi",
    "jiangshi_assassin",
    "jungle_sister",
    "kingu",
    "lahamu",
    "lamassu",
    "lavamander",
    "leprechaun",
    "locust",
    "madame_tusk",
    "mech",
    "mole",
    "monkey",
    "mosquito",
    "mummy",
    "necromancer",
    "octopy",
    "olmec",
    "olmite",
    "osiris",
    "pangxie",
    "quillback",
    "robot",
    "rock_dog",
    "scarab",
    "scorpion",
    "shopkeeper",
    "shopkeeper_clone",
    "shopkeeper_generator",
    "skeleton",
    "sorceress",
    "spark_trap",
    "sparrow",
    "spider",
    "sun_challenge_generator",
    "tadpole",
    "tiamat",
    "tiki_man",
    "tun",
    "turkey",
    "ufo",
    "vampire",
    "van_horsing",
    "waddler",
    "witch_doctor",
    "yang",
    "yeti_king",
    "yeti_queen"
}

INDENT = 5

ENT_TYPE_ID_TO_KEY_MAP = {}
for key, id in pairs(ENT_TYPE) do
    ENT_TYPE_ID_TO_KEY_MAP[id] = key
end

local ORIGIN_CHECK_COLOR = drawing.Draw_Color:new({
    Color:new(0.5, 1, 1, 1),
    Color:new(0.5, 0.75, 1, 1),
    Color:new(0.5, 1, 0.75, 1),
    Color:new(0.375, 1, 1, 1)
})
local HITBOX_OVERLAP_COLOR = drawing.Draw_Color:new({
    Color:new(0.25, 0.5, 1, 1),
    Color:new(0.25, 0.25, 1, 1)
})
local HURTBOX_COLOR = drawing.Draw_Color:new({
    Color:new(1, 0.5, 0.5, 1),
    Color:new(0.875, 0.625, 0.5, 1)
})
local MISC_BOX_COLOR = drawing.Draw_Color:new({
    Color:new(1, 0.875, 0.25, 1),
    Color:new(0.875, 1, 0.25, 1)
})
local TARGET_COLOR = drawing.Draw_Color:new({
    Color:new(1, 0.5, 0.0, 1)
})

local default_options = {
    options_window_visible = false,
    player_origin_visible = true,
    entity_ranges_visible = true,
    entity_target_visible = true
    -- entity_ai will be populated while loading entity AIs.
}

-- List of entity AIs. Contents should be initialized while loading the script.
local entity_ai_list
-- Map of entity AIs with entity type IDs as keys. Generated based on entity_ai_list.
local entity_ai_by_ent_type
-- List of all entity types covered by entity AIs. Generated based on entity_ai_by_ent_type.
local entity_ai_ent_type_list

-- Map of tracked entity IDs and their stored data.
local tracked_ents

-- TODO: I don't think this is exactly how entities do line-of-sight checks. It's mostly accurate, but not perfect along edges, and entities might actually be checking specific points instead of a ray.
-- TODO: For some monsters, this check might also get blocked by non-solid floors, such as ladders.
local function ray_cast_horizontal(start, end_x, layer)
    local aabb
    if start.x < end_x then
        aabb = AABB:new(start.x, start.y, end_x, start.y)
    else
        aabb = AABB:new(end_x, start.y, start.x, start.y)
    end
    local blocking_ids = get_entities_overlapping_hitbox(0, MASK.FLOOR | MASK.ACTIVEFLOOR, aabb, layer)
    local farthest_x = end_x
    for _, blocking_id in ipairs(blocking_ids) do
        if test_flag(get_entity(blocking_id).flags, ENT_FLAG.SOLID) then
            if start.x < end_x then
                local solid_x = get_hitbox(blocking_id).left
                if farthest_x > solid_x then
                    farthest_x = solid_x
                end
            else
                local solid_x = get_hitbox(blocking_id).right
                if farthest_x < solid_x then
                    farthest_x = solid_x
                end
            end
        end
    end
    return farthest_x
end

-- Builds precomputed data structures and prepares options for the entity AIs. This needs to be called before trying to process any entities.
local function init_entity_ai()
    entity_ai_list = {}
    for _, module_name in ipairs(ENTITY_AI_MODULES) do
        local full_module_name = "ai/"..module_name
        -- Load the module with error handling to identify it if it fails to load. The error that gets thrown by default is unhelpful.
        local success, module = pcall(function() return require(full_module_name) end)
        if success then
            if module[1] then
                -- The module contains a list of entity AIs.
                for _, module_entity_ai in ipairs(module) do
                    table.insert(entity_ai_list, module_entity_ai)
                end
            else
                -- The module contains a single entity AI.
                table.insert(entity_ai_list, module)
            end
        else
            print("Warning: Failed to load entity AI module \""..full_module_name.."\": "..module)
        end
    end

    entity_ai_by_ent_type = {}
    default_options.entity_ai = {}
    for _, entity_ai in ipairs(entity_ai_list) do
        local ent_types
        if type(entity_ai.ent_type) == "number" then
            ent_types = { entity_ai.ent_type }
        elseif type(entity_ai.ent_type) == "table" then
            ent_types = entity_ai.ent_type
        else
            ent_types = {}
        end
        for _, ent_type in ipairs(ent_types) do
            entity_ai_by_ent_type[ent_type] = entity_ai
        end
        if not entity_ai.parent_id then
            default_options.entity_ai[entity_ai.id] = {
                visible = true
            }
        end
    end

    entity_ai_ent_type_list = {}
    for ent_type, _ in pairs(entity_ai_by_ent_type) do
        table.insert(entity_ai_ent_type_list, ent_type)
    end
end

local function get_entity_ai(ent)
    if not ent then
        return nil
    end
    local entity_ai = entity_ai_by_ent_type[ent.type.id]
    if entity_ai == nil then
        -- TODO: This shouldn't happen, but I keep finding edge cases that cause it.
        print("Warning: entity_ai is nil for id="..ent.uid.." type="..ENT_TYPE_ID_TO_KEY_MAP[ent.type.id])
        tracked_ents[ent.uid] = nil
    end
    return entity_ai
end

local function create_tracked_entity(ent)
    tracked_ents[ent.uid] = {}
    return ent.uid
end

local function should_process_entities(screen)
    return screen == SCREEN.CAMP or screen == SCREEN.LEVEL or screen == SCREEN.DEATH
end

local function process_tracked_entity(id)
    local ent = get_entity(id)

    if not ent then
        -- This entity no longer exists.
        tracked_ents[id] = nil
        return
    end

    local tracked_ent_data = {
        draw_items = {}
    }
    tracked_ents[id] = tracked_ent_data

    local entity_ai = get_entity_ai(ent)
    if not entity_ai or entity_ai.is_dead(ent) then
        return
    end

    if not options.entity_ai[entity_ai.parent_id or entity_ai.id].visible then
        return
    end

    local ranges_visible = options.entity_ranges_visible
    local targetting_visible = options.entity_target_visible and entity_ai.targetting
    if not ranges_visible and not targetting_visible then
        return
    end

    local ent_x, ent_y, ent_layer = get_position(ent.uid)

    -- This processing context has a lifespan of one processing call, and is passed into every Entity_AI function. The entity is also passed into every function as its own parameter for convenience due to how frequently it is used.
    local process_ctx = {
        ent = ent,
        ent_x = ent_x,
        ent_y = ent_y,
        ent_layer = ent_layer
    }

    if ranges_visible then
        if entity_ai.preprocess then
            entity_ai.preprocess(ent, process_ctx)
        end

        process_ctx.is_facing_left = test_flag(ent.flags, ENT_FLAG.FACING_LEFT)
        -- TODO: The "stuck in something" flag is currently missing from ENT_MORE_FLAG.
        local is_stuck = test_flag(ent.more_flags, 8)
        -- TODO: Is state, stun_timer, or stun_state responsible for this?
        local is_stunned = ent.state == CHAR_STATE.STUNNED
        local is_frozen = ent.frozen_timer and ent.frozen_timer > 0

        if entity_ai.ranges then
            for i, range in ipairs(entity_ai.ranges) do
                if range.is_visible and not range.is_visible(ent, process_ctx) then
                    goto skip_range
                end

                local layer
                if range.layer then
                    if type(range.layer) == "function" then
                        layer = range.layer(ent, process_ctx)
                    else
                        layer = range.layer
                    end
                else
                    layer = ent_layer
                end
                if layer ~= LAYER.BOTH and layer ~= state.camera_layer then
                    goto skip_range
                end

                local shapes = {}
                if range.shape then
                    table.insert(shapes, range.shape:clone())
                end
                if range.shapes then
                    for _, shape in ipairs(range.shapes) do
                        table.insert(shapes, shape:clone())
                    end
                end

                local draw_color = ORIGIN_CHECK_COLOR
                if range.type == Entity_AI.RANGE_TYPE.MISC then
                    draw_color = MISC_BOX_COLOR
                elseif range.type == Entity_AI.RANGE_TYPE.HITBOX_OVERLAP then
                    draw_color = HITBOX_OVERLAP_COLOR
                elseif range.type == Entity_AI.RANGE_TYPE.HURTBOX then
                    draw_color = HURTBOX_COLOR
                end

                local is_inactive_when_stuck = range.is_inactive_when_stuck == nil or range.is_inactive_when_stuck
                local is_active = not is_stunned and not is_frozen
                    and not (is_inactive_when_stuck and is_stuck)
                    and (not range.is_active or range.is_active(ent, process_ctx))

                local ucolors = is_active and draw_color:get_variant(i).bright or draw_color:get_variant(i).dim

                local label
                local label_position = range.label_position
                if range.label ~= nil then
                    if type(range.label) == "function" then
                        label = range.label(ent, process_ctx)
                    else
                        label = tostring(range.label)
                    end
                end

                local x, y
                if range.translate_shape then
                    x, y = range.translate_shape(ent, process_ctx)
                end
                if not x or not y then
                    x, y = ent_x, ent_y
                end

                for _, shape in ipairs(shapes) do
                    if range.flip_with_ent and process_ctx.is_facing_left then
                        shape:flip_horizontal()
                        label_position = drawing.Draw_Item.flip_label_position_horizontal(label_position)
                    end
                    shape:translate(x, y)

                    if range.flip_with_ent and range.is_blocked_by_solids and shape.bounds then
                        -- Assume that the ray cast only needs to occur in the direction the entity is facing. There are no entities with two-way line-of-sight checks.
                        if process_ctx.is_facing_left then
                            shape:clip_left(ray_cast_horizontal(Vec2:new(ent_x, ent_y), shape.bounds.left, ent_layer))
                        else
                            shape:clip_right(ray_cast_horizontal(Vec2:new(ent_x, ent_y), shape.bounds.right, ent_layer))
                        end
                    end

                    if range.post_transform_shape then
                        shape = range.post_transform_shape(ent, process_ctx, shape)
                    end

                    table.insert(tracked_ent_data.draw_items, drawing.Draw_Item:new({
                        shape = shape,
                        ucolors = ucolors,
                        label = label,
                        label_position = label_position
                    }))
                end

                ::skip_range::
            end
        end
    end

    -- TODO: Dim the targetting when the entity is in a state where target doesn't matter, similar to dimming ranges. Maybe dim when entity cannot update targetting timer or find new targets.
    -- TODO: Put the timer somewhere on the entity if it has no target (target was destroyed or changed layer), but it's still seeking a new target.
    -- TODO: Indicate the direction of the targetting for when both the entity and target are off-screen.
    if targetting_visible then
        local target = get_entity(ai_common.get_field(ent, entity_ai.targetting.id_field))
        if target then
            local timer_value = ai_common.get_field(ent, entity_ai.targetting.timer_field)
            local timer
            if timer_value then
                timer = { value = timer_value, max_value = entity_ai.targetting.timer_max }
            end
            local target_x, target_y = get_position(target.uid)
            -- TODO: Don't show targetting when both entities are not on the camera layer.
            -- TODO: Handle targetting between both layers.
            table.insert(tracked_ent_data.draw_items, drawing.Draw_Item:new({
                shape = geometry.create_line_shape(Vec2:new(ent_x, ent_y), Vec2:new(target_x, target_y)),
                ucolors = TARGET_COLOR:get().bright,
                label = "Target",
                timer = timer
            }))
        end
    end
end

local function clear_tracked_entities()
    tracked_ents = {}
end

local function scan_for_tracked_entities()
    if should_process_entities(state.screen) then
        for _, ent_id in ipairs(get_entities_by_type(entity_ai_ent_type_list)) do
            process_tracked_entity(create_tracked_entity(get_entity(ent_id)))
        end
    end
end

local function draw_options(ctx, is_window)
    if not is_window then
        if ctx:win_button("Detach options into window") then
            options.options_window_visible = true
        end
    end

    options.player_origin_visible = ctx:win_check("Show player origin point", options.player_origin_visible)

    ctx:win_separator()

    ctx:win_section("Entity AI visualizations", function()
        ctx:win_indent(INDENT)

        options.entity_ranges_visible = ctx:win_check("Ranges visible", options.entity_ranges_visible)
        ctx:win_text("Global toggle for entity range overlay.")

        options.entity_target_visible = ctx:win_check("Targetting visible", options.entity_target_visible)
        ctx:win_text("Global toggle for entity targetting overlay.")

        if ctx:win_button("Check all") then
            for id, _ in pairs(options.entity_ai) do
                options.entity_ai[id].visible = true
            end
        end
        ctx:win_inline()
        if ctx:win_button("Uncheck all") then
            for id, _ in pairs(options.entity_ai) do
                options.entity_ai[id].visible = false
            end
        end

        for _, entity_ai in ipairs(entity_ai_list) do
            if not entity_ai.parent_id then
                options.entity_ai[entity_ai.id].visible = ctx:win_check(entity_ai.name, options.entity_ai[entity_ai.id].visible)
            end
        end

        ctx:win_indent(-INDENT)
    end)

    ctx:win_separator()

    if ctx:win_button("Save options") then
        if not save_script() then
            print("Save occurred too recently. Wait a few seconds and try again.")
        end
    end
    ctx:win_text("Immediately save the current options. Saves also happen automatically during screen changes.")

    if ctx:win_button("Reset options") then
        options = persistence.deep_copy(default_options)
    end
    ctx:win_text("Reset all options to their default values.")
end

local function on_draw_gui(ctx)
    ctx:draw_layer(DRAW_LAYER.BACKGROUND)
    if should_process_entities(state.screen) then
        for _, tracked_ent_data in pairs(tracked_ents) do
            if tracked_ent_data.draw_items then
                for _, draw_item in ipairs(tracked_ent_data.draw_items) do
                    draw_item:draw(ctx)
                end
            end
        end
        if options.player_origin_visible then
            for _, player in ipairs(players) do
                local x, y, layer = get_position(player.uid)
                if layer == state.camera_layer then
                    drawing.draw_point_mark(ctx, x, y)
                end
            end
        end
    end

    ctx:draw_layer(DRAW_LAYER.WINDOW)
    if options.options_window_visible then
        options.options_window_visible = ctx:window(meta.name.." Options", -1, -0.1, 0.35, 0.85, true, function()
            ctx:win_indent(INDENT)
            draw_options(ctx, true)
            ctx:win_indent(-INDENT)
        end)
    end
end

local function on_game_frame()
    if should_process_entities(state.screen) then
        for id, _ in pairs(tracked_ents) do
            process_tracked_entity(id)
        end
    end
end

local function on_pre_load_screen()
    -- Check whether the game is unloading a screen that could be tracking entities. It isn't normally possible to move from the options screen directly into a new level, so that case isn't handled here.
    if should_process_entities(state.screen) and state.screen_next ~= SCREEN.OPTIONS and state.screen_next ~= SCREEN.DEATH then
        clear_tracked_entities()
    end
end

set_callback(function(ctx)
    init_entity_ai()
    local load_table = persistence.load(ctx)
    options = persistence.combine_tables(default_options, load_table.options)
    register_option_callback("", options, draw_options)
    set_callback(persistence.save, ON.SAVE)

    set_callback(on_draw_gui, ON.GUIFRAME)
    -- TODO: Using a global interval here because ON.GAMEFRAME isn't triggering during OL frame advances.
    set_global_interval(on_game_frame, 1)
    set_callback(on_pre_load_screen, ON.PRE_LOAD_SCREEN)

    -- Immediately initialize the tracked entities and scan any entities that currently exist.
    clear_tracked_entities()
    scan_for_tracked_entities()

    -- Track any entities that are created after the initial scan.
    if #entity_ai_ent_type_list > 0 then
        set_post_entity_spawn(function(ent)
            if should_process_entities(state.screen) then
                process_tracked_entity(create_tracked_entity(ent))
            end
        end, SPAWN_TYPE.ANY, MASK.ANY, entity_ai_ent_type_list)
    end
end, ON.LOAD)
