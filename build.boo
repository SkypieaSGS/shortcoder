solution_file = "src/Shortcoder.sln"
configuration40 = "release-4.0"
configuration45 = "release-4.5"
version = env("version")
build_name = ""

if version != null:
  build_name = "Shortcoder-" + version
else:
  build_name = "Shortcoder"

build_dir = "build/${build_name}"

target default, (init, compile, deploy, package, nuget):
  pass

target init:
  rmdir(build_dir)
  
desc "Compiles the solution"
target compile:
  msbuild(file: solution_file, configuration: configuration40)
  msbuild(file: solution_file, configuration: configuration45)
  
desc "Copies the binaries to the 'build' directory"
target deploy:
  print "Copying to build dir"

  with FileList("src/Shortcoder/bin/release/net40"):
    .Include("*.{dll,exe}")
    .ForEach def(file):
      file.CopyToDirectory(build_dir + "/Shortcoder/net40")
    
  with FileList("src/Shortcoder/bin/release/net45"):
    .Include("*.{dll,exe}")
    .ForEach def(file):
      file.CopyToDirectory(build_dir + "/Shortcoder/net45")
        
  print "Copy readme file to build dir"
  
  cp("README.md", build_dir + "/Shortcoder/README.txt")
      
desc "Creates zip package"
target package:
  zip(build_dir, build_dir + "/" + build_name + '.zip')

desc "Making nuget-package"
target nuget, package:
  with FileList(build_dir + "/Shortcoder/net40"):
    .Include("*.{dll,exe}")
    .ForEach def(file):
      file.CopyToDirectory("src/NuGetPackage/lib/net40")
      
  with FileList(build_dir + "/Shortcoder/net45"):
    .Include("*.{dll,exe}")
    .ForEach def(file):
      file.CopyToDirectory("src/NuGetPackage/lib/net45")
    
  with nuget_pack():
    .toolPath = "tools/nuget/nuget.exe"
    .nuspecFile = "src/NuGetPackage/Shortcoder.nuspec"
    .outputDirectory = build_dir
    .basePath = "src/NuGetPackage"
    .version = version