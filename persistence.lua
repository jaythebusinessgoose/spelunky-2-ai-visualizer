local module = {}

-- Creates a deep copy of an object. Tables are copied by recursively deep copying their elements into a new table. Non-table objects are directly returned.
function module.deep_copy(obj)
    if type(obj) == "table" then
        local copy = {}
        for k, v in pairs(obj) do
            copy[k] = module.deep_copy(v)
        end
        return copy
    else
        return obj
    end
end

-- Combines two tables. The contents of base_table are the default values. If a base_table key also exists in override_table and both values have the same type, then override_table's value is used. If both values are tables, then they are combined recursively with the same rules. Keys that exist in override_table and not base_table are ignored. All returned tables are deep copies. A nil table is handled as though it were an empty table.
function module.combine_tables(base_table, override_table)
    base_table = base_table or {}
    override_table = override_table or {}
    local combined_table = {}
    for k, v1 in pairs(base_table) do
        local v2 = override_table[k]
        if type(v1) == type(v2) then
            if type(v1) == "table" then
                -- Recursively combine the value tables.
                combined_table[k] = module.combine_tables(v1, v2)
            else
                -- Use override_table's value.
                combined_table[k] = v2
            end
        else
            -- Use base_table's value.
            combined_table[k] = module.deep_copy(v1)
        end
    end
    return combined_table
end

function module.load(ctx)
    local load_data = ctx:load()
    if not load_data or load_data == "" then
        -- Save file is missing or empty.
        return {}
    else
        local success, result = pcall(function() return json.decode(load_data) end)
        if success then
            return result
        else
            print("Warning: Failed to decode loaded data as JSON: "..result)
            return {}
        end
    end
end

function module.save(ctx)
    local save_json = json.encode({
        format = 1,
        options = options
    })
    ctx:save(save_json)
end

return module
