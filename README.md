<h1 align="center">
  <img alt="cgapp logo" src="https://raw.githubusercontent.com/Indirecta-Technologies/branding/main/logos/indirecta_logo_medium500_withPill.png" width="350px"/><br/>
  Display over Bindable Protocol
</h1>
<p align="center">
  <a href="https://github.com/Indirecta-Technologies/branding">Branding</a> •
  <a href="https://github.com/Indirecta-Technologies/RFCs">RFCs</a> •
  <a href="https://github.com/Indirecta-Technologies/fosd">FOSD</a> •
  <a href="https://github.com/Indirecta-Technologies/indirectaSEA">iSEA</a> •
  <a href="https://github.com/Indirecta-Technologies/pcsi">pCsi</a> •
  <a href="https://github.com/Indirecta-Technologies/rtech-archive">rtech-archive</a> •
  <a href="https://github.com/Indirecta-Technologies/openlift">openlift</a> •
  <a href="https://github.com/Indirecta-Technologies/Rufus">Rufus</a>
</p>

# 💡 General Idea
Opensource RemoteEvent based "protocol" for communication between devices, monitors and interfaces in Xinu

> Up to Date Documentation: **https://indirecta.gitbook.io/xinu/introduction-to-xinu/outputting-to-display**

> ```lua
>device = {
>		Name = body.Name,
>		Identifier = body.Identifier,
>		Script = body.DeviceScript,
>		Object = body.Object,
>		SurfaceGui = body.SurfaceGui or nil,
>		Resolution = body.SurfaceGui and
>				{X = body.SurfaceGui.AbsoluteSize.X, Y = body.SurfaceGui.AbsoluteSize.Y} or nil,
>		TextBuffer = "",
>		LegacyTextLabel = body.LegacyTextLabel,
>		LegacyTextYLimit = body.LegacyTextYLimit,
>		DeviceType = (body.LegacyTextLabel and "LegacyMonitor" or (body.SurfaceGui and "Monitor" or (body.Object and "Device" or "Interface")));
>		CustomEchoSettings = body.CustomEchoSettings or nil;
>		CustomParams = body.CustomParams or nil;
>}
>```

It is heavily recommended to take a look at the module revision and it's code to use it appropriately.
> There are different types of devices:
> - **LegacyMonitor** --> DoB module performs size and truncation calculations, uses a buffer
> - **Monitor** --> Monitor is independent and receives the latest output
> - **Device** --> Like the monitor, it receives data independently, without a SurfaceGui
> - **Interface** --> Like the device, but it interfaces with the DoB module, the interface does not have an object/instance  
>
Before displaying an info, debug, warn, error, success preset message, the echo function is called with the device's custom echo settings, header, and text.
The echo functions handles all text manipulation like padding, time, color for RichText. This function returns a string which is in turn used by the DoB module or other modules.

# ⚗️ Use cases
Modern servers running the latest version of the Xinu HSE Kernel, feature a new module to interface with screen and output devices named DisplayOverBindable, present in the Modules folder.
This module is accessible through the Essentials table, and also uses presets in the Console table for compatibility.

```lua
Essentials.Output:OutputToAll("info","Hello world!")
```

![immagine](https://user-images.githubusercontent.com/26120324/184014566-a07e14f1-5112-413e-a8e1-781df3e69778.png)

## ⚠️ License

The DoB Protocol by Indirecta is released under the GNU GPL v3 license.



