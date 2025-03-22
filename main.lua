function love.load()

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
    player.speed = 2
    player.facing = "right"
    player.cardSpriteSheet = love.graphics.newImage('sprites/Cards.png')
    player.cardGrid = anim8.newGrid(100, 144, player.cardSpriteSheet:getWidth(), player.cardSpriteSheet:getHeight())

    player.spriteSheetRightRun = love.graphics.newImage('sprites/_RunRight.png') --assigning the spritesheet
    player.gridRunRight = anim8.newGrid(48, 48, player.spriteSheetRightRun:getWidth(), player.spriteSheetRightRun:getHeight()) --assigning the grid using the given spritesheet (size of the sprite and size of the canvas)

    player.spriteSheetRunLeft = love.graphics.newImage('sprites/_RunLeft.png')
    player.gridRunLeft = anim8.newGrid(48, 48, player.spriteSheetRunLeft:getWidth(), player.spriteSheetRunLeft:getHeight())
    
    player.spriteSheetIdle = love.graphics.newImage('sprites/_Idle.png')
    player.gridIdle = anim8.newGrid(48, 48, player.spriteSheetIdle:getWidth(), player.spriteSheetIdle:getHeight())

    player.animation = {}

    player.cardAnim = anim8.newAnimation(player.cardGrid('1-15', 4), 2)
    player.animation.runRight = anim8.newAnimation(player.gridRunRight('1-10', 1), 0.075) --setting up animation using the grid and the frames inside the grid with starting index and speed of next frame transition
    player.animation.runLeft = anim8.newAnimation(player.gridRunLeft('1-10', 1), 0.075)
    player.animation.idle = anim8.newAnimation(player.gridIdle('1-10', 1), 0.25)


    player.spriteSheet = player.spriteSheetIdle
    player.anim = player.animation.idle
end

function love.update(dt)
    local isMoving = false

    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed
        player.facing = "right"
        player.spriteSheet = player.spriteSheetRightRun
        player.anim = player.animation.runRight
        isMoving = true
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed
        player.facing = "left"
        player.spriteSheet = player.spriteSheetRunLeft
        player.anim = player.animation.runLeft
        isMoving = true
    end

    if isMoving == false then
        player.spriteSheet = player.spriteSheetIdle
        player.anim = player.animation.idle
    end
    player.anim:update(dt)

    cam:lookAt(player.x, player.y)

    -- Get screen and tilemap dimensions
    local screenW = love.graphics.getWidth()
    local mapW = gamemap.width * gamemap.tilewidth

    -- Adjust camera bounds dynamically
    local minX = mapW - (screenW * 1.5)  -- Leftmost boundary (player should not see outside the map)
    local maxX = mapW - (screenW * -0.70)
    
    if cam.x < minX then
        cam.x = minX
    end

    if cam.x > maxX then
        cam.x = maxX
    end

    -- Make sure the camera stops exactly at the map edges
    --cam.x = math.max(minX, math.min(player.x, maxX))
end

function love.draw()
    cam:attach()
        gamemap:drawLayer(gamemap.layers['Platform'])
        gamemap:drawLayer(gamemap.layers['Trees'])
        gamemap:drawLayer(gamemap.layers['Grass'])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2, nil, 24, 24)
    cam:detach()
end
