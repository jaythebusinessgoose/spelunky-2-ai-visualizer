local module = {}

-- An orthogonal line, parallel to either the X or Y axis. Used for efficient clipping and intersection calculations.
local Orthogonal_Line = {
    DIRECTION = {
        LEFT = { line_axis = "x", perp_axis = "y", mult = 1 },
        RIGHT = { line_axis = "x", perp_axis = "y", mult = -1 },
        DOWN = { line_axis = "y", perp_axis = "x", mult = -1 },
        UP = { line_axis = "y", perp_axis = "x", mult = 1 }
    }
}
Orthogonal_Line.__index = Orthogonal_Line

function Orthogonal_Line:new(direction, perp_axis_value)
    local o = {
        -- Parallel axis to this line.
        line_axis = direction.line_axis,
        -- Perpendicular axis to this line.
        perp_axis = direction.perp_axis,
        -- Negation multiplier for determining which sides of the line are left and right.
        mult = direction.mult,
        -- Position of the line along the perpendicular axis.
        perp_axis_value = perp_axis_value
    }
    setmetatable(o, self)
    return o
end

-- Returns a number specifying where the given point is relative to the forward direction of this line: negative for left, positive for right, zero for coincident.
function Orthogonal_Line:get_point_side(p)
    return self.mult * (p[self.perp_axis] - self.perp_axis_value)
end

--[[
Calculates the intersection of this orthogonal line and a given regular line.
Returns up to 3 values:
    Number of intersection points. -1 for infinity (lines coincident), 0 for none (lines parallel), 1 for a single point.
    Scalar for where the intersection point is relative to the endpoints of the given line. Only defined for a single point intersection.
    Intersection point. Only defined for a single point intersection.
]]
function Orthogonal_Line:intersect_with_line(line)
    if line.v1[self.perp_axis] == line.v2[self.perp_axis] then
        -- Given line is parallel to this line or degenerate.
        if line.v1[self.line_axis] == line.v2[self.line_axis] then
            -- Given line is degenerate and is actually a point.
            if line.v1[self.perp_axis] == self.perp_axis_value then
                -- Point is on this line.
                return 1, 0, self.perp_axis_value, line.v1[self.line_axis]
            else
                -- Point is not on this line.
                return 0
            end
        elseif line.v1[self.perp_axis] == self.perp_axis_value then
            -- Given line is coincident with this line.
            return -1
        else
            -- Given line is parallel to this line.
            return 0
        end
    else
        -- Given line intersects this line at a single point.
        local t = (self.perp_axis_value - line.v1[self.perp_axis]) / (line.v2[self.perp_axis] - line.v1[self.perp_axis])
        local intersect_value = line.v1[self.line_axis] + ((line.v2[self.line_axis] - line.v1[self.line_axis]) * t)
        if self.line_axis == "x" then
            return 1, t, Vec2:new(intersect_value, self.perp_axis_value)
        else
            return 1, t, Vec2:new(self.perp_axis_value, intersect_value)
        end
    end
end

local Line = {}
Line.__index = Line

function Line:new(v1, v2)
    local o = {
        v1 = Vec2:new(v1),
        v2 = Vec2:new(v2)
    }
    setmetatable(o, self)
    return o
end

--[[
A triangle primitive. The winding order of the vertices should be counter-clockwise. Edge exposure is preserved through transformations and clipping, and allows a collection of triangles to represent a single polygon with defined edges.
Vertex 1 to vertex 2 = edge A
Vertex 2 to vertex 3 = edge B
Vertex 3 to vertex 1 = edge C
]]
local Triangle = {}
Triangle.__index = Triangle

function Triangle:new(v1, v2, v3, ea_exposed, eb_exposed, ec_exposed)
    local o = {
        v1 = Vec2:new(v1),
        v2 = Vec2:new(v2),
        v3 = Vec2:new(v3),
        ea_exposed = ea_exposed == true,
        eb_exposed = eb_exposed == true,
        ec_exposed = ec_exposed == true
    }
    setmetatable(o, self)
    return o
end

