script.on_event(defines.events.on_entity_died, function(event)
  local entity = event.entity
  local boxes = entity.fluidbox
  local fluids = game.fluid_prototypes
  local num_pots = #boxes
  if num_pots == 0 then return end
  for k = 1, num_pots do
    local pot = boxes[k]
    if pot then 
      if fluids[pot.name].fuel_value > 0 then
        local fraction = pot.amount/boxes.get_capacity(k)
        if fraction > 0.025 then 
          flammable_explosion(entity, fraction)
          return
        end
      end
    end
  end
end)

function flammable_explosion(entity, fraction)

  if not entity.valid then return end
  local pos = entity.position
  local surface = entity.surface
  local radius = 0.5 * ((entity.bounding_box.right_bottom.x - pos.x) + (entity.bounding_box.right_bottom.y - pos.y))
  local width = radius * 2
  local area = {{pos.x - (radius + 0.5),pos.y - (radius + 0.5)},{pos.x + (radius + 0.5),pos.y + (radius + 0.5)}}
  local damage = math.random(20, 40) * fraction
  
  if width <= 1 then
    entity.surface.create_entity{name = "explosion", position = pos}
    entity.surface.create_entity{name = "oil-fire-flame", position = pos}
  else
    surface.create_entity{name = "medium-explosion", position = {pos.x+math.random(-radius,radius), pos.y+math.random(-radius,radius)}}
    for k = 1, math.ceil(width) do
      surface.create_entity{name = "oil-fire-flame", position = {pos.x+math.random(-radius,radius), pos.y+math.random(-radius,radius)}}
      for j = 1, math.ceil(4 * fraction) do
        local burst = width+(2 * fraction)
        surface.create_entity{name = "oil-fire-flame", position = {pos.x+math.random(-burst,burst), pos.y+math.random(-burst,burst)}}
      end
    end
  end
  
  if entity.type == "pipe-to-ground" then
    if entity.neighbours then
      for k, neighbour in pairs (entity.neighbours[1]) do
        if neighbour and neighbour.valid and (neighbour.type == "pipe-to-ground") then
          surface.create_entity{name = "oil-fire-flame", position = neighbour.position}
          neighbour.damage(damage, entity.force, "explosion")
          break
        end
      end
    end
  end
  
  for k, nearby in pairs (surface.find_entities(area)) do
    if nearby.valid and nearby.health then
      nearby.damage(damage, entity.force, "explosion")
    end
  end

end