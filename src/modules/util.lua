--[[
This file is part of the openPCells project.

This module provides a collection of geometry-related helper functions such as:
    - manipulation of point arrays
    - easier insertion of points in arrays
--]]

local M = {}

function M.xmirror(pts, xcenter)
    local mirrored = {}
    xcenter = xcenter or 0
    for i, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        mirrored[i] = point.create(2 * xcenter - x, y)
    end
    return mirrored
end

function M.ymirror(pts, ycenter)
    local mirrored = {}
    ycenter = ycenter or 0
    for i, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        mirrored[i] = point.create(x, 2 * ycenter - y)
    end
    return mirrored
end

function M.xymirror(pts, xcenter, ycenter)
    local mirrored = {}
    xcenter = xcenter or 0
    ycenter = ycenter or 0
    for i, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        mirrored[i] = point.create(2 * xcenter - x, 2 * ycenter - y)
    end
    return mirrored
end

function M.filter_forward(pts, fun)
    local filtered = {}
    for i = 1, #pts, 1 do
        if fun(pts[i]) then
            table.insert(filtered, pts[i]:copy())
        end
    end
    return filtered
end

function M.filter_backward(pts, fun)
    local filtered = {}
    for i = #pts, 1, -1 do
        if fun(pts[i]) then
            table.insert(filtered, pts[i]:copy())
        end
    end
    return filtered
end

function M.merge_forwards(pts, pts2)
    for i = 1, #pts2 do
        table.insert(pts, pts2[i])
    end
end

function M.merge_backwards(pts, pts2)
    for i = #pts2, 1, -1 do
        table.insert(pts, pts2[i])
    end
end

function M.reverse(pts)
    local new = {}
    for _, pt in ipairs(pts) do
        table.insert(new, 1, pt:copy())
    end
    return new
end

function M.make_insert_xy(pts, idx)
    if idx then
        return function(x, y) table.insert(pts, idx, point.create(x, y)) end
    else
        return function(x, y) table.insert(pts, point.create(x, y)) end
    end
end

function M.make_insert_pts(pts, idx)
    if idx then
        return function(...)
            for _, pt in ipairs({ ... }) do
                table.insert(pts, idx, pt)
            end
        end
    else
        return function(...)
            for _, pt in ipairs({ ... }) do
                table.insert(pts, pt)
            end
        end
    end
end

function M.check_grid(grid, ...)
    for _, num in ipairs({ ... }) do
        assert(num % grid == 0, string.format("number is not on-grid: %d", num))
    end
end

function M.is_point_in_polygon(pt, pts)
    local j = #pts
    local c = false
    local x, y = pt:unwrap()
    for i = 1, #pts do
        local xi, yi = pts[i]:unwrap()
        local xj, yj = pts[j]:unwrap()
        if ((yi > y) ~= (yj > y)) and (x < xi + (xj - xi) * (y - yi) / (yj - yi))
            then
            c = not(c)
        end
        j = i
    end
    return c
end

