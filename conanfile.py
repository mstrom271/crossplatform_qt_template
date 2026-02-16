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
        self.tool_requires("openjdk/21.0.2")

    def generate(self):
        toolchain = CMakeToolchain(self)
        os_name = str(self.settings.get_safe("os", "unknown")).lower()
        arch = str(self.settings.get_safe("arch", "unknown")).lower()
        toolchain.presets_prefix = f"{os_name}-{arch}"
        toolchain.generate()

        deps = CMakeDeps(self)
        deps.generate()

    def layout(self):
        # cmake_layout(self)
        self.folders.source = "."
        self.folders.build = "."
        self.folders.generators = "./generators"
