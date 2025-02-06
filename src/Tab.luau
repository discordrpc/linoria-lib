local Utils = require('./utils/Utils')
local UiUtils = require('./utils/UiUtils')
local GroupBox = require('./elements/GroupBox')
local Tab = {}

function Tab.new(window: Window, name: string): Tab
  local tab = setmetatable({}, { __index = Tab })
  local instances = {}
  local row: { left: Frame?, right: Frame?, container: Frame? } = {}

  local buttonWidth = UiUtils:GetTextBounds(name, Library.Font, 16)
  instances.Button = UiUtils:CreateButton({
    BackgroundColor3 = Library.BackgroundColor,
    BorderColor3 = Library.OutlineColor,
    Size = UDim2.new(0, buttonWidth.X + 12, 1, 0),
    Text = name,
    ZIndex = 1,
    Parent = window.Instances.TabArea
  })

  instances.Blocker = Utils:CreateInstance('Frame', {
    BackgroundColor3 = Library.MainColor,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundTransparency = 1,
    ZIndex = 3,
    Parent = instances.Button
  })

  instances.TabFrame = Utils:CreateInstance('Frame', {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 1, 0),
    Visible = false,
    ZIndex = 2,
    Parent = window.Instances.TabContainer
  })

  instances.Container = Utils:CreateInstance('ScrollingFrame', {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 1, 0),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 0,
    ZIndex = 2,
    Parent = instances.TabFrame
  })

  instances.ListLayout = Utils:CreateInstance('UIListLayout', {
    Padding = UDim.new(0, 8),
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    Parent = instances.Container
  })

  local listLayout = instances.Container:WaitForChild('UIListLayout')
  listLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
    instances.Container.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y);
  end)

  instances.Button.MouseButton1Click:Connect(function()
    tab:Show()
  end)

  --- Show the tab.
  function tab:Show()
    for _, t in ipairs(window.Tabs) do
      t:Hide()
    end
    instances.Blocker.BackgroundTransparency = 0
    instances.Button.BackgroundColor3 = Library.MainColor
    instances.TabFrame.Visible = true
  end

  --- Hide the tab.
  function tab:Hide()
    instances.Blocker.BackgroundTransparency = 1
    instances.Button.BackgroundColor3 = Library.BackgroundColor
    instances.TabFrame.Visible = false
  end

  --- Check if the tab is selected.
  function tab:IsSelected(): boolean
    return instances.TabFrame.Visible
  end

  --- Add a child to the tab.
  --- @param child The child object to add
  function tab:AddChild(side: Side, child: GuiObject)
    if side ~= 'both' then
      if not row.container then
        row.container = Utils:CreateInstance('Frame', {
          BackgroundTransparency = 1,
          Size = UDim2.new(1, 0, 0, 0),
          AutomaticSize = Enum.AutomaticSize.Y,
          Parent = instances.Container
        })
      end

      if not row[side] then
        local pos, size
        if side == 'left' then
          pos = UDim2.new(0, 0, 0, 0)
          size = UDim2.new(0.5, -2, 0, 0)
        elseif side == 'right' then
          pos = UDim2.new(0.5, 4, 0, 0)
          size = UDim2.new(0.5, -2, 0, 0)
        end

        local frame = Utils:CreateInstance('Frame', {
          BackgroundTransparency = 1,
          Position = pos,
          Size = size,
          Parent = row.container
        })
        Utils:CreateInstance('UIListLayout', {
          Padding = UDim.new(0, 8),
          FillDirection = Enum.FillDirection.Vertical,
          SortOrder = Enum.SortOrder.LayoutOrder,
          Parent = frame
        })
        row[side] = frame
      end

      local frame = row[side]
      child.Parent = frame
      local listLayout = frame:WaitForChild('UIListLayout')
      frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, listLayout.AbsoluteContentSize.Y)
    else
      row = {}
      child.Parent = instances.Container
    end
  end

  --- Add a new groupbox to the tab.
  --- @param side The side to add the groupbox to
  --- @param options The options for the groupbox
  function tab:AddGroupBox(side: Side, options: GroupBoxOptions): GroupBox
    local groupBox = GroupBox.new(options)
    self:AddChild(side, groupBox.Instances.Outer)
    return groupBox
  end

  --- Add a new groupbox to the left side of the tab.
  --- @param options The options for the groupbox
  function tab:AddLeftGroupBox(options: GroupBoxOptions): GroupBox
    return self:AddGroupBox('left', options)
  end

  --- Add a new groupbox to the right side of the tab.
  --- @param options The options for the groupbox
  function tab:AddRightGroupBox(options: GroupBoxOptions): GroupBox
    return self:AddGroupBox('right', options)
  end

  tab.Instances = instances
  table.insert(window.Tabs, tab)
  return tab
end

return Tab
