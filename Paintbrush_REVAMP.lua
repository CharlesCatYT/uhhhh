local _frames = {[1] = {items = {}, positions = {x = 0, y = 0, mainX = 0, mainY = 0}}}
local curFrame = 1

local curOption = 1
local curSize = 5

local colors = {r = 0, g = 0, b = 0}
local curcolor = '000000'

local spriteUtil = {}
local onColor = false
local selectors = {dar = nil, col = nil, bri = nil}

function spriteUtil.spriteExists(sprite) if type(getProperty(sprite..'.x')) ~= 'string' then return true else return false end end
function spriteUtil.makeGraphic(tag, width, height, hex, x, y, camera)
    x, y, camera = x or 0, y or 0, camera or 'game'
    if not spriteUtil.spriteExists(tag) then
        makeLuaSprite(tag, '', x, y)
    end
    makeGraphic(tag, width, height, hex)
    setObjectCamera(tag, camera)
    addLuaSprite(tag, true)
end
function spriteUtil.draw(x, y, width, height, color)
    if not spriteUtil.spriteExists('Paint'..curFrame..'_'..x..'_'..y..'_'..width..'_'..height..'_'..color) then
        local xf = 'Paint'..curFrame..'_'..x..'_'..y..'_'..width..'_'..height..'_'..color
        spriteUtil.makeGraphic(xf, width, height, color, x, y, 'other')
        setObjectOrder(xf, curFrame+3)
        
        if #_frames[curFrame].items <= 0 then
            _frames[curFrame].positions.mainX = x _frames[curFrame].positions.mainY = y
        end
        table.insert(_frames[curFrame].items, xf)
    end
end
function spriteUtil.tohex(r, g, b)
    local rgb = {r, g, b}
    local hexadecimal = '' -- yeah ignore

    for key, value in pairs(rgb) do
        local hex = ''

        while(value > 0)do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub('0123456789ABCDEF', index, index) .. hex            
        end

        if(string.len(hex) == 0)then
            hex = '00'

        elseif(string.len(hex) == 1)then
            hex = '0' .. hex
        end

        hexadecimal = hexadecimal .. hex
    end

    return hexadecimal
end

local _Groups = {}

function makeGroup(tag, sprites, camera, seperations, ignoreExists, useOldProp)
    ignoreExists = ignoreExists or false
    useOldProp = ignoreExists or false
    _Groups[tag] = {}
    _Groups[tag]['items'] = sprites
    for _, __ in pairs(sprites) do
        if not spriteUtil.spriteExists(__) and not ignoreExists then
            makeLuaSprite(tag..__, __)
            setObjectCamera(tag..__, camera)
            addLuaSprite(tag..__, true)
        end
        if seperations ~= nil then
            _Groups[tag]['seperations'] = seperations
            for q, i in pairs(seperations) do
                setProperty(__..'.'..q, (useOldProp and getProperty(__..'.'..q) or 0)+(_*i))
            end
        end
    end
end

local setProperty, getProperty
function setProperty(obj, value)
    local leObj = {}
    for property in string.gmatch(obj, "([^.]+)") do
        table.insert(leObj, property)
    end
    if _Groups[leObj[1]] == nil then
        getfenv().setProperty(obj, value)
    else
        for _, __ in pairs(_Groups[leObj[1]]['items']) do
            local lep = _Groups[leObj[1]]['seperations'][leObj[2]] ~= nil and _Groups[leObj[1]]['seperations'][leObj[2]] or 0
            getfenv().setProperty(__..obj:gsub(leObj[1], ''), leObj[2] ~= ('visible' or 'color') and value + (lep * _) or value)
        end
    end
