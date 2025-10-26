# 🧠 Modern C++ Memory Management — Smart Pointers Deep Dive

**Folder:** `0x00-C++Modern-Review_Unreal_Basics`  
**Requisito:** C++11 o superior

---
## 📋 Contenido

Este proyecto demuestra:
- `std::unique_ptr` - Propiedad exclusiva
- `std::shared_ptr` - Propiedad compartida
- `std::weak_ptr` - Referencias no propietarias
- `std::enable_shared_from_this` - Auto-referencia segura

## 🏗️ Estructura del Proyecto

```
.
├── include/          # Headers públicos
│   ├── Weapon.h
│   ├── Texture.h
│   ├── Material.h
│   ├── Enemy.h
│   └── Player.h
├── src/              # Implementaciones
│   ├── main.cpp
│   ├── Weapon.cpp
│   ├── Texture.cpp
│   ├── Material.cpp
│   ├── Enemy.cpp
│   └── Player.cpp
├── build/            # Archivos de compilación
├── bin/              # Ejecutable final
├── CMakeLists.txt    # Sistema de build CMake
├── Makefile          # Makefile alternativo
└── README.md         # Este archivo## 📋 Contenido
```

---

## 🚀 Introducción

En **C++ clásico** (pre-C++11), la gestión de memoria era completamente manual:

```cpp
// ❌ Estilo antiguo (C++98/03) - PROPENSO A ERRORES
Weapon* pistol = new Weapon();
pistol->Fire();
delete pistol; // Si olvidas esto = MEMORY LEAK 💥
```

### 🔴 Problemas del Manejo Manual de Memoria

1. **Memory Leaks**: Olvidar hacer `delete` deja memoria ocupada permanentemente
2. **Dangling Pointers**: Acceder a un puntero después de hacer `delete` causa crashes
3. **Double Delete**: Llamar `delete` dos veces = comportamiento indefinido (crash)
4. **Excepciones**: Si ocurre una excepción antes del `delete`, nunca se libera la memoria

```cpp
void ProblematicFunction() {
    Weapon* pistol = new Weapon();
    pistol->Fire();
    
    // Si Fire() lanza una excepción, nunca llegamos aquí:
    delete pistol; // ⚠️ NUNCA SE EJECUTA = MEMORY LEAK
}
```

---

## ✨ La Solución: Smart Pointers (C++11+)

A partir de **C++11**, se introdujeron los **smart pointers** en la biblioteca estándar (`<memory>`).

### 🎯 ¿Qué son los Smart Pointers?

Son **clases template** que envuelven punteros crudos (`raw pointers`) y automatizan la gestión de memoria mediante el principio **RAII** (Resource Acquisition Is Initialization).

### 🔑 Principio RAII

**RAII** = "La adquisición de un recurso es su inicialización"

```cpp
{
    std::unique_ptr<Weapon> pistol = std::make_unique<Weapon>();
    pistol->Fire();
    
    // Al salir del scope {}, el destructor de unique_ptr
    // automáticamente llama a delete
    
} // ← Aquí se libera la memoria automáticamente ✅
// No necesitas escribir 'delete' manualmente
```

**Ventajas:**
- ✅ **No memory leaks**: La memoria siempre se libera
- ✅ **Exception-safe**: Incluso si hay excepciones, se libera correctamente
- ✅ **Código más limpio**: No necesitas recordar hacer `delete`

---

## 🧩 Smart Pointers Overview

| Smart Pointer | Ownership | Reference Count | Copyable | Uso Típico |
|---------------|-----------|-----------------|----------|------------|
| `std::unique_ptr` | **Exclusiva** | ❌ (Ninguno) | ❌ (Solo movible) | Un único dueño del recurso |
| `std::shared_ptr` | **Compartida** | ✅ (Contador) | ✅ | Múltiples dueños |
| `std::weak_ptr` | **No posee** | ✅ (Observa el contador) | ✅ | Romper referencias circulares |

---

## 🔒 `std::unique_ptr` - Propiedad Exclusiva

### 💡 Concepto Fundamental

`unique_ptr` representa **propiedad exclusiva** de un objeto. Solo **un** `unique_ptr` puede poseer el objeto a la vez.

**Analogía del mundo real:**  
Es como la **llave de tu casa**. Solo existe UNA llave maestra. Si se la das a otra persona, tú ya no la tienes (ownership transfer).

### 📋 Características

1. **Propiedad exclusiva**: Solo un `unique_ptr` puede apuntar al objeto
2. **No copiable**: No puedes copiar un `unique_ptr` (evita múltiples dueños)
3. **Movible**: Puedes transferir la propiedad con `std::move()`
4. **Cero overhead**: Mismo tamaño que un puntero crudo (no hay contador de referencias)
5. **Destrucción automática**: Cuando sale del scope, llama `delete` automáticamente

### 🔧 Sintaxis y Uso

```cpp
// ✅ Creación moderna (C++14+)
std::unique_ptr<Weapon> pistol = std::make_unique<Weapon>();

// ⚠️ También válido pero menos seguro (C++11)
std::unique_ptr<Weapon> rifle(new Weapon());

// ✅ Uso normal (como un puntero)
pistol->Fire();
pistol->Reload();

// ❌ ERROR: No se puede copiar
std::unique_ptr<Weapon> pistol2 = pistol; // ❌ NO COMPILA

// ✅ Transferir propiedad (move)
std::unique_ptr<Weapon> pistol2 = std::move(pistol);
// Ahora pistol es nullptr y pistol2 posee el objeto
```

### 🧬 Ciclo de Vida de la Memoria

```
STACK                    HEAP
┌──────────────────┐    ┌──────────────┐
│ unique_ptr       │───→│ Weapon       │
│ pistol           │    │ object       │
└──────────────────┘    └──────────────┘
                         Ref count: NO EXISTE
                         (propiedad única)

// Al salir del scope:
pistol destruido → automáticamente llama delete → objeto liberado ✅
```

