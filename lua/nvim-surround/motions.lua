local buffer = require("nvim-surround.buffer")
local utils = require("nvim-surround.utils")

local M = {}

-- Gets a selection based on a given motion.
---@param motion string The provided motion.
---@return selection? @The selection that represents the text-object.
M.get_selection = function(motion)
    local char = utils.get_alias(motion:sub(2, 2))
    -- Smart quotes feature; jump to the next quote if it is on the same line
    local curpos = buffer.get_curpos()

    buffer.set_operator_marks(motion)
    -- Adjust the marks to reside on non-whitespace characters
    buffer.adjust_mark("[")
    buffer.adjust_mark("]")

    -- Get the row and column of the first and last characters of the selection
    local first_pos = buffer.get_mark("[")
    local last_pos = buffer.get_mark("]")
    -- If a selection is found surrounding the cursor or after it, then return
    if first_pos and last_pos and buffer.comes_before(first_pos, last_pos) then
        -- Restore the cursor position
        buffer.set_curpos(curpos)
        return {
            first_pos = first_pos,
            last_pos = last_pos,
        }
    end

    -- Since no selection was found around/after the cursor, we look behind
    if char == "t" then -- Handle special case with lookbehind for HTML tags (search for `>` instead of `t`)
        vim.fn.searchpos(">", "bcW")
    elseif char then -- General case, jump to the character
        vim.fn.searchpos(char, "bcW")
    end

    buffer.set_operator_marks(motion)
    -- Adjust the marks to reside on non-whitespace characters
    buffer.adjust_mark("[")
    buffer.adjust_mark("]")

    -- Get the row and column of the first and last characters of the selection
    first_pos = buffer.get_mark("[")
    last_pos = buffer.get_mark("]")
    -- Restore the cursor position
    buffer.set_curpos(curpos)
    -- Return nil if either endpoint of the selection do not exist, or no match is found (marks out of order)
    if not first_pos or not last_pos or buffer.comes_before(first_pos, last_pos) then
        return nil
    end
    return {
        first_pos = first_pos,
        last_pos = last_pos,
    }
end

return M