end
function getProperty(obj)
    local leObj = {}
    for property in string.gmatch(obj, "([^.]+)") do
        table.insert(leObj, property)
    end
    if _Groups[leObj[1]] == nil then
        return getfenv().getProperty(obj)
    else
        local leReturn = {}
        for _, __ in pairs(_Groups[leObj[1]]['items']) do
            leReturn[__] = getfenv().getProperty(__..obj:gsub(leObj[1], ''))
            return leReturn
        end
    end
end

local function tableThing(tbl, txt)
    local piss = {} for _, __ in pairs(tbl) do piss[_] = __..txt end return piss
end

local function mouseOverlaps(spr, cam)
    local mx, my = getMouseX(cam or 'other'), getMouseY(cam or 'other')
    local x, y, w, h = getProperty(spr .. '.x'), getProperty(spr .. '.y'),
                       getProperty(spr .. '.width'),
                       getProperty(spr .. '.height')
    return mx >= x and mx <= x + w and my >= y and my <= y + h;
end


local mlem = {[1] = 'Paint', [2] = 'Erase', [3] = 'Move', [4] = '+Frame'}
function display()
    setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
    spriteUtil.makeGraphic('__BG__', screenWidth, screenHeight, 'd7d7d7', 0, 0, 'hud')
    spriteUtil.makeGraphic('ToolBox', 100, screenHeight, '200020', screenWidth-100, 0, 'hud')
    spriteUtil.makeGraphic('colorDislloxpcpxo', 100, 100, 'ffffff', 0, 0, 'hud')
    spriteUtil.makeGraphic('__Selector', 80, 30, '0x33ffffff', screenWidth-90, 0, 'other')
    -- spriteUtil.makeGraphic('posi', 80, 30, 'ffffff', 500, 200, 'other')
    -- setProperty('posi.alpha', 0.3)
    -- loadGraphic('posi', 'rdy')

    spriteUtil.makeGraphic('colorGrad', 80, 30, 'ffffff', 7.5, -605, 'other')
    loadGraphic('colorGrad', 'draw/colorGrad')
    scaleObject('colorGrad', 0.8, 1)

    spriteUtil.makeGraphic('darknessGrad', 80, 30, 'ffffff', -605, 7.5, 'other')
    loadGraphic('darknessGrad', 'draw/brightnessGrad')
    scaleObject('darknessGrad', 1, 0.8)

    spriteUtil.makeGraphic('darknessSelector', 3, 100, 'b00fff', 105, 0, 'other')
    spriteUtil.makeGraphic('brightnessSelector', 10, 10, 'b00fff', 110, 105, 'other') -- current
    spriteUtil.makeGraphic('colorSelector', 100, 3, 'ffffff', 0, 105, 'other')

    spriteUtil.makeGraphic('tt', 120, 785, '0x00000000', 7.5, 0, 'other') -- invisible frame
    spriteUtil.makeGraphic('tt2', 685, 80, '0x00000000', 0, 7.5, 'other') -- invisible frame
    spriteUtil.makeGraphic('tt3', 20, 578, '0x00000000', 100, 105, 'other') -- invisible frame

    makeLuaText('frameDisplayer', '< FRAME1 >', 0, screenWidth-97.5, 0)
    setTextSize('frameDisplayer', 15)
    setObjectCamera('frameDisplayer', 'other')
    addLuaText('frameDisplayer')

    for _, __ in pairs(mlem) do
        makeLuaText(__..'__Txt', __, 0, screenWidth-90, 0)
        setTextSize(__..'__Txt', 18)
        setObjectCamera(__..'__Txt', 'other')
        addLuaText(__..'__Txt')
        setProperty(__..'__Txt.x', screenWidth-100+50-getProperty(__..'__Txt.width')/2)
    end
    makeGroup('ToolBoxGrp', tableThing(mlem, '__Txt'), 'other', {y = 45}, true)

    -- loadDrawing('imagedrawing')
end

function onStartCountdown()
    luaDebugMode = true
    display()
    return Function_Stop
end

function table.find(tbl, v)
    for _, __ in pairs(tbl) do if __ == v then return _ end end
