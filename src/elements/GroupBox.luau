local Utils = require('../utils/Utils')
local UiUtils = require('../utils/UiUtils')
local Dropdown = require('../inputs/Dropdown')
local GroupBox = {}

function GroupBox.new(options: GroupBoxOptions): GroupBox
  local box = setmetatable({}, { __index = GroupBox })
  local instances = {}

  if type(options.Title) ~= 'string' then
    options.Title = 'No Title'
  end
  if type(options.Collapsible) ~= 'boolean' then
    options.Collapsible = false
  end
  if type(options.Collapsed) ~= 'boolean' then
    options.Collapsed = false
  end

  instances.Outer = Utils:CreateInstance('Frame', {
    BackgroundColor3 = Library.BackgroundColor,
    BorderColor3 = Library.OutlineColor,
    BorderMode = Enum.BorderMode.Inset,
    Size = UDim2.new(1, 0, 0, 18),
    AutomaticSize = Enum.AutomaticSize.Y,
    ZIndex = 2
  })

  instances.Inner = Utils:CreateInstance('Frame', {
    BackgroundColor3 = Library.BackgroundColor,
    BorderColor3 = Color3.new(0, 0, 0),
    Size = UDim2.new(1, -2, 1, -2),
    AutomaticSize = Enum.AutomaticSize.Y,
    Position = UDim2.new(0, 1, 0, 1),
    ZIndex = 4,
    Parent = instances.Outer
  })

  instances.Highlight = Utils:CreateInstance('Frame', {
    BackgroundColor3 = Library.AccentColor,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 2),
    ZIndex = 5,
    Parent = instances.Inner
  })

  instances.Label = UiUtils:CreateLabel({
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 4, 0, 2),
    TextSize = 14,
    Text = options.Title,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
    Parent = instances.Inner
  })

  instances.Container = Utils:CreateInstance('Frame', {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 4, 0, 38),
    Size = UDim2.new(1, -4, 1, -20),
    AutomaticSize = Enum.AutomaticSize.Y,
    ClipsDescendants = true,
    ZIndex = 1,
    Parent = instances.Inner
  })

  instances.ListLayout = Utils:CreateInstance('UIListLayout', {
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = instances.Container
  })

  --- Add a dropdown to the box.
  --- @param options The options for the dropdown
  function box:AddDropdown(options: DropdownOptions): Dropdown
    local dropdown = Dropdown.new(options)
    dropdown.Instances.Container.Parent = instances.Container
    return dropdown
  end

  box.Instances = instances
  return box
end

return GroupBox
