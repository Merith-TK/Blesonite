bl_info = {
    "name": "Blue DLL Runner",
    "blender": (4, 0, 0),
    "category": "Development",
    "author": "Merith, wav3",
    "version": (1, 0, 0),
    "description": "Runs Resonite in Blender",
}

import bpy
import os

def load_blue_dll():
    try:
        from pythonnet import load
        load("coreclr")
        import clr
        from System.Reflection import Assembly
        from System.IO import Directory

        addon_dir = os.path.dirname(__file__)
        dll_path = os.path.join(addon_dir, "Blue.dll")
        Directory.SetCurrentDirectory(addon_dir)
        asm = Assembly.LoadFrom(dll_path)
        runner_type = asm.GetType("Blue.FrooxEngineRunner", True)
        instance = clr.System.Activator.CreateInstance(runner_type)
        print("✅ Blue.FrooxEngineRunner loaded and instantiated.")
    except Exception as e:
        print("❌ Failed to load Blue.dll:", e)

class BLUE_OT_Load(bpy.types.Operator):
    bl_idname = "blue.load"
    bl_label = "Load Blue.dll"

    def execute(self, context):
        load_blue_dll()
        return {'FINISHED'}

def menu_func(self, context):
    self.layout.operator(BLUE_OT_Load.bl_idname)

def register():
    bpy.utils.register_class(BLUE_OT_Load)
    bpy.types.TOPBAR_MT_app_system.append(menu_func)

def unregister():
    bpy.types.TOPBAR_MT_app_system.remove(menu_func)
    bpy.utils.unregister_class(BLUE_OT_Load)