### 🎮 Ejemplo Práctico en Unreal

```cpp
class APlayer : public AActor {
private:
    std::unique_ptr<WeaponSystem> weaponSystem;
    
public:
    APlayer() {
        // El jugador ES EL ÚNICO dueño de su sistema de armas
        weaponSystem = std::make_unique<WeaponSystem>();
    }
    
    // No necesitas destructor, unique_ptr limpia automáticamente
    // ~APlayer() { } // No necesario!
};
```

### ⚠️ ¿Cuándo NO usar `unique_ptr`?

- Cuando **múltiples objetos** necesitan acceder al mismo recurso
- Cuando necesitas **compartir propiedad** entre varios sistemas

---

## 🤝 `std::shared_ptr` - Propiedad Compartida

### 💡 Concepto Fundamental

`shared_ptr` permite que **múltiples punteros** compartan la propiedad del mismo objeto mediante un **contador de referencias**.

**Analogía del mundo real:**  
Es como un **documento en Google Docs**. Múltiples personas pueden tener acceso simultáneamente. El documento solo se elimina cuando la última persona cierra el acceso.

### 📋 Características

1. **Propiedad compartida**: Múltiples `shared_ptr` pueden apuntar al mismo objeto
2. **Contador de referencias**: Internamente cuenta cuántos `shared_ptr` apuntan al objeto
3. **Copiable**: Puedes copiar un `shared_ptr` libremente
4. **Destrucción automática**: Cuando el último `shared_ptr` se destruye, libera el objeto
5. **Thread-safe**: El contador de referencias es atómico (seguro para threads)

### 🔢 El Contador de Referencias

```cpp
auto texture = std::make_shared<Texture>("Grass.png");
std::cout << texture.use_count(); // 1

{
    auto tex2 = texture; // Copia
    std::cout << texture.use_count(); // 2
    
    auto tex3 = texture; // Otra copia
    std::cout << texture.use_count(); // 3
    
} // tex2 y tex3 destruidos, contador -= 2

std::cout << texture.use_count(); // 1

// texture sale del scope, contador = 0 → objeto destruido ✅
```

### 🧬 Estructura Interna (Control Block)

```
┌──────────────────┐     ┌─────────────────────────┐
│ shared_ptr #1    │────→│   CONTROL BLOCK         │
└──────────────────┘     │  ┌──────────────────┐   │
                         │  │ Ref Count: 3     │   │
┌──────────────────┐     │  │ Weak Count: 1    │   │
│ shared_ptr #2    │────→│  │ Deleter          │   │
└──────────────────┘     │  └──────────────────┘   │
                         │           │              │
┌──────────────────┐     └───────────┼──────────────┘
│ shared_ptr #3    │────────────────→│
└──────────────────┘                 ↓
                              ┌──────────────┐
                              │ Texture      │
                              │ Object       │
                              └──────────────┘
```

### 🔧 Sintaxis y Uso

```cpp
// ✅ Creación recomendada
auto texture = std::make_shared<Texture>("Grass.png");

// ✅ Compartir entre múltiples objetos
auto materialA = std::make_shared<Material>(texture);
auto materialB = std::make_shared<Material>(texture);
auto materialC = std::make_shared<Material>(texture);

// Todos comparten la MISMA textura en memoria
// Cuando los 3 materiales se destruyan, recién se libera la textura
```

### 🎮 Ejemplo Práctico en Unreal

```cpp
class TextureManager {
private:
    std::map<std::string, std::shared_ptr<Texture>> loadedTextures;
    
public:
    std::shared_ptr<Texture> LoadTexture(const std::string& path) {
        // Si ya está cargada, devolver la existente
        if (loadedTextures.count(path)) {
            return loadedTextures[path]; // Incrementa ref count
        }
        
        // Si no existe, cargarla
        auto texture = std::make_shared<Texture>(path);
        loadedTextures[path] = texture;
        return texture;
    }
};

// Uso:
auto grass1 = textureManager.LoadTexture("Grass.png"); // Carga y ref=2
auto grass2 = textureManager.LoadTexture("Grass.png"); // Mismo objeto, ref=3
// Ambos apuntan a la MISMA textura en memoria (eficiente)
```

### ⚠️ Overhead de `shared_ptr`

- **Tamaño**: 2 punteros (16 bytes en 64-bit)
  - 1 puntero al objeto
  - 1 puntero al control block
- **Performance**: Operaciones atómicas en el contador (ligeramente más lento)

### 🚨 El Problema de las Referencias Circulares

```cpp
// ❌ PROBLEMA: Ciclo de referencias
class Enemy {
public:
    std::shared_ptr<Player> target; // Enemy → Player
};

class Player {
public:
    std::shared_ptr<Enemy> target; // Player → Enemy
};

auto player = std::make_shared<Player>();
auto enemy = std::make_shared<Enemy>();

player->target = enemy; // Player apunta a Enemy (ref=2)
enemy->target = player; // Enemy apunta a Player (ref=2)

// Cuando salen del scope:
// - player tiene ref=1 (enemy aún lo referencia)
// - enemy tiene ref=1 (player aún lo referencia)
// ❌ NINGUNO SE DESTRUYE = MEMORY LEAK!
```

**Solución:** Usar `weak_ptr` para romper el ciclo.

---

## 👀 `std::weak_ptr` - El Observador

### 💡 Concepto Fundamental

`weak_ptr` es un **puntero NO propietario** que "observa" un objeto gestionado por `shared_ptr` **sin incrementar** el contador de referencias.

**Analogía del mundo real:**  
Es como tener el **número de teléfono de un amigo**. Puedes intentar llamarlo, pero no garantiza que esté disponible. Si cambió de número (objeto destruido), la llamada falla.

