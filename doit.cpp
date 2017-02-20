#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/types.h>
#include <unistd.h>

void recurse(const char* path, int dfd) {
    DIR* dir = fdopendir(dfd);
    struct dirent* dent;

    if (!dir) {
        printf("can't opendir %s(%d)\n", path, dfd);
        return;
    }

    while (dent = readdir(dir)) {
        if (!strcmp(dent->d_name, ".") || !strcmp(dent->d_name, "..")) {
            continue;
        }
        char new_path[PATH_MAX];
        snprintf(new_path, sizeof(new_path), "%s/%s", path, dent->d_name);
        int fd = open(new_path, O_RDONLY);
        if (fd < 0) {
            printf("can't open %s: %d\n", new_path, errno);
            continue;
        }
        struct stat st;
        fstat(fd, &st);
        printf("%s: mode=%o size=%lu\n", new_path, st.st_mode, st.st_size);
        if (S_ISDIR(st.st_mode)) {
            recurse(new_path, fd);
        }
        // intentionally leak the fd here
    }
}

int main(int argc, char** argv) {
    recurse(argv[1], open(argv[1], O_RDONLY));
}
