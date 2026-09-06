local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Nodekit = require(ReplicatedStorage.Packages.Nodekit)

local Node = Nodekit.Node

local FlippableImage = Node:inherit()

export type Image = {
  image: string,
  width: number,
  height: number
}

local function updateImageRect(self)
  local instance = self:getRblxInstance()

  local imageSize = Vector2.new(self._width, self._height)
  local flipX = self._flipX and 1 or 0
  local flipY = self._flipY and 1 or 0
  local imageRectOffset = self._rectOffset

  instance.ImageRectOffset = imageRectOffset + imageSize * Vector2.new(flipX, flipY)
  instance.ImageRectSize = imageSize * Vector2.new(-(flipX - 0.5) * 2, -(flipY - 0.5) * 2)
end

function FlippableImage:create(image: Image?)
  local inst = setmetatable(Node.Image:create(image and image.image), FlippableImage)
  
  inst._width = image and image.width or 0
  inst._height = image and image.height or 0
  inst._flipX = false
  inst._flipY = false
  inst._rectOffset = Vector2.zero
  inst:setType("FlippableImage")

  updateImageRect(inst)

  return inst
end

function FlippableImage:setImage(image: Image?)
  if image == nil or (typeof(image) == "table" and typeof(image.image) == "string" and typeof(image.width) == "number" and typeof(image.height) == "number") then
    local instance = self:getRblxInstance()
    instance.Image = image and image.image or ""
    self._width = image and image.width or 0
    self._height = image and image.height or 0
  end
  return self
end

function FlippableImage:setFlipX(flipX: boolean)
  if typeof(flipX) == "boolean" then
    self._flipX = flipX
    updateImageRect(self)
  end
  return self
end

function FlippableImage:setFlipY(flipY: boolean)
  if typeof(flipY) == "boolean" then
    self._flipY = flipY
    updateImageRect(self)
  end
  return self
end

function FlippableImage:setImageRectOffset(imageRectOffset: Vector2)
  if typeof(imageRectOffset) == "Vector2" then
    self._rectOffset = imageRectOffset
    updateImageRect(self)
  end
  return self
end

function FlippableImage:setImageRectSize(imageRectSize: Vector2) -- Handled internally, should not be used
  return self
end

return FlippableImage