### 📋 Características

1. **No posee el objeto**: No incrementa el reference count
2. **Observa**: Puede verificar si el objeto aún existe
3. **Conversión temporal**: Debes convertirlo a `shared_ptr` para usarlo (`.lock()`)
4. **Evita ciclos**: Solución perfecta para referencias circulares
5. **Puede expirar**: Si el objeto es destruido, `weak_ptr` lo detecta

### 🔧 Sintaxis y Uso

```cpp
std::shared_ptr<Enemy> enemy = std::make_shared<Enemy>();
std::weak_ptr<Enemy> weakEnemy = enemy; // No incrementa ref count

// Para usar el objeto, debes "lockearlo"
if (auto sharedEnemy = weakEnemy.lock()) {
    // Convierte weak_ptr a shared_ptr temporalmente
    sharedEnemy->TakeDamage(25); // ✅ Seguro
} else {
    std::cout << "Enemy ya fue destruido!\n";
}

// Verificar si aún existe
if (weakEnemy.expired()) {
    std::cout << "El objeto ya no existe\n";
}
```

### 🔄 Contador de Referencias con `weak_ptr`

```cpp
auto enemy = std::make_shared<Enemy>();
std::cout << enemy.use_count(); // 1 (solo shared)

std::weak_ptr<Enemy> weak1 = enemy;
std::weak_ptr<Enemy> weak2 = enemy;
std::weak_ptr<Enemy> weak3 = enemy;

std::cout << enemy.use_count(); // 1 (weak_ptr NO incrementa!)

enemy.reset(); // Destruye el objeto
// Ahora weak1, weak2, weak3 están "expirados"
```

### 🎮 Ejemplo Práctico: Romper Referencias Circulares

```cpp
class Enemy;

class Player {
public:
    std::weak_ptr<Enemy> target; // ✅ weak_ptr rompe el ciclo
    
    void Attack() {
        if (auto enemy = target.lock()) { // Intenta obtener shared_ptr
            enemy->TakeDamage(25);
            std::cout << "Enemy dañado!\n";
        } else {
            std::cout << "Target ya no existe!\n";
        }
    }
};

class Enemy {
public:
    std::shared_ptr<Player> target; // shared_ptr es OK aquí
    int health = 100;
    
    void TakeDamage(int damage) {
        health -= damage;
    }
};

// Uso:
auto player = std::make_shared<Player>(); // ref=1
auto enemy = std::make_shared<Enemy>();   // ref=1

player->target = enemy; // weak NO incrementa ref (enemy ref=1)
enemy->target = player; // shared incrementa ref (player ref=2)

// Al salir del scope:
// 1. enemy se destruye (ref=1 → 0) ✅
// 2. Al destruirse enemy, suelta su shared_ptr a player
// 3. player se destruye (ref=2 → 1 → 0) ✅
// ✅ NO HAY MEMORY LEAK
```

### 📊 Comparación: `shared_ptr` vs `weak_ptr`

```
ESCENARIO: Player → Enemy ← Environment

┌─────────────────┐
│ Player          │
│ weak_ptr enemy ─┼───┐    NO incrementa ref
└─────────────────┘   │
                      ↓
               ┌──────────────┐
┌──────────────│ Enemy        │
│ shared_ptr   │ (ref=2)      │
│              └──────────────┘
│                     ↑
│              ┌──────┘
│              │
└──────────────┼───────────────┐
               │               │
        ┌──────────────┐       │
        │ Environment  │───────┘
        │ shared_ptr   │  Incrementa ref
        └──────────────┘

Cuando Environment se destruye:
- Enemy ref: 2 → 1 (aún existe porque Player puede necesitarlo)
- Player puede seguir atacando a Enemy

Cuando Player ataca:
- player.lock() funciona (devuelve shared_ptr temporal)
- Enemy recibe daño

Cuando Enemy muere (ref=0):
- Player.target.lock() devuelve nullptr
- Player sabe que el enemigo ya no existe ✅
```

---

## 🧠 `std::enable_shared_from_this`

### 💡 Concepto Fundamental

`enable_shared_from_this` permite que un objeto **gestionado por `shared_ptr`** pueda crear **nuevos `shared_ptr`** a sí mismo de manera segura.

**¿Por qué existe?**  
Si intentas crear un `shared_ptr` desde `this` directamente, creas un **segundo control block** independiente, causando **double-delete**.

### 🚨 El Problema Sin `enable_shared_from_this`

```cpp
class Enemy {
public:
    std::shared_ptr<Enemy> GetPtr() {
        return std::shared_ptr<Enemy>(this); // ❌ PELIGROSO!
    }
};

auto enemy1 = std::make_shared<Enemy>(); // Control block #1, ref=1
auto enemy2 = enemy1->GetPtr();           // Control block #2, ref=1

// ❌ Ambos control blocks intentan destruir el mismo objeto
// = DOUBLE DELETE = CRASH 💥
```

### ✅ La Solución Correcta

```cpp
class Enemy : public std::enable_shared_from_this<Enemy> {
public:
    std::shared_ptr<Enemy> GetPtr() {
        return shared_from_this(); // ✅ Usa el mismo control block
    }
    
    void RegisterInSystem() {
        // Puedo pasarme a mí mismo como shared_ptr
        GameSystem::RegisterEnemy(shared_from_this());
    }
};

auto enemy1 = std::make_shared<Enemy>(); // Control block único, ref=1
auto enemy2 = enemy1->GetPtr();           // MISMO control block, ref=2
// ✅ Seguro, ambos comparten el mismo control block
```

### ⚙️ Funcionamiento Interno

