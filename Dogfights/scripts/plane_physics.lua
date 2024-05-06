function ElevatorEasing(id)
	local elevator = data.planes[tostring(id)].elevator
	if data.planes[tostring(id)].elevator_target == 1 then
		elevator = elevator + (6/fps)
	end
	if data.planes[tostring(id)].elevator_target == -1 then
		elevator = elevator - (6/fps)
	end
	if data.planes[tostring(id)].elevator_target == 0 then
		if elevator < 0 then elevator = elevator + (8/fps) end
		if elevator > 0 then elevator = elevator - (8/fps) end
		if elevator < (8/fps) and elevator > -(8/fps) then elevator = 0 end
	end
	if elevator < -1 then elevator = -1 end
	if elevator > 1 then elevator = 1 end
	data.planes[tostring(id)].elevator = elevator
end

function UpdatePlanePhysics(id, saveName, teamId)
	--test if helicopter and end
	if GetProjectileParamBool(saveName, teamId, "sb_planes.helicopter", false) then return end
	--velocity
	local velocity = NodeVelocity(id)
	local speed = math.sqrt(velocity.x ^ 2 + velocity.y ^ 2)
	--angle of lift
	local angle = Vec2Rad(velocity)
	angle = angle + 1.5708
	if data.planes[tostring(id)].elevator < 0 then
		angle = angle - 0.0436332
	else
		angle = angle + 0.0436332
	end
	--elevators
	local elevator_strength = GetProjectileParamFloat(saveName, teamId, "sb_planes.elevator", 70000)
	local advanced_physics = GetProjectileParamBool(saveName, teamId, "sb_planes.advanced_physics", false)
	local elevator_lift = Vec3(0,0)
	--elevator easing
	ElevatorEasing(id)

	--100 degrees
	if advanced_physics then
		elevator_lift = MultiplyVec(Rad2Vec(angle), data.planes[tostring(id)].elevator * elevator_strength * (speed / 2000))
	else
		elevator_lift = MultiplyVec(Rad2Vec(angle), data.planes[tostring(id)].elevator * elevator_strength)
	end
	dlc2_ApplyForce(id, elevator_lift)
	--advanced physics mode
	if advanced_physics then
		angle = Vec2Rad(velocity)
		angle = angle + 1.5708 --90 degrees
		--lift
		if angle - 1.5708 > 1.5708 or angle - 1.5708 < -1.5708 then
			angle = angle - 1.5708 * 2
		end
		local lift_strength = GetProjectileParamFloat(saveName, teamId, "sb_planes.lift_multiplier", 4.3)
		local lift_max = GetProjectileParamFloat(saveName, teamId, "sb_planes.lift_max_speed", 99999)
		local wing_lift = MultiplyVec(Rad2Vec(angle), -lift_strength)
		wing_lift = MultiplyVec(wing_lift, math.min(math.abs(velocity.x), lift_max))
		dlc2_ApplyForce(id, wing_lift)
		--thrust
		angle = Vec2Rad(velocity)
		local thrust_value = GetProjectileParamFloat(saveName, teamId, "sb_planes.thrust", 50000)
		local throttle = data.planes[tostring(id)].throttle
		dlc2_ApplyForce(id, MultiplyVec(Rad2Vec(angle), thrust_value * throttle))
	end
end

function UpdateHeliPhysics(id, saveName, teamId)
	--test if not helicopter and end
	if not GetProjectileParamBool(saveName, teamId, "sb_planes.helicopter", false) then return end
	--gather values
	local thrust_value = GetProjectileParamFloat(saveName, teamId, "sb_planes.thrust", 50000)
	local throttle = data.planes[tostring(id)].throttle
	ElevatorEasing(id)
	local elevator_strength = GetProjectileParamFloat(saveName, teamId, "sb_planes.elevator", 1)
	local elevator = data.planes[tostring(id)].elevator
	--update angle from elevator
	local angle = data.planes[tostring(id)].angle + (elevator * elevator_strength * math.pi / 180)
	data.planes[tostring(id)].angle = angle
	--do thrust
	local thrust_vector = MultiplyVec(Rad2Vec(angle), thrust_value * throttle)
	dlc2_ApplyForce(id, thrust_vector)
end