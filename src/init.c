/*
 * SparkOS Init - Minimal init system for SparkOS
 * This is the first process that runs after the kernel boots
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/reboot.h>
#include <signal.h>
#include <errno.h>
#include <string.h>

// Default user configuration
#define SPARK_UID 1000
#define SPARK_GID 1000
#define SPARK_HOME "/home/spark"
#define SPARK_USER "spark"

static void signal_handler(int sig) {
    if (sig == SIGCHLD) {
        // Reap zombie processes
        while (waitpid(-1, NULL, WNOHANG) > 0);
    }
}

static void spawn_shell() {
    pid_t pid = fork();
    
    if (pid < 0) {
        perror("fork failed");
        return;
    }
    
    if (pid == 0) {
        // Child process - exec shell as spark user
        
        // Set user and group IDs to spark user
        if (setgid(SPARK_GID) != 0) {
            perror("setgid failed");
            exit(1);
        }
        if (setuid(SPARK_UID) != 0) {
            perror("setuid failed");
            exit(1);
        }
        
        char *argv[] = {"/bin/sh", "-l", NULL};
        char *envp[] = {
            "HOME=" SPARK_HOME,
            "PATH=/bin:/sbin:/usr/bin:/usr/sbin",
            "TERM=linux",
            "PS1=SparkOS$ ",
            "USER=" SPARK_USER,
            "LOGNAME=" SPARK_USER,
            NULL
        };
        
        // Change to home directory
        if (chdir(SPARK_HOME) != 0) {
            perror("chdir failed");
        }
        
        execve("/bin/sh", argv, envp);
        
        perror("failed to exec shell");
        exit(1);
    }
    
    // Parent process - wait for shell to exit
    int status;
    waitpid(pid, &status, 0);
}

int main(int argc, char *argv[]) {
    printf("SparkOS Init System Starting...\n");
    
    // Make sure we're PID 1
    if (getpid() != 1) {
        fprintf(stderr, "init must be run as PID 1\n");
        return 1;
    }
    
    // Set up signal handlers
    signal(SIGCHLD, signal_handler);
    
    // Mount essential filesystems
    printf("Mounting essential filesystems...\n");
    if (system("mount -t proc proc /proc 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to mount /proc\n");
    }
    if (system("mount -t sysfs sys /sys 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to mount /sys\n");
    }
    if (system("mount -t devtmpfs dev /dev 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to mount /dev\n");
    }
    if (system("mount -t tmpfs tmpfs /tmp 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to mount /tmp\n");
    }
    
    // Set up overlay filesystem for immutable base OS
    printf("Setting up overlay filesystem for writable layer...\n");
    
    // Create overlay directories in tmpfs
    if (system("mkdir -p /tmp/overlay/upper /tmp/overlay/work 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to create overlay directories\n");
    }
    
    // Mount overlay on /var for logs and runtime data
    if (system("mount -t overlay overlay -o lowerdir=/var,upperdir=/tmp/overlay/upper,workdir=/tmp/overlay/work /var 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to mount overlay on /var - system may be read-only\n");
    } else {
        printf("Overlay filesystem mounted on /var (base OS is immutable)\n");
    }
    
    // Mount tmpfs on /run for runtime data
    if (system("mkdir -p /run 2>/dev/null") == 0) {
        if (system("mount -t tmpfs tmpfs /run 2>/dev/null") != 0) {
            fprintf(stderr, "Warning: Failed to mount /run\n");
        }
    }
    
    // Initialize network (wired only for bootstrap)
    printf("Initializing wired network...\n");
    if (system("/sbin/init-network 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Network initialization failed - check network interface availability\n");
    }
    
    printf("Starting shell...\n");
    printf("Welcome to SparkOS!\n");
    printf("===================\n");
    printf("Base OS: Read-only (immutable)\n");
    printf("Writable: /tmp, /var (overlay), /run\n\n");
    
    // Main loop - keep respawning shell
    while (1) {
        spawn_shell();
        
        // If shell exits, ask if user wants to reboot
        printf("\nShell exited. Press Ctrl+Alt+Del to reboot or wait for new shell...\n");
        sleep(2);
    }
    
    return 0;
}