```
Paso 1: Crear el primer shared_ptr
───────────────────────────────────
auto enemy = std::make_shared<Enemy>();

┌──────────────────┐     ┌─────────────────────────┐
│ shared_ptr       │────→│   CONTROL BLOCK         │
│ enemy            │     │  ┌──────────────────┐   │
└──────────────────┘     │  │ Strong ref: 1    │   │
                         │  │ Weak ref: 1      │◄──┼─┐
                         │  └──────────────────┘   │ │
                         └────────┬────────────────┘ │
                                  │                  │
                                  ↓                  │
                          ┌──────────────┐          │
                          │ Enemy object │          │
                          │ (hereda de   │          │
                          │ enable_...)  │          │
                          │              │          │
                          │ weak_ptr ────┼──────────┘
                          └──────────────┘
                          Internal weak reference

Paso 2: Llamar shared_from_this()
──────────────────────────────────
auto enemy2 = enemy->shared_from_this();

El objeto "lockea" su weak_ptr interno → obtiene shared_ptr
┌──────────────────┐
│ shared_ptr       │──┐
│ enemy2           │  │   Ambos apuntan al MISMO control block
└──────────────────┘  │
                      ↓
                ┌─────────────────────────┐
                │   CONTROL BLOCK         │
                │  ┌──────────────────┐   │
                │  │ Strong ref: 2    │◄──┼── Incrementado!
                │  │ Weak ref: 1      │   │
                │  └──────────────────┘   │
                └─────────────────────────┘
```

### ⚠️ Restricción Importante

```cpp
class Enemy : public std::enable_shared_from_this<Enemy> {
public:
    void BadUsage() {
        auto ptr = shared_from_this(); // ❌ CRASH!
    }
};

// ❌ Crear con 'new' no inicializa el weak_ptr interno
Enemy* enemy = new Enemy();
enemy->BadUsage(); // ❌ Lanza std::bad_weak_ptr

// ✅ SIEMPRE usar make_shared
auto enemy = std::make_shared<Enemy>();
enemy->BadUsage(); // ✅ Funciona correctamente
```

### 🎮 Caso de Uso Real en Unreal

```cpp
class ANetworkedActor : public AActor, 
                        public std::enable_shared_from_this<ANetworkedActor> {
public:
    void BeginPlay() override {
        // Registrarse en el sistema de red
        NetworkManager::Get()->RegisterActor(shared_from_this());
    }
    
    void OnDestroy() override {
        // Desregistrarse
        NetworkManager::Get()->UnregisterActor(shared_from_this());
    }
    
    void SendNetworkUpdate() {
        // Crear un evento de red que incluye referencia a este actor
        auto updateEvent = std::make_shared<NetworkEvent>(
            shared_from_this(), // Pasamos shared_ptr a nosotros mismos
            transform,
            velocity
        );
        
        NetworkManager::Get()->QueueEvent(updateEvent);
    }
};
```

---

## ⚡ ¿Por Qué No Necesitas `delete` Manualmente?

### 🔄 Mecanismo de Destrucción Automática

Los smart pointers utilizan el **destructor** de la clase para liberar memoria automáticamente:

```cpp
template<typename T>
class unique_ptr {
private:
    T* ptr;
    
public:
    // Constructor
    unique_ptr(T* p) : ptr(p) {}
    
    // Destructor - SE LLAMA AUTOMÁTICAMENTE
    ~unique_ptr() {
        delete ptr; // ← Liberación automática
    }
    
    // Prevenir copia
    unique_ptr(const unique_ptr&) = delete;
    unique_ptr& operator=(const unique_ptr&) = delete;
};
```

### 📋 Ciclo de Vida Completo

```cpp
void GameLoop() {
    std::unique_ptr<Weapon> pistol = std::make_unique<Weapon>();
    // ptr creado → objeto Weapon creado en heap
    
    pistol->Fire();
    
    // Fin de la función
    // 1. La variable 'pistol' (stack) va a ser destruida
    // 2. Se llama automáticamente ~unique_ptr()
    // 3. ~unique_ptr() ejecuta: delete ptr;
    // 4. Se llama ~Weapon() del objeto
    // 5. Memoria liberada ✅
    
} // ← Aquí ocurre todo automáticamente
```

### 🆚 Comparación: Manual vs Automático

```cpp
// ❌ C++98/03 - Manual (PROPENSO A ERRORES)
void OldStyle() {
    Weapon* pistol = new Weapon();
    
    pistol->Fire();
    
    if (condition) {
        delete pistol; // Tienes que recordar aquí
        return;
    }
    
    pistol->Reload();
    
    delete pistol; // Y también aquí!
    // Si olvidas cualquiera = MEMORY LEAK
}

// ✅ C++11+ - Automático (SEGURO)
void ModernStyle() {
    auto pistol = std::make_unique<Weapon>();
    
    pistol->Fire();
    
    if (condition) {
        return; // ✅ unique_ptr limpia automáticamente
    }
    
    pistol->Reload();
    
    // ✅ unique_ptr limpia automáticamente
    // No importa por dónde salgas de la función
}
```

---

## 🎯 Reglas de Oro para Elegir Smart Pointer

```
┌─────────────────────────────────────────────────┐
│ ¿Un solo dueño del recurso?                    │
│ (ej: Player posee su Inventory)                │
└────────────┬────────────────────────────────────┘
             │ SÍ
             ↓
      ┌──────────────┐
      │ unique_ptr   │ ← Usa esto
      └──────────────┘
      
┌─────────────────────────────────────────────────┐
│ ¿Múltiples objetos necesitan acceso?           │
│ (ej: Varios Materials usan misma Texture)       │
└────────────┬────────────────────────────────────┘
             │ SÍ
             ↓
      ┌──────────────┐
      │ shared_ptr   │ ← Usa esto
      └──────────────┘
      
┌─────────────────────────────────────────────────┐
│ ¿Puede haber referencias circulares?           │
│ (ej: Player ↔ Enemy)                            │
└────────────┬────────────────────────────────────┘
             │ SÍ
             ↓
      ┌──────────────┐
      │ weak_ptr     │ ← Usa esto para romper ciclo
      └──────────────┘
      
┌─────────────────────────────────────────────────┐
│ ¿El objeto necesita crear shared_ptr a sí      │
│ mismo? (ej: Actor en NetworkManager)            │
└────────────┬────────────────────────────────────┘
             │ SÍ
             ↓
  ┌──────────────────────────┐
  │ enable_shared_from_this  │ ← Hereda de esto
  └──────────────────────────┘
```

