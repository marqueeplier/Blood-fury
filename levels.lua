levels = {}

function levels:load()
	self.lvls = {}
	self.no_of_walls = 0
	self.player_off = { {(screenWidth - player.width) / 2, screenHeight - 100},
						{((screenWidth - player.width) / 2) + 200, screenHeight - 100}
				   	   }
	self.current_level = 2
	self.level_spawn = true
	self.walls_img = love.graphics.newImage("assets/maps/walls.png")
end

function levels:update(dt)
	levels:collide()
	levels:create_levels(self.current_level)
	levels:level_change(dt)
end

function levels:draw()
	love.graphics.setColor(255, 255, 255)
	for i, l in pairs(self.lvls) do 
		
		if l.img then 
			love.graphics.draw(self.walls_img, l.img, l.x, l.y)
		end
		love.graphics.setColor(255, 100, 100)
		love.graphics.rectangle("line", l.x, l.y, l.width, l.height)
	end
end

function levels:collide()
	for i1, e in pairs(enemy.enemies) do 
		for i2, b in pairs(e.bullets) do 
			for i3, l in pairs(self.lvls) do 
				if CheckCollisions(b, l) then 
					table.remove(e.bullets, i2)
				end	
			end
		end
	end

	for i1, b in pairs(player.bullets) do 
		for i2, l in pairs(self.lvls) do 
			if CheckCollisions(b, l) then 
				table.remove(player.bullets, i1)
			end	
		end
	end
end

function levels:create(x, y, w, h, img)
	self.no_of_walls = self.no_of_walls + 1
	
	lvl = {}
	lvl.x = x
	lvl.y = y
	lvl.width = w
	lvl.height = h
	lvl.img = img or nil

	table.insert(self.lvls, lvl)
end

function levels:remove(dt)
	for i, l in ipairs(self.lvls) do 
		for r = 0, self.no_of_walls, dt do 
			table.remove(self.lvls, r)
		end
	end
end

function level_1()
--horizontal
	levels:player_offset()
	levels:create(0, 0, 800, 20, love.graphics.newQuad(0, 0, 800, 20, levels.walls_img:getDimensions()))
	levels:create(0, 0, 500 ,20, love.graphics.newQuad(0, 0, 500, 20, levels.walls_img:getDimensions()))
--vertical 
	levels:create(0, 300, 400, 20, love.graphics.newQuad(0, 0, 400, 20, levels.walls_img:getDimensions()))
	levels:create(0, 450, 500, 20, love.graphics.newQuad(0, 0, 500, 20, levels.walls_img:getDimensions()))
end

function level_2()
	levels:player_offset()
	levels:create(0, 100, 250, 20, love.graphics.newQuad(0, 0, 250, 20, levels.walls_img:getDimensions()))
	levels:create(250, 100, 20 , 150, love.graphics.newQuad(0, 0, 20, 150, levels.walls_img:getDimensions()))
	levels:create(250, 250, 250, 20, love.graphics.newQuad(0, 0, 250, 20, levels.walls_img:getDimensions()))
	levels:create(600, 250, 250 ,20, love.graphics.newQuad(0, 0, 250, 20, levels.walls_img:getDimensions()))
	levels:create(350, 350, 20, 100, love.graphics.newQuad(0, 0, 20, 100, levels.walls_img:getDimensions()))
	levels:create(0, 450, 450 ,20, love.graphics.newQuad(0, 0, 450, 20, levels.walls_img:getDimensions()))
	levels:create(550, 450, 300, 20, love.graphics.newQuad(0, 0, 300, 20, levels.walls_img:getDimensions()))
end

function levels:player_offset()
	player.x = self.player_off[self.current_level][1]
	player.y = self.player_off[self.current_level][2]
end

function levels:level_change(dt)
	if #enemy.enemies == 0 and player.currrent_state ~= player.states.death then
		if arrow then 
			if CheckCollisions(player, arrow) then 
				self.current_level = self.current_level + 1
				self.level_spawn = true
				levels:remove(dt)
			end
		end
	end

	next_lvl()
end

function levels:create_levels(current_lvl)
	if (current_lvl == 1 and self.level_spawn == true) then
		self.level_spawn = false
		level_1()
		enemy:spawner(50, 150, enemy.enemy_imgs[1])
		enemy:spawner(200, 150, enemy.enemy_imgs[2])
		enemy:spawner(500, 100, enemy.enemy_imgs[3])
	end

	if current_lvl == 2 and self.level_spawn == true then
		self.level_spawn = false 
		self.no_of_walls = 0
		level_2()
		enemy:spawner(50, 50, enemy.enemy_imgs[3])
		enemy:spawner(50, 150, enemy.enemy_imgs[1])
		enemy:spawner(70, 350, enemy.enemy_imgs[2])
		enemy:spawner(700, 350, enemy.enemy_imgs[3])
		enemy:spawner(600, 100, enemy.enemy_imgs[3])
	end	
end

function next_lvl()
	if #enemy.enemies == 0 then 
		arrow = {x = (screenWidth - 64) / 2, y = (screenHeight - 64) / 2 + 200, width = 64, height = 64}
	else
		arrow = nil
	end
end