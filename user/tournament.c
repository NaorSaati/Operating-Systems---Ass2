#include "user.h"

#define MAX_PROCESSES 16

int
main(int argc, char *argv[]) {
  if (argc != 2) {
    fprintf(2, "Usage: tournament <num_processes>\n");
    exit(1);
  }

  int n = atoi(argv[1]);
  if (n < 2 || n > MAX_PROCESSES) {
    fprintf(2, "Number of processes must be between 2 and 16\n");
    exit(1);
  }

  int index = tournament_create(n);
  if (index < 0) {
    fprintf(2, "tournament_create failed\n");
    exit(1);
  }

  sleep(10); // waiting for all the process created
  if (tournament_acquire() < 0) {
    fprintf(2, "Process %d failed to acquire tournament lock\n", index);
    exit(1);
  }

  printf("[PID %d] Tournament ID %d ENTERED critical section\n", getpid(), index);

  sleep(20);

  printf("[PID %d] Tournament ID %d EXITING critical section\n", getpid(), index);

  if (tournament_release() < 0) {
    fprintf(2, "Process %d failed to release tournament lock\n", index);
    exit(1);
  }

  exit(0);
}
