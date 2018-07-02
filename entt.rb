class Entt < Formula
  desc "Fast and reliable entity-component system and much more"
  homepage "https://skypjack.github.io/entt/"
  url "https://github.com/skypjack/entt/archive/v2.7.1.tar.gz"
  sha256 "50a0387889aa3a28ba24424a2be71d60884aa46534cc0742883c8e7729ed68bc"
  head "https://github.com/skypjack/entt.git"

  option "with-docs", "Build the documentation with cmake and doxygen --with-graphviz"

  depends_on "cmake" => :build if build.with? "docs"
  depends_on "doxygen" => [:build, "with-graphviz"] if build.with? "docs"

  def install
    if build.with? "docs"
      cd "build"
      system "cmake", "..", "-DBUILD_TESTING=NO", "-DBUILD_DOCS=YES", *std_cmake_args
      system "make"
      system "make", "install"
    else
      include.install "src/entt"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <entt/entt.hpp>

      struct Position {
        int x;
        int y;
      };

      void moveSystem(entt::DefaultRegistry &reg, Position shift) {
        auto view = reg.view<Position>();
        for (const uint32_t entity : view) {
          Position &pos = view.get(entity);
          pos.x += shift.x;
          pos.y += shift.y;
        }
      }

      int main() {
        entt::DefaultRegistry reg;
        uint32_t entity = reg.create();
        reg.assign<Position>(entity, 2, 6);
        moveSystem(reg, {4, 4});

        Position expected = {6, 10};
        Position actual = reg.get<Position>(entity);
        reg.destroy(entity);

        return actual.x != expected.x || actual.y != expected.y;
      }
    EOS
    system ENV.cxx, "-std=c++14", "test.cpp", "-o", "test"
    system "./test"
  end
end
