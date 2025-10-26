#include "Material.h"
#include "Texture.h"


Material::Material(std::shared_ptr<Texture> tex) : texture_(tex) {
    std::cout << "Material created\n";
}

Material::~Material() {
    std::cout << "Material destroyed\n";
}