local function triangle_clip_partial(v1, v2, v3, ea_exposed, eb_exposed, ec_exposed, clip_line)
    local line_a = Line:new(v1, v2)
    local count_a, t_a, inter_a = clip_line:intersect_with_line(line_a)
    if count_a == 0 then
        -- Clip is parallel to edge A. Result is uncertain.
        return nil
    else
        -- Clip intersects line A once.
        if t_a < 0 or t_a >= 1 then
            -- Clip intersects vertex 2 or does not intersect edge A. Result is uncertain.
            return nil
        else
            local line_b = Line:new(v2, v3)
            local count_b, t_b, inter_b = clip_line:intersect_with_line(line_b)
            if t_a == 0 then
                -- Clip intersects vertex 1.
                if count_b == 1 and t_b > 0 and t_b < 1 then
                    -- Clip intersects edge B between its endpoints.
                    if clip_line:get_point_side(v2) <= 0 then
                        -- Keep the part of the triangle with vertex 2.
                        return { Triangle:new(v1, v2, inter_b, ea_exposed, eb_exposed, true) }
                    else
                        -- Keep the part of the triangle with vertex 3.
                        return { Triangle:new(v1, inter_b, v3, true, eb_exposed, ec_exposed) }
                    end
                else
                    -- Clip does not intersect edge B between its endpoints. Result is uncertain.
                    return nil
                end
            else
                -- Clip intersects edge A between its endpoints.
                if count_b == 1 and t_b > 0 and t_b < 1 then
                    -- Clip intersects edge B between its endpoints.
                    if clip_line:get_point_side(v2) <= 0 then
                        -- Keep the part of the triangle with vertex 2.
                        return { Triangle:new(inter_a, v2, inter_b, ea_exposed, eb_exposed, true) }
                    else
                        -- Keep the part of the triangle with edge C.
                        return {
                            Triangle:new(v1, inter_b, v3, false, eb_exposed, ec_exposed),
                            Triangle:new(v1, inter_a, inter_b, ea_exposed, true, false)
                        }
                    end
                else
                    -- Clip does not intersect edge B between its endpoints. Result is uncertain.
                    return nil
                end
            end
        end
    end
end

-- Clips a triangle along a line. The returned value will be a list containing 0, 1, or 2 triangles, and could contain the original triangle object. Triangles which graze the outside of the clip line are entirely excluded, rather than returning a line segment or point.
function Triangle:clip(clip_line)
    local v1_clip_side = clip_line:get_point_side(self.v1)
    local v2_clip_side = clip_line:get_point_side(self.v2)
    local v3_clip_side = clip_line:get_point_side(self.v3)
    if v1_clip_side >= 0 and v2_clip_side >= 0 and v3_clip_side >= 0 then
        -- The entire triangle is outside the clip.
        return {}
    elseif v1_clip_side <= 0 and v2_clip_side <= 0 and v3_clip_side <= 0 then
        -- The entire triangle is within the clip.
        return { self }
    else
        -- There is at least one vertex on either side of the clip.
        -- Each partial clip handles a few clipping scenarios for specific edges and vertices on the triangle. If it can handle a scenario, then the triangle is clipped and the operation is complete. Otherwise, it defers clipping to the next partial clip. Between partial clip attempts, the labels of the vertices and edges of the triangle are "rotated" CW, so that vertex 2 is now labelled as vertex 1, and so on. The same partial clip is then performed on the rotated triangle. By doing this with up to all three rotations of the triangle, the partial clips together are guaranteed to cover every triangle clipping scenario without duplicate code. Any cases not handled by the partial clips should have been covered earlier by the checks for full inclusion or exclusion of the triangle.
        local tris = triangle_clip_partial(self.v1, self.v2, self.v3, self.ea_exposed, self.eb_exposed, self.ec_exposed, clip_line)
        if not tris then
            tris = triangle_clip_partial(self.v2, self.v3, self.v1, self.eb_exposed, self.ec_exposed, self.ea_exposed, clip_line)
            if not tris then
                tris = triangle_clip_partial(self.v3, self.v1, self.v2, self.ec_exposed, self.ea_exposed, self.eb_exposed, clip_line)
            end
        end
        return tris or {}
    end
end

local Shape = {}
Shape.__index = Shape

function Shape:new()
    local o = {}
    setmetatable(o, self)
    return o
end

function Shape:clone()
    local clone = Shape:new()
    if self.bounds then
        clone.bounds = AABB:new(self.bounds)
    end
    if self.points then
        clone.points = {}
        for i, point in ipairs(self.points) do
            clone.points[i] = Vec2:new(point)
        end
    end
    if self.lines then
        clone.lines = {}
        for i, line in ipairs(self.lines) do
            clone.lines[i] = Line:new(line.v1, line.v2)
        end
    end
    if self.tris then
        clone.tris = {}
        for i, tri in ipairs(self.tris) do
            clone.tris[i] = Triangle:new(tri.v1, tri.v2, tri.v3, tri.ea_exposed, tri.eb_exposed, tri.ec_exposed)
        end
    end
    if self.convex_polygons then
        clone.convex_polygons = {}
        for i, convex_polygon in ipairs(self.convex_polygons) do
            clone.convex_polygons[i] = {}
            for j, v in ipairs(convex_polygon) do
                clone.convex_polygons[i][j] = Vec2:new(v)
            end
        end
    end
    return clone
