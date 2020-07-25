module("TableUtil", package.seeall)

local CardLogic = require("shisanzhanglq.CardLogic")

function getRankByScore(scores, ascend)
	local ranks = {}

	local temp = {}
	for k, v in pairs(scores) do
		table.insert(temp, {k, v})
	end

	table.sort(temp, function(c1, c2)
		if ascend then
			return c1[2]<c2[2]
		else
			return c1[2]>c2[2]
		end
	end)

	for i, v in ipairs(temp) do
		ranks[v[1]] = i
	end

	return ranks
end

function getRankByPX(managerList, ascend)
	local ranks = {}

	local temp = {}

	for k, v in pairs(managerList) do
		table.insert(temp, {k, v})
	end

	table.sort(temp, function(c1, c2)
		local bResult = CardLogic.DunCompare(c1[2], c2[2])
		if ascend then
			return bResult==0xff
		else
			return bResult==1
		end
	end)

	for i, v in ipairs(temp) do
		ranks[v[1]] = i
	end

	return ranks
end