end

function string.split(self, split)
    split = split or '%s'
    local t={}
    for str in self:gmatch("([^"..split.."]+)") do table.insert(t, str) end
    return t
end

local function getStuffAt(x, y, distanceX, distanceY)
    for _, __ in pairs(_frames[curFrame].items) do
        local pee = __:split('_')
        pee[2], pee[3] = tonumber(pee[2]), tonumber(pee[3])
        if pee[2] <= x+distanceX and pee[2] >= x-distanceX and pee[3] <= y+distanceY and pee[3] >= y-distanceY then
            return {scX = pee[4], scY = pee[5]}
        end
    end
end

function overlapBySize(sprite, width, height, x, y)
    if spriteUtil.spriteExists(sprite) then
        local x2 = getProperty(sprite..'.x')-_frames[curFrame].positions.x
        local y2 = getProperty(sprite..'.y')-_frames[curFrame].positions.y

        return x2 >= x and x2 <= x + width and y2 >= y and y2 <= y + height
    end
end

 
local function lerp(a, b, ratio)
    return a + ratio * (b - a)
end

local function getFrameWnHByFrame(coco)
    local minP, maxP = {x = screenWidth+100, y = screenHeight+100}, {x = 0, y = 0}
    for _, __ in pairs(_frames[coco].items) do
        if spriteUtil.spriteExists(__) then
            minP.x = math.min(minP.x, getProperty(__..'.x')) minP.y = math.min(minP.y, getProperty(__..'.y'))
            maxP.y = math.max(maxP.y, getProperty(__..'.y')) maxP.x = math.max(maxP.x, getProperty(__..'.x'))
        end
    end
    local width, height = (maxP.x-minP.x)+5, (maxP.y-minP.y)+5
    -- debugPrint(width, ' - ', height)
    return {w = width, h = height}
end

local pie = false

local function dforogjrog()
    if not mouseOverlaps('colorDislloxpcpxo') then
        if not onColor then return true else
            if  not mouseOverlaps('tt') and not mouseOverlaps('tt2') and not mouseOverlaps('tt3') and not mouseOverlaps('brightnessSelector') then
                return true
            else
                return false
            end
        end
    else
        return false
    end
end

