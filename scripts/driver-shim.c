/* Installed as libexec/sysroot/flux-driver, in front of Flux's own driver,
 * which sits beside it as flux-driver-real. It drops every -Zthreads=N
 * argument and runs the real driver with the rest: huacnlee/cargo passes
 * -Zthreads=8 on nightly, and Flux's driver panics under rustc's parallel
 * front end (retrieve_mir_body). It is a binary, not a script, because
 * macOS strips the DYLD_* variables rustup sets when it starts /bin/sh. */
#include <limits.h>
#include <mach-o/dyld.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv) {
    char self[PATH_MAX], real[PATH_MAX];
    uint32_t size = sizeof self;
    if (_NSGetExecutablePath(self, &size) != 0 || !realpath(self, real)) {
        fprintf(stderr, "flux-driver: cannot find its own path\n");
        return 127;
    }
    if (strlcat(real, "-real", sizeof real) >= sizeof real) return 127;
    char *args[argc + 1];
    int n = 0;
    args[n++] = real;
    for (int i = 1; i < argc; i++)
        if (strncmp(argv[i], "-Zthreads=", 10) != 0) args[n++] = argv[i];
    args[n] = NULL;
    execv(real, args);
    perror(real);
    return 127;
}
