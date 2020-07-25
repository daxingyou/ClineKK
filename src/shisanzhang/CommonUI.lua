module("UI", package.seeall)

-- 注册一个计时label
function registerTimerLabel(label, startTime, endTime)
    if not label.setString then
        assert(false, "not label!")
    end

    label:setString(startTime)
    label:setTag(startTime)

    local function update()
        local time = label:getTag()
        time = (startTime>endTime and time-1 or time+1)

        label:setString(time)
        label:setTag(time)
        if time==endTime then
            label:unschedule(update)
        end
	end

	function label:stopTimer()
		label:unschedule(update)
	end

	label:schedule(update, 1)
	
end