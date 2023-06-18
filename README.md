# Input
Библиотека для love2d, назначение которой - обработка ввода с клавиатуры, мыши и джойстиков.

Перед началом работы убедитесь, что файл библиотеки подключается в main.lua и функция Input.update помещена в конец love.update:
```lua
require 'your/path/to/input'

...

function love.update(dt)
    ...

    Input:update(dt)
end
```
###### **Передавать dt в Input.update не обязательно**, но это стандартная практика для вызова функции обновления состояния в love2d.
<br><br>
## Проверка состояния клавиш
```lua
function love.update(dt)
    if Input.keyboard:isDown('a') then
        print 'key "a" is down'
    end
    if Input.keyboard:isDown('w', 'a', 's', 'd') then
        print 'one of "wasd" keys is down'
    end
    if Input.keyboard:isDownFor('a', 0.75) then
        print 'key "a" is down for 0.75'
    end
    if Input.keyboard:isPressed('a') then
        print 'key "a" is pressed'
    end
    if Input.keyboard:isPressed('w', 'a', 's', 'd') then
        print 'one of "wasd" keys is pressed'
    end
    if Input.keyboard:isReleased('a') then
        print 'key "a" is released'
    end
    if Input.keyboard:isReleased('w', 'a', 's', 'd') then
        print 'one of "wasd" keys is released'
    end
    Input:update(dt)
end
```
Все вышеприведенные функции применимы к мыши и геймпадам (джойстикам), т.е. вы можете использовать, например, Input.mouse:isDown(1) для проверки состояния ЛКМ клавиши.
<br><br>
## Мышь и колесо мыши
```lua
function love.update(dt)
    if Input.mouse:isMoved() then
        print 'mouse has been moved in any direction'
    end
    if Input.mouse:isMoved(nil, 10) then
        print 'mouse has been moved in any direction for more than 10 pixels'
    end
    if Input.mouse:isMoved('down') then
        print 'mouse has been moved down'
    end
    if Input.mouse:isMoved() then
        print 'mouse wheel has been moved in any direction'
    end
    if Input.mouse:wheelIsMoved('down') then
        print 'mouse wheel has been moved down'
    end
    Input:update(dt)
end
```
<br><br>
## Геймпады
Вы можете использовать для геймпадов методы проверки состояния клавиш:
```lua
function love.update(dt)
    if Input.gamepads[1]:isDown('dpup') then
        print 'gamepad 1 button up on dpad is down'
    end
    if Input.gamepads[1]:isDownFor('lefttrigger', 0.25) then
        print 'gamepad left trigger is down for 0.25 seconds'
    end
    -- isPressed and isReleased
    Input:update(dt)
end
```
А также проверить, нажата ли определенная кнопка на любом из джойстиков:
```lua
function love.update(dt)
    if Input.gamepads:isAnyDown(1) then
        print 'button 1 is down on any gamepad'
    end
    if Input.joysticks:isAnyDownFor(1, 0.25) then
        print 'button 1 is down for 0.25 seconds on any joystick'
    end
    -- isAnyPressed and isAnyReleased
    Input:update(dt)
end
```
Вот так можно получить значение стиков и триггеров:
```lua
function love.update(dt)
    print ('left trigger: ' .. Input.gamepads[1]:getLTPos())
    print ('right trigger: ' .. Input.gamepads[1]:getRTPos())

    print ('right stick x: ' .. Input.gamepads[1]:getRSPos().x)
    print ('left stick y: ' .. Input.gamepads[1]:getLSPos().y)

    Input:update(dt)
end
```
