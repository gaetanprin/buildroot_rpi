//
//  How to access GPIO registers from C-code on the Raspberry-Pi
//  Example program
//  15-January-2012
//  Dom and Gert
//  Revised: 01-01-2013

// 
// PF: Fix mmap() error code + use POSIX.4 timer
//
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <time.h>
#include <signal.h>
#include <libgen.h>
#include <string.h>
#include <sys/ioctl.h>

#include "rpi_gpio.h"

unsigned int count;
unsigned long period = 500000000; // default is 5 ms

timer_t my_timer;
unsigned long loop_prt;
int test_loops = 0;             /* outer loop count */
time_t t = 0, told = 0;
int fd;

void got_sigint (int sig) 
{
  printf ("Got SIGINT\n");

  if (timer_delete (my_timer) < 0) {
    perror ("timer_delete");
    exit (1);
  }

  close (fd);
  exit (0);
}

void got_sigalrm (int sig)
{
  struct timespec tr;
  time_t jitter;
  static time_t jitter_max = 0, jitter_avg = 0;

  told = t;

  clock_gettime (CLOCK_REALTIME, &tr);
  t = (tr.tv_sec * 1000000000) + tr.tv_nsec;    

  if (test_loops % 2)
    ioctl (fd, RPI_GPIO_SET, 0);
  else
    ioctl (fd, RPI_GPIO_CLEAR, 0);

  // Calculate jitter + display
  jitter = abs(t - told - period);
  jitter_avg += jitter;
  if (test_loops && (jitter > jitter_max))
    jitter_max = jitter;
  
  if (test_loops && !(test_loops % loop_prt)) {
    jitter_avg /= loop_prt;
    printf ("Loop= %d sec= %ld nsec= %ld delta= %ld ns jitter cur= %ld ns avg= %ld ns max= %ld ns\n", test_loops,  tr.tv_sec, tr.tv_nsec, t-told, jitter, jitter_avg, jitter_max);
    jitter_avg = 0;
  }

  test_loops++;
}

void usage (char *s)
{
  fprintf (stderr, "Usage: %s [-p period (ns)]\n", s);
  exit (1);
}

int main(int ac, char **av)
{
  char *cp, *progname = (char*)basename(av[0]);
  struct itimerspec its, its_old;
  struct timespec tr;

  signal (SIGALRM, got_sigalrm);
  signal (SIGINT, got_sigint);

  while (--ac) {
    if ((cp = *++av) == NULL)
      break;
    if (*cp == '-' && *++cp) {
      switch(*cp) {
      case 'p' :
	period = (unsigned long)atoi(*++av); break;

      default: 
	usage(progname);
	break;
      }
    }
    else
      break;
  }

  // Display every 2 sec
  loop_prt = 2000000000 / period;
  
  printf ("Using period %ld ns\n", period);

  // Open RPi GPIO driver
  if ((fd = open ("/dev/rpi_gpio_drv", O_WRONLY)) < 0) {
    perror ("open");
    exit (1);
  }

  /*
  clock_gettime (CLOCK_REALTIME, &tr);
  t = (tr.tv_sec * 1000000000) + tr.tv_nsec;    
  */

  if (timer_create (CLOCK_REALTIME, NULL, &my_timer) < 0) {
    perror ("timer_create");
    exit (1);
  }

  its.it_value.tv_sec = 0;
  its.it_value.tv_nsec = 50000000;
  its.it_interval.tv_sec = 0;
  its.it_interval.tv_nsec = period;

  if (timer_settime (my_timer, 0, &its, &its_old) < 0) {
    perror ("timer_settime");
    exit (1);
  }

  while (1)
    pause();

  return 0;
}
