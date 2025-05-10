# Makefile for POKEY emulator library
# Compiles the POKEY emulator into a shared library (.so)

# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++14 -Wall -Wextra -pedantic -fPIC -O2
LDFLAGS = -shared -lm

# Directories
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = lib
INCLUDE_DIR = include

# Target
TARGET = $(BIN_DIR)/libpokey.so

# Source files
SRCS = $(wildcard $(SRC_DIR)/*.cpp)
OBJS = $(SRCS:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.o)

# Make sure the directories exist
$(shell mkdir -p $(OBJ_DIR) $(BIN_DIR))

# Default target
all: $(TARGET)

# Build the shared library
$(TARGET): $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $^

# Compile source files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -I$(INCLUDE_DIR) -c $< -o $@

# Clean build artifacts
clean:
	rm -rf $(OBJ_DIR)/*.o $(TARGET)

# Clean everything, including directories
cleanall: clean
	rm -rf $(OBJ_DIR) $(BIN_DIR)

# Install the library to system directory (requires root)
install: $(TARGET)
	install -m 755 $(TARGET) /usr/local/lib/
	ldconfig

# Python example
python_example: $(TARGET)
	python3 examples/pokey_test.py

# Rebuild everything
rebuild: clean all

.PHONY: all clean cleanall install python_example rebuild