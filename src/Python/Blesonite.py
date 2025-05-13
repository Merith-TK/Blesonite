import os
addon_dir = os.path.dirname(__file__)
dll_path = os.path.join(addon_dir, "Blue.dll")
Directory.SetCurrentDirectory(addon_dir)
Blue = Assembly.LoadFrom(dll_path)
Activator.CreateInstance(Blue.GetType("Blue.FrooxEngineRunner",True))