end

function Shape:translate(x, y)
    if self.bounds then
        self.bounds.left = self.bounds.left + x
        self.bounds.bottom = self.bounds.bottom + y
        self.bounds.right = self.bounds.right + x
        self.bounds.top = self.bounds.top + y
    end
    if self.points then
        for _, point in ipairs(self.points) do
            point.x = point.x + x
            point.y = point.y + y
        end
    end
    if self.lines then
        for _, line in ipairs(self.lines) do
            line.v1.x = line.v1.x + x
            line.v1.y = line.v1.y + y
            line.v2.x = line.v2.x + x
            line.v2.y = line.v2.y + y
        end
    end
    if self.tris then
        for _, tri in ipairs(self.tris) do
            tri.v1.x = tri.v1.x + x
            tri.v1.y = tri.v1.y + y
            tri.v2.x = tri.v2.x + x
            tri.v2.y = tri.v2.y + y
            tri.v3.x = tri.v3.x + x
            tri.v3.y = tri.v3.y + y
        end
    end
    if self.convex_polygons then
        for _, convex_polygon in ipairs(self.convex_polygons) do
            for _, v in ipairs(convex_polygon) do
                v.x = v.x + x
                v.y = v.y + y
            end
        end
    end
    return self
end

-- Flips the shape horizontally. Polygon primitives also have their vertex orders reversed to keep their original winding direction.
function Shape:flip_horizontal()
    if self.bounds then
        self.bounds.left, self.bounds.right = -self.bounds.right, -self.bounds.left
    end
    if self.points then
        for _, point in ipairs(self.points) do
            point.x = -point.x
        end
    end
    if self.lines then
        for _, line in ipairs(self.lines) do
            line.v1.x = -line.v1.x
            line.v2.x = -line.v2.x
        end
    end
    if self.tris then
        for _, tri in ipairs(self.tris) do
            tri.v1.x, tri.v2.x, tri.v3.x = -tri.v1.x, -tri.v3.x, -tri.v2.x
            tri.v2.y, tri.v3.y = tri.v3.y, tri.v2.y
            tri.ea_exposed, tri.ec_exposed = tri.ec_exposed, tri.ea_exposed
        end
    end
    if self.convex_polygons then
        for _, convex_polygon in ipairs(self.convex_polygons) do
            for i = 1, math.ceil(#convex_polygon / 2) do
                local end_i = #convex_polygon - i + 1
                convex_polygon[i].x = -convex_polygon[i].x
                if i ~= end_i then
                    convex_polygon[end_i].x = -convex_polygon[end_i].x
                    convex_polygon[i], convex_polygon[end_i] = convex_polygon[end_i], convex_polygon[i]
                end
            end
        end
    end
    return self
end

-- Clip the shape along the given clip line, keeping the left portion relative to the clip line.
function Shape:_clip(clip_line)
    if self.points then
        local new_points = {}
        for _, point in ipairs(self.points) do
            if clip_line:get_point_side(point) <= 0 then
                table.insert(new_points, point)
            end
        end
        self.points = new_points
    end
    if self.lines then
        local new_lines = {}
        for _, line in ipairs(self.lines) do
            local v1_inside_clip = clip_line:get_point_side(line.v1) <= 0
            local v2_inside_clip = clip_line:get_point_side(line.v2) <= 0
            if v1_inside_clip then
                if v2_inside_clip then
                    -- This edge is inside the clip.
                    table.insert(new_lines, line)
                else
                    -- This edge crosses from inside to outside the clip.
                    local _, _, inter = clip_line:intersect_with_line(line)
                    table.insert(new_lines, Line:new(line.v1, inter))
                end
            else
                if v2_inside_clip then
                    -- This edge crosses from outside to inside the clip.
                    local _, _, inter = clip_line:intersect_with_line(line)
                    table.insert(new_lines, Line:new(inter, line.v2))
                end
            end
        end
        self.lines = new_lines
    end
    if self.tris then
        local new_tris = {}
        for _, tri in ipairs(self.tris) do
            for _, new_tri in ipairs(tri:clip(clip_line)) do
                table.insert(new_tris, new_tri)
            end
        end
        self.tris = new_tris
    end
    if self.convex_polygons then
        local new_convex_polygons = {}
        for _, convex_polygon in ipairs(self.convex_polygons) do
            local new_convex_polygon = {}
            local prev_v = convex_polygon[#convex_polygon]
            local within_clip = clip_line:get_point_side(prev_v) <= 0
            for _, v in ipairs(convex_polygon) do
                if within_clip then
                    -- The previous vertex was within the clip.
                    if clip_line:get_point_side(v) <= 0 then
                        -- This vertex is within the clip.
                        table.insert(new_convex_polygon, v)
                    else
                        -- This edge crosses from inside to outside the clip.
                        within_clip = false
                        local line = Line:new(prev_v, v)
                        local _, _, inter = clip_line:intersect_with_line(line)
                        table.insert(new_convex_polygon, inter)
                    end
                else
                    -- The previous vertex was outside the clip.
                    if clip_line:get_point_side(v) <= 0 then
                        -- This edge crosses from outside to inside the clip.
                        within_clip = true
                        local line = Line:new(prev_v, v)
                        local _, _, inter = clip_line:intersect_with_line(line)
                        table.insert(new_convex_polygon, inter)
                        table.insert(new_convex_polygon, v)
                    end
                end
                prev_v = v
            end
            if #new_convex_polygon > 0 then
                table.insert(new_convex_polygons, new_convex_polygon)
            end
        end
        self.convex_polygons = new_convex_polygons
    end
end

-- Clips off the left side of the shape below the given X value, keeping the right side.
function Shape:clip_left(x)
    self:_clip(Orthogonal_Line:new(Orthogonal_Line.DIRECTION.DOWN, x))
    if self.bounds then
        self.bounds.left = math.max(self.bounds.left, x)
    end
    return self
end

-- Clips off the bottom side of the shape below the given Y value, keeping the top side.
function Shape:clip_bottom(y)
    self:_clip(Orthogonal_Line:new(Orthogonal_Line.DIRECTION.RIGHT, y))
    if self.bounds then
        self.bounds.bottom = math.max(self.bounds.bottom, y)
    end
    return self
end

-- Clips off the right side of the shape above the given X value, keeping the left side.
function Shape:clip_right(x)
    self:_clip(Orthogonal_Line:new(Orthogonal_Line.DIRECTION.UP, x))
    if self.bounds then
        self.bounds.right = math.min(self.bounds.right, x)
    end
    return self
end

-- Clips off the top side of the shape above the given Y value, keeping the bottom side.
function Shape:clip_top(y)
    self:_clip(Orthogonal_Line:new(Orthogonal_Line.DIRECTION.LEFT, y))
    if self.bounds then
        self.bounds.top = math.min(self.bounds.top, y)
    end
    return self
end

-- Clips off the parts of the shape that are outside the given box, keeping the inner portion. A side with a nil constraint will not be clipped.
function Shape:clip_box(left, bottom, right, top)
    if left then
        self:clip_left(left)
    end
    if bottom then
        self:clip_bottom(bottom)
    end
    if right then
        self:clip_right(right)
    end
    if top then
        self:clip_top(top)
    end
    return self
end

-- Grow the bounds of the shape to contain the given point.
function Shape:_update_bounds(p)
    if self.bounds then
        if p.x < self.bounds.left then
            self.bounds.left = p.x
        elseif p.x > self.bounds.right then
            self.bounds.right = p.x
        end
        if p.y < self.bounds.bottom then
            self.bounds.bottom = p.y
        elseif p.y > self.bounds.top then
            self.bounds.top = p.y
        end
    else
        self.bounds = AABB:new(p.x, p.y, p.x, p.y)
    end
end

local function validate_create_box_shape(left, bottom, right, top)
    if left > right then
        error("Box left edge ("..tostring(left)..") is greater than right edge ("..tostring(right)..").")
    end
    if bottom > top then
        error("Box bottom edge ("..tostring(bottom)..") is greater than top edge ("..tostring(top)..").")
    end
end

local CIRCLE_MIN_SLICE_COUNT = 6
local CIRCLE_MAX_SLICE_ARC_LENGTH = 0.5
local function calculate_circle_slice_count(r, divisibility)
    local slice_count = divisibility * math.ceil(math.max(CIRCLE_MIN_SLICE_COUNT, 2 * math.pi * r / CIRCLE_MAX_SLICE_ARC_LENGTH) / divisibility)
    return slice_count, 2 * math.pi / slice_count
end

function module.create_point_set_shape(...)
    local shape = Shape:new()

    shape.points = {}
    for i, point in ipairs({ ... }) do
        shape.points[i] = Vec2:new(point)
        shape:_update_bounds(point)
    end

    return shape
end

function module.create_line_shape(v1, v2)
    local shape = Shape:new()

    shape.lines = {
        Line:new(v1, v2)
    }

    shape:_update_bounds(v1)
    shape:_update_bounds(v2)

    return shape
end

function module.create_triangle_shape(v1, v2, v3)
    local shape = Shape:new()

    shape.tris = {
        Triangle:new(v1, v2, v3, true, true, true)
    }

    shape:_update_bounds(v1)
    shape:_update_bounds(v2)
    shape:_update_bounds(v3)

    return shape
end

function module.create_box_shape(left, bottom, right, top)
    validate_create_box_shape(left, bottom, right, top)

    local shape = Shape:new()

    shape.convex_polygons = {
        {
            Vec2:new(left, bottom),
            Vec2:new(right, bottom),
            Vec2:new(right, top),
            Vec2:new(left, top)
        }
    }

    shape.bounds = AABB:new(left, top, right, bottom)

    return shape
end

-- Creates a box with the given edges and then grown outward by the given radius.
function module.create_rounded_box_shape(left, bottom, right, top, r)
    validate_create_box_shape(left, bottom, right, top)
    if r == 0 then
        return module.create_box_shape(left, bottom, right, top)
    elseif r < 0 then
        error("Box corner radius ("..tostring(r)..") is negative.")
    end

    local shape = Shape:new()

    local slice_count, slice_angle = calculate_circle_slice_count(r, 4)
    local corner_x, corner_y = right, top

    local convex_polygon = {}
    shape.convex_polygons = { convex_polygon }
    for i = 1, slice_count do
        local r_cos = r * math.cos(slice_angle * i)
        local r_sin = r * math.sin(slice_angle * i)
        table.insert(convex_polygon, Vec2:new(corner_x + r_cos, corner_y + r_sin))
        local add_side_vert = false
        if i == slice_count / 4 then
            corner_x = left
            add_side_vert = true
        elseif i == 2 * slice_count / 4 then
            corner_y = bottom
            add_side_vert = true
        elseif i == 3 * slice_count / 4 then
            corner_x = right
            add_side_vert = true
        elseif i == slice_count then
            corner_y = top
            add_side_vert = true
        end
        if add_side_vert then
            table.insert(convex_polygon, Vec2:new(corner_x + r_cos, corner_y + r_sin))
        end
    end

    shape.bounds = AABB:new(left - r, top + r, right + r, bottom - r)

    return shape
end

function module.create_circle_shape(r)
    if r < 0 then
        error("Circle radius ("..tostring(r)..") is negative.")
    end

    local shape = Shape:new()

    if r > 0 then
        local slice_count, slice_angle = calculate_circle_slice_count(r, 1)
        local convex_polygon = {}
        shape.convex_polygons = { convex_polygon }
        for i = 1, slice_count do
            table.insert(convex_polygon, Vec2:new(r * math.cos(slice_angle * i), r * math.sin(slice_angle * i)))
        end
    end

    shape.bounds = AABB:new(-r, r, r, -r)

    return shape
end

function module.create_donut_shape(r_min, r_max)
    if r_min == 0 then
        return module.create_circle_shape(r_max)
    end
    if r_min < 0 then
        error("Donut inner radius ("..tostring(r_min)..") is negative.")
    end
    if r_max < 0 then
        error("Donut outer radius ("..tostring(r_max)..") is negative.")
    end
    if r_min > r_max then
        error("Donut inner radius ("..tostring(r_min)..") is greater than outer radius ("..tostring(r_max)..").")
    end

    local shape = Shape:new()

    if r_max > 0 then
        local slice_count, slice_angle = calculate_circle_slice_count(r_max, 1)
        local inner_verts = {}
        local outer_verts = {}
        for i = 1, slice_count do
            local cos = math.cos(slice_angle * i)
            local sin = math.sin(slice_angle * i)
            table.insert(inner_verts, Vec2:new(r_min * cos, r_min * sin))
            table.insert(outer_verts, Vec2:new(r_max * cos, r_max * sin))
        end
        shape.tris = {}
        for i = 1, slice_count do
            local next_i = (i % slice_count) + 1
            table.insert(shape.tris, Triangle:new(
                inner_verts[i], outer_verts[i], outer_verts[next_i],
                false, true, false))
            table.insert(shape.tris, Triangle:new(
                inner_verts[i], outer_verts[next_i], inner_verts[next_i],
                false, false, true))
        end
    end

    shape.bounds = AABB:new(-r_max, r_max, r_max, -r_max)

    return shape
end

return module
