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
