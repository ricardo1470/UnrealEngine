#!/bin/bash

# Script para crear estructura de proyecto C++ moderno
# Uso: ./setup_cpp_project.sh [nombre_proyecto]

PROJECT_NAME="${1:-0x00-C++Modern-Review_Unreal_Basics}"

echo "🚀 Creando estructura de proyecto: $PROJECT_NAME"
echo ""

# Crear directorios
echo "📁 Creando directorios..."
mkdir -p "$PROJECT_NAME"/{include,src,build}

# Crear archivos headers
echo "📝 Creando headers..."

# Weapon.h
cat > "$PROJECT_NAME/include/Weapon.h" << 'EOF'
#ifndef WEAPON_H
#define WEAPON_H

#include <memory>
#include <string>

/**
 * @brief Abstract base class for weapons
 * Demonstrates polymorphism and unique_ptr
 */
class Weapon {
public:
    virtual ~Weapon();
    virtual void Fire() = 0;
};

class Pistol : public Weapon {
public:
    void Fire() override;
};

class Rifle : public Weapon {
public:
    void Fire() override;
};

std::unique_ptr<Weapon> CreateUniqueWeapon(const std::string& type);

#endif // WEAPON_H
EOF

# Texture.h
cat > "$PROJECT_NAME/include/Texture.h" << 'EOF'
#ifndef TEXTURE_H
#define TEXTURE_H

#include <string>

/**
 * @brief Texture class demonstrating shared_ptr
 * Can be shared among multiple materials
 */
class Texture {
public:
    explicit Texture(const std::string& name);
    ~Texture();
    
    const std::string& GetName() const;

private:
    std::string name_;
};

#endif // TEXTURE_H
EOF

# Material.h
cat > "$PROJECT_NAME/include/Material.h" << 'EOF'
#ifndef MATERIAL_H
#define MATERIAL_H

#include <memory>

class Texture;

/**
 * @brief Material class that shares Texture ownership
 * Demonstrates shared_ptr usage
 */
class Material {
public:
    explicit Material(std::shared_ptr<Texture> tex);
    ~Material();

private:
    std::shared_ptr<Texture> texture_;
};

#endif // MATERIAL_H
EOF

# Enemy.h
cat > "$PROJECT_NAME/include/Enemy.h" << 'EOF'
#ifndef ENEMY_H
#define ENEMY_H

#include <memory>

/**
 * @brief Enemy class demonstrating enable_shared_from_this
 * Allows creating shared_ptr to itself safely
 */
class Enemy : public std::enable_shared_from_this<Enemy> {
public:
    Enemy();
    
    void TakeDamage(int damage);
    bool IsAlive() const;
    std::shared_ptr<Enemy> GetSharedPtr();

private:
    int health_;
};

#endif // ENEMY_H
EOF

# Player.h
cat > "$PROJECT_NAME/include/Player.h" << 'EOF'
#ifndef PLAYER_H
#define PLAYER_H

#include <memory>

class Enemy;

/**
 * @brief Player class demonstrating weak_ptr
 * Uses weak_ptr to avoid circular references
 */
class Player {
public:
    void SetTarget(std::shared_ptr<Enemy> enemy);
    void Attack();

private:
    std::weak_ptr<Enemy> target_;
};

#endif // PLAYER_H
EOF

# Crear archivos de implementación
echo "⚙️  Creando implementaciones..."

# Weapon.cpp
cat > "$PROJECT_NAME/src/Weapon.cpp" << 'EOF'
#include "Weapon.h"
#include <iostream>

Weapon::~Weapon() {
    std::cout << "Weapon destroyed\n";
}

void Pistol::Fire() {
    std::cout << "Bang!\n";
}

void Rifle::Fire() {
    std::cout << "Rat-a-tat-tat!\n";
}

std::unique_ptr<Weapon> CreateUniqueWeapon(const std::string& type) {
    if (type == "pistol") {
        return std::make_unique<Pistol>();
    } else if (type == "rifle") {
        return std::make_unique<Rifle>();
    }
    return nullptr;
}
EOF

