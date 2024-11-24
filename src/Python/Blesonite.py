import bpy
from pythonnet import load
load("coreclr")

import clr
from System.Reflection import *
from System.IO import *
from System import *

Directory.SetCurrentDirectory("Z:/media/relt/M2/Blendesonite/Headless2/")
Blue = Assembly.LoadFrom("Z:/media/relt/M2/Blendesonite/Headless2/Blue.dll")
Activator.CreateInstance(Blue.GetType("Blue.FrooxEngineRunner",True))