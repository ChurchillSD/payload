require('__shared/common')

Events:Subscribe('Level:Loaded', function(levelName, gameMode)
    if levelName == "Levels/MP_Subway/MP_Subway" and gameMode == "ConquestSmall0" then
        print("Creating thing")
        local entityData = PointLightEntityData()
        entityData.color = Vec3(1.0, 0.0, 0.0)
        entityData.radius = 1000.0
        entityData.intensity = 1.0
        entityData.visible = true
        entityData.enlightenEnable = false

        local entityPos = LinearTransform()
        entityPos.trans = Vec3(58.085938, 65.002731, 229.448242)

        local createdEntity = EntityManager:CreateEntity(entityData, entityPos)

        if createdEntity ~= nil then
            createdEntity:Init(Realm.Realm_ClientAndServer, true)
        end
        print("Created thing")
    end
end)



--