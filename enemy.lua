enemy = {}

function enemy:load()
	self.enemies = {}
	self.enemy_imgs = { love.graphics.newImage("assets/enemy/enemy-pistol_d.png"),
  						love.graphics.newImage("assets/enemy/enemy-uzi_s.png"),
  						love.graphics.newImage("assets/enemy/enemy-uzi_d.png")
					   }
	self.enemy_walk = love.graphics.newImage("assets/enemy/enemy-walk-spr.png")
	self.enemy_death = love.graphics.newImage("assets/enemy/enemy-death-spr.png")
	self.arrow_img = love.graphics.newImage("assets/enemy/arrow.png")
	self.dropped_weapons = {}
end

function enemy:update(dt)
-- enemy bullets	
	enemy:bullet_add(dt)
	enemy:bullet_u(dt)
	enemy:bullet_dissp(dt)
-- animations
	enemy:walk_animations(dt)
	enemy:death_animations(dt)
-- levels
	enemy:remove(dt)
end

function enemy:draw()
	love.graphics.setColor(255, 255, 255)
-- enemy
	for i, e in pairs(self.enemies) do 
		if e.current_state ~= e.states.death then
			love.graphics.rectangle("fill", e.x, e.y, 64, 64, e.rotation, 1, 1, 32, 32) 
			love.graphics.draw(self.enemy_walk, e.current_walk, e.x + 32, e.y + 32, e.rotation, 1, 1, 32, 32)
			love.graphics.draw(e.img, e.x + 32, e.y + 32, e.rotation, 1, 1, 32, 32)
			
		else
			love.graphics.draw(self.enemy_death, e.current_death, e.x + 32, e.y + 32, e.rotation, 1, 1, 32, 32)
		end
	end
-- enemy bullets
	for i1, e in pairs(self.enemies) do 
		for i2, b in pairs(e.bullets) do 
			love.graphics.draw(_bullets, b.x, b.y, e.rotation, 1, 1, 32, 32)
		end
	end
	enemy:drop_weapon_d()
-- level 
	if arrow then 
		love.graphics.draw(self.arrow_img, arrow.x, arrow.y)
	end
end

function enemy:spawner(x, y, enemy_img)
	local curr_lvl = self.current_level
	enem = {}
	enem.x = x
	enem.y = y
	enem.width = 64
	enem.height = 64
	enem.states = {walk = "walk",
				   attack = "attack", 
				   death = "death"}
	enem.current_state = enem.states.walk
	enem.img = enemy_img
	enem.walk_xoff = 0
	enem.death_xoff = 0
	enem.current_walk = love.graphics.newQuad(enem.walk_xoff, 0, 64, 64, self.enemy_walk:getDimensions())
	enem.current_death = love.graphics.newQuad(enem.death_xoff, 0, 64, 64, self.enemy_death:getDimensions())
	enem.fps = 5
	enem.anim_timer = 1 / enem.fps
	enem.rotation = math.atan2( player.x - enem.x, enem.y - player.y ) - math.pi / 2
	enem.bullets = {} 
	enem.bullet_timer = 25
	enem.bullet_speed = 250
	enem.bullet_add_t = 50
	enem.remove_timr = 100
	enem.remove_t = 0
	enem.gun_dropped = false

	table.insert(self.enemies, enem)
end

function enemy:walk_animations(dt)
	for i, e in pairs(self.enemies) do 
		e.anim_timer = e.anim_timer - dt

		if e.current_state == e.states.walk then
			if e.anim_timer <= 0 then
				e.anim_timer = 1 / e.fps
				e.walk_xoff = e.walk_xoff + 64
			
				if e.walk_xoff >= 320 then
					e.walk_xoff = 0
				end
		
				e.current_walk = love.graphics.newQuad(e.walk_xoff, 0, 64, 64, 
													self.enemy_walk:getDimensions())
			end 
		end

		if e.current_state ~= e.states.death then 
			e.rotation = math.atan2( player.x - e.x, e.y - player.y ) - math.pi / 2
		end
	end
