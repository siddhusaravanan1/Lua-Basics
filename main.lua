function love.load()

    wf = require('libraries/windfield')
    world = wf.newWorld(0, 10000)

    camera = require('libraries/camera')
    cam = camera()
    --to import anim8 lib
    anim8 = require('libraries/anim8')

    --to make the filter work properly
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require('libraries/sti')-- to import tileset support
    gamemap = sti('sprites/tileset/tileset.lua')

    --Player Basic Attributes
    player = {}
    player.x = 300
    player.y = 280
    player.speed = 300
    player.jumpSpeed = -1000
    player.facing = "right"
    player.collision = world:newBSGRectangleCollider(300, 240, 40, 75, 10)
    player.collision:setFixedRotation(true)

    player.spriteSheetRightRun = love.graphics.newImage('sprites/_RunRight.png') --assigning the spritesheet
    player.gridRunRight = anim8.newGrid(48, 48, player.spriteSheetRightRun:getWidth(), player.spriteSheetRightRun:getHeight()) --assigning the grid using the given spritesheet (size of the sprite and size of the canvas)

    player.spriteSheetRunLeft = love.graphics.newImage('sprites/_RunLeft.png')
    player.gridRunLeft = anim8.newGrid(48, 48, player.spriteSheetRunLeft:getWidth(), player.spriteSheetRunLeft:getHeight())
    
    player.spriteSheetIdle = love.graphics.newImage('sprites/_Idle.png')
    player.gridIdle = anim8.newGrid(48, 48, player.spriteSheetIdle:getWidth(), player.spriteSheetIdle:getHeight())

    player.animation = {}
    player.animation.runRight = anim8.newAnimation(player.gridRunRight('1-10', 1), 0.075) --setting up animation using the grid and the frames inside the grid with starting index and speed of next frame transition
    player.animation.runLeft = anim8.newAnimation(player.gridRunLeft('1-10', 1), 0.075)
    player.animation.idle = anim8.newAnimation(player.gridIdle('1-10', 1), 0.25)


    player.spriteSheet = player.spriteSheetIdle
    player.anim = player.animation.idle

    Colliders = {}
    if gamemap.layers['Collisions'] then
        for i, obj in pairs(gamemap.layers['Collisions'].objects) do
            local platform = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            platform:setType('static')
            table.insert(Colliders, collider)
        end
    end
end

function love.update(dt)
    local isMoving = false

    local velX = 0
    local velY = 0

    if love.keyboard.isDown("d") then
        velX = player.speed
        player.facing = "right"
        player.spriteSheet = player.spriteSheetRightRun
        player.anim = player.animation.runRight
        isMoving = true
    end
    if love.keyboard.isDown("a") then
        velX = player.speed * -1
        player.facing = "left"
        player.spriteSheet = player.spriteSheetRunLeft
        player.anim = player.animation.runLeft
        isMoving = true
    end

    if isMoving == false then
        player.spriteSheet = player.spriteSheetIdle
        player.anim = player.animation.idle
    end
    player.collision:setLinearVelocity(velX, 0)
    player.anim:update(dt)
    world:update(dt)
    player.x = player.collision:getX()
    player.y = player.collision:getY()

    cam:lookAt(player.x, player.y)

    -- Get screen and tilemap dimensions
    local screenW = love.graphics.getWidth()
    local mapW = gamemap.width * gamemap.tilewidth

    -- Adjust camera bounds dynamically
    local minX = mapW - (screenW * 1.52)  -- Leftmost boundary (player should not see outside the map)
    local maxX = mapW - (screenW * -0.72)
    
    if cam.x < minX then
        cam.x = minX
    end

    if cam.x > maxX then
        cam.x = maxX
    end

    cam.y = player.y + 150
end

function love.draw()
    cam:attach()
        gamemap:drawLayer(gamemap.layers['BG'])
        gamemap:drawLayer(gamemap.layers['BG1'])
        gamemap:drawLayer(gamemap.layers['BG2'])
        gamemap:drawLayer(gamemap.layers['BG3'])
        gamemap:drawLayer(gamemap.layers['BG4'])
        gamemap:drawLayer(gamemap.layers['Platform'])
        gamemap:drawLayer(gamemap.layers['Trees'])
        gamemap:drawLayer(gamemap.layers['Grass'])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2, nil, 24, 24)
        --world:draw()
    cam:detach()
end
