tile = class:new()
color = {}
color[-1] = {200,200,200}
color[0] = {100,100,100}
color[1] = {0,0,255}
color[2] = {100,200,255}
color[3] = {0,255,0}
color[4] = {255,255,0}
color[5] = {255,150,40}
color[6] = {255,0,0}
color[7] = {255,50,150}
color[8] = {180,0,255}
color[9] = {0,0,0}
function tile:init( x, y , size)
	self.x = x
	self.y = y
	self.size = size
	self.covered = true
	self.value = 0
	self.flagged = false
end

function tile:uncover()
	self.covered=false
end

function tile:isCovered()
	return self.covered
end

function tile:isMine()
	return self.value >= 9
end

function tile:setValue(i)
	self.value = i;
end

function tile:getValue()
	return self.value
end

function tile:increment()
	self.value = self.value+1
end

function tile:reset()
	self.value = 0
	self.covered = true
	self.flagged = false
end

function tile:toggleFlag()
	self.flagged = not self.flagged
	return self.flagged
end

function tile:isFlagged()
	return self.flagged
end

function tile:draw()
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", self.x*self.size,self.y*self.size, self.size, self.size)
	love.graphics.setColor(self:getColor())
	love.graphics.rectangle("fill", self.x*self.size+1,self.y*self.size+1, self.size-2, self.size-2)
	if self.value > 0 and not self:isCovered() then
		love.graphics.setColor(0,0,0)
		love.graphics.printf(self.value,self.x*self.size+self.size/2,self.y*self.size+self.size/2-6,0,"center")
	end
	if self:isFlagged() then
		love.graphics.setColor(255,0,0)
		love.graphics.line(self.x*self.size+2,self.y*self.size+2,(self.x+1)*self.size-2,(self.y+1)*self.size-2)
		love.graphics.line(self.x*self.size+2,(self.y+1)*self.size-2,(self.x+1)*self.size-2,self.y*self.size+2)
	end
end

function tile:getColor()
	if self.covered then
		return color[-1]
	else
		return color[self.value]
	end
end