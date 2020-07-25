local ui = {}

function ui.csbNode(csb)
    local node = cc.CSLoader:createNode(csb)
    node:setCascadeOpacityEnabled(true)
    return node
end

local Action = {}

function Action.fadeOut(t)
    return cc.FadeOut:create(t)
end

function Action.fadeIn(t)
    return cc.FadeIn:create(t)
end

function Action.delay(t)
    return cc.DelayTime:create(t)
end

function Action.fadeTo(t, p)
    return cc.FadeTo:create(t, p)
end

function Action.tintto(t,color)
    return cc.TintTo:create(t, color[1],color[2],color[3])
end

function Action.scaleTo(t,s1,s2)
    return cc.ScaleTo:create(t,s1,s2)
end

function Action.moveTo(t,x,y)
    return cc.MoveTo:create(t,cc.p(x,y))
end

function Action.moveBy(t,x,y)
    return cc.MoveBy:create(t,cc.p(x,y))
end

function Action.blink(t, n)
    return cc.Blink:create(t, n)
end

function Action.skewBy(t, sx, sy)
    return cc.SkewBy:create(t, sx, sy)
end

function Action.rotateBy(t, r)
    return cc.RotateBy:create(t,r)
end

function Action.rotateTo(t, r)
    return cc.RotateTo:create(t,r)
end

function Action.bezierBy(t,points)
    local config = {}
    config.controlPoint_1 = cc.p(points[1], points[2])
    config.controlPoint_2 = cc.p(points[3], points[4])
    config.endPosition = cc.p(points[5], points[6])
    return cc.BezierBy:create(t, config)
end

function Action.bezierTo(t,points)
    local config = {}
    config.controlPoint_1 = cc.p(points[1], points[2])
    config.controlPoint_2 = cc.p(points[3], points[4])
    config.endPosition = cc.p(points[5], points[6])
    return cc.BezierTo:create(t, config)
end

function Action.remove(cleanup)
    if cleanup==nil then cleanup=true end
    return cc.RemoveSelf:create(cleanup)
end

function Action.hide()
    return cc.Hide:create()
end

function Action.show()
    return cc.Show:create()
end

function Action.call(func)
    return cc.CallFunc:create(func)
end

function Action.easeIn(action, spd)
    return cc.EaseIn:create(Action.action(action), spd)
end

function Action.easeSineIn(action)
    return cc.EaseSineIn:create(Action.action(action))
end

function Action.easeSineOut(action)
    return cc.EaseSineOut:create(Action.action(action))
end

function Action.easeSineIO(action)
    return cc.EaseSineInOut:create(Action.action(action))
end

function Action.easeBackIn(action)
     return cc.EaseBackIn:create(Action.action(action))
end

function Action.easeBackOut(action)
     return cc.EaseBackOut:create(Action.action(action))
end

function Action.easeBackInOut(action)
     return cc.EaseBackInOut:create(Action.action(action))
end

function Action.actionShake(d,ampx,ampy)
    return ActionShake:create(d,ampx,ampy)
end

Action["repeat"] = function (action, num)
    if num and num>0 then
        return cc.Repeat:create(Action.action(action), num)
    else
        return cc.RepeatForever:create(Action.action(action))
    end
end

Action.arepeat = Action["repeat"]

Action.animate = ui.animate

local _action

function Action.sequence(actions)
    local anum = #actions
    if anum==1 then
        return _action(actions[1])
    else
        local array = {}
        for _,action in ipairs(actions) do
            table.insert(array, _action(action))
        end
        return cc.Sequence:create(array)
    end
end

function Action.spawn(actions)
    local anum = #actions
    if anum==1 then
        return _action(actions[1])
    else
        local array = {}
        for _,action in ipairs(actions) do
            table.insert(array, _action(action))
        end
        return cc.Spawn:create(array)
    end
end

function Action.action(action)
    if type(action)=="table" then
        return Action[action[1]](action[2],action[3],action[4])
    elseif type(action)=="string" then
        return Action[action]()
    else
        return action
    end
end
_action = Action.action
local _sequence = Action.sequence

local _dr_settings = {{"delay",1},"remove"}
function Action.dr(t,n)
    if not t or t<=0 or not n then
        return
    end
    local ds = _dr_settings
    ds[1][2] = t
    n:runAction(_sequence(ds))
end

ui.action = Action

return ui