---

## 📚 Resumen Ejecutivo

| Aspecto | `unique_ptr` | `shared_ptr` | `weak_ptr` |
|---------|--------------|--------------|------------|
| **Propiedad** | Exclusiva | Compartida | No posee |
| **Contador** | ❌ No | ✅ Sí (atómico) | ✅ Observa |
| **Copiable** | ❌ No | ✅ Sí | ✅ Sí |
| **Overhead** | 0 bytes | 16 bytes (64-bit) | 16 bytes |
| **Performance** | Máxima | Buena (atomic ops) | Buena |
| **Uso típico** | Propiedad única | Recursos compartidos | Romper ciclos |
| **Desde** | C++11 | C++11 | C++11 |

### 🎓 Conceptos Clave

1. **Smart pointers = RAII**: Automatizan la liberación de memoria
2. **C++11+ requerido**: No funciona en C++98/03
3. **No necesitas `delete`**: El destructor lo hace automáticamente
4. **Elige según ownership**: único, compartido, o observador
5. **Previene errores comunes**: memory leaks, dangling pointers, double-delete

### 🎮 En el Contexto de Unreal Engine

Unreal tiene su propio sistema de smart pointers (`TSharedPtr`, `TWeakPtr`, `TUniquePtr`) que funciona similar a los de la STL, pero:

- Son compatibles con el sistema de reflexión de Unreal
- Funcionan con `UObject` y el Garbage Collector
- Tienen sintaxis similar pero no son intercambiables

**Estudiar los smart pointers de C++ estándar te prepara para entender los de Unreal** 🚀

---

## 🔗 Referencias y Recursos

