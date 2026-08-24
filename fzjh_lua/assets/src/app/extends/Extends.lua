--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-06-12 18:04:31
--]]
local extends =
{
	"tableEx",
	"StringEx",
	"NodeEx",
	"MathEx",

	-- ui控件
	"WidgetEx",
	"LoadingBarEx",
	"RichTextEx",
	"YXSkeletonAnimationEx",
	"ExtPageView",
	"TextEx",
	"EditBoxEx",
	"TableViewEx",
	"ExtListView",
}

for i,v in ipairs(extends) do
	require("app.extends."..v)
end
000000000