# Texture.cpp
cat > "$PROJECT_NAME/src/Texture.cpp" << 'EOF'
#include "Texture.h"
#include <iostream>

Texture::Texture(const std::string& name) : name_(name) {
    std::cout << "Texture loaded: " << name_ << "\n";
}

Texture::~Texture() {
    std::cout << "Texture unloaded: " << name_ << "\n";
}

const std::string& Texture::GetName() const {
    return name_;
}
EOF

# Material.cpp
cat > "$PROJECT_NAME/src/Material.cpp" << 'EOF'
#include "Material.h"
#include "Texture.h"
#include <iostream>

Material::Material(std::shared_ptr<Texture> tex) : texture_(tex) {
    std::cout << "Material created\n";
}

Material::~Material() {
    std::cout << "Material destroyed\n";
}
EOF

# Enemy.cpp
cat > "$PROJECT_NAME/src/Enemy.cpp" << 'EOF'
#include "Enemy.h"
#include <iostream>

Enemy::Enemy() : health_(100) {
    std::cout << "Enemy created with " << health_ << " health\n";
}

void Enemy::TakeDamage(int damage) {
    health_ -= damage;
    std::cout << "Enemy health: " << health_ << "\n";
}

bool Enemy::IsAlive() const {
    return health_ > 0;
}

std::shared_ptr<Enemy> Enemy::GetSharedPtr() {
    return shared_from_this();
}
EOF

# Player.cpp
cat > "$PROJECT_NAME/src/Player.cpp" << 'EOF'
#include "Player.h"
#include "Enemy.h"
#include <iostream>

void Player::SetTarget(std::shared_ptr<Enemy> enemy) {
    target_ = enemy;
    std::cout << "Target set\n";
}

void Player::Attack() {
    if (auto enemy = target_.lock()) {
        if (enemy->IsAlive()) {
            std::cout << "Attacking target...\n";
            enemy->TakeDamage(25);
        } else {
            std::cout << "Enemy is already dead!\n";
        }
    } else {
        std::cout << "Target is gone!\n";
    }
}
EOF

# main.cpp
cat > "$PROJECT_NAME/src/main.cpp" << 'EOF'
#include "Weapon.h"
#include "Texture.h"
#include "Material.h"
#include "Enemy.h"
#include "Player.h"
#include <iostream>

/**
 * @brief Main function demonstrating smart pointer usage
 * Tests unique_ptr, shared_ptr, weak_ptr, and enable_shared_from_this
 */
int main() {
    std::cout << "=== Smart Pointers Demo ===\n\n";
    
    // Test 1: unique_ptr
    std::cout << "=== Test 1: unique_ptr (Exclusive Ownership) ===\n";
    {
        auto pistol = CreateUniqueWeapon("pistol");
        if (pistol) {
            pistol->Fire();
        }
        
        auto rifle = CreateUniqueWeapon("rifle");
        if (rifle) {
            rifle->Fire();
        }
        std::cout << "Leaving scope, weapons will be destroyed...\n";
    }
    std::cout << "\n";
    
    // Test 2: shared_ptr
    std::cout << "=== Test 2: shared_ptr (Shared Ownership) ===\n";
    {
        auto texture = std::make_shared<Texture>("brick.png");
        std::cout << "Texture ref count: " << texture.use_count() << "\n";
        
        {
            Material mat1(texture);
            std::cout << "After mat1, ref count: " << texture.use_count() << "\n";
            
            Material mat2(texture);
            std::cout << "After mat2, ref count: " << texture.use_count() << "\n";
            
            std::cout << "Materials going out of scope...\n";
        }
        
        std::cout << "After materials destroyed, ref count: " 
                  << texture.use_count() << "\n";
    }
    std::cout << "\n";
    
    // Test 3: weak_ptr
    std::cout << "=== Test 3: weak_ptr (Non-owning Reference) ===\n";
    Player player;
    {
        auto enemy = std::make_shared<Enemy>();
        player.SetTarget(enemy);
        
        std::cout << "Attacking while enemy exists:\n";
        player.Attack();
        player.Attack();
        
        std::cout << "Enemy about to be destroyed...\n";
    }
    
    std::cout << "Attacking after enemy destroyed:\n";
    player.Attack();
    std::cout << "\n";
    
    // Test 4: enable_shared_from_this
    std::cout << "=== Test 4: enable_shared_from_this ===\n";
    {
        auto enemy = std::make_shared<Enemy>();
        auto sameEnemy = enemy->GetSharedPtr();
        
        std::cout << "Both pointers point to same enemy: " 
                  << (enemy == sameEnemy ? "YES" : "NO") << "\n";
        std::cout << "Ref count: " << enemy.use_count() << "\n";
    }
    
    std::cout << "\n=== Demo Complete ===\n";
    return 0;
}
EOF

