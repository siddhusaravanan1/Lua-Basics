function love.load()
    --to import anim8 lib
    anim8 = require('anim8')

    --to make the filter work properly
    love.graphics.setDefaultFilter("nearest", "nearest")

    --Player Basic Attributes
    player = {}
    player.x = 10
    player.y = 10
    player.speed = 1
    player.facing = "right"
    player.cardSpriteSheet = love.graphics.newImage('sprites/Cards.png')
    player.cardGrid = anim8.newGrid(100, 144, player.cardSpriteSheet:getWidth(), player.cardSpriteSheet:getHeight())

    player.spriteSheetRun = love.graphics.newImage('sprites/_Run.png') --assigning the spritesheet
    player.gridRun = anim8.newGrid(32, 48, player.spriteSheetRun:getWidth(), player.spriteSheetRun:getHeight()) --assigning the grid using the given spritesheet (size of the sprite and size of the canvas)
    
    player.spriteSheetIdle = love.graphics.newImage('sprites/_Idle.png')
    player.gridIdle = anim8.newGrid(32, 48, player.spriteSheetIdle:getWidth(), player.spriteSheetIdle:getHeight())

    player.animation = {}

    player.cardAnim = anim8.newAnimation(player.cardGrid('1-15', 4), 2)
    player.animation.run = anim8.newAnimation(player.gridRun('1-10', 1), 0.075) --setting up animation using the grid and the frames inside the grid with starting index and speed of next frame transition
    player.animation.idle = anim8.newAnimation(player.gridIdle('1-10', 1), 0.25)


    player.spriteSheet = player.spriteSheetIdle
    player.anim = player.animation.idle
end

function love.update(dt)
    local isMoving = false

    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed
        player.facing = "right"
        player.spriteSheet = player.spriteSheetRun
        player.anim = player.animation.run
        isMoving = true
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed
        player.facing = "left"
        player.spriteSheet = player.spriteSheetRun
        player.anim = player.animation.run
        isMoving = true
    end

    if isMoving == false then
        player.spriteSheet = player.spriteSheetIdle
        player.anim = player.animation.idle
    end
    player.anim:update(dt)
end

function love.draw()
    local scaleX = (player.facing == "left") and -4 or 4
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, scaleX, 4, 32, 0)
    --player.anim:draw(player.cardSpriteSheet, player.x, player.y)
end
