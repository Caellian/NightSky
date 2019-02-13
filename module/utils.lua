function setHasItem(set, item)
  for i,v in ipairs(set) do
    if v == item then
      return true
    end
  end
  return false
end
