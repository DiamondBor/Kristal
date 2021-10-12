local ModList, super = newClass(Object)

function ModList:init(x, y, width, height)
    super:init(self, x, y, width, height)

    self.ui_move = love.audio.newSource("assets/sounds/ui_move.wav", "static")

    self.scroll = 0
    self.scroll_target = 0

    self.mod_container = Object()
    self:add(self.mod_container)

    self.mod_list_height = 0

    self.mods = {}
    self.selected = 0
end

function ModList:getSelected()
    return self.mods[self.selected]
end

function ModList:getSelectedMod()
    local selected = self.mods[self.selected]
    return selected and selected.mod
end

function ModList:getSelectedId()
    local selected = self.mods[self.selected]
    return selected and selected.id
end

function ModList:getById(id)
    for i,v in ipairs(self.mods) do
        if v.id == id then
            return v, i
        end
    end
end

function ModList:clearMods()
    for _,v in ipairs(self.mods) do
        self.mod_container:remove(v)
    end
    self.mods = {}
    self.selected = 0
    self.mod_list_height = 0
    self:setScroll(0)
end

function ModList:addMod(mod)
    table.insert(self.mods, mod)
    self.mod_container:add(mod)
    mod:setPosition(4, self.mod_list_height + 4)
    self.mod_list_height = self.mod_list_height + mod.height + 8
end

function ModList:select(i, mute)
    local success = false
    local last_selected = self.selected
    self.selected = i
    if last_selected ~= self.selected then
        if not mute then
            self.ui_move:stop()
            self.ui_move:play()
        end
        if self.mods[last_selected] then
            self.mods[last_selected]:onDeselect()
        end
        self.mods[self.selected]:onSelect()
        success = true
    end
    self:setScroll()

    return success
end

function ModList:selectUp(no_wrap)
    if self.selected == 0 or #self.mods == 0 then
        self:select(1)
    else
        if no_wrap then
            self:select(math.max(self.selected - 1, 1))
        else
            self:select((self.selected - 2) % #self.mods + 1)
        end
    end
end

function ModList:selectDown(no_wrap)
    if self.selected == 0 or #self.mods == 0 then
        self:select(1)
    else
        if no_wrap then
            self:select(math.min(self.selected + 1, #self.mods))
        else
            self:select(self.selected % #self.mods + 1)
        end
    end
end

function ModList:pageUp(no_wrap)
    if self.selected == 0 or #self.mods == 0 then
        self:select(1)
    elseif self.selected == #self.mods then
        self:select(math.max(1, #self.mods - 4))
    elseif self.selected > 5 then
        local last_scroll = self.scroll_target
        self:select(self.selected - 5)
        self:setScroll(last_scroll - (5 * 70))
    elseif self.selected == 1 then
        if not no_wrap then
            self:select(#self.mods)
            self:setScroll(self.height)
        end
    else
        self:select(1)
        self:setScroll(0)
    end
end

function ModList:pageDown(no_wrap)
    if self.selected == 0 or #self.mods == 0 then
        self:select(1)
    elseif self.selected < #self.mods - 4 then
        local last_scroll = self.scroll_target
        self:select(self.selected + 5)
        self:setScroll(last_scroll + (5 * 70))
    elseif self.selected == #self.mods then
        if not no_wrap then
            self:select(1)
            self:setScroll(0)
        end
    else
        self:select(#self.mods)
        self:setScroll(self.height)
    end
end

function ModList:setScroll(scroll)
    scroll = scroll or self.scroll_target

    local max_scroll = math.max(self.mod_list_height - self.height, 0)

    local selected = self:getSelected()
    local min_selected_scroll = math.max(selected and (selected.y + selected.height + 4 - self.height) or 0, 0)
    local max_selected_scroll = math.min(selected and (selected.y - 4) or max_scroll, max_scroll)

    self.scroll_target = utils.clamp(scroll, min_selected_scroll, max_selected_scroll)
end

function ModList:update(dt)
    if self.selected > #self.mods then
        self:select(#self.mods)
    end

    -- Move the mod menu closer to the target
    if (math.abs((self.scroll_target - self.scroll)) <= 2) then
        self.scroll = self.scroll_target
    end

    self.scroll = self.scroll + ((self.scroll_target - self.scroll) / 2) * (dt * 30)
    self.mod_container.y = -self.scroll

    self:updateChildren(dt)
end

function ModList:draw()
    -- Draw the scrollbar (only if we have to)
    if #self.mods > 5 then
        -- Draw the scrollbar background
        love.graphics.setColor({0, 0, 0, 0.5})
        love.graphics.rectangle("fill", self.width + 2, 0, 4, self.height)

        local scrollbar_height = (self.height / self.mod_list_height) * self.height
        local scrollbar_y = (self.scroll / math.max(self.mod_list_height - self.height, 0)) * (self.height - scrollbar_height)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", self.width + 2, scrollbar_y, 4, scrollbar_height)
    end

    kristal.graphics.pushScissor()
    kristal.graphics.scissor(0, 0, self.width, self.height)
    self:drawChildren()
    kristal.graphics.popScissor()
end

return ModList