local Window = require('./Window')
local Library = {
  ScreenGui = Instance.new('ScreenGui'),
  MainColor = Color3.fromRGB(28, 28, 28),
  BackgroundColor = Color3.fromRGB(20, 20, 20),
  AccentColor = Color3.fromRGB(0, 85, 255),
  OutlineColor = Color3.fromRGB(50, 50, 50),
  RiskColor = Color3.fromRGB(255, 50, 50),
  Black = Color3.new(0, 0, 0),
  FontColor = Color3.fromRGB(255, 255, 255),
  Font = Enum.Font.Code
}

getgenv().Library = Library
Library.ScreenGui.Parent = game:GetService('CoreGui')

--- Create a new window.
---@param options The desired options to apply to the window
function Library:CreateWindow(options: WindowOptions): Window
  return Window.new(options)
end

return Library