function M.intersection(s1, s2, c1, c2)
    local s1x, s1y = s1:unwrap()
    local s2x, s2y = s2:unwrap()
    local c1x, c1y = c1:unwrap()
    local c2x, c2y = c2:unwrap()
    local snum = (c2x - c1x) * (s1y - c1y) - (s1x - c1x) * (c2y - c1y)
    local cnum = (s2x - s1x) * (s1y - c1y) - (s1x - c1x) * (s2y - s1y)
    local den = (s2x - s1x) * (c2y - c1y) - (c2x - c1x) * (s2y - s1y)
    if den == 0 then
        return nil
    end

    -- you can use cnum with c-edge or snum with s-edge
    local pt = point.create(s1x + snum * (s2x - s1x) // den, s1y + snum * (s2y - s1y) // den)
    --local pt = point.create(c1x + cnum * (c2x - c1x) // den, c1y + cnum * (c2y - c1y) // den)
    -- the comparison is complex to avoid division
    if (snum == 0 or (snum < 0 and den < 0 and snum >= den) or (snum > 0 and den > 0 and snum <= den)) and
       (cnum == 0 or (cnum < 0 and den < 0 and cnum >= den) or (cnum > 0 and den > 0 and cnum <= den)) then
       return pt
    end
    -- if the edges don't truly overlap, we return the imaginary intersection after nil:
    return nil, pt
end

function M.intersection_ab(P, Q)
    local P1x, P1y = P[1]:unwrap()
    local P2x, P2y = P[2]:unwrap()
    local Q1x, Q1y = Q[1]:unwrap()
    local Q2x, Q2y = Q[2]:unwrap()

    local A = function(P, Q, R)
        local Px, Py = P:unwrap()
        local Qx, Qy = Q:unwrap()
        local Rx, Ry = R:unwrap()
        return (Qx - Px) * (Ry - Py) - (Qy - Py) * (Rx - Px)
    end

    -- edges are parallel
    if (A(P[1], Q[1], Q[2]) - A(P[2], Q[1], Q[2])) == 0 and (A(Q[1], P[1], P[2]) - A(Q[2], P[1], P[2])) == 0 then
        local function dot(P, Q)
            local Px, Py = P:unwrap()
            local Qx, Qy = Q:unwrap()
            return Px * Qx + Py * Qy
        end
        local anum = dot(Q[1] - P[1], P[2] - P[1])
        local aden = dot(P[2] - P[1], P[2] - P[1])
        local bnum = dot(P[1] - Q[1], Q[2] - Q[1])
        local bden = dot(Q[2] - Q[1], Q[2] - Q[1])

        -- T-Overlap (a < 0 or a >= 1 and 0 < b < 1 OR b = 0 and 0 < a < 1)
        if (anum > 0 and anum > aden or anum < 0 and aden > 0)      and
           (bnum > 0 and bden > 0) or (bnum < 0 and bden < 0)       and
           (bnum < 0 and bnum > bden) or (bnum > 0 and bnum < bden) then
           return P[1]
        end
        if (bnum > 0 and bnum > bden or bnum < 0 and bden > 0)      and
           (anum > 0 and aden > 0) or (anum < 0 and aden < 0)       and
           (anum < 0 and anum > aden) or (anum > 0 and anum < aden) then
           return Q[1]
        end

        -- V-Overlap (a == b == 0)
        if anum == 0 and bnum == 0 then
            return P[1] -- or Q[1]
        end

        -- X-Overlap (0 < a, b < 1)
        if (anum > 0 and aden > 0) or (anum < 0 and aden < 0)       and
           (anum < 0 and anum > aden) or (anum > 0 and anum < aden) and
           (bnum > 0 and bden > 0) or (bnum < 0 and bden < 0)       and
           (bnum < 0 and bnum > bden) or (bnum > 0 and bnum < bden) then
        end
        local a = anum / aden
        return point.create((1 - a) * P1x + a * P2x, (1 - a) * P1y + a * P2y)
    else
        local anum = A(P[1], Q[1], Q[2])
        local aden = A(P[1], Q[1], Q[2]) - A(P[2], Q[1], Q[2])
        local bnum = A(Q[1], P[1], P[2])
        local bden = A(Q[1], P[1], P[2]) - A(Q[2], P[1], P[2])

        -- T-Intersection (a = 0 and 0 < b < 1 OR b = 0 and 0 < a < 1)
        if anum == 0 and bnum ~= 0 then
            if (bnum > 0 and bden > 0) or (bnum < 0 and bden < 0) and
               (bnum < 0 and bnum > bden) or (bnum > 0 and bnum < bden) then
                return P[1]
            end
        end
        if bnum == 0 and anum ~= 0 then
            if (anum > 0 and aden > 0) or (anum < 0 and aden < 0) and
               (anum < 0 and anum > aden) or (anum > 0 and anum < aden) then
                return Q[1]
            end
        end

        -- V-Intersection (a == b == 0)
        if anum == 0 and bnum == 0 then
            return P[1] -- or Q[1]
        end

        -- X-Intersection (0 < a, b < 1)
        if (anum > 0 and aden > 0) or (anum < 0 and aden < 0)       and
           (anum < 0 and anum > aden) or (anum > 0 and anum < aden) and
           (bnum > 0 and bden > 0) or (bnum < 0 and bden < 0)       and
           (bnum < 0 and bnum > bden) or (bnum > 0 and bnum < bden) then
        end
        local a = anum / aden
        return point.create((1 - a) * P1x + a * P2x, (1 - a) * P1y + a * P2y)
    end
end

function M.fill_all_with(num, filler)
    local t = {}
    for i = 1, num do
        t[i] = filler
    end
    return t
end

function M.fill_predicate_with(num, filler, predicate, other)
    local t = {}
    for i = 1, num do
        if predicate(i) then
            t[i] = filler
        else
            t[i] = other
        end
    end
    return t
end

function M.fill_even_with(num, filler, other)
    return M.fill_predicate_with(num, filler, function(i) return i % 2 == 0 end, other)
end

function M.fill_odd_with(num, filler, other)
    return M.fill_predicate_with(num, filler, function(i) return i % 2 == 1 end, other)
end

return M
