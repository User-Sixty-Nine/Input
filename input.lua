--------------------   Общий для всех источником ввода код  --------------------
local InputSource = {}

InputSource.keyStates = {}

InputSource.keyPressedStates = {}

function InputSource:isDown(keycode, ...)
    if 
        (self.type == 'gamepad' and 
            (keycode == 'lefttrigger' and self:getLTPos() > 0) or
            (keycode == 'righttrigger' and self:getRTPos() > 0) or
            (keycode ~= 'lefttrigger' and keycode ~= 'righttrigger' and self.source:isGamepadDown(keycode))
        ) or
        (self.type == 'other' and self.source.isDown(keycode))
    then
        self.keyStates[keycode] = true
        return true
    else
        self.keyStates[keycode] = false
    end
    for _, key in ipairs({...}) do
        if self:isDown(key) then
            return true
        end
    end
    return false
end

function InputSource:isPressed(keycode, ...)
    if not self.keyStates[keycode] and self:isDown(keycode) then
        return true
    end
    for _, key in ipairs({...}) do
        if not self.keyStates[keycode] and self:isDown(keycode) then
            return true
        end
    end
    return false
end

function InputSource:isReleased(keycode, ...)
    if self.keyStates[keycode] and not self:isDown(keycode) then
        return true
    end
    for _, key in ipairs({...}) do
        if self.keyStates[keycode] and not self:isDown(keycode) then
            return true
        end
    end
    return false
end

function InputSource:isDownFor(keycode, seconds)
    if self.keyPressedStates[keycode] then
        if self:isReleased(keycode) then
            self.keyPressedStates[keycode] = nil
            return false
        end
        if love.timer.getTime() - self.keyPressedStates[keycode].pressedTime > self.keyPressedStates[keycode].interval then
            self.keyPressedStates[keycode].pressedTime = love.timer.getTime()
            return true
        end
    elseif self:isPressed(keycode) then
        self.keyPressedStates[keycode] = {pressedTime = love.timer.getTime(), interval = seconds, pressed = false}
    end
    return false
end

function InputSource:new(source, type)
    local obj = {}
    for k, v in pairs(self) do
        obj[k] = v
    end
    obj.source = source
    obj.type = type or 'other'
    return obj
end
--------------------------------------------------------------------------------

local Input = {}

Input.keyboard = InputSource:new(love.keyboard)

--------------------                геймпады               --------------------
Input.gamepads = {}
Input.gamepads.defaultSensitivity = 0

function Input.gamepads:isAnyDown(keycode, ...)
    for _, inputSource in ipairs(self.list) do
        if inputSource:isDown(keycode) then
            return true
        end
        for _, key in ipairs({...}) do
            if inputSource:isDown(key) then
                return true
            end
        end
    end
    return false
end

function Input.gamepads:isAnyDownFor(keycode, seconds)
    for _, inputSource in ipairs(self.list) do
        if inputSource:isDownFor(keycode, seconds) then
            return true
        end
    end
    return false
end

function Input.gamepads:isAnyPressed(keycode, ...)
    for _, inputSource in ipairs(self.list) do
        if inputSource:isPressed(keycode, {...}) then
            return true
        end
    end
    return false
end

function Input.gamepads:isAnyReleased(keycode, ...)
    for _, inputSource in ipairs(self.list) do
        if inputSource:isReleased(keycode, {...}) then
            return true
        end
    end
    return false
end

for i, joystick in ipairs(love.joystick.getJoysticks()) do
    if joystick:isGamepad() then
        local gamepad = InputSource:new(joystick, 'gamepad')
        function gamepad:getLTPos() return self.source:getAxis(5) end
        function gamepad:getRTPos() return self.source:getAxis(6) end
        function gamepad:getLSPos() return {x = self.source:getAxis(1), y = self.source:getAxis(2)} end
        function gamepad:getRSPos() return {x = self.source:getAxis(3), y = self.source:getAxis(4)} end
        table.insert(Input.gamepads, gamepad)
    end
end

Input.gamepads.list = Input.gamepads;
--------------------------------------------------------------------------------

--------------------                  мышь                  --------------------
Input.mouse = InputSource:new(love.mouse)
function Input.mouse:update(dt)
    self.wheelMoved = {}
end

local oldFunction = function() end
if love.wheelmoved then
    oldFunction = love.wheelmoved
end
love.wheelmoved = function(dx, dy)
    oldFunction(dx, dy)
    Input.mouse.wheelMoved = {dx=x, dy=y}
end

Input.mouse.defaultSensitivity = 0

function Input.mouse:wheelIsMoved(side)
    -- TODO: настраиваемая чувствительность
    if not self.wheelMoved or (not self.wheelMoved.x and not self.wheelMoved.y) then
        return false
    end
    if not side then
        if self.wheelMoved.y ~= 0 or self.wheelMoved.x ~= 0 then
            return true
        end
    elseif side == 'down' then
        if self.wheelMoved.y < 0 then
            return true
        end
    elseif side == 'up' then
        if self.wheelMoved.y > 0 then
            return true
        end
    elseif side == 'left' then
        if self.wheelMoved.x > 0 then
            return true
        end
    elseif side == 'right' then
        if self.wheelMoved.x < 0 then
            return true
        end
    end
    return false
end

function Input.mouse:isMoved(side, sensitivity)
    if not sensitivity then
        sensitivity = self.defaultSensitivity
    end

    
    local movedy, movedx = false, false
    if self.mousePosition then
        self.mousePositionDelta = {x=self.mousePosition.x - love.mouse.getX(), y=self.mousePosition.y - love.mouse.getY()}
        
        if self.mousePositionDelta.y < -sensitivity then
            self.mousePosition.y = love.mouse.getY()
            movedy = 'down'
        elseif self.mousePositionDelta.y > sensitivity then
            self.mousePosition.y = love.mouse.getY()
            movedy = 'up'
        end
        if self.mousePositionDelta.x > sensitivity then
            self.mousePosition.y = love.mouse.getY()
            movedx = 'left'
        elseif self.mousePositionDelta.x < -sensitivity then
            self.mousePosition.y = love.mouse.getY()
            movedx = 'right'
        end
    else
        self.mousePosition = {x=love.mouse.getX(), y=love.mouse.getY()}
    end

    return (not side) and (movedy or movedx) or (movedx == side or movedy == side)
end
--------------------------------------------------------------------------------

function Input:update(dt)
    self.mouse:update(dt)
end

return Input