end

function enemy:death_animations(dt)
	for i, e in pairs(self.enemies) do 
		e.anim_timer = e.anim_timer - dt

		if e.current_state == e.states.death then
			if e.anim_timer <= 0 then
				e.anim_timer = 1 / e.fps
				e.death_xoff = e.death_xoff + 64
			
				if e.death_xoff >= self.enemy_death:getWidth() then
					e.death_xoff = 448
				end
		
				e.current_death = love.graphics.newQuad(e.death_xoff, 0, 64, 64, 
													self.enemy_death:getDimensions())
			end 
		end
	end
end

function enemy:bullet_add(dt)
	for i, e in pairs(self.enemies) do 
		e.bullet_timer = e.bullet_timer - e.bullet_add_t * dt
	
		if e.bullet_timer <= 0 and e.current_state ~= e.states.death 
			and player.current_state ~= player.states.death then 
			
			love.audio.play(player.gun_sounds[1])
			e.bullet_timer = 25
			local startX = e.x + e.width / 2
			local startY = e.y + e.height / 2
			local mouseX = player.x
			local mouseY = player.y		

			local angle = math.atan2(mouseY - startY, mouseX - startX)

			local bulletDx = e.bullet_speed * math.cos(angle)
			local bulletDy = e.bullet_speed * math.sin(angle)

			table.insert(e.bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy, timer = 100, br_timer = 0, width = 5, height =5})
		end
	end
end

function enemy:bullet_u(dt)
	for i1, e in pairs(self.enemies) do 
		for i2, b in pairs(e.bullets) do 
			b.x = b.x + (b.dx * dt)
			b.y = b.y + (b.dy * dt)
		end
	end
end

function enemy:bullet_dissp(dt)
	for i1, e in pairs(self.enemies) do 
		for i2, b in pairs(e.bullets) do 
			b.timer = b.timer - 100 * dt

			if b.timer <= 0 then 
				b.br_timer = b.br_timer + 1
			end

			if b.br_timer >= 10 or player.current_state == player.states.death then 
				b.br_timer = 0
				table.remove(e.bullets, i2)
			end
		end
	end
end

function enemy:remove(dt)
	for i1, e in pairs(self.enemies) do 
		if e.current_state == e.states.death then

			if player.current_state == player.states.death then 
				e.current_state = e.states.walk
			end 

			e.remove_timr = e.remove_timr - 100 * dt

			if e.remove_timr <= 0 then 
				e.remove_timr = 100
				e.remove_t = e.remove_t + 1
			end 	

			if e.remove_t >= 5 then 
				table.remove(self.enemies, i1)
				table.remove(self.dropped_weapons, i1)
			end 	
		end
	end
end

function enemy:drop_weapon_u()
	for i, e in pairs(self.enemies) do
		local random_gun = math.random(1, #player.gun_table)
		
		gun = {} 
		gun.x =	player.gun_table[random_gun].x + e.x
		gun.y = player.gun_table[random_gun].y + e.y
		gun.width = 64
		gun.height = 64
		gun.img = player.gun_table[random_gun].img
		gun.index = random_gun
		gun.rotation = e.rotation
		gun.bullets = player.gun_table[random_gun].bullets
		gun.total = player.gun_table[random_gun].total

		if e.current_state == e.states.death and e.gun_dropped == false then 
		  	e.gun_dropped = true 
		  	table.insert(self.dropped_weapons, gun)
		end
	end
end

function enemy:drop_weapon_d()
	love.graphics.setColor(255, 255, 255)
	for i, g in pairs(self.dropped_weapons) do
		if g then
			love.graphics.rectangle("fill", g.x, g.x, 64, 64, g.rotation)
			love.graphics.draw(g.img, g.x, g.y, g.rotation)
		end	
	end
end