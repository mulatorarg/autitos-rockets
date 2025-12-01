class_name ImpactReceiver
extends Area3D

signal impacted(source: Node3D, force: Vector3)

const EXPLOSION_PARTICLES_SCENE: PackedScene = preload("uid://evbr8n5dfye3")


func receive_impact(source: Node3D, force: Vector3) -> void:
	_create_explosion_effect()
	impacted.emit(source, force)

func _create_explosion_effect() -> void:
	var particle_effects_container: Node3D = get_tree().get_first_node_in_group("ParticleEffectsContainer")
	
	if particle_effects_container == null:
		push_warning("Tiene que existir un Node3D en cualquier lugar de la escena con el grupo 'ParticleEffectsContainer' para almacenar instancias de efectos de particulas")
		return
	
	var explosion_effect_instance: CPUParticles3D = EXPLOSION_PARTICLES_SCENE.instantiate()
	explosion_effect_instance.emitting = false
	explosion_effect_instance.one_shot = true
	
	particle_effects_container.add_child(explosion_effect_instance)
	explosion_effect_instance.global_position = global_position
	explosion_effect_instance.emitting = true
	


#
