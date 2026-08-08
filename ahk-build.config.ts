import { defineConfig } from "@alysoid/ahk-build";

export default defineConfig({
  entry: "VirtualDesktopExtension.ahk",
  app: {
    name: "Virtual Desktop Extension",
    executable: "VirtualDesktopExtension.exe",
    description: "Virtual Desktop Extension",
    copyright: "Copyright (c) 2024-2026, Andrea Brandi",
    language: "0x0409",
    icon: "icons/app.ico",
  },
  compile: {
    directives: "preserve",
    includes: ["icons"],
    assets: ["VirtualDesktopAccessor.dll", { from: "icons", to: "icons" }],
  },
  portable: {
    output: "${buildDir}/VirtualDesktopExtension-${packageVersion}.zip",
    files: [
      { from: "${buildDir}/VirtualDesktopExtension.exe", to: "VirtualDesktopExtension.exe" },
      { from: "${buildDir}/VirtualDesktopAccessor.dll", to: "VirtualDesktopAccessor.dll" },
      "LICENSE",
      { from: "${buildDir}/icons", to: "icons" },
    ],
  },
  wix: {
    source: "wix/VirtualDesktopExtension.wxs",
    output: "${buildDir}/VirtualDesktopExtension-${packageVersion}.msi",
    extensions: ["WixToolset.UI.wixext", "WixToolset.Util.wixext"],
    additionalArgs: ["-acceptEula", "wix7"],
  },
  release: {
    repository: "starise/win11-virtual-desktop-extension",
  },
  hooks: {
    beforeCompile: [{ command: "pnpm", args: ["run", "build:icons"] }],
  },
});
