local module = {}

-- Screen width divided by height.
local ASPECT_RATIO

--------------------------------------------------------------------------------

module.Draw_Item = {}
module.Draw_Item.__index = module.Draw_Item

--[[
The coordinate system for `pivot` and `anchor` is based on the bounding box of the label and parent shape respectively. X is horizontal, Y is vertical, the bottom-left corner is always (0, 0), and the top-right corner is always (1, 1).
pivot: The point on the label acting as its origin.
anchor: The point on the parent shape where the label's pivot will be placed.
anchor_screen_offset: Screen coordinate offset to add to the anchor, in screen width units.
]]
module.Draw_Item.LABEL_POSITION = {
    CENTER = { pivot = Vec2:new(0.5, 0.5), anchor = Vec2:new(0.5, 0.5), anchor_screen_offset = Vec2:new(0.0, 0.0) },
    LEFT = { pivot = Vec2:new(0.0, 0.5), anchor = Vec2:new(0.0, 0.5), anchor_screen_offset = Vec2:new(0.01, 0.0) },
    RIGHT = { pivot = Vec2:new(1.0, 0.5), anchor = Vec2:new(1.0, 0.5), anchor_screen_offset = Vec2:new(-0.01, 0.0) },
    BOTTOM = { pivot = Vec2:new(0.5, 0.0), anchor = Vec2:new(0.5, 0.0), anchor_screen_offset = Vec2:new(0.0, 0.01) },
    TOP = { pivot = Vec2:new(0.5, 1.0), anchor = Vec2:new(0.5, 1.0), anchor_screen_offset = Vec2:new(0.0, -0.01) }
}

module.Draw_Item.label_size = 24
module.Draw_Item.label_position = module.Draw_Item.LABEL_POSITION.CENTER

function module.Draw_Item:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function module.Draw_Item:draw(ctx)
    if self.shape then
        if self.shape.tris then
            for _, tri in ipairs(self.shape.tris) do
                local v1 = Vec2:new(screen_position(tri.v1.x, tri.v1.y))
                local v2 = Vec2:new(screen_position(tri.v2.x, tri.v2.y))
                local v3 = Vec2:new(screen_position(tri.v3.x, tri.v3.y))
                ctx:draw_triangle_filled(v1, v3, v2, self.ucolors.fill)
                if tri.ea_exposed then
                    ctx:draw_line(v1.x, v1.y, v2.x, v2.y, 1, self.ucolors.line)
                end
                if tri.eb_exposed then
                    ctx:draw_line(v2.x, v2.y, v3.x, v3.y, 1, self.ucolors.line)
                end
                if tri.ec_exposed then
                    ctx:draw_line(v3.x, v3.y, v1.x, v1.y, 1, self.ucolors.line)
                end
            end
        end
        if self.shape.convex_polygons then
            for _, convex_polygon in ipairs(self.shape.convex_polygons) do
                local screen_verts = {}
                for i, v in ipairs(convex_polygon) do
                    screen_verts[i] = Vec2:new(screen_position(v.x, v.y))
                end
                ctx:draw_poly_filled(screen_verts, self.ucolors.fill)
                -- Close the poly-line by adding the first vertex to the end.
                table.insert(screen_verts, screen_verts[1])
                ctx:draw_poly(screen_verts, 1, self.ucolors.line)
            end
        end
        if self.shape.lines then
            for _, line in ipairs(self.shape.lines) do
                local x1, y1 = screen_position(line.v1.x, line.v1.y)
                local x2, y2 = screen_position(line.v2.x, line.v2.y)
                ctx:draw_line(x1, y1, x2, y2, 1, self.ucolors.line)
            end
        end
        if self.label and self.shape.bounds then
            local label_origin_x, label_origin_y = screen_position(
                ((1.0 - self.label_position.anchor.x) * self.shape.bounds.left) + (self.label_position.anchor.x * self.shape.bounds.right),
                ((1.0 - self.label_position.anchor.y) * self.shape.bounds.bottom) + (self.label_position.anchor.y * self.shape.bounds.top))
            label_origin_x = label_origin_x + self.label_position.anchor_screen_offset.x
            label_origin_y = label_origin_y + (self.label_position.anchor_screen_offset.y * ASPECT_RATIO)
            local label_draw_helper = module.Text_Draw_Helper:new(label_origin_x, label_origin_y,
                self.label_position.pivot.x, self.label_position.pivot.y, self.label_size)
            local text_x, text_y = label_draw_helper:get_text_position(self.label, self.timer and 0.5 or 0.0)
            ctx:draw_text(text_x, text_y, self.label_size, self.label, self.ucolors.text)
            if self.timer then
                local bar_left, bar_bottom, bar_right, bar_top = label_draw_helper:get_text_bounds("0000/0000", -0.5)
                ctx:draw_rect(bar_left, bar_top, bar_right, bar_bottom, 1, 0, self.ucolors.line)
                local bar_fill_right = bar_left + ((bar_right - bar_left) * self.timer.value / self.timer.max_value)
                ctx:draw_rect_filled(bar_left, bar_top, bar_fill_right, bar_bottom, 0, self.ucolors.fill)
                local timer_text = self.timer.value.."/"..self.timer.max_value
                local timer_text_x, timer_text_y = label_draw_helper:get_text_position(timer_text, -0.5)
                ctx:draw_text(timer_text_x, timer_text_y, self.label_size, timer_text, self.ucolors.text)
            end
        end
    end
