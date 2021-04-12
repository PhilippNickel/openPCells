local M = {}

function M.filter(obj, layers, listtype)
    for i, S in obj:iter() do
        if listtype == "black" then
            if aux.any_of(function(l) return S.lpp:str() == l end, layers) then
                obj:remove_shape(i)
            end
        else
            if aux.all_of(function(l) return S.lpp:str() ~= l end, layers) then
                obj:remove_shape(i)
            end
        end
    end
end

return M
