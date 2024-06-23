import bpy # type: ignore

def list_images_and_users():
    image_data = {}

    # Traverse all images in the Blender file

    for img in bpy.data.images:
        print("name=%s, filepath=%s" % (img.name, img.filepath))

if __name__ == "__main__":
    list_images_and_users()
