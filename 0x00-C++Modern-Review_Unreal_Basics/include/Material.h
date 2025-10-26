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
