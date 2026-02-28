import os

from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain, CMakeDeps, cmake_layout

class Recipe(ConanFile):
    settings = "os", "compiler", "build_type", "arch"

    def requirements(self):
        pass

    def build_requirements(self):
        self.tool_requires("cmake/3.26.4")
        self.tool_requires("ninja/1.11.1")
        if str(self.settings.get_safe("os", "")).lower() == "android":
            self.tool_requires("openjdk/21.0.2")

    def generate(self):
        toolchain = CMakeToolchain(self)
        os_name = str(self.settings.get_safe("os", "unknown")).lower()
        arch = str(self.settings.get_safe("arch", "unknown")).lower()
        toolchain.presets_prefix = f"{os_name}-{arch}"

        # add cmake cached variables to get CLI/IDE uniform behaviour
        for name in [
            "PROJECT_NAME",
            "PROJECT_VERSION",
            "PROJECT_LABEL",
            "BUILD_NUMBER",
            "ANDROID_SDK_ROOT",
            "ANDROID_NDK",
            "ANDROID_PROJECT_NAME",
        ]:
            value = os.getenv(name)
            if value:
                toolchain.cache_variables[name] = value

        toolchain.generate()

        deps = CMakeDeps(self)
        deps.generate()

    def layout(self):
        self.folders.source = "./"
        self.folders.build = "./"
        self.folders.generators = "./generators"

    def build(self):
        target = self.conf.get("user.step:target", default="build")
        self.output.info(f"user.step:target={target}")
        cmake = CMake(self)

        match target:
            case "configure":
                self.run("bash ./scripts/translations.sh", cwd=self.recipe_folder)
                self.run("bash ./rcc/rcc.sh", cwd=self.recipe_folder)
                cmake.configure()
            case "build":
                cmake.build()
            case "package":
                self.run("bash ./scripts/package.sh", cwd=self.recipe_folder)
            case "deploy":
                self.run("bash ./scripts/deploy.sh", cwd=self.recipe_folder)
            case _:
                self.output.warning(f"Unknown user.step:target '{target}', no action executed")
