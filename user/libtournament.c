#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/petersonlock.h"

// Global variables for the tournament tree
static int proc_id = 0;  // ID of the current process in the tournament
static int num_processes = 0;   // Number of processes in the tournament
static int num_levels = 0;      // Number of levels in the tournament tree
static int *lock_ids = 0;       // Array of Peterson lock IDs

int tournament_create(int processes) {
    // Check if the number of processes is valid
    if (processes <= 0 || processes > 16 || (processes & (processes - 1)) != 0) {
        return -1; 
    }

    num_processes = processes;
    lock_ids = malloc(sizeof(int) * (num_processes - 1)); // N-1 lockers fo binary tree
    if (!lock_ids) {
        return -1;  // Memory allocation failed
    }

    for (int i = 0; i < processes - 1; i++) {
        lock_ids[i] = peterson_create();
        if (lock_ids[i] < 0) {
            for (int j = 0; j < i; j++) {
                peterson_destroy(lock_ids[j]);
            }
            free(lock_ids);
            lock_ids = 0;
            return -1;
        }
    }

    // Calculating the number of levels in a tree
    num_levels = 0;
    int temp = num_processes;
    while (temp > 1) {
        temp >>= 1;
        num_levels++;
    }

    for (int i = 1; i < processes; i++) { // Creating processes with fork()
        int pid = fork();
        if (pid < 0) {
            printf("fork failed!\n");
            return -1;
        }
        if (pid == 0) { // Each fork() creates another process with a different ID (in the loop)
            proc_id = i;
            return proc_id;
        }
    }
    return proc_id;
}


int tournament_acquire(void) {
    if (num_processes == 0 || num_levels == 0 || lock_ids == 0) {
        return -1;  // Tournament not initialized
    }

    int node = proc_id, role;
    for (int i = num_levels - 1; i >= 0; i--) {
        // Calculating the "role" of current level
        int shift = num_levels - i - 1;
        role = (proc_id & (1 << shift)) >> shift;

        // Calculate the index of the lock at this level
        int lock_level_idx = proc_id >> (num_levels - i);
        node = lock_level_idx + (1 << i) - 1;

        if (peterson_acquire(node, role) < 0) {
            printf("failed to acquire: %d \n", proc_id);
            for (int j = i; j < num_levels; j++) {
                int shift2 = num_levels - j - 1;
                int r = (proc_id & (1 << shift2)) >> shift2;
                int li = (proc_id >> (num_levels - j)) + (1 << j) - 1;
                if (peterson_release(li, r) < 0) {
                    return -1;
                }
            }
            return -1;
        }
    }

    return 0;
}


int tournament_release(void) {
    int node = proc_id, role;
    for (int i = 0; i < num_levels; i++) {
        // Calculate the "role"
        int shift = num_levels - i - 1;
        role = (proc_id & (1 << shift)) >> shift;

        // Calculating the index of the lock
        int lock_level_idx = proc_id >> (num_levels - i);
        node = lock_level_idx + (1 << i) - 1;

        if (peterson_release(node, role) < 0) {
            return -1;
        }
    }
    return 0;
}