end

function module.Draw_Item.flip_label_position_horizontal(label_position)
    if label_position == module.Draw_Item.LABEL_POSITION.LEFT then
        return module.Draw_Item.LABEL_POSITION.RIGHT
    elseif label_position == module.Draw_Item.LABEL_POSITION.RIGHT then
        return module.Draw_Item.LABEL_POSITION.LEFT
    else
        return label_position
    end
end

--------------------------------------------------------------------------------

local LINE_COLOR_ALPHA = 0.5
local FILL_COLOR_ALPHA = 0.125
local TEXT_COLOR_ALPHA = 0.75

module.Draw_Color = {}
module.Draw_Color.__index = module.Draw_Color

function module.Draw_Color:new(colors)
    local o = {
        ucolors = {}
    }

    for _, color in ipairs(colors) do
        table.insert(o.ucolors, {
            bright = {
                line = Color:new(color.r, color.g, color.b, LINE_COLOR_ALPHA):get_ucolor(),
                fill = Color:new(color.r, color.g, color.b, FILL_COLOR_ALPHA):get_ucolor(),
                text = Color:new(color.r, color.g, color.b, TEXT_COLOR_ALPHA):get_ucolor(),
            },
            dim = {
                line = Color:new((0.325 * color.r) + 0.125, (0.325 * color.g) + 0.125, (0.325 * color.b) + 0.125, LINE_COLOR_ALPHA):get_ucolor(),
                fill = Color:new((0.325 * color.r) + 0.125, (0.325 * color.g) + 0.125, (0.325 * color.b) + 0.125, FILL_COLOR_ALPHA):get_ucolor(),
                text = Color:new((0.325 * color.r) + 0.125, (0.325 * color.g) + 0.125, (0.325 * color.b) + 0.125, TEXT_COLOR_ALPHA):get_ucolor()
            }
        })
    end

    setmetatable(o, self)
    return o
end

function module.Draw_Color:get()
    return self.ucolors[1]
end

function module.Draw_Color:get_variant(index)
    index = ((index - 1) % #self.ucolors) + 1
    return self.ucolors[index]
end

--------------------------------------------------------------------------------

module.Text_Draw_Helper = {}
module.Text_Draw_Helper.__index = module.Text_Draw_Helper

function module.Text_Draw_Helper:new(origin_x, origin_y, pivot_x, pivot_y, text_size)
    local o = {
        origin_x = origin_x,
        origin_y = origin_y,
        pivot_x = pivot_x,
        pivot_y = pivot_y,
        text_size = text_size
    }
    setmetatable(o, self)
    return o
end

-- Returns the screen coordinates to provide to the text drawing function for the given text.
function module.Text_Draw_Helper:get_text_position(text, row)
    local text_width, text_height = draw_text_size(self.text_size, text)
    -- Math for X and Y differs because screen coordinates increase from bottom-left to top-right, but the text drawing origin is its top-left corner and the text height is negative.
    return self.origin_x - (self.pivot_x * text_width), self.origin_y - ((1 + row - self.pivot_y) * text_height)
end

-- Returns the bounds of the given text in screen coordinates, in order of left, bottom, right, and top.
function module.Text_Draw_Helper:get_text_bounds(text, row)
    local text_width, text_height = draw_text_size(self.text_size, text)
    -- Math for X and Y differs because screen coordinates increase from bottom-left to top-right, but the text drawing origin is its top-left corner and the text height is negative.
    return self.origin_x - (self.pivot_x * text_width), self.origin_y + ((self.pivot_y - row) * text_height),
        self.origin_x + ((1 - self.pivot_x) * text_width), self.origin_y - ((1 + row - self.pivot_y) * text_height)
end

--------------------------------------------------------------------------------

local POINT_MARK_UCOLOR = Color:new(0, 0.5, 1, 0.75):get_ucolor()
-- Width of the square enclosing the point mark, in screen coordinates.
local POINT_MARK_W = 0.015
-- Height of the square enclosing the point mark, in screen coordinates.
local POINT_MARK_H

function module.draw_point_mark(ctx, x, y)
    local screen_x, screen_y = screen_position(x, y)
    local left = screen_x - (POINT_MARK_W / 2)
    local right = screen_x + (POINT_MARK_W / 2)
    local bottom = screen_y - (POINT_MARK_H / 2)
    local top = screen_y + (POINT_MARK_H / 2)
    ctx:draw_line(left, screen_y, right, screen_y, 2, POINT_MARK_UCOLOR)
    ctx:draw_line(screen_x, bottom, screen_x, top, 2, POINT_MARK_UCOLOR)
end

-- Compute all variables that depend on the screen size. This should be called once before every drawing frame.
function module.compute_screen_vars()
    local window_w, window_h = get_window_size()
    if window_h == 0 then
        -- Use a sane fallback value in case window height is briefly zero.
        ASPECT_RATIO = 1
    else
        ASPECT_RATIO = window_w / window_h
    end
    POINT_MARK_H = POINT_MARK_W * ASPECT_RATIO
end

return module
