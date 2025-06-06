class Entt < Formula
  desc "Fast and reliable entity-component system and much more"
  homepage "https://skypjack.github.io/entt/"
  url "https://github.com/skypjack/entt/archive/refs/tags/v3.15.0.tar.gz"
  sha256 "01466fcbf77618a79b62891510c0bbf25ac2804af5751c84982b413852234d66"
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
        int x, y;
      };

      void moveSystem(entt::registry &reg, Position shift) {
        reg.view<Position>().each([shift](auto &pos) {
          pos.x += shift.x;
          pos.y += shift.y;
        });
      }

      int main() {
        entt::registry reg;
        const auto entity = reg.create();
        reg.assign<Position>(entity, 2, 6);
        moveSystem(reg, {4, 4});

        const Position expected = {6, 10};
        const Position actual = reg.get<Position>(entity);
        reg.destroy(entity);

        return actual.x != expected.x || actual.y != expected.y;
      }
    EOS
    system ENV.cxx, "-std=c++17", "test.cpp", "-o", "test"
    system "./test"
  end
end
