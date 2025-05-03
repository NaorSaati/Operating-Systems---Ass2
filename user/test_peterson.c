#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    int lock_id = peterson_create();
    if (lock_id < 0) {
        printf("Failed to create lock\n");
        exit(1);
    }

    printf("Created lock %d\n", lock_id);

    int fork_ret = fork();
    int role = fork_ret > 0 ? 0 : 1;

    for (int i = 0; i < 10; i++) {
        if (peterson_acquire(lock_id, role) < 0) {
            printf("Failed to acquire lock\n");
            exit(1);
        }

        // Critical section
        if (role == 0)
            printf("[PARENT] In critical section (iteration %d)\n", i);
        else
            printf("[CHILD ] In critical section (iteration %d)\n", i);

        if (peterson_release(lock_id, role) < 0) {
            printf("Failed to release lock\n");
            exit(1);
        }

    }

    if (fork_ret > 0) {
        wait(0);
        printf("Parent destroying lock\n");
        if (peterson_destroy(lock_id) < 0) {
            printf("Failed to destroy lock\n");
            exit(1);
        }
        printf("Lock destroyed\n");
    }

    exit(0);
}
