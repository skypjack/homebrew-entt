class Entt < Formula
  desc "Fast and reliable entity-component system and much more"
  homepage "https://skypjack.github.io/entt/"
  url "https://github.com/skypjack/entt/archive/v2.6.0.tar.gz"
  sha256 "48bfb34ee3c2b3704c6dfe125e65439808f18527c84af77e56a80bf382421b3e"
  head "https://github.com/skypjack/entt.git"

  option "with-docs", "Install the HTML documentation"

  depends_on "cmake" => :build if build.with? "docs"
  depends_on "doxygen" => :build if build.with? "docs"

  def install
    include.install "src/entt"
    if build.with? "docs"
      cd "build"
      system "cmake", ".."
      system "make", "docs"
      (prefix/"docs").install "docs/html"
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
