MoveKeys = {[keys.A] = {xD = -1, yD = 0}, [keys.D] = {xD = 1, yD = 0},
			[keys.W] = {xD = 0, yD = -1}, [keys.S] = {xD = 0, yD = 1}}
--Body
body = {xD = 0, yD = 0}

--Snek
Snek = {head = {xD = 0, yD = 0}, body = {}, move = {xD = 1, yD = 0}, buffer = {},comeu = false}

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

--tuned button
DButton = Button:new()

function DButton:new(fVertex, Dimen, name, bkgcol, textcol, fn)
	tbl = {}  
	setmetatable(tbl, self)
	self.__index = self
	self.fVertex.xD = (fVertex and fVertex.xD) or 0
	self.fVertex.yD = (fVertex and fVertex.yD) or 0

	self.Dimen.xD = (Dimen and Dimen.xD) or 0
	self.Dimen.yD = (Dimen and Dimen.yD) or 0
	self.name = name or ""
	self.bkgcol = bkgcol or colors.WHITE
	self.textcol = textcol or colors.BLACK
	self.fn = fn
	self.times = 0
	return tbl
end

function DButton:DrawCentralized(m)
	m = m or {xD = GetMouseX(), yD = GetMouseY()}
	if(self:is_hovering(m)) then
		if(self.times < 20) then
			self.times = self.times + 1
		end
	else
		self.times = 0
	end 

	local tam = (100-self.times)/100
	local Dx = math.floor(self.Dimen.xD*tam)
	local Dy = math.floor(self.Dimen.yD*tam)
	local x = self.fVertex.xD - Dx
	local y = self.fVertex.yD - Dy
	FillRect(x, y, Dx*2, Dy*2, self.bkgcol)
	DrawRect(x, y, Dx*2, Dy*2, colors.BLACK)
	DrawCentralS(self.fVertex.xD, self.fVertex.yD, self.name, self.textcol, 1)
end

--all buttons used in main screen
MainButtons = {}

--initializes buttons
function init_MB()
	local w = math.floor(gridinfo.width*0.5)
	local h = math.floor(gridinfo.length*0.6)
	local wD = math.floor(gridinfo.width*0.2)
	local hD = math.floor(gridinfo.length*0.2)
	local TempB = DButton:new({xD = w,yD= h},{xD = wD, yD = hD}, "Jogo",
		colors.WHITE, colors.YELLOW, (function() Update = Update_V1 end))
	table.insert(MainButtons, TempB)	
	w = w + wD + math.floor(gridinfo.width*0.15)
	wD = math.floor(gridinfo.width*0.1)
	hD = math.floor(gridinfo.length*0.1)
	
	local TempB2 = DButton:new({xD = w,yD= h},{xD = wD, yD = hD}, "Config",
		colors.WHITE, colors.YELLOW, (function() Update = Config end))
	print(MainButtons[1].name)
	table.insert(MainButtons, TempB2)	
end

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
		if(KeyPressed(k) and
			(Snek.buffer.xD*v.xD == 0) and
			(Snek.buffer.yD*v.yD == 0)) then
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
	Snek.buffer = Snek.move
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
	Update = (endthisshit and (Update_V2)) or Update
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
	init_MB()

	Update = Update_V0
	return true
end

function Update_V0(f)
	Clear(colors.WHITE)
	local w = math.floor(gridinfo.width*0.5)
	local l = math.floor(gridinfo.length*0.3)
	for _,v in pairs(MainButtons) do
		v:DrawCentralized()
		v:activate()

	end
	DrawCentralS(w,l, "COBRINHA", colors.GREEN, 2)
	Update = (KeyPressed(keys.T) and (Update_V1)) or Update
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
