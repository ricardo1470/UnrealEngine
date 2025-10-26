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
