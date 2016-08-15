class LibcypherParser < Formula
  desc "C parsing library and command line linter for the Cypher Query Language"
  homepage "https://cleishm.github.io/libcypher-parser/"
  url "https://github.com/cleishm/libcypher-parser/releases/download/v0.5.1/libcypher-parser-0.5.1.tar.gz"
  sha256 "bc9e3234e97b2e7c5829bfe17ed9e2f6a619a2e66144b6db7a6082e697441ead"

  head do
    url "https://github.com/cleishm/libcypher-parser.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
    depends_on "peg" => :build
  end

  depends_on "pkg-config" => :build

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
#include <cypher-parser.h>
#include <errno.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
    cypher_parse_result_t *result = cypher_parse(
            "MATCH (n) RETURN n", NULL, NULL, CYPHER_PARSE_ONLY_STATEMENTS);
    if (result == NULL)
    {
        perror("cypher_parse");
        return EXIT_FAILURE;
    }

    printf("Parsed %d AST nodes\n", cypher_parse_result_nnodes(result));
    cypher_parse_result_free(result);
    return 0;
}
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lcypher-parser", "-o", "test"
    assert_match "Parsed 10 AST nodes", shell_output("./test")
  end
end