function onUpdate(el)
    if mousePressed('left') then
        if dforogjrog() then
            if mlem[curOption] == 'Paint' then
                spriteUtil.draw(getMouseX('other')-_frames[curFrame].positions.x, getMouseY('other')-_frames[curFrame].positions.y, curSize, curSize, curcolor)
            elseif mlem[curOption] == 'Erase' then
                for _, __ in pairs(_frames[curFrame].items) do
                    if overlapBySize(__, curSize, curSize, getMouseX('other')-_frames[curFrame].positions.x, getMouseY('other')-_frames[curFrame].positions.y) then
                        removeLuaSprite(__)
                        _frames[curFrame].items[_] = nil
                        -- table.remove(_frames[curFrame].items, table.find(_frames[curFrame].items, __))
                    end
                end
            elseif mlem[curOption] == 'Move' then
                _frames[curFrame].positions.x = getMouseX('other')-_frames[curFrame].positions.mainX 
                _frames[curFrame].positions.y = getMouseY('other')-_frames[curFrame].positions.mainY
            end
        end
        if mouseOverlaps('colorGrad', 'other') then setProperty('colorSelector.y', getMouseY 'other') end
        if mouseOverlaps('darknessGrad', 'other') then setProperty('darknessSelector.x', getMouseX 'other') end
        if mouseOverlaps('tt3', 'other') and mouseOverlaps('tt', 'other') then setProperty('brightnessSelector.y', getMouseY 'other') end
    end

    if mouseClicked('left') then
        if mouseOverlaps('colorDislloxpcpxo', 'other') then onColor = not onColor end
    end

    if keyboardPressed('CTRL') and keyboardPressed('SHIFT')  then
        if keyboardJustPressed('S') then
            saveDrawing('PNG')
            -- saveDrawing('TEXT') -- l8er bby
            debugPrint('Saved!')
        end
    end

    if pie then
        local pixelcolor = getPixelColor('colorGrad', getProperty('colorSelector.x')-(getProperty('colorGrad.x'))+getProperty('colorSelector.width')/2, getProperty('colorSelector.y')-(getProperty('colorGrad.y'))+getProperty('colorSelector.height')/2)
        
        local darknessLevel = (getProperty('darknessSelector.x')-105)/getProperty('darknessGrad.width')
        local brightnessLevel = (getProperty('brightnessSelector.y')-105)/getProperty('colorGrad.height')

        local rgb = intToRgb(pixelcolor)
        local rgb2 = colorDarken(rgb.R, rgb.G, rgb.B, darknessLevel+brightnessLevel)

        local rgb3 = colorDarken(rgb.R, rgb.G, rgb.B, brightnessLevel+1)
        setProperty('darknessGrad.color', getColorFromHex(spriteUtil.tohex(rgb3.R, rgb3.G, rgb3.B)))

        curcolor = spriteUtil.tohex(rgb2.R, rgb2.G, rgb2.B)
        -- debugPrint(brightnessLevel, ' ', colorLightning(rgb.R, rgb.G, rgb.B, brightnessLevel), ' ', curcolor)
    end

    setProperty('colorDislloxpcpxo.color', getColorFromHex(curcolor))

    if keyboardJustPressed('N') then
        changeOption(-1)
    elseif keyboardJustPressed('DOWN') then
        changeOption(1)
    end

    if keyboardPressed('I') then
        curSize =  curSize + 1
    elseif keyboardPressed('O') then
        curSize = math.abs(curSize - 1)
    end

    if keyboardJustPressed('LEFT') then
        changeFrame(-1)
    elseif keyboardJustPressed('RIGHT') then 
        changeFrame(1)
    end

    setTextString('frameDisplayer', '< Frame'..curFrame..' >')

    if keyboardJustPressed('ENTER') then
        if mlem[curOption] == '+Frame' then
            table.insert(_frames, {items = {}, positions = {x = 0, y = 0}})
        end
    end
    
    -- if keyboardJustPressed('E') then
    --     setProperty('posi.visible', not getProperty('posi.visible')) end
    for _, __ in pairs(mlem) do
        if curOption == _ then
            setProperty(__..'__Txt.alpha', lerp(getProperty(__..'__Txt.alpha'), 1, el*5))
        else
            setProperty(__..'__Txt.alpha', lerp(getProperty(__..'__Txt.alpha'), 0.6, el*5))
        end
    end

    setProperty('__Selector.y', lerp(getProperty('__Selector.y'), getProperty(mlem[curOption]..'__Txt.y')+getProperty(mlem[curOption]..'__Txt.height')/2-getProperty('__Selector.height')/2, el*10))
    
    if onColor then
        --y:105, x:7.5
        setProperty('colorGrad.y', lerp(getProperty('colorGrad.y'), 105, el*5))
        setProperty('darknessGrad.x', lerp(getProperty('darknessGrad.x'), 105, el*5))

        if getProperty('darknessGrad.x') >= 104 and getProperty('colorGrad.y') >= 104 then pie = true end
        if not pie then
            setProperty('darknessSelector.x', selectors.dar or (105+getProperty('darknessGrad.width')))
            setProperty('brightnessSelector.x', selectors.bri or 105)
            setProperty('colorSelector.y', selectors.col or 105)
        else
            selectors.col = getProperty('colorSelector.y')
            selectors.dar = getProperty('darknessSelector.x')
            selectors.bri = getProperty('brightnessSelector.x')
        end
    else
        setProperty('colorGrad.y', lerp(getProperty('colorGrad.y'), -605, el*5))
        setProperty('darknessGrad.x', lerp(getProperty('darknessGrad.x'), -605, el*5))
        setProperty('darknessSelector.x', -100)
        setProperty('colorSelector.y', -100)
        setProperty('brightnessSelector.x', -100)
        pie = false
    end
    for _, __ in pairs(_frames[curFrame].items) do
        local boing = __:split('_')
        -- debugPrint(boing)
        setProperty(__..'.x', _frames[curFrame].positions.x+boing[2])
        setProperty(__..'.y', _frames[curFrame].positions.y+boing[3])
    end
