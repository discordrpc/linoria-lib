local Utils = require('./utils/Utils')
local UiUtils = require('./utils/UiUtils')
local Tab = require('./Tab')
local Window = {}

--- Create a new UI Window.
--- @param options A table of desired options
function Window.new(options: WindowOptions): Window
  local window = setmetatable({}, { __index = Window })
  local instances = {}

  if type(options.Title) ~= 'string' then
    options.Title = 'No Title'
  end
  if type(options.AutoShow) ~= 'boolean' then
    options.AutoShow = true
  end
  if type(options.TabPadding) ~= 'number' then
    options.TabPadding = 0
  end
  if type(options.MenuFadeTime) ~= 'number' then
    options.MenuFadeTime = 0.5
  end
  if typeof(options.Position) ~= 'UDim2' then
    options.Position = UDim2.fromOffset(175, 50)
  end
  if typeof(options.Size) ~= 'UDim2' then
    options.Size = UDim2.fromOffset(550, 600)
  end
  if type(options.Center) ~= 'boolean' then
    options.Center = true
  end
  if typeof(options.AnchorPoint) ~= 'Vector2' then
    options.AnchorPoint = Vector2.zero
  end

  if options.Center then
    options.AnchorPoint = Vector2.new(0.5, 0.5)
    options.Position = UDim2.fromScale(0.5, 0.5)
  end

  instances.Outer = Utils:CreateInstance('Frame', {
    AnchorPoint = options.AnchorPoint,
    BackgroundColor3 = Color3.new(0, 0, 0),
    BorderSizePixel = 0,
    Position = options.Position,
    Size = options.Size,
    Visible = options.AutoShow,
    ZIndex = 1,
    Parent = Library.ScreenGui
  })
  UiUtils:MakeDraggable(instances.Outer)

  instances.Inner = Utils:CreateInstance('Frame', {
    BackgroundColor3 = Library.MainColor,
    BorderColor3 = Library.AccentColor,
    BorderMode = Enum.BorderMode.Inset,
    Position = UDim2.new(0, 1, 0, 1),
    Size = UDim2.new(1, -2, 1, -2),
    ZIndex = 1,
    Parent = instances.Outer
  })

  instances.WindowLabel = UiUtils:CreateLabel({
    Position = UDim2.new(0, 7, 0, 0),
    Size = UDim2.new(0, 0, 0, 25),
    Text = options.Title,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 1,
    Parent = instances.Inner
  })

  instances.MainSectionOuter = Utils:CreateInstance('Frame', {
    BackgroundColor3 = Library.BackgroundColor,
    BorderColor3 = Library.OutlineColor,
    Position = UDim2.new(0, 8, 0, 25),
    Size = UDim2.new(1, -16, 1, -33),
    ZIndex = 1,
    Parent = instances.Inner
  })

  instances.MainSectionInner = Utils:CreateInstance('Frame', {
    BackgroundColor3 = Library.BackgroundColor,
    BorderColor3 = Color3.new(0, 0, 0),
    BorderMode = Enum.BorderMode.Inset,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 1,
    Parent = instances.MainSectionOuter
  })

  instances.TabArea = Utils:CreateInstance('Frame', {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 8),
    Size = UDim2.new(1, -16, 0, 21),
    ZIndex = 1,
    Parent = instances.MainSectionInner
  })

  instances.TabListLayout = Utils:CreateInstance('UIListLayout', {
    Padding = UDim.new(0, options.TabPadding),
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = instances.TabArea
  })

  instances.TabContainer = Utils:CreateInstance('Frame', {
    BackgroundColor3 = Library.MainColor,
    BorderColor3 = Library.OutlineColor,
    Position = UDim2.new(0, 8, 0, 30),
    Size = UDim2.new(1, -16, 1, -38),
    ZIndex = 2,
    Parent = instances.MainSectionInner
  })

  --- Set the window's title.
  --- @param title The new title
  function window:SetTitle(title: string)
    instances.WindowLabel.Text = title
  end

  --- Add a new tab to the window.
  --- @param name The name of the tab
  function window:AddTab(name: string): Tab
    local tab = Tab.new(window, name)
    if #window.Tabs == 1 then
      tab:Show()
    end
    return tab
  end

  window.Instances = instances
  window.Tabs = {}
  return window
end

return Window