- [C++ Reference - Smart Pointers](https://en.cppreference.com/w/cpp/memory)
- [Unreal Engine Smart Pointers](https://docs.unrealengine.com/en-US/ProgrammingAndScripting/ProgrammingWithCPP/SmartPointerLibrary/)
- [C++11 Standard (ISO/IEC 14882:2011)](https://www.iso.org/standard/50372.html)

---

## 🧩 Ejemplo de Salida del Programa

```
Texture loaded: Grass.png
Weapon created
Bang!
Rat-a-tat-tat!
Enemy health: 75
Enemy health: 50
Attacking target...
Target eliminated!
Enemy destroyed
Weapon destroyed
Texture unloaded: Grass.png
```

---

**Nota Final:** Los smart pointers son parte fundamental de **Modern C++** y son esenciales para desarrollo profesional. Una vez que te acostumbras a usarlos, volver a `new`/`delete` manual se siente como programar sin cinturón de seguridad 🚗💨

---

## 🔬 Casos de Uso Avanzados

### 🎯 Custom Deleters

A veces necesitas hacer algo especial al destruir un objeto (cerrar archivos, liberar recursos externos, etc.):

```cpp
// Deleter personalizado para archivos
auto fileDeleter = [](FILE* f) {
    if (f) {
        std::cout << "Cerrando archivo...\n";
        fclose(f);
    }
};

std::unique_ptr<FILE, decltype(fileDeleter)> file(
    fopen("data.txt", "r"),
    fileDeleter
);

// Para shared_ptr es más simple
auto file2 = std::shared_ptr<FILE>(
    fopen("data.txt", "r"),
    [](FILE* f) { 
        if (f) fclose(f); 
    }
);

// Útil para recursos de Unreal
auto texture = std::shared_ptr<UTexture2D>(
    LoadTextureFromFile("grass.png"),
    [](UTexture2D* tex) {
        // Custom cleanup
        UnloadTexture(tex);
    }
);
```

### 🎮 Arrays con Smart Pointers

```cpp
// ✅ Manera correcta para arrays (C++11)
std::unique_ptr<int[]> numbers(new int[100]);
numbers[0] = 42;
numbers[99] = 100;
// Se llama delete[] automáticamente

// ✅ Mejor aún (C++14+): usar make_unique
auto numbers2 = std::make_unique<int[]>(100);

// ⚠️ shared_ptr requiere especificar deleter manualmente en C++11-16
std::shared_ptr<int> arr(new int[100], std::default_delete<int[]>());

// ✅ C++17+ soporta arrays directamente
auto arr2 = std::shared_ptr<int[]>(new int[100]);
```

### 🔄 Conversión Entre Smart Pointers

```cpp
// unique_ptr → shared_ptr (OK, pierde exclusividad)
std::unique_ptr<Enemy> uniqueEnemy = std::make_unique<Enemy>();
std::shared_ptr<Enemy> sharedEnemy = std::move(uniqueEnemy);
// uniqueEnemy ahora es nullptr

// ❌ shared_ptr → unique_ptr (NO POSIBLE directamente)
// Violaría el contrato de unique_ptr (propiedad exclusiva)

// shared_ptr → weak_ptr (OK)
std::shared_ptr<Enemy> enemy = std::make_shared<Enemy>();
std::weak_ptr<Enemy> weakEnemy = enemy;

// weak_ptr → shared_ptr (OK, temporalmente)
if (auto sharedAgain = weakEnemy.lock()) {
    // Ahora tenemos shared_ptr temporal
}
```

### 🧵 Thread Safety

```cpp
// ✅ shared_ptr: el CONTADOR es thread-safe
std::shared_ptr<Texture> texture = std::make_shared<Texture>();

// Thread 1
std::thread t1([texture]() {
    auto copy = texture; // ✅ Seguro, incremento atómico
});

// Thread 2
std::thread t2([texture]() {
    auto copy = texture; // ✅ Seguro, incremento atómico
});

// ⚠️ Pero el OBJETO no está protegido
// ❌ Esto NO es thread-safe:
std::thread t3([texture]() {
    texture->ModifyData(); // ⚠️ Race condition!
});

std::thread t4([texture]() {
    texture->ModifyData(); // ⚠️ Race condition!
});

// ✅ Solución: Agregar mutex
class ThreadSafeTexture {
private:
    std::shared_ptr<Texture> texture_;
    std::mutex mutex_;
    
public:
    void ModifyData() {
        std::lock_guard<std::mutex> lock(mutex_);
        texture_->ModifyData(); // ✅ Seguro
    }
};
```

---

## 🎓 Ejercicios Prácticos

### 📝 Ejercicio 1: Sistema de Inventario

Implementa un sistema de inventario donde:
- El `Player` posee un `Inventory` (unique ownership)
- Los `Items` pueden estar en múltiples inventarios (shared ownership)
- El `UI` observa el inventario sin poseerlo (weak reference)

```cpp
class Item {
public:
    std::string name;
    int value;
    
    Item(std::string n, int v) : name(n), value(v) {}
};

class Inventory {
private:
    std::vector<std::shared_ptr<Item>> items_;
    
public:
    void AddItem(std::shared_ptr<Item> item) {
        items_.push_back(item);
    }
    
    int GetTotalValue() const {
        int total = 0;
        for (const auto& item : items_) {
            total += item->value;
        }
        return total;
    }
};

class Player {
private:
    std::unique_ptr<Inventory> inventory_;
    
public:
    Player() : inventory_(std::make_unique<Inventory>()) {}
    
    Inventory* GetInventory() { return inventory_.get(); }
};

class InventoryUI {
private:
    std::weak_ptr<Inventory> observedInventory_;
    
public:
    void ObserveInventory(std::shared_ptr<Inventory> inv) {
        observedInventory_ = inv;
    }
    
    void Update() {
        if (auto inv = observedInventory_.lock()) {
            std::cout << "Total value: " << inv->GetTotalValue() << "\n";
        } else {
            std::cout << "Inventory no longer exists\n";
        }
    }
};
```

### 📝 Ejercicio 2: Sistema de Partículas

Crea un sistema donde:
- El `ParticleSystem` gestiona múltiples `Emitters`
- Los `Emitters` comparten `Textures`
- Las partículas tienen referencias débiles a su emisor

```cpp
class Texture {
public:
    std::string path;
    Texture(std::string p) : path(p) {
        std::cout << "Texture loaded: " << path << "\n";
    }
    ~Texture() {
        std::cout << "Texture unloaded: " << path << "\n";
    }
};

class Emitter : public std::enable_shared_from_this<Emitter> {
private:
    std::shared_ptr<Texture> texture_;
    std::string name_;
    
public:
    Emitter(std::string name, std::shared_ptr<Texture> tex)
        : name_(name), texture_(tex) {}
    
    void SpawnParticle() {
        // La partícula obtiene una referencia débil al emisor
        auto particle = std::make_shared<Particle>(shared_from_this());
    }
    
    std::string GetName() const { return name_; }
};

class Particle {
private:
    std::weak_ptr<Emitter> emitter_;
    
public:
    Particle(std::shared_ptr<Emitter> emitter) : emitter_(emitter) {}
    
    void Update() {
        if (auto emitter = emitter_.lock()) {
            std::cout << "Particle from: " << emitter->GetName() << "\n";
        } else {
            std::cout << "Emitter destroyed, particle orphaned\n";
        }
    }
};

class ParticleSystem {
private:
    std::vector<std::unique_ptr<Emitter>> emitters_;
    
public:
    void AddEmitter(std::unique_ptr<Emitter> emitter) {
        emitters_.push_back(std::move(emitter));
    }
};
```

---

## ⚠️ Errores Comunes y Cómo Evitarlos

### 🐛 Error 1: Mezclar Smart Pointers con Raw Pointers

```cpp
// ❌ MAL: Crear shared_ptr desde raw pointer dos veces
Enemy* rawPtr = new Enemy();
std::shared_ptr<Enemy> ptr1(rawPtr); // Control block #1
std::shared_ptr<Enemy> ptr2(rawPtr); // Control block #2 ❌
// Double delete cuando ambos se destruyen

// ✅ BIEN: Usar make_shared
auto ptr1 = std::make_shared<Enemy>();
auto ptr2 = ptr1; // Comparte el mismo control block
```

### 🐛 Error 2: Usar `shared_from_this()` Incorrectamente

```cpp
class Enemy : public std::enable_shared_from_this<Enemy> {
public:
    void BadMethod() {
        RegisterSelf();
    }
    
private:
    void RegisterSelf() {
        // ❌ Si se llama antes de que exista un shared_ptr = CRASH
        auto self = shared_from_this();
        GameSystem::Register(self);
    }
};

// ❌ Esto crashea
Enemy enemy;
enemy.BadMethod(); // No existe shared_ptr aún

// ✅ Esto funciona
auto enemy = std::make_shared<Enemy>();
enemy->BadMethod();
```

### 🐛 Error 3: Almacenar `this` en un Container

```cpp
class Enemy {
public:
    void RegisterSelf() {
        // ❌ NUNCA hagas esto
        enemyList.push_back(this); // Raw pointer = peligro
        
        // ❌ Tampoco esto (si no heredas de enable_shared_from_this)
        enemyList.push_back(std::shared_ptr<Enemy>(this));
    }
};

// ✅ Solución: Heredar de enable_shared_from_this
class Enemy : public std::enable_shared_from_this<Enemy> {
public:
    void RegisterSelf() {
        enemyList.push_back(shared_from_this());
    }
};
```

### 🐛 Error 4: Ciclos de Referencias

```cpp
// ❌ Esto es un memory leak
struct Node {
    std::shared_ptr<Node> next;
    std::shared_ptr<Node> prev; // ❌ Ciclo!
};

auto node1 = std::make_shared<Node>();
auto node2 = std::make_shared<Node>();

node1->next = node2; // node2 ref=2
node2->prev = node1; // node1 ref=2

// Al salir del scope:
// node1 ref: 2 → 1 (no se destruye)
// node2 ref: 2 → 1 (no se destruye)
// ❌ MEMORY LEAK

// ✅ Solución: Usar weak_ptr
struct Node {
    std::shared_ptr<Node> next;
    std::weak_ptr<Node> prev; // ✅ Rompe el ciclo
};
```

### 🐛 Error 5: Reset Incorrecto

```cpp
std::shared_ptr<Enemy> enemy = std::make_shared<Enemy>();
std::shared_ptr<Enemy> backup = enemy;

// ❌ Esto NO destruye el objeto
enemy.reset(); // Solo libera la referencia de 'enemy'
// backup aún mantiene el objeto vivo

// ✅ Para destruir forzadamente
enemy.reset();
backup.reset(); // Ahora sí se destruye (ref=0)

// 🔍 Verificar cuántas referencias quedan
std::cout << enemy.use_count(); // 0
std::cout << backup.use_count(); // 0
```

---

## 🎯 Best Practices (Mejores Prácticas)

### ✅ 1. Prefiere `make_unique` y `make_shared`

```cpp
// ❌ Evita esto (C++11)
std::unique_ptr<Enemy> enemy(new Enemy());

// ✅ Usa esto (C++14+)
auto enemy = std::make_unique<Enemy>();

// Razones:
// 1. Más corto y legible
// 2. Exception-safe (en caso de múltiples parámetros)
// 3. make_shared es más eficiente (una sola allocación)
```

### ✅ 2. Usa `auto` con Smart Pointers

```cpp
// ❌ Verboso
std::unique_ptr<WeaponSystem> weapons = std::make_unique<WeaponSystem>();

// ✅ Más limpio
auto weapons = std::make_unique<WeaponSystem>();

// El tipo es obvio por el constructor
```

### ✅ 3. Pasa Smart Pointers por Referencia

```cpp
// ❌ Ineficiente (copia innecesaria, incrementa ref count)
void ProcessEnemy(std::shared_ptr<Enemy> enemy) {
    enemy->Update();
}

// ✅ Eficiente (no copia, no incrementa ref count)
void ProcessEnemy(const std::shared_ptr<Enemy>& enemy) {
    enemy->Update();
}

// ✅ Mejor aún: Si no necesitas ownership, usa raw pointer
void ProcessEnemy(Enemy* enemy) {
    if (enemy) enemy->Update();
}
```

### ✅ 4. Retorna por Valor, no por Referencia

```cpp
// ❌ Peligroso
const std::shared_ptr<Enemy>& GetEnemy() {
    static std::shared_ptr<Enemy> enemy = std::make_shared<Enemy>();
    return enemy;
}

// ✅ Seguro (RVO/NRVO elimina la copia)
std::shared_ptr<Enemy> GetEnemy() {
    return std::make_shared<Enemy>();
}
```

### ✅ 5. Usa `.get()` Solo Cuando Sea Necesario

```cpp
std::unique_ptr<Enemy> enemy = std::make_unique<Enemy>();

// ❌ Innecesario
Enemy* raw = enemy.get();
raw->Update();

// ✅ Usa directamente
enemy->Update();

// ✅ .get() es útil para APIs de C o funciones que requieren raw pointer
LegacyFunction(enemy.get());
```

### ✅ 6. Verifica Antes de Usar `weak_ptr`

```cpp
std::weak_ptr<Enemy> weakEnemy;

// ❌ No seguro
auto enemy = weakEnemy.lock();
enemy->TakeDamage(10); // Puede ser nullptr!

// ✅ Siempre verifica
if (auto enemy = weakEnemy.lock()) {
    enemy->TakeDamage(10);
} else {
    std::cout << "Enemy ya no existe\n";
}
```

---

## 📊 Comparación de Performance

### ⏱️ Benchmarks Aproximados

```cpp
// Creación de 1,000,000 objetos
┌─────────────────────────┬──────────┬───────────┐
│ Método                  │ Tiempo   │ Memoria   │
├─────────────────────────┼──────────┼───────────┤
│ Raw pointer (new/delete)│ ~100ms   │ 8 bytes   │
│ unique_ptr              │ ~105ms   │ 8 bytes   │
│ shared_ptr              │ ~150ms   │ 16 bytes  │
│ make_shared             │ ~130ms   │ 16 bytes* │
└─────────────────────────┴──────────┴───────────┘

* make_shared es más eficiente porque hace una sola
  allocación para objeto + control block
```

### 🎯 Cuándo Preocuparse por Performance

**NO te preocupes en:**
- Juegos modernos (el overhead es mínimo)
- Sistemas de alto nivel (UI, GamePlay, IA)
- Objetos de larga duración (Managers, Sistemas)

**SÍ considera alternativas en:**
- Tight loops (millones de iteraciones por frame)
- Sistemas de partículas masivos (10k+ partículas)
- Pooling de objetos pequeños de alta frecuencia

```cpp
// ⚠️ En hot paths críticos, considera object pooling
class ParticlePool {
private:
    std::vector<std::unique_ptr<Particle>> pool_;
    std::vector<Particle*> active_;
    
public:
    Particle* Acquire() {
        if (pool_.empty()) {
            pool_.push_back(std::make_unique<Particle>());
        }
        auto particle = pool_.back().get();
        active_.push_back(particle);
        pool_.pop_back();
        return particle; // Raw pointer OK aquí
    }
    
    void Release(Particle* p) {
        active_.erase(std::remove(active_.begin(), active_.end(), p));
        pool_.push_back(std::unique_ptr<Particle>(p));
    }
};
```

---

## 🔗 Integración con Unreal Engine

### 🎮 Smart Pointers de Unreal vs STL

Unreal Engine tiene sus propios smart pointers que debes conocer:

```cpp
// STL (C++ estándar)          →  Unreal Engine
std::unique_ptr<T>             →  TUniquePtr<T>
std::shared_ptr<T>             →  TSharedPtr<T>
std::weak_ptr<T>               →  TWeakPtr<T>
std::enable_shared_from_this   →  TSharedFromThis<T>
```

### ⚙️ Cuándo Usar Cada Uno

```cpp
// ✅ Para UObject (clases de Unreal)
UPROPERTY()
UTexture2D* Texture; // Usa el Garbage Collector de Unreal

// ✅ Para clases C++ puras (no UObject)
TSharedPtr<FCustomData> Data; // Usa smart pointers de Unreal

// ✅ Para código portable o bibliotecas externas
std::shared_ptr<ExternalLibData> LibData; // Usa STL
```

### 🔄 Conversión entre Sistemas

```cpp
// Unreal → STL (requiere cuidado)
TSharedPtr<FMyData> unrealPtr = MakeShared<FMyData>();
std::shared_ptr<FMyData> stdPtr(
    unrealPtr.Get(),
    [unrealPtr](FMyData*) mutable { unrealPtr.Reset(); }
);

// Mejor: Evita mezclarlos, usa consistentemente uno u otro
```

### 📝 Ejemplo Completo en Unreal

```cpp
// MyActor.h
#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "MyActor.generated.h"

// Clase C++ pura para datos complejos
class FWeaponData : public TSharedFromThis<FWeaponData> {
public:
    FString Name;
    float Damage;
    
    TSharedRef<FWeaponData> AsShared() {
        return AsShared();
    }
};

UCLASS()
class MYGAME_API AMyActor : public AActor {
    GENERATED_BODY()
    
private:
    // ✅ UObject: usa UPROPERTY (Garbage Collector)
    UPROPERTY()
    UStaticMeshComponent* MeshComponent;
    
    // ✅ C++ puro: usa TSharedPtr
    TSharedPtr<FWeaponData> WeaponData;
    
    // ✅ Propiedad exclusiva: usa TUniquePtr
    TUniquePtr<FComplexSystem> System;
    
public:
    AMyActor() {
        MeshComponent = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
        WeaponData = MakeShared<FWeaponData>();
        System = MakeUnique<FComplexSystem>();
    }
};
```

---

## 🎓 Quiz de Autoevaluación

### Pregunta 1
```cpp
std::unique_ptr<Enemy> enemy1 = std::make_unique<Enemy>();
std::unique_ptr<Enemy> enemy2 = enemy1; // ¿Compila?
```
<details>
<summary>Ver respuesta</summary>

❌ **NO compila**. `unique_ptr` no es copiable. Debes usar `std::move(enemy1)`.
</details>

### Pregunta 2
```cpp
auto enemy = std::make_shared<Enemy>();
std::weak_ptr<Enemy> weak = enemy;
enemy.reset();
auto ptr = weak.lock(); // ¿Qué contiene ptr?
```
<details>
<summary>Ver respuesta</summary>

**`nullptr`**. El objeto fue destruido cuando hicimos `reset()`, así que `lock()` devuelve un `shared_ptr` vacío.
</details>

### Pregunta 3
¿Cuál es más eficiente y por qué?
```cpp
// A)
auto enemy = std::make_shared<Enemy>();

// B)
std::shared_ptr<Enemy> enemy(new Enemy());
```
<details>
<summary>Ver respuesta</summary>

**A) `make_shared`** es más eficiente porque hace **una sola allocación** (objeto + control block juntos), mientras que B) hace **dos allocaciones** separadas.
</details>

### Pregunta 4
```cpp
class Enemy : public std::enable_shared_from_this<Enemy> {
public:
    std::shared_ptr<Enemy> GetSelf() {
        return shared_from_this();
    }
};

Enemy enemy; // Stack
auto ptr = enemy.GetSelf(); // ¿Qué pasa?
```
<details>
<summary>Ver respuesta</summary>

❌ **Lanza `std::bad_weak_ptr`**. `shared_from_this()` solo funciona si el objeto fue creado con `make_shared` o `shared_ptr`.
</details>

---

## 🏆 Conclusión

Los **smart pointers** son una de las características más importantes de C++ moderno. Dominarlos te hace un mejor programador y tu código más seguro y mantenible.

### 🎯 Puntos Clave para Recordar

1. **C++11+ requerido**: Smart pointers no existen en C++98/03
2. **RAII automático**: No necesitas `delete` manual
3. **unique_ptr por defecto**: Úsalo a menos que necesites shared ownership
4. **shared_ptr para recursos compartidos**: Múltiples dueños
5. **weak_ptr para romper ciclos**: Referencias sin ownership
6. **enable_shared_from_this**: Para crear shared_ptr del objeto mismo
7. **Prefiere make_unique/make_shared**: Más seguro y eficiente
8. **En Unreal**: Usa los smart pointers de Unreal (TSharedPtr, etc.)

### 🚀 Próximos Pasos

- Practica con los ejercicios propuestos
- Refactoriza código viejo con `new`/`delete` a smart pointers
- Estudia los smart pointers de Unreal Engine (TSharedPtr, TWeakPtr, TUniquePtr)
- Investiga move semantics y perfect forwarding (C++11+)

**¡Feliz coding! 🎮💻**