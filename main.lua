local hsl2rgb = require("hsl")

local rect = function(x, y, w, h, r)
    return {x=x, y=y, w=w, h=h, r=r}
end

local getPoints = function(rect)
    local s, c = math.sin(rect.r), math.cos(rect.r)
    local points = {}
    local px, py
    local rpx, rpy
    for i = 1, 4 do
        px = (i-1)/3%1 == 0 and -rect.w/2 or rect.w/2
        py = i>2 and -rect.h/2 or rect.h/2
        rpx = px * c - py * s
        rpy = px * s + py * c
        points[i*2-1] = rect.x + rpx
        points[i*2] = rect.y + rpy
    end
    return points
end

local r = {}

local function calculateBottomPoint(rect)
    local s, c = math.sin(rect.r), math.cos(rect.r) --get the rotation
    local i = math.ceil(rect.r/1.57079632679)%4+1 -- this is interesting.
    -- If you divide a circle into quadrants, you can select the last quadrant based on your current rotation.
    -- so we'll always use the point at the bottom, based on rotation.
    local px = (i-1)/3%1 == 0 and -rect.w/2 or rect.w/2 -- calculate the x
    local py = i>2 and -rect.h/2 or rect.h/2 -- calculate the y
    return (px * s + py * c) + rect.y -- add rotation and return the location of our bottom point
    -- This can return any point on a rectangle, you just have to adjust the starting theta.
    -- you may also return the x location if you need it.
end

    
function love.wheelmoved(x, y)
    r[1].r = r[1].r + y/20
end

function love.load()
    local rnd = math.random
    for i = 1, 10 do
        r[i] = rect(rnd(800),rnd(600),100,100,rnd()*math.pi*2)
        r[i].c = hsl2rgb(rnd(255),128,128,255)
    end
    r[1].w = 300
end

function love.update(dt)
    --r[1].r = r[1].r + math.rad(1)
    r[1].x, r[1].y = love.mouse.getPosition()
    
end

function love.draw()
    local y = calculateBottomPoint(r[1])
    local c
    for i = #r, 1, -1 do
        if r[i].y < y then
            c = hsl2rgb(r[i].c[1], 1, 128, 255)
        else
            c = r[i].c
        end
        love.graphics.setColor(c)
        love.graphics.polygon("fill", getPoints(r[i]))
        love.graphics.setColor(0,0,0)
        love.graphics.polygon("line", getPoints(r[i]))
        love.graphics.setColor(255,255,255)
        love.graphics.circle("fill", r[i].x, r[i].y, 8)
    end
    love.graphics.setColor(255,255,255)
    love.graphics.line(0, y, 800, y)
    love.graphics.print(love.timer.getFPS(),16,16)
end