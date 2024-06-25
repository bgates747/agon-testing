from PIL import Image, ImageDraw, ImageFont

# Define the grid size and image size
grid_size = 3
cell_size = 11  # Size of each cell
image_size = grid_size * cell_size

# Colors for each number from 1 to 9
colors = [
    (170, 0, 0), # 1 Dark red
    (0, 170, 0), # 2 Dark green
    (170, 170, 0), # 3 Olive
    (0, 0, 170), # 4 Dark blue
    (170, 0, 170), # 5 Dark magenta
    (0, 170, 170), # 6 Teal
    (170, 170, 170), # 7 Light gray
    (85, 85, 85), # 8 Gray
    (255, 0, 0)  # 9 Red
]

# Create a new image with a white background
image = Image.new('RGB', (image_size, image_size), (255, 255, 255))
draw = ImageDraw.Draw(image)

# Define font for drawing numbers
# Update this to the correct path for a TTF font on your system
font_path = "/Library/Fonts/Arial.ttf"
font = ImageFont.truetype(font_path, 16)

# Draw the grid with numbers and colors
for i in range(grid_size):
    for j in range(grid_size):
        # Calculate the position and number for the cell
        x = j * cell_size
        y = i * cell_size
        number = (i * grid_size + j) + 1
        
        # Draw the cell background color
        color = colors[number - 1]
        draw.rectangle([x, y, x + cell_size, y + cell_size], fill=color)
        
        # Draw the cell border
        draw.rectangle([x, y, x + cell_size, y + cell_size], outline=(255, 255, 255))
        
        # # Draw the number in the center of the cell
        # text = str(number)
        # text_bbox = draw.textbbox((0, 0), text, font=font)
        # text_width = text_bbox[2] - text_bbox[0]
        # text_height = text_bbox[3] - text_bbox[1]
        # text_x = x + (cell_size - text_width) / 2
        # text_y = y + (cell_size - text_height) / 2
        # draw.text((text_x, text_y), text, fill=(255, 255, 255), font=font)

# Save the image as a PNG file
image.save('grid_image.png')

# Display the image (optional)
# image.show()