end

function changeOption(who)
    curOption = curOption+who
    if curOption < 1 then
        curOption = #mlem
    elseif curOption > #mlem then
        curOption = 1
    end
end

function changeFrame(who)
    curFrame = curFrame+who
    if curFrame < 1 then
        curFrame = #_frames
    elseif curFrame > #_frames then
        curFrame = 1
    end
end

function saveDrawing(imageType)
    imageType = imageType or 'PNG'
    local maxframeShit = {w = 0, h = 0}
    if imageType:upper() == 'PNG' then
        -- for frm = 1, #_frames do
        --     maxframeShit.w = math.max(maxframeShit.w, getFrameWnHByFrame(frm).w)
        --     maxframeShit.h = math.max(maxframeShit.h, getFrameWnHByFrame(frm).h)
        -- end
        addHaxeLibrary('File', 'sys.io')
        runHaxeCode('sprite = new FlxSprite(0, 0).makeGraphic(FlxG.width+5, FlxG.height+5, 0x00000000);')

        for frm = 1, #_frames do
            for _, __ in pairs(_frames[frm].items) do
                local pee = __:split('_')
                local x, y, w, h, c = pee[2], pee[3], pee[4], pee[5], pee[6]
                runHaxeCode(
                    'var gliss'.._..' = new FlxSprite('..x..', '..y..').makeGraphic('..w..', '..h..', 0xFF'..c..');\n'.. -- didnt want to use game.getLuaObject cause yes ok
                    'sprite.stamp(gliss'.._..', '..x..', '..y..');'
                )
            end
        end

        runHaxeCode(
        [[
            var pixelsData = sprite.pixels.image.encode();
            //game.addTextToDebug(pixelsData == null, 0xFFffffff);
            File.saveBytes("LUADrawing.png", pixelsData);
        ]])
    elseif imageType:upper() == 'TEXT' then
        local contString = ''
        for frame = 1, #_frames do
            for _, __ in pairs(_frames[frame].items) do
                contString = contString..__..'\n'
            end
        end
        saveFile('imagedrawing.txt', contString)
    end
end

function loadDrawing(drawing)
    local pee = getTextFromFile(drawing..'.txt'):split('\n')
    for _, __ in pairs(pee) do
        local piss = __:split('_')
        local f, x, y, w, h, c = tonumber((piss[1]:gsub('Paint', ''))), tonumber(piss[2]), tonumber(piss[3]), tonumber(piss[4]), tonumber(piss[5]), piss[6]
        if _frames[f] == nil then
            _frames[f] = {items = {}, positions = {x = 0, y = 0, mainX = 0, mainY = 0}}
        end 
        table.insert(_frames[f].items, _, __)
        spriteUtil.draw(x, y, w, h, c)
    end
end

-- oi time to use some code from my stage editor

function intToHex(int) return string.format("%06x", bit.band(0xFFFFFF, int)) end
function intToRgb(int) return { R = bit.band(bit.rshift(int, 16), 0xff), G = bit.band(bit.rshift(int, 8), 0xff), B = bit.band((int), 0xff) } end
function colorDarken(r, g, b, x)
    x = math.floor((x*255))-255
    return {R = math.max(math.min(255, r+x), 0), G = math.max(math.min(255, g+x), 0), B = math.max(math.min(255, b+x), 0)}
end
