MoveKeys = {[keys.A] = {xD = -1, yD = 0}, [keys.D] = {xD = 1, yD = 0},
			[keys.W] = {xD = 0, yD = -1}, [keys.S] = {xD = 0, yD = 1}}
--Body
body = {xD = 0, yD = 0}

--Snek
Snek = {head = {xD = 0, yD = 0}, body = {}, move = {xD = 1, yD = 0}, comeu = false}

-- Food
Food = {xD = 0, yD = 0}

-- Grid variables 
grid = {}
gridinfo = {xD = 0, yD = 0, width = 0, length = 0}
gridFill = 0
sqrDimensions = {xD = 0, yD = 0}

--time control
time_buff = 0.00001
fps = 5
time_period = 1/fps

--Terminate variable
endthisshit = false

--Variable to hold update function
Update = nil

function body:new(xD, yD)
	t = {}
	setmetatable(t, self)
	self.__index = self
	self.xD = xD
	self.yD = yD 
	return t
end

function recv_input()
	for k,v in pairs(MoveKeys) do
		if(KeyPressed(k)) then
			Snek.move = v
			break
		end
	end
end

function comeu()
	if(Snek.head.xD == Food.xD and
	   Snek.head.yD == Food.yD) then
		Snek.comeu = true
		genFood()
	end
end

function move()
	if(Snek.comeu) then
		local xD = (#Snek.body > 0 and Snek.body[#Snek.body].xD) or Snek.head.xD
		local yD = (#Snek.body > 0 and Snek.body[#Snek.body].yD) or Snek.head.yD
		table.insert(Snek.body, body:new(xD,yD))
		Snek.comeu = false
	elseif(#Snek.body ~= 0) then
		grid[(Snek.body[#Snek.body].xD/sqrDimensions.xD) + ((Snek.body[#Snek.body].yD/sqrDimensions.yD)*gridinfo.xD)] = true
	else
		grid[(Snek.head.xD/sqrDimensions.xD) + ((Snek.head.yD/sqrDimensions.yD)*gridinfo.xD)] = true	
	end
	
	for i = #Snek.body, 2, -1 do
		Snek.body[i].xD = Snek.body[i-1].xD
		Snek.body[i].yD = Snek.body[i-1].yD
	end
	
	if(#Snek.body > 0) then
		Snek.body[1].xD = Snek.head.xD
		Snek.body[1].yD = Snek.head.yD
	end

	Snek.head.xD = (Snek.head.xD + Snek.move.xD)%gridinfo.width
	Snek.head.yD = (Snek.head.yD + Snek.move.yD)%gridinfo.length
	
	local p = (Snek.head.xD/sqrDimensions.xD) + ((Snek.head.yD/sqrDimensions.yD)*gridinfo.xD)
	
	if(grid[p] == false) then
		endthisshit = true
	end
	
	grid[p] = false
end

function print_snek()
	FillRect(Snek.head.xD, Snek.head.yD, sqrDimensions.xD, sqrDimensions.yD, colors.GREEN)
	DrawRect(Snek.head.xD, Snek.head.yD, sqrDimensions.xD, sqrDimensions.yD, colors.WHITE)
	
	for _,v in ipairs(Snek.body) do
		FillRect(v.xD, v.yD, sqrDimensions.xD, sqrDimensions.yD, colors.GREEN)
		DrawRect(v.xD, v.yD, sqrDimensions.xD, sqrDimensions.yD, colors.WHITE)
	end
end

function print_M()
	Clear(colors.MAGENTA)
	FillRect(Food.xD, Food.yD, sqrDimensions.xD, sqrDimensions.yD, colors.RED)
	DrawRect(Food.xD, Food.yD, sqrDimensions.xD, sqrDimensions.yD, colors.BLACK)
	print_snek()
end

function genFood()
	local location = (random(math.randomseed())%(gridFill))
	while(not grid[location]) do
		location = (location + 1)%gridFill
	end

	Food.xD, Food.yD = location%gridinfo.xD, math.floor(location/gridinfo.xD)
	Food.xD = Food.xD*sqrDimensions.xD
	Food.yD = Food.yD*sqrDimensions.yD
end

function terminou()
	if(endthisshit) then
		Update = Update_V2		
	end
end

function Create()
	gridinfo.xD,gridinfo.yD = 16,16
	gridinfo.width = ScreenWidth()
	gridinfo.length= ScreenHeight()

	sqrDimensions.xD = math.floor(gridinfo.width/gridinfo.xD)
	sqrDimensions.yD = math.floor(gridinfo.length/gridinfo.yD)
	gridFill = gridinfo.xD*gridinfo.yD - 1
	 
	for i = 0,gridinfo.xD*gridinfo.yD - 1 do
		grid[i] = true
	end  
	grid[0] = false

	for k,v in pairs(MoveKeys) do
		MoveKeys[k].xD = v.xD*sqrDimensions.xD
		MoveKeys[k].yD = v.yD*sqrDimensions.yD
	end
	Snek.move = MoveKeys[keys.D]

	genFood()
	
	Update = Update_V1
	return true
end

function Update_V1(f)
	recv_input()
	time_buff = time_buff + f
	if(time_buff >= time_period) then
		time_buff = time_buff - time_period
		move()
		print_M()
		comeu()
		terminou()
	end
	return true
end

function Update_V2(f)
	local rp = random(math.randomseed())
	a = math.floor(rp%256)
	b = math.floor((rp/256)%256)
	c = math.floor((rp/(256*256))%256)
	
	Clear(colors.WHITE)
	DrawCentralS(gridinfo.width/2, gridinfo.length/2, "SHITASS", Pixel(a,b,c), 1)
	
	Update = (KeyHold(keys.T) and (function() return false end)) or Update
	return true
end

if(Construct(256,256,1,1)) then
	Start()
end