#include "Texture.h"

Texture::Texture(const std::string& name) : name_(name) {
    std::cout << "Texture loaded: " << name_ << "\n";
}

Texture::~Texture() {
    std::cout << "Texture unloaded: " << name_ << "\n";
}

const std::string& Texture::GetName() const {
    return name_;
}
