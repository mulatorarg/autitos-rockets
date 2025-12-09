# Trabajo Práctico N° 2: Juego 3D

Adaptación de varios juegos de carreras arcade, desarrollado en Godot Engine 4.5.

**Desarrolladores**:
* Gabriel Campo.
* Tomás Duggan.

**Titulo:** Autitos Rockets.

**Género:** Autos de carreras.

**Resolución objetivo:** HD 1366×768 (UI y HUD diseñados para esta resolución).

**Estética:** Low poly épico.

## Estado Actual del Proyecto

En desarrollo.

### Sistema de Carreras Implementado

El proyecto ahora cuenta con un sistema completo de carreras arcade que incluye:

- **Clase Car Base**: Sistema modular con clases PlayerCar y AICar
- **IA de Enemigos**: Navigation3D con seguimiento de checkpoints y evasión de obstáculos
- **Sistema de Checkpoints**: Detección secuencial de paso por checkpoints
- **Gestión de Carreras**: Singletons (GameManager, RaceManager) para control de estados
- **HUD Completo**: Velocidad, posición, vueltas, tiempo y pantalla de resultados
- **Pista de Ejemplo**: Track funcional con Navigation3D y múltiples enemigos IA

### Controles

- **WASD / Flechas**: Conducir
- **Space**: Frenar
- **R**: Reiniciar carrera

### 1. Concepto

Juego de carreras arcade en 3D donde el jugador compite contra oponentes controlados por IA en circuitos con checkpoints y obstáculos. El objetivo es completar un número determinado de vueltas en el menor tiempo posible y lograr el primer puesto.

### 2. Referencias principales

- Micro Machines (estilo arcade)
- Mario Kart (jugabilidad arcade divertida)
- RollCage (jugabilidad arcade divertida)

### 3. Meta de desarrollo

* **Motor:** **Godot Engine 4.5.1**.
* **Plataforma objetivo:** PC (Windows/Linux), MAC y dispositivos móviles Android e iOS.
* **Estilo visual:** 3D, arte en **low poly** con animaciones simples.
* **Sesiones;** Cortas y progresivas por niveles.

### 4. Características Técnicas

* **Física arcade** con RigidBody3D
* **Sistema de navegación** con NavigationAgent3D para IA
* **Gestión de estados** mediante Autoloads
* **UI responsive** con información en tiempo real
* **Sistema modular** fácil de extender


### 5. Herramientas y Fuentes de Ideas

* Para el manejo el auto en formato arcade, nos basamos de:
https://kidscancode.org/godot_recipes/4.x/3d/3d_sphere_car/index.html

* Para modelar las casas, utilizamos SweetHome3D, fantástico software open source:
https://www.sweethome3d.com/

* Utilizamos assets del genial Kenney:
https://www.kenney.nl/assets/toy-car-kit