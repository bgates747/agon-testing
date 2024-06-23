import subprocess
import os
import shutil

def do_blender(blender_script_path, blender_executable, blender_local_prefs_path, *args):
    """
    Runs Blender with the given script and optionally uses a local user preferences file.
    Dynamically accepts additional arguments to pass to the Blender script.
    
    :param blender_script_path: Path to the Blender script to run.
    :param blender_executable: Path to the Blender executable.
    :param blender_local_prefs_path: Optional path to a directory containing the userpref.blend file.
    :param args: Arbitrary list of additional arguments to pass to the Blender script.
    """
    # Environment variables for Blender
    env_vars = os.environ.copy()
    
    # If a local user preferences path is provided, set it in the environment
    if blender_local_prefs_path and os.path.exists(blender_local_prefs_path):
        env_vars["BLENDER_USER_CONFIG"] = blender_local_prefs_path
    
    # Command to run Blender in headless mode with the specified script, including additional arguments
    cmd = [
        blender_executable, 
        "-b", 
        "-P", blender_script_path, 
        "--"
    ] + [str(arg) for arg in args]  # Convert all arguments to strings and append
    
    print(' '.join(cmd))
    subprocess.run(cmd, env=env_vars)