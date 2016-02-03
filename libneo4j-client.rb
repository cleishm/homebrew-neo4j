class Libneo4jClient < Formula
  desc "Shell client and C driver for Neo4j"
  homepage "https://cleishm.github.io/libneo4j-client/"
  url "https://github.com/cleishm/libneo4j-client/releases/download/v0.7.1/libneo4j-client-0.7.1.tar.gz"
  sha256 "8d218883d5afdaebbecc7f4cdc6a4e5e0f8ba9fa75537ae8240e790cf1b98972"

  head do
    url "https://github.com/cleishm/libneo4j-client.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
    depends_on "peg" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "openssl"

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--with-libs=#{Formula["openssl"].opt_prefix}",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
        #include <neo4j-client.h>
        #include <stdio.h>

        int main(int argc, char *argv[])
        {
            neo4j_client_init();
            neo4j_value_t v = neo4j_string("hello world");
            char buf[128];
            printf(\"%s\\n\", neo4j_tostring(v, buf, sizeof(buf)));
            neo4j_client_cleanup();
            return 0;
        }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lneo4j-client", "-o", "test"
    system "./test | grep 'hello world'"
  end
end