# Crear CMakeLists.txt
echo "🔧 Creando CMakeLists.txt..."
cat > "$PROJECT_NAME/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.10)
project(SmartPointersDemo VERSION 1.0 LANGUAGES CXX)

# C++ Standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Compiler flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Include directories
include_directories(${PROJECT_SOURCE_DIR}/include)

# Source files
set(SOURCES
    src/main.cpp
    src/Weapon.cpp
    src/Texture.cpp
    src/Material.cpp
    src/Enemy.cpp
    src/Player.cpp
)

# Executable
add_executable(${PROJECT_NAME} ${SOURCES})

# Output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Print configuration
message(STATUS "Project: ${PROJECT_NAME}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
EOF

# Crear Makefile alternativo (sin CMake)
echo "🛠️  Creando Makefile alternativo..."
cat > "$PROJECT_NAME/Makefile" << 'EOF'
# Compiler
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -Wpedantic -I./include

# Directories
SRC_DIR = src
BUILD_DIR = build
BIN_DIR = bin

# Target executable
TARGET = $(BIN_DIR)/SmartPointers

# Source files
SOURCES = $(wildcard $(SRC_DIR)/*.cpp)
OBJECTS = $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/%.o,$(SOURCES))

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
NC = \033[0m # No Color

# Default target
all: directories $(TARGET)

# Create directories
directories:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR)

# Link
$(TARGET): $(OBJECTS)
	@echo "$(GREEN)Linking executable...$(NC)"
	$(CXX) $(CXXFLAGS) -o $@ $^
	@echo "$(GREEN)Build complete! Executable: $(TARGET)$(NC)"

# Compile
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@echo "$(YELLOW)Compiling $<...$(NC)"
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean
clean:
	@echo "$(YELLOW)Cleaning build files...$(NC)"
	rm -rf $(BUILD_DIR) $(BIN_DIR)
	@echo "$(GREEN)Clean complete!$(NC)"

# Run
run: all
	@echo "$(GREEN)Running program...$(NC)"
	@echo ""
	@./$(TARGET)

# Help
help:
	@echo "Available targets:"
	@echo "  all     - Build the project (default)"
	@echo "  clean   - Remove build files"
	@echo "  run     - Build and run the project"
	@echo "  help    - Show this help message"

.PHONY: all clean run help directories
EOF


# Crear .gitignore
echo "🔒 Creando .gitignore..."
cat > "$PROJECT_NAME/.gitignore" << 'EOF'
# Build directories
build/
bin/
*.o
*.out

# CMake
CMakeCache.txt
CMakeFiles/
cmake_install.cmake
Makefile

# Executables
SmartPointers
SmartPointersDemo

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db
EOF

# Resumen
echo ""
echo "✅ Estructura del proyecto creada exitosamente!"
echo ""
echo "📂 Estructura generada:"
tree -L 2 "$PROJECT_NAME" 2>/dev/null || find "$PROJECT_NAME" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
echo ""
echo "🚀 Próximos pasos:"
echo ""
echo "  cd $PROJECT_NAME"
echo ""
echo "  # Opción 1: Compilar con CMake"
echo "  mkdir -p build && cd build"
echo "  cmake .."
echo "  cmake --build ."
echo "  ./bin/SmartPointersDemo"
echo ""
echo "  # Opción 2: Compilar con Makefile"
echo "  make run"
echo ""
echo "🎉 ¡Listo para empezar!"