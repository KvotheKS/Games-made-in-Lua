loadfile("auxB.lua")()

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

--all buttons used in main screen
MainButtons = {}

--Config Buttons
ConfigButtons = {}

--Table that holds game configs
Memories = {}
layerStk = 0

--Variable to hold update function	
Update = nil

--Terminate variable
endthisshit = false


--tuned button

SCButton = CButton:new()
SCButton.__index = SCButton

function SCButton:new(fxD, Dimen, name, bkgcol, textcol, key, typef)
		return setmetatable({
		fxD = fxD or 0,
		Dimen = {xD = (Dimen and Dimen.xD) or 0,
			     yD = (Dimen and Dimen.yD) or 0},
		name = name or "",
		bkgcol = bkgcol or colors.WHITE,
		textcol = textcol or colors.BLACK,
		key = key,
		cBuff = false,
		type = typef or 1,
		tBuff = ""
	}, self)
end
	
function SCButton:cBuffCheck(mouse)
	local flag = (not self.cBuff and self:activate(mouse))
	self.cBuff = self.cBuff or (dequeuePBuffer() and flag)
end

function SCButton:analyze()
	local p = (self.type == 1 and keys[self.tBuff] and self.tBuff)
	p = p or (colors[self.tBuff] or tonumber(self.tBuff))
	if(p) then
		self.key = p
	end
	self.tBuff = ""
end

function SCButton:updateSCB(yd)
	local act = ((self.type == 1 and not self.cBuff and (self:printCol(yd)))) or (self:print(yd))
end


function SCButton:updateBuff()
	if(not self.cBuff) then return end
	local scp = dequeuePBuffer()
	for _,v in pairs(scp) do
		if(v == '\n') then
			self:analyze()
			return false
		end
		self.tBuff = self.tBuff .. string.format("%c", v)
	end
	return true
end

function SCButton:print(yD)
	local x = self.fxD - self.Dimen.xD
	local y = yD - self.Dimen.yD
	local lW = math.floor(self.Dimen.xD*0.8)

	FillRect(x,y,lW,self.Dimen.yD*2, self.bkgcol)
	DrawRect(x,y,lW,self.Dimen.yD*2, colors.BLACK)
	
	DrawCentralS(x + math.floor(lW*0.5), yD, self.name, self.textcol, 1)
	DrawCentralS(self.fxD, yD, "-->", self.textcol, 1)

	x = self.fxD + math.floor(self.Dimen.xD*0.2)
	y = yD + self.Dimen.yD
	DrawLine(x, y, x + math.floor(self.Dimen.xD*0.8), y, self.bkgcol)

	x = x + math.floor(self.Dimen.xD*0.4)
	DrawCentralS(x, y - 5, (self.cBuff and self.tBuff) or self.key, self.textcol, 1)	
end

function SCButton:printCol(yd)
	local x = self.fxD - self.Dimen.xD
	local y = yD - self.Dimen.yD
	local lW = math.floor(self.Dimen.xD*0.8)

	FillRect(x,y,lW,self.Dimen.yD*2, self.bkgcol)
	DrawRect(x,y,lW,self.Dimen.yD*2, colors.BLACK)
	
	DrawCentralS(x + math.floor(lW*0.5), yD, self.name, self.textcol, 1)
	DrawCentralS(self.fxD, yD, "-->", self.textcol, 1)

	x = self.fxD + math.floor(self.Dimen.xD*0.2)
	FillRect(x, y, lW, self.Dimen.yD*2, self.key)
	return true
end

--TO-DO ---> config file
function initConfig()
	Memories = {
		["Bkg"] = colors.MAGENTA,
		["Snek"] = colors.GREEN,
		["Food"] = colors.RED,
		["Up"] = "W",
		["Down"] = "S",
		["Left"] = "A",
		["Right"] = "D"
	}
end
--(fxD, Dimen, name, bkgcol, textcol, key, typef)
function initConfigMenu()
	local fxd = {math.floor(gridinfo.width*0.28), math.floor(gridinfo.length*0.72)}
	local Dimen = {xD = math.floor(gridinfo.width*0.22),
				   yD = math.floor(gridinfo.length*0.12)} 
	local i = 0
	for k, v in pairs(Memories) do
		table.insert(ConfigButtons, SCButton:new(fxd[i%2 + 1], Dimen, 
									k,colors.WHITE, colors.BLACK, v, (type(v) == string and 2) or 1))
	end
end


--initializes buttons
function initMB()
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

	local TempB2 = DButton:new({xD = w,yD= h}, {xD = wD, yD = hD}, "Config",
		colors.WHITE, colors.YELLOW, (function() Update = Config end))
	
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

function printSnek()
	FillRect(Snek.head.xD, Snek.head.yD, sqrDimensions.xD, sqrDimensions.yD, colors.GREEN)
	DrawRect(Snek.head.xD, Snek.head.yD, sqrDimensions.xD, sqrDimensions.yD, colors.WHITE)
	
	for _,v in ipairs(Snek.body) do
		FillRect(v.xD, v.yD, sqrDimensions.xD, sqrDimensions.yD, colors.GREEN)
		DrawRect(v.xD, v.yD, sqrDimensions.xD, sqrDimensions.yD, colors.WHITE)
	end
end

function printM()
	Clear(colors.MAGENTA)
	FillRect(Food.xD, Food.yD, sqrDimensions.xD, sqrDimensions.yD, colors.RED)
	DrawRect(Food.xD, Food.yD, sqrDimensions.xD, sqrDimensions.yD, colors.BLACK)
	printSnek()
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

function Config(f)
	
	ConfigButtons[i]:cBuffCheck({xD = GetMouseX(), yD = GetMouseY()})
	ConfigButtons[i]:updateBuff()
	

	Clear(colors.BLACK)
	local ceiling = (layerStk*2) + 6
	local j, yD = 0, math.floor(gridinfo.length*0.12)
	for i = (layerStk*2)+ 1, ceiling do
		if(i > #ConfigButtons) then
			break
		end
		yD = yD + (j ~= 0 and j%2 == 0 and math.floor(gridinfo.length*0.3))
		ConfigButtons[i]:updateSCB(yD)
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
		printM()
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
