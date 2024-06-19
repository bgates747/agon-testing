from PIL import Image

# Create a new image with 48x64 pixels
img = Image.new('RGB', (48, 64), color='black')

# Define colors for each face
colors = {
    'top': (0, 255, 255),    # Cyan
    'left': (255, 0, 0),     # Red
    'right': (0, 255, 0),    # Green
    'front': (255, 255, 0),  # Yellow
    'back': (255, 0, 255),   # Magenta
    'bottom': (0, 0, 255)    # Blue
}

# Each face is a 16x16 pixel section of the texture
face_size = 16

# Define positions for each face
positions = {
    'front': (16, 0),
    'left': (0, 16),
    'bottom': (16, 16),
    'right': (32, 16),
    'back': (16, 32),
    'top': (16, 48)
}

# Draw each face on the image
for face, (x_offset, y_offset) in positions.items():
    color = colors[face]
    for x in range(face_size):
        for y in range(face_size):
            img.putpixel((x + x_offset, y + y_offset), color)

# Save the image
img.save('pingo/src/blender/CubeObj/colorcube.png')
