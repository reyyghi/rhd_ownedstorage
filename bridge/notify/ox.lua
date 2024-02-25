local isServer = IsDuplicityVersion()

function RB.n.send(text, type, duration)
    lib.notify({
        description = text,
        type = type,
        duration = duration
    })
end

if isServer then
    function RB.n.send(source, text, type, duration)
        lib.notify(source, {
            description = text,
            type = type,
            duration = duration
        })
    end
end
