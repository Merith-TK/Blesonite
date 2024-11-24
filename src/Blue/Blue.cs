using System;
using System.Reflection;
using System.Threading;
using FrooxEngine;
using Elements.Core;
using SkyFrost.Base;

[assembly:DataModelAssemblyAttribute(DataModelAssemblyType.Dependency)]
namespace Blue
{
	public class SlotConnector : Connector<Slot>, ISlotConnector, IConnector
	{
		public static Delegate SlotInitialize;
		public static Delegate SlotApplyChanges;
		public static Delegate SlotDestroy;
		public int REFID_HIGH; 
		public int REFID_LOW; 
		public Object PythonObject = null;
		
		public override void Initialize()
		{
			this.REFID_HIGH = (int)((ulong)(this.Owner.ReferenceID) >> 8);
			this.REFID_LOW = (int)((ulong)(this.Owner.ReferenceID)&255);
			SlotInitialize.DynamicInvoke(new object[]{this});
		}
		
		public override void ApplyChanges()
		{
			SlotApplyChanges.DynamicInvoke(new object[]{this});
		}
		
		public override void Destroy(bool destroyingWorld)
		{
			SlotDestroy.DynamicInvoke(new object[]{this});
		}
	}
	
	public class FrooxEngineRunner
	{
		public Engine engine;
		
		public FrooxEngineRunner()
		{
			string curdir = System.IO.Directory.GetCurrentDirectory();
			LaunchOptions launchOptions = new LaunchOptions
			{
				DataDirectory = curdir+"/../Data/",
				CacheDirectory = curdir+"/../Cache/",
				LogsDirectory = curdir+"/../Logs/",
				CloudProfile = CloudProfile.Production,
				VerboseInit = true
			};
			this.engine = new Engine();
			StandaloneSystemInfo systemInfo = new StandaloneSystemInfo();
			var configuredTaskAwaiter = this.engine.Initialize(
				curdir,
				launchOptions,
				systemInfo,
				null,
				new ConsoleEngineInitProgress()
			).ConfigureAwait(false).GetAwaiter();
			while(!configuredTaskAwaiter.IsCompleted)
			{
				Thread.Sleep(16);
			}
			var consolelogin = this.engine.Cloud.InteractiveConsoleLogin().ConfigureAwait(false).GetAwaiter();
			while(!consolelogin.IsCompleted)
			{
				
			}
			World world = Userspace.SetupUserspace(this.engine);
			this.engine.RunUpdateLoop();
			WorldStartSettings worldStart = new WorldStartSettings();
			worldStart.AutoFocus = true;
			worldStart.InitWorld = delegate(World w)
			{
				WorldPresets.Grid(w);
				w.AccessLevel = SessionAccessLevel.Anyone;
				w.ForceAnnounceOnWAN = true;
				w.MaxUsers = 16;
				w.Name = "Blesonite";
			};
			worldStart.DefaultAccessLevel = SessionAccessLevel.Anyone;
			var opener = Userspace.OpenWorld(worldStart).ConfigureAwait(false).GetAwaiter();
			new Thread(() =>
            {
				try
				{
					while(true)
					{
						this.engine.RunUpdateLoop();
						systemInfo.FrameFinished();
						Thread.Sleep(16);
					}
				}
				catch (Exception ex)
				{
					Console.WriteLine(ex.ToString() + "\n" + Environment.StackTrace);
				}
			}).Start();
		}
	}
}