function love.load()
    math.randomseed(os.time())



    sprites={} --Sprite table 

    sprites.background = love.graphics.newImage('sprites/background.png') --Adding sprites to table 
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {} --player table 
    player.x = love.graphics.getWidth() / 2 -- placing player in the middle of the screen 
    player.y = love.graphics.getHeight() / 2
    player.speed = 300

    myFont = love.graphics.newFont(30)


    zombies = {} -- creating a table of zombies
    bullets = {}

    gameState = 1
    maxTime = 2
    timer = maxTime
    score = 0 

end

function love.update(dt)
    if gameState == 2 then
        if love.keyboard.isDown('d') and player.x < love.graphics.getWidth() - 10 then -- checking if a key is pressed then moveing the player according to a set speed
            player.x = player.x + player.speed*dt
        end
        if love.keyboard.isDown('a') and player.x > 10 then
            player.x = player.x - player.speed*dt
        end
        if love.keyboard.isDown('s') and player.y < love.graphics.getHeight() - 10 then
            player.y = player.y + player.speed*dt
        end
        if love.keyboard.isDown('w')  and player.y > 10 then
            player.y = player.y - player.speed*dt
        end
    end

    for i, z in ipairs(zombies) do 
        z.x = z.x + (math.cos(zombiePlayerAngle(z)) * z.speed * dt )  -- here we are making it so that the zombies walk towards the player 
        z.y = z.y + (math.sin(zombiePlayerAngle(z)) * z.speed * dt )    

        if distanceBetween(z.x,z.y,player.x,player.y)<30 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
                gameState = 1
                player.x = love.graphics.getWidth()/2
                player.y = love.graphics.getHeight()/2
            end
        end
    end

    for i, b in ipairs(bullets) do
        b.x = b.x + (math.cos(b.direction) * b.speed * dt)
        b.y = b.y + (math.sin(b.direction) * b.speed * dt)
    end


    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.y <0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then 
            table.remove(bullets, i)
        end
    end


    for i,z in ipairs(zombies) do
        for j, b in ipairs(bullets) do 
            if distanceBetween(z.x,z.y, b.x, b.y) < 20 then 
                z.dead = true
                b.dead = true
                score = score + 1
            end
        end
    end
    
    for i=#zombies,1,-1 do 
        local z = zombies[i]
        if z.dead == true then 
            table.remove(zombies, i)
        end
    end

    for i=#bullets,1,-1 do 
        local b = bullets[i]
        if b.dead == true then 
            table.remove(bullets, i)
        end
    end

    if gameState == 2 then 
        timer = timer - dt 
        if timer <= 0 then 
            spawnZombie()
            maxTime = 0.95 * maxTime
            timer = maxTime
        end
    end

end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0) -- adding background
    if gameState == 1 then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    end
    love.graphics.printf("Score: ".. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")


    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil,nil,sprites.player:getWidth()/2,sprites.player:getHeight()/2) -- adding player 

    for i, z in ipairs(zombies) do 
        love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), nil, nil,sprites.zombie:getWidth()/2,sprites.zombie:getHeight()/2 )  -- here we are iterating through the zombies tables to draw each zombie
    end

    for i, b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end


end



function playerMouseAngle() -- function to get the mouse angle so we can make the player face the mouse
    return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi -- returning the angle 
end

function zombiePlayerAngle(enemy) -- function to get the player angle so we can make the zombie walk towards them 
    return math.atan2(player.y - enemy.y, player.x - enemy.x) -- returning the angle 
end

function spawnZombie() --Spawn zombie function adds a zombie object to the zombies table so we can have multiple zombies in the game 
    local zombie = {}

    zombie.x = 0
    zombie.y = 0
    zombie.speed = 100
    zombie.dead = false
    local side = math.random(1,4) -- here we are selecting a side on which to spawn the zombies at random 
    
    if side == 1 then  -- if statements to spawn the zombies 
        zombie.x = -30
        zombie.y = math.random (0, love.graphics.getHeight())
    end
    if side == 2 then 
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random (0, love.graphics.getHeight())
    end
    if side == 3 then 
        zombie.y = -30
        zombie.x = math.random (0, love.graphics.getWidth())
    end
    if side == 4 then 
        zombie.y = love.graphics.getHeight() +30
        zombie.x = math.random (0, love.graphics.getWidth())
    end



    table.insert(zombies, zombie)

end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    bullet.direction = playerMouseAngle()
    table.insert(bullets,bullet)
end



function distanceBetween (x,y,x1,y1) --take in 2 x's and y's and return the distance between the 2 


    return math.sqrt((x1-x)^2 + (y1 - y)^2) -- returning the result of calc

end

function love.mousepressed(x,y,button)
    if button == 1 and gameState == 2  then
        spawnBullet()
    elseif button == 1 and gameState == 1 then
        gameState = 2
        maxTime = 2
        score = 0 
    end
end